(* Complete the existing map with the accepted distinct-sector pair result. *)
$HistoryLength=0;
assemblySource=FileNameJoin[{Directory[],"common","s08_assemble_Hqq_merged_targets.wls"}];
assemblyBase=FileNameJoin[{Directory[],"common","s08_map_real_targets.wls"}];
If[IntegerString[FileHash[assemblyBase,"SHA256"],16,64]=!=
  "8700fb675c4a0196d1a6f7aa7d1710e25a9210b0de85bd902990e2e7589772a9",Quit[1]];
assemblyText=Import[assemblyBase,"Text"];
assemblyBoundary=StringPosition[assemblyText,"\nmapTargetTask[index_]"];
If[Length[assemblyBoundary]=!=1,Quit[1]];
assemblyPrefix=StringTake[assemblyText,First[First[assemblyBoundary]]-1];
If[!SyntaxQ[assemblyPrefix]||!SyntaxQ[Import[assemblySource,"Text"]],Quit[1]];
ToExpression[assemblyPrefix,InputForm];
gate["own Hqq verified target assembly",channel==="Hqq"];
pairDirectory=FileNameJoin[{root,channel,"s08_distinct_pair_merge_result"}];
pairProofPath=FileNameJoin[{pairDirectory,"s08_result.wl"}];
pairReceiptPath=FileNameJoin[{pairDirectory,"s08_execution.json"}];
pairReceipt=Import[pairReceiptPath,"RawJSON"];
gate["accepted exact distinct-pair receipt",TrueQ[pairReceipt["passed"]]&&
  pairReceipt["result_sha256"][channel<>"/s08_distinct_pair_merge_result/s08_result.wl"]===
    IntegerString[FileHash[pairProofPath,"SHA256"],16,64]];
pairProof=Get[pairProofPath];
pairSource=FileNameJoin[{root,"common","s08_merge_Hqq_distinct_pairs.wls"}];
pairConfiguration=FileNameJoin[{root,"common","s08_Hqq_distinct_merge_inputs.json"}];
gate["accepted complete own pair comparison",pairProof["Schema"]==="polarized-sidis-pair-merge-linearity-v1"&&
  pairProof["Channel"]===channel&&And@@Values[pairProof["Checks"]]&&
  TrueQ[pairProof["Checks"]["entire own accepted pair coefficient map identical"]]&&
  And@@Lookup[pairProof["Components"],"ReconstructionPassed"]&&
  And@@Flatten[Values[#["Checks"]]&/@pairProof["Components"]]];
gate["pair comparison exact source and inputs",pairProof["SourceHash"]===FileHash[pairSource,"SHA256"]&&
  pairProof["ConfigurationHash"]===FileHash[pairConfiguration,"SHA256"]&&
  pairProof["InputHashes"]===inputHashes&&pairProof["TargetInputHash"]===targetInputHash&&
  pairProof["MappingInputHash"]===inputHash&&pairProof["NativeVersions"]==={$Version,$FeynCalcVersion}];
gate["unchanged original mapping and merge equations",pairProof["OriginalMappingDefinitions"]===DownValues[mapExpression]&&
  pairProof["OriginalMergeDefinitions"]===DownValues[merge]];
proofComponents=Association[(#["ComponentIndex"]->#)&/@pairProof["Components"]];
gate["complete unique pair component inventory",Length[proofComponents]===Length[pairProof["Components"]]&&
  Sort[Keys[proofComponents]]===Sort[pairProof["SelectedIndices"]]];
reusedFiles=<||>;reusedProofIndices={};
targetComponents=Table[
  path=FileNameJoin[{targetCache,"component_"<>IntegerString[index,10,4]<>".wl"}];
  If[FileExistsQ[path],
    record=Get[path];AssociateTo[reusedFiles,StringDrop[path,StringLength[root]+1]->FileHash[path,"SHA256"]],
    gate["missing canonical component has accepted pair map "<>ToString[index],KeyExistsQ[proofComponents,index]];
    record=Join[proofComponents[index],<|"PairMappingValidationHash"->FileHash[pairProofPath,"SHA256"]|>];
    AppendTo[reusedProofIndices,index]];
  gate["exact accepted component binding "<>ToString[index],record["InputHash"]===targetInputHash&&
    KeyTake[record,{"Sector","Kind","Index"}]===KeyDrop[tasks[[index]],"Value"]&&
    TrueQ[record["ReconstructionPassed"]]&&AssociationQ[record["Checks"]]&&Length[record["Checks"]]>0&&
    And@@Values[record["Checks"]]];
  gate["recorded component reduction coverage "<>ToString[index],record["MissingTargets"]===
    Complement[Keys[record["Coefficients"]],ruleKeys,reduction["Masters"]]];
  record,{index,Length[tasks]}];
gate["every actual target component accepted",Length[targetComponents]===Length[tasks]&&AllTrue[targetComponents,AssociationQ]];
gate["retained original target calculation identity",targetSourceHash===FileHash[assemblyBase,"SHA256"]];workers=0;
assemblyExportBoundary=StringPosition[assemblyText,"\ntargetInventory ="];
gate["unique original target export boundary",Length[assemblyExportBoundary]===1];
assemblyTail=StringDrop[assemblyText,First[First[assemblyExportBoundary]]-1];
assemblyMetadata="\"SourceHash\" -> targetSourceHash,";
gate["unique original target metadata",StringCount[assemblyTail,assemblyMetadata]===1];
assemblyChanges={
  assemblyMetadata->(assemblyMetadata<>" \"DispatchSourceHash\" -> FileHash[assemblySource,\"SHA256\"], \"PairMappingValidationHash\" -> FileHash[pairProofPath,\"SHA256\"], \"PairExecutionHash\" -> FileHash[pairReceiptPath,\"SHA256\"], \"ReusedComponentFiles\" -> reusedFiles, \"ReusedProofIndices\" -> reusedProofIndices,"),
  "PASS: s08_map_real_targets"->"PASS: s08_assemble_Hqq_merged_targets"};
assemblyExport=StringReplace[assemblyTail,assemblyChanges];
gate["unchanged complete native target export",SyntaxQ[assemblyExport]&&
  StringReplace[assemblyExport,Reverse/@assemblyChanges]===assemblyTail];
ToExpression[assemblyExport,InputForm];
