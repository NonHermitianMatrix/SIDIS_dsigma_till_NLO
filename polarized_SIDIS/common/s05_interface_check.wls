(* Validate real coordinate and photon interfaces on their actual saved inputs. *)
$HistoryLength = 0; root = Directory[];
ownSource = FileNameJoin[{root, "common", "s05_interface_check.wls"}];
productionPath = FileNameJoin[{root, "common", "s05_real_spin_response.wls"}];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!=
  "d34991466b6c4677600840ae1c837fab5879e2483932e778096134f8784c4d84", Quit[1]];
productionText = Import[productionPath, "Text"];
sectorBegin = First[First[StringPosition[productionText, "Do[\n  amplitudes ="]]];
ToExpression[StringTake[productionText, sectorBegin - 1]];
gate["interface source syntax", SyntaxQ[Import[ownSource, "Text"]]];
gate["comparison owns saved real pair", channel === "Hqqprime"];
label = First[labels];
sectorEnd = First[First[Select[StringPosition[productionText, "  slots ="], First[#] > sectorBegin &]]];
ToExpression[StringTake[productionText, {sectorBegin + StringLength["Do[\n"], sectorEnd - 1}]];
coordinateBegin = First[First[StringPosition[productionText, "(* Derive the old coordinate conversion"]]];
coordinateEnd = First[First[StringPosition[productionText, "Do[\n  cdr = sectorResults"]]];
coordinateCode = StringTake[productionText, {coordinateBegin, coordinateEnd - 1}];
oldSolve = "solutions = Solve[Thread[(oldValues /. Thread[oldVariables -> temporary]) == targetValues], temporary];";
newSolve = "solutions = Block[{$Assumptions = True}, Solve[Thread[(oldValues /. Thread[oldVariables -> temporary]) == targetValues], temporary]];";
gate["single coordinate interface change", StringCount[coordinateCode, oldSolve] === 1];
coordinateCode = StringReplace[coordinateCode, oldSolve -> newSolve];
ToExpression[coordinateCode];
diagnosticPath = FileNameJoin[{root, channel, "s05_coordinate_result", "s05_result.wl"}];
diagnostic = Get[diagnosticPath];
gate["coordinate diagnostic source binding", diagnostic["ProductionSourceHash"] === sourceHash];
gate["same saved coordinate equations", diagnostic["OldRows"] === oldRows && diagnostic["TargetValues"] === targetValues];
diagnosticRules = Thread[diagnostic["OldVariables"] ->
  (diagnostic["TemporaryVariables"] /. First[diagnostic["Solutions"]])];
gate["coordinate solutions agree on physical domain", zeroArray[simplify[
  (oldVariables /. diagnosticRules) - (oldVariables /. coordinateRules)]]];
projectionProofPath = FileNameJoin[{root, "Hqq", "s07_photon_projection_result", "s07_result.wl"}];
projectionProof = Get[projectionProofPath];
gate["accepted native projection definition", projectionProof["Schema"] === "polarized-sidis-complete-photon-projection-v1" &&
  And @@ Values[projectionProof["Checks"]]];
gate["same spin and angular inputs", And @@ Table[
  projectionProof["InputHashes"][relative] === inputHashes[relative],
  {relative, {"common/s02_result/s02_result.wl", "common/s04_result/s04_result.wl"}}]];
DownValues[completePhotonProject] = projectionProof["ProjectionDefinitions"];
baselinePath = FileNameJoin[{cache, label <> "_" <> ToString[First[First[pairs]]] <> "_" <> ToString[Last[First[pairs]]] <> ".wl"}];
baseline = Get[baselinePath];
gate["accepted real pair input binding", baseline["InputHash"] === inputHash && And @@ Values[baseline["Checks"]]];
tensor = bounded[buildPair[Sequence @@ First[pairs], None], "real projection comparison closure"];
axes = Join[photonSymbols, {p, q}];
Do[gate["real projection unchanged " <> ToString[{a, b}, InputForm],
  bounded[DiracSimplify[Contract[completePhotonProject[tensor, a, b] - photonProject[tensor, a, b]]],
    "real projection equality"] === 0], {a, axes}, {b, axes}];
newMatrix = Table[bounded[traceScalar[completePhotonProject[tensor, a, b]], {"complete real projection", a, b}],
  {a, photonSymbols}, {b, photonSymbols}];
gate["complete accepted real photon matrix unchanged", zeroArray[algebraicReduce[newMatrix - baseline["PhotonMatrix"]]]];
resultDir = FileNameJoin[{root, channel, "s05_interface_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
put[<|"Schema" -> "polarized-sidis-real-interface-validation-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[ownSource, "SHA256"], "ProductionSourceHash" -> sourceHash,
  "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "CoordinateCode" -> coordinateCode, "ReferenceCoordinateRules" -> coordinateRules,
  "CoordinateDiagnosticHash" -> FileHash[diagnosticPath, "SHA256"],
  "ProjectionDefinitions" -> DownValues[completePhotonProject],
  "ProjectionProofHash" -> FileHash[projectionProofPath, "SHA256"],
  "BaselinePath" -> baselinePath, "BaselineHash" -> FileHash[baselinePath, "SHA256"],
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>, FileNameJoin[{resultDir, "s05_result.wl"}]];
Print["PASS: s05_interface_check"]; Quit[0];
