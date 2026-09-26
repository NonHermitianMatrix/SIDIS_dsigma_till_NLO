(* Read the actual saved Hqq reconstruction inputs; do not rerun amplitudes. *)
$HistoryLength = 0;
equationReaderSource = FileNameJoin[{Directory[], "common", "s05_read_reconstruction_equations.wls"}];
equationReaderBase = FileNameJoin[{Directory[], "common", "s05_real_spin_response_cached_scalar.wls"}];
If[Environment["POLARIZED_SIDIS_CHANNEL"] =!= "Hqq" ||
  IntegerString[FileHash[equationReaderBase, "SHA256"], 16, 64] =!=
    "ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff",
  Print["FAIL: reconstruction reader channel and source"]; Quit[1]];
equationReaderText = Import[equationReaderBase, "Text"];
equationReaderBoundary = StringPosition[equationReaderText, "Do[\n  amplitudes ="];
If[Length[equationReaderBoundary] =!= 1, Print["FAIL: unique production initialization"]; Quit[1]];
equationReaderPrefix = StringTake[equationReaderText, First[First[equationReaderBoundary]] - 1];
equationReaderPackage = "$FeynCalcStartupMessages = False; $LoadAddOns = {\"FeynArts\"}; Get[\"FeynCalc`\"];";
If[StringCount[equationReaderPrefix, equationReaderPackage] =!= 1,
  Print["FAIL: unique native package initialization"]; Quit[1]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
equationReaderPrefix = StringReplace[equationReaderPrefix, equationReaderPackage ->
  "gate[\"native package already loaded\", ValueQ[$FeynCalcVersion]];"];
If[!SyntaxQ[equationReaderPrefix] || !SyntaxQ[Import[equationReaderSource, "Text"]],
  Print["FAIL: complete equation reader syntax"]; Quit[1]];
ToExpression[equationReaderPrefix, InputForm];
label = "RealSame";
gate["reported sector exists in generated inventory", MemberQ[labels, label]];
equationFieldSetup = sourceSection[equationReaderText, "\n  amplitudes =", "  quarkIn ="];
gate["unchanged complete field setup", SyntaxQ[equationFieldSetup]];
ToExpression[equationFieldSetup, InputForm];
equationComponents = {8, 9};
gate["components belong to actual photon inventory", And @@ (MemberQ[Range[Length[basis["PhotonDual"]]], #] & /@ equationComponents)];
equationSymbolicMatrix = Array[reconstructionEntry, Dimensions[First[basis["PhotonDual"]]]];
equationDefinitions = Tr[#.equationSymbolicMatrix] & /@ basis["PhotonDual"][[equationComponents]];
equationEntries = DeleteDuplicates[Cases[equationDefinitions, _reconstructionEntry, Infinity]];
equationInputHashes = <||>;
equationRules = Table[
  equationKey = "Photon_" <> StringRiffle[ToString /@ (List @@ entry), "_"];
  equationPath = FileNameJoin[{cache, label <> "_assembled_" <> equationKey <> ".wl"}];
  equationPacket = Get[equationPath];
  gate["saved equation identity " <> equationKey, AssociationQ[equationPacket] &&
    equationPacket["InputHash"] === inputHash && equationPacket["Key"] === equationKey &&
    AssociationQ[equationPacket["Checks"]] && And @@ Values[equationPacket["Checks"]]];
  AssociateTo[equationInputHashes, StringDrop[equationPath, StringLength[root] + 1] -> FileHash[equationPath, "SHA256"]];
  entry -> equationPacket["Value"], {entry, equationEntries}];
equationValues = equationDefinitions /. equationRules;
gate["complete actual photon equations", FreeQ[equationValues, _reconstructionEntry | _Missing | $Failed | $Aborted]];
equationResponses = compactSpinResponse[equationValues, inVariables, outVariables];
equationBindings = MapThread[Hash[{inputHash, label, {#1, #2, #3}, inVariables, outVariables}, "SHA256"] &,
  {equationComponents, equationValues, equationResponses}];
equationControlPath = FileNameJoin[{cache, label <> "_spin_reconstruction_" <> ToString[First[equationComponents]] <> ".wl"}];
equationControl = Get[equationControlPath];
gate["own accepted reconstruction control", equationControl["InputHash"] === inputHash &&
  equationControl["Binding"] === First[equationBindings] && TrueQ[equationControl["Accepted"]] &&
  AssociationQ[equationControl["Checks"]] && And @@ Values[equationControl["Checks"]]];
AssociateTo[equationInputHashes, StringDrop[equationControlPath, StringLength[root] + 1] -> FileHash[equationControlPath, "SHA256"]];
equationResultDirectory = FileNameJoin[{root, channel, "s05_reconstruction_equation_result"}];
If[!DirectoryQ[equationResultDirectory], CreateDirectory[equationResultDirectory, CreateIntermediateDirectories -> True]];
equationFiles = Table[
  equationFile = FileNameJoin[{equationResultDirectory, "s05_input_" <> IntegerString[equationComponents[[i]], 10, 2] <> ".wl"}];
  put[equationValues[[i]], equationFile];
  gate["bounded readable equation " <> ToString[equationComponents[[i]]], FileByteCount[equationFile] < 128*1024^2];
  gate["readable equation exact reload " <> ToString[equationComponents[[i]]], Get[equationFile] === equationValues[[i]]];
  <|"Component" -> equationComponents[[i]], "File" -> StringDrop[equationFile, StringLength[root] + 1],
    "SHA256" -> IntegerString[FileHash[equationFile, "SHA256"], 16, 64], "FileBytes" -> FileByteCount[equationFile],
    "NativeBytes" -> ByteCount[equationValues[[i]]]|>, {i, Length[equationComponents]}];
equationResult = <|"Schema" -> "polarized-sidis-reconstruction-equations-v1", "Channel" -> channel, "Sector" -> label,
  "Components" -> equationComponents, "Equations" -> equationValues, "Responses" -> equationResponses,
  "Bindings" -> equationBindings, "IncomingVariables" -> inVariables, "OutgoingVariables" -> outVariables,
  "AcceptedControl" -> equationControl, "Files" -> equationFiles, "InputHash" -> inputHash,
  "PhysicalInputHashes" -> inputHashes, "EquationInputHashes" -> equationInputHashes,
  "ExtractionDefinitions" -> DownValues[compactSpinResponse], "ReconstructionDefinitions" -> DownValues[spinPolynomialZero],
  "SourceHash" -> FileHash[equationReaderSource, "SHA256"], "ProductionSourceHash" -> FileHash[equationReaderBase, "SHA256"],
  "NativeVersions" -> {$Version, $FeynCalcVersion}, "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
equationResultPath = FileNameJoin[{equationResultDirectory, "s05_result.wl"}];
equationSerialized = "Uncompress[" <> ToString[Compress[equationResult], InputForm] <> "]\n";
gate["bounded equation packet", StringLength[equationSerialized] < 128*1024^2];
Export[equationResultPath, equationSerialized, "Text"];
gate["complete equation packet exact reload", Get[equationResultPath] === equationResult];
Export[FileNameJoin[{equationResultDirectory, "s05_checks.json"}],
  <|"channel" -> channel, "checks" -> checks, "equation_files" -> equationFiles,
    "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_read_reconstruction_equations"]; Quit[0];
