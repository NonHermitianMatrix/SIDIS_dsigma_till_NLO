(* Publish the accepted components through the original real-tensor interface. *)
$HistoryLength = 0;
hggExportSource = FileNameJoin[{Directory[], "common", "s05_export_Hgg_components.wls"}];
hggExportBase = FileNameJoin[{Directory[], "common", "s05_assemble_Hgg_component_sum.wls"}];
If[IntegerString[FileHash[hggExportBase, "SHA256"], 16, 64] =!=
  "67f4b5daf66d9ef7a7413eff9d64f61adcec1776a1d2679937355f797dae781f", Quit[1]];
hggExportText = StringTrim[Import[hggExportBase, "Text"]];
hggExportTerminal = "ToExpression[assemblyRunTail, InputForm];";
If[!StringEndsQ[hggExportText, hggExportTerminal] || !SyntaxQ[Import[hggExportSource, "Text"]], Quit[1]];
hggExportPrefix = StringDrop[hggExportText, -StringLength[hggExportTerminal]];
If[!SyntaxQ[hggExportPrefix], Quit[1]];
ToExpression[hggExportPrefix, InputForm];

hggReadAccepted[relative_, schema_] := Module[{path, receiptPath, receipt, value},
  path = FileNameJoin[{root, relative}];
  receiptPath = FileNameJoin[{DirectoryName[path], "s05_execution.json"}];
  receipt = Import[receiptPath, "RawJSON"];
  gate["accepted component file " <> relative, TrueQ[receipt["passed"]] &&
    receipt["result_sha256"][relative] === IntegerString[FileHash[path, "SHA256"], 16, 64]];
  value = bounded[Get[path], {"accepted component reader", relative}];
  gate["component native conventions " <> relative, AssociationQ[value] && value["Schema"] === schema &&
    value["Channel"] === channel && value["InputHash"] === inputHash && value["InputHashes"] === inputHashes &&
    value["NativeVersions"] === {$Version, $FeynCalcVersion} && AssociationQ[value["Checks"]] &&
    Length[value["Checks"]] > 0 && And @@ Values[value["Checks"]]];
  value];
hggFileRow[relative_] := <|"File" -> relative,
  "Hash" -> FileHash[FileNameJoin[{root, relative}], "SHA256"]|>;

assembleCompletedPairs[] := Module[{projectPath, projectionSource, records = {}, cdrPhotons = {},
  taskRows = {}, taskMetadata = {}, covered = <||>, record, relative, row, scalarKeys, scalarRows = {},
  wardValues = <||>, metricRow, pairMetadata = {}, cdrRules, cdrAverage, cdrPg, cdr, pWeights,
  expected, sumReceipt, sumKey, component, generic, genericCoefficients, scalarValue, sector,
  metadata, metadataPath, reader, resultPath, loaded, actual, expectedResponse, payloadRows,
  directory, manifest, report, started = AbsoluteTime[]},
  gate["bounded complete Hgg export setup", channel === "Hgg" && labels === {label} && workerCount === 0 && !validationOnly];
  Clear[componentPacket, componentProof]; ClearSystemCache[];
  projectionSource = FileNameJoin[{root, "common", "s05_project_Hgg_component_sum.wls"}];
  gate["reviewed complete photon projection source", IntegerString[FileHash[projectionSource, "SHA256"], 16, 64] ===
    "8da952ed338e8def5ff361a70cb26d6836433e69e0e0858e474830fb35d609b6"];
  generic = Table[Unique["hggMatrixEntry"], {Length[photonSymbols]}, {Length[photonSymbols]}];
  genericCoefficients = Tr[#.generic] & /@ basis["PhotonDual"];
  gate["complete original photon inverse", Expand[generic -
    Total[MapThread[Times, {genericCoefficients, basis["PhotonBasis"]}]]] === ConstantArray[0, Dimensions[generic]]];
  pWeights = (pComponents.#.pComponents &) /@ basis["PhotonBasis"];
  gate["original momentum projector in saved photon basis", Expand[
    pComponents.generic.pComponents - pWeights.genericCoefficients] === 0];
  Do[
    relative = channel <> "/s05_projected_components_result/Photon_" <> ToString[component] <> "/s05_result.wl";
    record = hggReadAccepted[relative, "polarized-sidis-complete-photon-spin-component-v1"];
    gate["complete photon component " <> ToString[component], record["Component"] === component &&
      record["PhotonLabel"] === basis["PhotonLabels"][[component]] && record["SourceHash"] === FileHash[projectionSource, "SHA256"] &&
      record["BasisHash"] === FileHash[basisPath, "SHA256"] &&
      record["IncomingVariables"] === inVariables && record["OutgoingVariables"] === outVariables &&
      Dimensions[record["Response"]] === {Length[outVariables], Length[inVariables]} &&
      TrueQ[record["Reconstruction"]["Accepted"]] && And @@ Values[record["Reconstruction"]["Checks"]]];
    gate["all native photon acceptance predicates " <> ToString[component], And @@
      (TrueQ[record["Checks"][#]] & /@ {"entire actual spin polynomial reconstructed",
        "own complete original reconstruction reproduced", "own original Hermiticity reproduced",
        "original photon inverse for every matrix entry", "actual photon support reproduces original trace"})];
    expected = Position[Transpose[basis["PhotonDual"][[component]]], v_ /; v =!= 0, {2}, Heads -> False];
    expected = Union[expected, Reverse /@ expected];
    expected = (channel <> "/s05_component_sums_result/Photon_" <> StringRiffle[ToString /@ #, "_"] <> "/s05_result.wl" &) /@ expected;
    gate["complete native photon support " <> ToString[component], Sort[Keys[record["SumInputHashes"]]] === Sort[expected]];
    KeyValueMap[Function[{name, hash},
      sumReceipt = Import[FileNameJoin[{root, DirectoryName[name], "s05_execution.json"}], "RawJSON"];
      gate["accepted assembled parent " <> name, TrueQ[sumReceipt["passed"]] &&
        sumReceipt["result_sha256"][name] === IntegerString[hash, 16, 64] &&
        sumReceipt["reviewed_sha256"]["common/s05_assemble_Hgg_component_sum.wls"] === IntegerString[FileHash[hggExportBase, "SHA256"], 16, 64]];
      If[KeyExistsQ[covered, name], gate["same reused assembled parent " <> name, covered[name] === hash]];
      AssociateTo[covered, name -> hash]], record["SumInputHashes"]];
    row = hggFileRow[relative]; AppendTo[records, row]; AppendTo[cdrPhotons, record["CDRPhotonCoefficient"]];
    MapIndexed[Function[{value, index}, If[value =!= 0,
      AppendTo[taskMetadata, <|"Sector" -> label, "Kind" -> "ExtendedResponse", "Index" -> Prepend[index, component]|>];
      AppendTo[taskRows, <|"Payload" -> row, "Field" -> "Response", "Index" -> index|>]]], record["Response"], {2}];
    Clear[record]; ClearSystemCache[], {component, Length[basis["PhotonLabels"]]}];
  expected = Flatten[Table[channel <> "/s05_component_sums_result/Photon_" <> ToString[a] <> "_" <> ToString[b] <> "/s05_result.wl",
    {a, Length[photonSymbols]}, {b, Length[photonSymbols]}]];
  gate["all matrix entries covered by native Hermiticity checks", Sort[Keys[covered]] === Sort[expected]];
  scalarKeys = Select[Import[FileNameJoin[{root, channel, "s05_component_sums_result", "Photon_1_1", "s05_checks.json"}], "RawJSON"]["all_component_keys"], StringStartsQ[#, "Scalar_"] &];
  cdrRules = Thread[Join[Rest[inVariables], Rest[outVariables]] ->
    (If[MemberQ[{eIn, eOut}, #], 1, 0] & /@ Join[Rest[inVariables], Rest[outVariables]])];
  cdrAverage = If[incomingQuark, 1, basis["IncomingDensityNormalization"]/gluonDimensions[p]];
  Do[
    relative = channel <> "/s05_component_sums_result/" <> sumKey <> "/s05_result.wl";
    record = hggReadAccepted[relative, "polarized-sidis-complete-component-sum-v1"];
    gate["complete scalar input " <> sumKey, record["Key"] === sumKey && record["SourceHash"] === FileHash[hggExportBase, "SHA256"] &&
      record["ManifestHash"] === FileHash[assemblyManifestPath, "SHA256"] && record["ParentFiles"] === assemblyManifest["pairs"]];
    row = hggFileRow[relative]; AppendTo[scalarRows, row];
    If[pairMetadata === {}, pairMetadata = record["PairMetadata"]];
    If[sumKey === "Scalar_PgD", metricRow = row;
      cdrPg = bounded[algebraicReduce[cdrAverage (record["Value"] /. cdrRules)], "original CDR metric contraction"],
      gate["scalar mode is an original Ward projection", StringContainsQ[sumKey, "Ward"]];
      gate["complete " <> sumKey, record["Value"] === 0];
      AssociateTo[wardValues, StringDrop[sumKey, StringLength["Scalar_"]] -> record["Value"]]];
    Clear[record]; ClearSystemCache[], {sumKey, scalarKeys}];
  gate["complete accepted pair metadata", Length[pairMetadata] === Length[pairs] &&
    AllTrue[pairMetadata, AssociationQ] && And @@ Flatten[Values[#["Checks"]] & /@ pairMetadata]];
  gate["dimensional photon metric present", AssociationQ[metricRow]];
  AssociateTo[wardValues, "PhotonWard" -> wardProof["ScalarValue"]];
  KeyValueMap[gate[label <> " " <> #1, #2 === 0] &, wardValues];
  AppendTo[taskMetadata, <|"Sector" -> label, "Kind" -> "PhotonMetricD", "Index" -> {}|>];
  AppendTo[taskRows, <|"Payload" -> metricRow, "Field" -> "Value", "Index" -> {}|>];
  cdr = <|"Pg" -> cdrPg, "Ppp" -> bounded[algebraicReduce[pWeights.cdrPhotons], "original CDR momentum contraction"]|>;
  Clear[cdrPhotons]; ClearSystemCache[];
  Do[scalarValue = If[core, reference["Contractions"][mode], reference[If[mode === "Pg", "g", "pp"]] /. {Nc -> SUNN, gs -> 1}];
    gate[label <> " reference " <> mode, bounded[algebraicReduce[cdr[mode] - (scalarValue /. coordinateRules)], {"original reference", mode}] === 0],
    {mode, {"Pg", "Ppp"}}];
  gate["executed complete real photon definition", DownValues[photonProject] ===
    (interfaceProof["ProjectionDefinitions"] /. completePhotonProject -> photonProject)];
  sector = <|"CDRContractions" -> cdr, "WardChecks" -> wardValues, "TagWeight" -> tagWeight,
    "TagWeightAppliedToTensor" -> core, "OutgoingFields" -> outgoingFields,
    "IncomingSpinLabels" -> If[incomingQuark, basis["SpinLabels"], Append[basis["SpinLabels"], "E"]],
    "OutgoingSpinLabels" -> If[outgoingQuark, basis["SpinLabels"], Append[basis["SpinLabels"], "E"]],
    "ParallelRuntime" -> runtimeEvidence, "WorkerCount" -> workerCount, "ComponentSumEvidence" -> covered,
    "PairComparisons" -> (KeyTake[#, {"ComparedCheckpoint", "ComparedCheckpointHash", "Checks"}] & /@
      Select[pairMetadata, Lookup[#, "ComparedCheckpoint", None] =!= None &]),
    "ChargeDegrees" -> degrees, "AmplitudeCouplingPowers" -> First[couplingPowers], "DiagramPairs" -> pairs,
    "ReusedPairCheckpoints" -> (KeyTake[#, {"ReusedCheckpoint", "ReusedCheckpointHash"}] & /@
      Select[pairMetadata, KeyExistsQ[#, "ReusedCheckpoint"] &])|>;
  metadata = <|"Schema" -> "polarized-sidis-real-response-v1", "Channel" -> channel,
    "PhotonLabels" -> basis["PhotonLabels"], "SpinLabels" -> basis["SpinLabels"],
    "IndexOrder" -> {"photon component", "outgoing spin", "incoming spin"}, "Sectors" -> <|label -> sector|>,
    "RealScalarProducts" -> realScalarProducts, "ReferenceCoordinateRules" -> coordinateRules,
    "Frame" -> frame, "TransverseSubstitution" -> transverseRule, "TransverseConstraint" -> transverseConstraint,
    "PhysicalRegion" -> $Assumptions, "Dimension" -> D, "Gamma5Scheme" -> "BMHV",
    "CutMomenta" -> {k2, p + q - k1 - k2}, "CutEnergySupport" -> {energy[k2] > 0, energy[p + q - k1 - k2] > 0},
    "ResidualAngularAverageApplied" -> True, "PhaseSpaceIntegrated" -> False, "FiniteNLOFHatsComputed" -> False,
    "CouplingsRemoved" -> If[core, "e_q^2 g_s^4; distinct-charge ratio retained", "ee^2 gs^4; flavor charges retained"],
    "SourceHash" -> sourceHash, "CalculationSourceHash" -> calculationSourceHash, "InputHashes" -> inputHashes, "InputHash" -> inputHash,
    "InterfaceValidationHash" -> FileHash[interfaceProofPath, "SHA256"], "SpinExtractionValidationHash" -> FileHash[spinExtractionProofPath, "SHA256"],
    "ComponentExportSourceHash" -> FileHash[hggExportSource, "SHA256"], "ComponentProjectionSourceHash" -> FileHash[projectionSource, "SHA256"],
    "ComponentStorage" -> <|"Sector" -> label, "PhotonFiles" -> records, "MetricFile" -> metricRow,
      "PhotonBasis" -> basis["PhotonBasis"], "IncomingVariables" -> inVariables, "OutgoingVariables" -> outVariables|>,
    "MappingTaskMetadata" -> taskMetadata, "MappingTaskSources" -> taskRows,
    "Checks" -> checks, "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>;
  directory = FileNameJoin[{root, channel, "s05_result"}];
  If[!DirectoryQ[directory], CreateDirectory[directory, CreateIntermediateDirectories -> True]];
  metadataPath = FileNameJoin[{directory, "s05_metadata.wl"}]; put[metadata, metadataPath];
  reader = "Module[{base=DirectoryName[$InputFileName,3],fetch,data,storage},\n" <>
    "fetch=With[{taskRoot=base},Function[row,Module[{p=FileNameJoin[{taskRoot,row[\"File\"]}]}," <>
    "If[!FileExistsQ[p]||FileHash[p,\"SHA256\"]=!=row[\"Hash\"],Print[\"FAIL: component payload identity\"];Abort[]];Get[p]]]];\n" <>
    "data=fetch[" <> ToString[hggFileRow[channel <> "/s05_result/s05_metadata.wl"], InputForm] <> "];storage=data[\"ComponentStorage\"];\n" <>
    "With[{read=fetch,rows=storage[\"PhotonFiles\"],pg=storage[\"MetricFile\"],pb=storage[\"PhotonBasis\"]," <>
    "iv=storage[\"IncomingVariables\"],ov=storage[\"OutgoingVariables\"],ns=Length[data[\"SpinLabels\"]]," <>
    "small=data[\"Sectors\"][storage[\"Sector\"]],all=data,lab=storage[\"Sector\"]},\n" <>
    "Join[all,<|\"Sectors\"-><|lab->Join[small,<|" <>
    "\"ExtendedResponse\":>Table[read[rows[[a]]][\"Response\"],{a,Length[rows]}]," <>
    "\"Response\":>Table[read[rows[[a]]][\"Response\"][[1;;ns,1;;ns]],{a,Length[rows]}]," <>
    "\"ExtendedResponseComponent\"->Function[a,read[rows[[a]]][\"Response\"]]," <>
    "\"PhotonMatrix\":>Total[Table[With[{rr=read[rows[[a]]][\"Response\"]},pb[[a]] Sum[iv[[i]] ov[[j]] rr[[j,i]],{i,Length[iv]},{j,Length[ov]}]],{a,Length[rows]}]]," <>
    "\"PhotonMetricD\":>read[pg][\"Value\"]|>]|>|>]]]\n";
  gate["native component reader syntax", SyntaxQ[reader]];
  resultPath = FileNameJoin[{directory, "s05_result.wl"}];
  Export[resultPath <> ".tmp", reader, "Text"];
  loaded = Get[resultPath <> ".tmp"];
  gate["exact complete metadata interface", KeyDrop[loaded, "Sectors"] === KeyDrop[metadata, "Sectors"] &&
    KeyTake[loaded["Sectors"][label], Keys[sector]] === sector];
  Do[
    expectedResponse = bounded[Get[FileNameJoin[{root, records[[component]]["File"]}]]["Response"], "accepted response reload"];
    actual = bounded[loaded["Sectors"][label]["ExtendedResponseComponent"][component], "actual component reader"];
    gate["exact accepted response through loader " <> ToString[component], actual === expectedResponse];
    Clear[actual, expectedResponse]; ClearSystemCache[], {component, Length[records]}];
  scalarValue = bounded[Get[FileNameJoin[{root, metricRow["File"]}]]["Value"], "accepted metric reload"];
  gate["exact dimensional metric through loader", bounded[loaded["Sectors"][label]["PhotonMetricD"], "actual dimensional metric reader"] === scalarValue];
  Clear[scalarValue, loaded]; ClearSystemCache[];
  RenameFile[resultPath <> ".tmp", resultPath, OverwriteTarget -> True];
  payloadRows = Join[records, scalarRows, {hggFileRow[channel <> "/s05_result/s05_metadata.wl"]}];
  manifest = <|"schema" -> "polarized-sidis-component-native-result-v1", "result" -> channel <> "/s05_result/s05_result.wl",
    "result_sha256" -> IntegerString[FileHash[resultPath, "SHA256"], 16, 64], "exact_component_round_trips" -> True,
    "payloads" -> (<|"file" -> #["File"], "sha256" -> IntegerString[#["Hash"], 16, 64],
      "bytes" -> FileByteCount[FileNameJoin[{root, #["File"]}]]|> & /@ payloadRows)|>;
  Export[FileNameJoin[{directory, "s05_component_manifest.json"}], manifest, "RawJSON"];
  report = <|"channel" -> channel, "checks" -> checks, "sectors" -> labels,
    "component_count" -> Length[records], "mapping_task_count" -> Length[taskRows],
    "elapsed_seconds" -> AbsoluteTime[] - started, "peak_kernel_memory_bytes" -> MaxMemoryUsed[],
    "finite_nlo_fhats_computed" -> False, "job_id" -> Environment["JOB_ID"]|>;
  Export[FileNameJoin[{directory, "s05_checks.json"}], report, "RawJSON"];
  Print["PASS: s05_export_Hgg_components"]; Quit[0]];
ToExpression[assemblyRunTail, InputForm];
