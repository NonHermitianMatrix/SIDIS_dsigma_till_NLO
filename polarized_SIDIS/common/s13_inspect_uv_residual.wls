(* Inspect a failed UV assembly component using the unchanged accepted inputs. *)
$HistoryLength = 0;
inspectionSource = FileNameJoin[{Directory[], "common", "s13_inspect_uv_residual.wls"}];
inspectionBaseline = FileNameJoin[{Directory[], "common", "s13_assemble_virtual_spin.wls"}];
If[IntegerString[FileHash[inspectionBaseline, "SHA256"], 16, 64] =!=
  "44bc4684e7aa164e7d9e0928bb2572c7f7ea146e8215653516fef6bf1e729989", Quit[1]];
inspectionText = Import[inspectionBaseline, "Text"];
inspectionBoundary = StringPosition[inspectionText, "\nkeys = Keys[mapped[\"Components\"]];"];
If[Length[inspectionBoundary] =!= 1, Quit[1]];
inspectionPrefix = StringTake[inspectionText, First[First[inspectionBoundary]] - 1];
If[!SyntaxQ[inspectionPrefix] || !SyntaxQ[Import[inspectionSource, "Text"]], Quit[1]];
ToExpression[inspectionPrefix, InputForm];
inspectionConfigPath = FileNameJoin[{root, "common", "s13_uv_inspection_inputs.json"}];
inspectionConfig = Import[inspectionConfigPath, "RawJSON"];
gate["UV inspection channel", channel === inspectionConfig["channel"]];
inspectionKey = inspectionConfig["key"];
gate["failed component exists in actual map", KeyExistsQ[mapped["Components"], inspectionKey]];
gate["failed component UV sum exists", KeyExistsQ[spinUV, inspectionKey]];
gate["same Born and virtual transverse conventions", born["TransverseSubstitution"] === spin["TransverseSubstitution"] &&
  born["TransverseConstraint"] === spin["TransverseConstraint"]];
key = inspectionKey;
coefficients = mapped["Components"][key];
pre = bounded[reduce[integrateComponent[coefficients, key] /. spin["TransverseSubstitution"]], {key, "physical loop sum"}];
hermitian = bounded[reduce[ComplexExpand[pre + Conjugate[pre], TargetFunctions -> {Re, Im}]], {key, "Hermitian interference"}];
residue = spinUV[key] /. spin["TransverseSubstitution"];
fullUV = Factor[ComplexExpand[residue + Conjugate[residue]]];
separated = hermitian + fullUV (1/epsUV - 1/eps);
gate["UV separation preserves tensor", Expand[(separated /. epsUV -> eps) - hermitian] === 0];
bornD = bornComponent[key] /. D -> 4 - 2 eps;
counterterm = book["CouplingWeight"] uv["CouplingResidue"] (uv["MSPole"] /. eps -> epsUV) bornD;
complete = separated + externalInterference bornD + counterterm;
residual = bounded[FullSimplify[Coefficient[Expand[complete], epsUV, -1] /. eps -> 0, physical], {key, "UV cancellation"}];
inspectionTerms = <|"PreHermitianUV" -> residue, "HermitianUV" -> fullUV,
  "BornD" -> bornD, "BornD4" -> (bornD /. eps -> 0),
  "ExternalUV" -> Coefficient[Expand[externalInterference bornD], epsUV, -1],
  "CountertermUV" -> Coefficient[Expand[counterterm], epsUV, -1],
  "Residual" -> residual,
  "FactoredResidual" -> bounded[Factor[Together[residual]], "factored actual UV residual"],
  "TransverseSubstitution" -> spin["TransverseSubstitution"],
  "TransverseConstraint" -> spin["TransverseConstraint"], "FieldBookkeeping" -> book,
  "CouplingResidue" -> uv["CouplingResidue"], "MSPole" -> uv["MSPole"]|>;
KeyValueMap[Print["ACTUAL_UV_EQUATION ", #1, " ", InputForm[#2]] &, inspectionTerms];
inspectionDiagramUV = KeyTake[#, {"Label", "Value"}] & /@ Select[uvValues, #["Key"] === key &];
Print["ACTUAL_DIAGRAM_UV ", InputForm[inspectionDiagramUV]];
inspectionResult = <|"Schema" -> "polarized-sidis-uv-residual-inspection-v1", "Channel" -> channel,
  "Key" -> key, "Terms" -> inspectionTerms, "DiagramUV" -> inspectionDiagramUV,
  "SourceHash" -> FileHash[inspectionSource, "SHA256"], "BaselineSourceHash" -> FileHash[inspectionBaseline, "SHA256"],
  "ConfigurationHash" -> FileHash[inspectionConfigPath, "SHA256"], "ProductionInputHash" -> inputHash,
  "InputHashes" -> inputHashes, "Checks" -> checks, "NativeVersions" -> {$Version, $FeynCalcVersion},
  "InspectionComplete" -> True, "UVCancellationPassed" -> (residual === 0), "FiniteNLOFHatsComputed" -> False|>;
inspectionDir = FileNameJoin[{root, channel, "s13_uv_inspection_result"}];
If[!DirectoryQ[inspectionDir], CreateDirectory[inspectionDir, CreateIntermediateDirectories -> True]];
inspectionPath = FileNameJoin[{inspectionDir, "s13_result.wl"}];
put[inspectionResult, inspectionPath];
gate["UV inspection exact native reload", Get[inspectionPath] === inspectionResult];
Export[FileNameJoin[{inspectionDir, "s13_checks.json"}], <|"channel" -> channel, "key" -> key,
  "checks" -> checks, "uv_cancellation_passed" -> (residual === 0), "inspection_complete" -> True,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s13_inspect_uv_residual"]; Quit[0];
