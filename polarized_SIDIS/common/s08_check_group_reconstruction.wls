(* Exact term certificates and native formal linearity for denominator grouping. *)
$HistoryLength = 0;
comparisonPath = FileNameJoin[{Directory[], "common", "s08_check_group_reconstruction.wls"}];
inspectionSource = FileNameJoin[{Directory[], "common", "s08_inspect_grouping_equation.wls"}];
If[IntegerString[FileHash[inspectionSource, "SHA256"], 16, 64] =!=
  "c8b300a59efd7290a72a9420be5e7aa32e8cf792dd3a24d2ba5ea1af88f7d0ea",
  Print["FAIL: pinned grouping inspection initialization"]; Quit[1]];
inspectionText = Import[inspectionSource, "Text"];
boundary = First[First[StringPosition[inspectionText, "\nmeasurements = {};"]]];
initialization = StringTake[inspectionText, boundary - 1];
If[!SyntaxQ[initialization], Print["FAIL: complete comparison initialization syntax"]; Quit[1]];
ToExpression[initialization];
gate["complete grouping comparison syntax", SyntaxQ[Import[comparisonPath, "Text"]]];
capturePath = FileNameJoin[{root, channel, "s08_group_equation_result", "s08_result.wl"}];
gate["pinned actual grouping equation", IntegerString[FileHash[capturePath, "SHA256"], 16, 64] ===
  "bb7fd3bbbad24b69ac0dc7ce5cc6a4182044a24ff81cc39876d3a726f32ecfdb"];
capture = Get[capturePath];
gate["captured equation native identity", capture["InputHashes"] === inputHashes &&
  capture["MappingInputHash"] === targetInputHash && capture["Denominators"] === denominators &&
  And @@ Values[capture["Checks"]] && capture["Outcome"]["Operation"] === "complete group reconstruction"];
controlPath = FileNameJoin[{root, channel, "s08_equation_result", "s08_result.wl"}];
gate["pinned accepted grouping outputs", IntegerString[FileHash[controlPath, "SHA256"], 16, 64] ===
  "1b22fb16c047be46bd56fa9988873eb4c0e8cd526bd939ca8a5ec3e93d5c6a64"];
control = Get[controlPath];
gate["accepted grouping control identity", control["InputHashes"] === inputHashes &&
  control["MappingInputHash"] === targetInputHash && control["Denominators"] === denominators &&
  And @@ Values[control["Checks"]]];
originalGroupingDefinitions = DownValues[groupDenominators];
certifyGrouping[expression_, terms_, atoms_, groups_] := Module[
  {rebuiltTerms, positions, groupValues, formalNumerators, formalDenominators, flatFormal,
   groupedFormal, substitutions, groupDenominatorsValues},
  gate["certificate original additive inventory", Total[terms] === expression && Length[atoms] === Length[terms]];
  rebuiltTerms = (Last[#]/(Times @@ MapThread[Power, {denominators, First[#]}])) & /@ atoms;
  gate["every original term reconstructs exactly", And @@ MapThread[zero[#1 - #2] &, {terms, rebuiltTerms}]];
  positions = GroupBy[Range[Length[atoms]], First[atoms[[#]]] &];
  gate["group partition covers each original term exactly once", Sort[Flatten[Values[positions]]] === Range[Length[atoms]] &&
    Keys[positions] === Keys[groups]];
  gate["every grouped numerator is its complete exact sum", And @@ KeyValueMap[
    groups[#1] === Total[Last /@ atoms[[#2]]] &, positions]];
  groupDenominatorsValues = (Times @@ MapThread[Power, {denominators, #}]) & /@ Keys[groups];
  formalNumerators = Table[Unique["groupNumerator"], {Length[atoms]}];
  formalDenominators = AssociationThread[Keys[groups], Table[Unique["groupDenominator"], {Length[groups]}]];
  flatFormal = MapThread[#1/formalDenominators[First[#2]] &, {formalNumerators, atoms}];
  groupedFormal = KeyValueMap[Total[formalNumerators[[#2]]]/formalDenominators[#1] &, positions];
  gate["native complete linear grouping identity", Expand[Total[flatFormal] - Total[groupedFormal]] === 0];
  substitutions = Join[Thread[formalNumerators -> (Last /@ atoms)],
    Thread[Values[formalDenominators] -> groupDenominatorsValues]];
  groupValues = MapThread[Divide, {Values[groups], groupDenominatorsValues}];
  gate["formal identity specializes to every original reconstructed term", (flatFormal /. substitutions) === rebuiltTerms];
  gate["formal identity specializes to every actual group", (groupedFormal /. substitutions) === groupValues];
  True];
oldPredicate = "zero[expression - reconstructed]";
newPredicate = "certifyGrouping[expression, terms, atoms, groups]";
gate["unique reconstruction predicate replacement", StringCount[groupCode, oldPredicate] === 1];
candidateCode = StringReplace[groupCode, oldPredicate -> newPredicate];
gate["all grouping equations otherwise unchanged", StringReplace[candidateCode, newPredicate -> oldPredicate] === groupCode];
gate["complete certified grouping syntax", SyntaxQ[candidateCode]];
ToExpression[candidateCode];
measurements = {}; compared = {};
Do[
  equation = control["Equations"][index]["OriginalValue"];
  {seconds, groups} = AbsoluteTiming[bounded[groupDenominators[equation], {"accepted grouping control", index}]];
  gate["own accepted complete grouping output " <> ToString[index], groups === control["Equations"][index]["Groups"]];
  AppendTo[compared, index];
  AppendTo[measurements, <|"Component" -> index, "Seconds" -> seconds, "InputBytes" -> ByteCount[equation],
    "GroupCount" -> Length[groups], "ComparedAcceptedOutput" -> True|>];
  Print["GROUP_CERTIFICATE_CONTROL ", InputForm[Last[measurements]]], {index, Keys[control["Equations"]]}];
equation = capture["Equation"];
gate["actual failing component identity", equation === (tasks[[capture["Inventory"]["Component"]]]["Value"] /. coordinateRules)];
{seconds, groups} = AbsoluteTiming[bounded[groupDenominators[equation], "actual failed grouping reconstruction"]];
reconstructed = Total[KeyValueMap[#2/(Times @@ MapThread[Power, {denominators, #1}]) &, groups]];
gate["exact captured reconstruction expression reproduced", equation - reconstructed === capture["OperationInput"]];
AppendTo[measurements, <|"Component" -> capture["Inventory"]["Component"], "Seconds" -> seconds,
  "InputBytes" -> ByteCount[equation], "GroupCount" -> Length[groups], "ComparedAcceptedOutput" -> False,
  "CapturedExpressionIdentical" -> True|>];
Print["GROUP_CERTIFICATE_CAPTURE ", InputForm[Last[measurements]]];
result = <|"Schema" -> "polarized-sidis-group-reconstruction-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[comparisonPath, "SHA256"], "CaptureHash" -> FileHash[capturePath, "SHA256"],
  "ControlHash" -> FileHash[controlPath, "SHA256"], "GroupingProofHash" -> FileHash[proofPath, "SHA256"],
  "InputHashes" -> inputHashes, "MappingInputHash" -> targetInputHash, "NativeVersions" -> {$Version, $FeynCalcVersion},
  "OriginalGroupingDefinitions" -> originalGroupingDefinitions, "GroupingDefinitions" -> DownValues[groupDenominators],
  "CertificateDefinitions" -> DownValues[certifyGrouping], "ControlComparisons" -> compared,
  "CapturedComponent" -> capture["Inventory"]["Component"], "CapturedGroups" -> groups,
  "Measurements" -> measurements, "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
directory = FileNameJoin[{root, channel, "s08_group_certificate_result"}];
If[!DirectoryQ[directory], CreateDirectory[directory, CreateIntermediateDirectories -> True]];
path = FileNameJoin[{directory, "s08_result.wl"}];
serialized = "Uncompress[" <> ToString[bounded[Compress[result], "group certificate compression"], InputForm] <> "]\n";
gate["bounded group certificate file", StringLength[serialized] < 128*1024^2];
Export[path <> ".tmp", serialized, "Text"];
gate["group certificate exact saved round trip", bounded[Get[path <> ".tmp"] === result, "group certificate reload"]];
RenameFile[path <> ".tmp", path, OverwriteTarget -> True];
Export[FileNameJoin[{directory, "s08_checks.json"}], <|"checks" -> checks,
  "measurements" -> measurements, "accepted_comparisons" -> compared,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_check_group_reconstruction"]; Quit[0];
