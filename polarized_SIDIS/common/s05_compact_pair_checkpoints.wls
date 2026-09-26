(* Lossless native storage of completed, unpinned pair checkpoints. *)
$HistoryLength = 0; root = Directory[]; checks = <||>;
sourcePath = FileNameJoin[{root, "common", "s05_compact_pair_checkpoints.wls"}];
gate[name_, test_] := If[TrueQ[test], AssociateTo[checks, name -> True]; Print["PASS: ", name],
  Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
gate["complete pair storage syntax", SyntaxQ[Import[sourcePath, "Text"]]];
inputPath = FileNameJoin[{root, "Hgg", "s05_pair_storage_result", "s05_inputs.json"}];
settings = Import[inputPath, "RawJSON"];
gate["bounded pair storage contract", settings["schema"] === "polarized-sidis-pair-storage-inputs-v1" &&
  settings["channel"] === "Hgg" && Length[settings["files"]] > 0];
proofPath = FileNameJoin[{root, "Hgq", "s05_storage_validation_result", "s05_result.wl"}];
gate["accepted native storage proof", IntegerString[FileHash[proofPath, "SHA256"], 16, 64] ===
  "9b8cea3c856074a6421ce965cfafab0e0b87aa93b3d3c89ae2f5f4bdc1b0351f"];
proof = Get[proofPath];
gate["same native storage runtime", proof["NativeVersions"] === {$Version, $FeynCalcVersion} && And @@ Values[proof["Checks"]]];
archiveCode = "from pathlib import Path\nimport sys,json,gzip,hashlib,shutil\np=Path(sys.argv[1]);a=Path(sys.argv[2]);expected=sys.argv[3]\ndef digest(path):\n h=hashlib.sha256()\n with path.open('rb') as f:\n  for b in iter(lambda:f.read(1024**2),b''):h.update(b)\n return h.hexdigest()\nassert digest(p)==expected and not a.exists()\na.parent.mkdir(parents=True,exist_ok=True);t=a.with_name(a.name+'.tmp')\nwith p.open('rb') as f,gzip.open(str(t),'wb',compresslevel=1) as o:shutil.copyfileobj(f,o,1024**2)\nh=hashlib.sha256();n=0\nwith gzip.open(str(t),'rb') as f:\n for b in iter(lambda:f.read(1024**2),b''):h.update(b);n+=len(b)\nassert h.hexdigest()==expected and n==p.stat().st_size and digest(p)==expected\nassert t.stat().st_size<128*1024**2\nt.rename(a)\nprint(json.dumps({'sha256':digest(a),'bytes':a.stat().st_size,'source_sha256':expected,'source_bytes':n}))\n";
outputDirectory = DirectoryName[inputPath]; rows = {}; archives = {};
Do[
  relative = item["file"]; path = FileNameJoin[{root, relative}];
  gate["own completed checkpoint " <> relative, StringStartsQ[relative, "cache/s05/Hgg/"] &&
    StringMatchQ[FileNameTake[path], RegularExpression["Real[^_]*_[0-9]+_[0-9]+\\.wl"]] &&
    !MemberQ[settings["protected_paths"], relative]];
  gate["unchanged source bytes " <> relative, IntegerString[FileHash[path, "SHA256"], 16, 64] === item["sha256"] &&
    FileByteCount[path] === item["bytes"]];
  Print["PAIR_STORAGE_BEGIN ", relative, " bytes ", FileByteCount[path]];
  original = Get[path];
  gate["completed own native pair " <> relative, AssociationQ[original] &&
    original["InputHash"] === FromDigits[FileNameTake[DirectoryName[path]], 16] &&
    KeyExistsQ[original, "PhotonMatrix"] && KeyExistsQ[original, "ScalarModes"] &&
    AssociationQ[original["Checks"]] && And @@ Values[original["Checks"]]];
  {seconds, serialized} = AbsoluteTiming["Uncompress[" <> ToString[Compress[original], InputForm] <> "]\n"];
  gate["bounded native checkpoint " <> relative, StringLength[serialized] < 128*1024^2];
  temporary = path <> ".native.tmp"; Export[temporary, serialized, "Text"];
  gate["exact native checkpoint reload " <> relative, Get[temporary] === original];
  archiveRelative = "Hgg/s05_pair_storage_result/s05_sources/" <> FileNameTake[path] <> ".gz";
  archivePath = FileNameJoin[{root, archiveRelative}];
  process = RunProcess[{"python3", "-c", archiveCode, path, archivePath, item["sha256"]}];
  gate["lossless original byte archive " <> relative, process["ExitCode"] === 0];
  archive = ImportString[process["StandardOutput"], "RawJSON"];
  gate["verified original bytes " <> relative, archive["source_sha256"] === item["sha256"] && archive["source_bytes"] === item["bytes"]];
  gate["unchanged checkpoint before publication " <> relative, IntegerString[FileHash[path, "SHA256"], 16, 64] === item["sha256"]];
  RenameFile[temporary, path, OverwriteTarget -> True];
  row = <|"file" -> relative, "original_sha256" -> item["sha256"], "original_bytes" -> item["bytes"],
    "sha256" -> IntegerString[FileHash[path, "SHA256"], 16, 64], "bytes" -> FileByteCount[path],
    "source_archive" -> archiveRelative, "exact_native_reload" -> True, "compression_seconds" -> seconds|>;
  AppendTo[rows, row]; AppendTo[archives, Join[archive, <|"file" -> archiveRelative|>]];
  manifest = <|"schema" -> "polarized-sidis-native-pair-storage-v1", "channel" -> "Hgg", "files" -> rows,
    "archives" -> archives, "protected_paths" -> settings["protected_paths"], "complete" -> False,
    "source_archives_verified" -> True, "exact_native_reload" -> True|>;
  Export[FileNameJoin[{outputDirectory, "s05_cache_manifest.json"}], manifest, "RawJSON"];
  Print["PAIR_STORAGE_ACCEPTED ", relative, " bytes ", row["bytes"], " archive bytes ", archive["bytes"]];
  Clear[original, serialized]; ClearSystemCache[], {item, settings["files"]}];
manifest["complete"] = True;
Export[FileNameJoin[{outputDirectory, "s05_cache_manifest.json"}], manifest, "RawJSON"];
result = <|"Schema" -> "polarized-sidis-native-pair-storage-v1", "SourceHash" -> FileHash[sourcePath, "SHA256"],
  "InputHash" -> FileHash[inputPath, "SHA256"], "NativeVersions" -> {$Version, $FeynCalcVersion},
  "Files" -> rows, "Archives" -> archives, "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
Put[result, FileNameJoin[{outputDirectory, "s05_result.wl"}]];
Export[FileNameJoin[{outputDirectory, "s05_checks.json"}], <|"checks" -> checks, "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s05_compact_pair_checkpoints"]; Quit[0];
