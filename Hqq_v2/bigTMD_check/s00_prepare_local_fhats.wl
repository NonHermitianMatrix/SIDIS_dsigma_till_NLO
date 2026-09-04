(* ::Package:: *)

(* Hqq_v2 BigTMD check S00: context-stable accepted-hat bridge. *)

$HistoryLength = 0;
$IterationLimit = Infinity;
$LoadAddOns = {};
$FeynCalcStartupMessages = False;
Quiet[Needs["FeynCalc`"]];
$FCAdvice = False;

ClearAll[
  fatal, require, fileSHA256, expressionSHA256,
  allBooleanLeavesTrueQ, atomicPut
];

fatal[message_String, detail_: Null] := (
  Print["HQQV2_BIGTMD_S00_FATAL: " <> message];
  If[detail =!= Null,
    Print["HQQV2_BIGTMD_S00_DETAIL=", InputForm[detail]]];
  Quit[1]
);
require[condition_, message_String, detail_: Null] :=
  If[! TrueQ[condition], fatal[message, detail]];
fileSHA256[path_String] := FileHash[path, "SHA256", "HexString"];
expressionSHA256[expression_] :=
  IntegerString[Hash[expression, "SHA256"], 16, 64];
allBooleanLeavesTrueQ[expression_] := Module[{leaves},
  leaves = Cases[expression, True | False, {0, Infinity}];
  leaves =!= {} && FreeQ[expression, False] && AllTrue[leaves, TrueQ]
];
atomicPut[expression_, path_String] := Module[
  {temporaryPath = path <> ".tmp", reloaded},
  require[! FileExistsQ[path] && ! FileExistsQ[temporaryPath],
    "refusing to overwrite bridge output or temporary"];
  Put[expression, temporaryPath];
  require[FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "temporary bridge output is absent or empty"];
  RenameFile[temporaryPath, path];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published bridge output is absent or empty"];
  reloaded = Quiet@Check[Get[path], $Failed];
  require[AssociationQ[reloaded] &&
      reloaded["Stage"] === "HqqV2BigTMDCheckS00-v1" &&
      AssociationQ[reloaded["Checks"]] &&
      allBooleanLeavesTrueQ[reloaded["Checks"]] &&
      And @@ Table[
        expressionSHA256[reloaded[hat]] ===
          reloaded["AcceptedHatSHA256", hat],
        {hat, {"F1Hat", "F2Hat"}}],
    "fresh bridge reload failed"]
];

checkDirectory = DirectoryName[ExpandFileName[$InputFileName]];
channelDirectory = DirectoryName[checkDirectory];
scriptsDirectory = DirectoryName[channelDirectory];
programPath = ExpandFileName[$InputFileName];
s08ProgramPath = FileNameJoin[
  {channelDirectory, "s08_extract_hqq_fhats.wl"}];
s08ResultPath = FileNameJoin[{channelDirectory, "s08_result.wl"}];
paperPath = FileNameJoin[{scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"}];
outputPath = FileNameJoin[
  {checkDirectory, "s00_prepared_local_fhats.wl"}];

scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
expectedS08ProgramSHA256 =
  "f426373c24143950cb8cdb09a6410e7ec76e0d4f960293f6380021cf54c211b7";
expectedS08ResultSHA256 =
  "0b69a0db7740127ab16c53d181317b7defbd17af846e55582213ca28d1d35741";
expectedPaperSHA256 =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedHatSHA256 = <|
  "F1Hat" ->
    "24010c0ba80c1da601d39fcad6684a986024773cd84beafcbc09e956d6da4823",
  "F2Hat" ->
    "54aa977540c56796b7c5b03aead322022788455caa110b9fe285373fec139b36"|>;
hatLabels = {"F1Hat", "F2Hat"};
sectorLabels = {"Delta", "BoundedPlus", "Ordinary"};

Print[scopeTag];
Print["HQQV2_BIGTMD_S00_STAGE=validate accepted S08 hats"];
require[And @@ (FileExistsQ[#] && FileByteCount[#] > 0 & /@
      {s08ProgramPath, s08ResultPath, paperPath}),
  "an accepted input is absent"];
require[fileSHA256[s08ProgramPath] === expectedS08ProgramSHA256 &&
    fileSHA256[s08ResultPath] === expectedS08ResultSHA256 &&
    fileSHA256[paperPath] === expectedPaperSHA256,
  "accepted input identity changed"];

s08 = Quiet@Check[Get[s08ResultPath], $Failed];
require[AssociationQ[s08] && s08["Stage"] === "HqqV2S08-v1" &&
    s08["ScopeTag"] === scopeTag &&
    FileNameTake[s08["Source", "Path"]] ===
      FileNameTake[s08ProgramPath] &&
    s08["Source", "SHA256"] === expectedS08ProgramSHA256 &&
    s08["Inputs", "PaperSHA256"] === expectedPaperSHA256 &&
    AssociationQ[s08["Checks"]] &&
    allBooleanLeavesTrueQ[s08["Checks"]],
  "accepted S08 schema, provenance, or check ledger changed"];
hatChecks = AssociationMap[Function[hat,
  AssociationQ[s08[hat]] && Keys[s08[hat]] === sectorLabels &&
    expressionSHA256[s08[hat]] === expectedHatSHA256[hat] &&
    FreeQ[s08[hat], epsilon | D | FeynCalc`EpsilonUV |
      FeynCalc`EpsilonIR | _SeriesData | _Real | $Failed]], hatLabels];
require[And @@ Values[hatChecks],
  "accepted S08 hat identity, schema, or exactness changed", hatChecks];

payload = <|
  "Stage" -> "HqqV2BigTMDCheckS00-v1",
  "ScopeTag" -> scopeTag,
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> <|"Path" -> programPath,
    "SHA256" -> fileSHA256[programPath]|>,
  "Source" -> <|"Path" -> s08ResultPath,
    "ByteCount" -> FileByteCount[s08ResultPath],
    "SHA256" -> expectedS08ResultSHA256,
    "ProgramPath" -> s08ProgramPath,
    "ProgramSHA256" -> expectedS08ProgramSHA256,
    "PaperSHA256" -> expectedPaperSHA256|>,
  "AcceptedHatSHA256" -> expectedHatSHA256,
  "F1Hat" -> s08["F1Hat"],
  "F2Hat" -> s08["F2Hat"],
  "Checks" -> <|
    "AcceptedFiles" -> True,
    "AcceptedS08Ledger" -> True,
    "AcceptedHatIdentity" -> hatChecks,
    "OriginalContext" ->
      And @@ (Context[#] === "Global`" & /@
        {Mpl, mzv, PaXDiLog})|>|>;
require[allBooleanLeavesTrueQ[payload["Checks"]],
  "bridge check ledger failed", payload["Checks"]];

Print["HQQV2_BIGTMD_S00_STAGE=write context bridge"];
atomicPut[payload, outputPath];
Print["HQQV2_BIGTMD_S00_OUTPUT=", outputPath];
Print["HQQV2_BIGTMD_S00_OUTPUT_BYTES=", FileByteCount[outputPath]];
Print["HQQV2_BIGTMD_S00_SUCCESS"];
Quit[0];
