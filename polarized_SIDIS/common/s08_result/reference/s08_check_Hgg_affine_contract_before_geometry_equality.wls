(* Compare the saved native affine proof with the exact production artifact chain. *)
$HistoryLength=0;root=Directory[];checks=<||>;
contractSource=FileNameJoin[{root,"common","s08_check_Hgg_affine_contract.wls"}];
gate[name_,test_]:=If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],Print["FAIL: ",name];Quit[1]];
gate["native allocation and complete source",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]&&SyntaxQ[ReadString[contractSource]]];
contractRead[relative_]:=Module[{path=FileNameJoin[{root,relative}],receipt},
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 gate["accepted native artifact "<>relative,TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];Get[path]];
contractProof=contractRead["Hgg/s08_affine_piece_basis_result/s08_result.wl"];
contractInput=contractRead["Hgg/s08_failed_group_input_result/s08_result.wl"];
contractExternal=contractRead["Hgg/s08_external_factor_result/s08_result.wl"];
contractScalar=contractRead["Hgg/s08_scalar_certificate_result/s08_result.wl"];
contractAtoms=contractRead["Hgg/s08_factored_atom_certificate_result/s08_result.wl"];
contractGeometry=Get[FileNameJoin[{root,"common","s06_result","reference","s02_result.wl"}]]/.{Q2->Q^2,w->s23};
contractFixed={contractExternal["MappingDefinitions"],contractExternal["OriginalAliasDefinitions"],
 contractExternal["MergeDefinitions"],contractScalar["FamilyCertificateDefinitions"],
 contractScalar["MappingCertificateDefinitions"],contractAtoms["DispatchDefinitions"]};
contractFlags=<|"Schema"->(contractProof["Schema"]==="polarized-sidis-affine-family-basis-v1"),
 "Channel"->(contractProof["Channel"]==="Hgg"),"Accepted"->TrueQ[contractProof["Accepted"]],
 "OwnAcceptedComparison"->TrueQ[contractProof["OwnAcceptedComparison"]],
 "Checks"->(Length[contractProof["Checks"]]>0&&And@@Values[contractProof["Checks"]]),
 "SourceHash"->(contractProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_Hgg_affine_family_basis.wls"}],"SHA256"]),
 "InputHash"->(contractProof["InputHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_failed_group_input_result","s08_result.wl"}],"SHA256"]),
 "InputHashes"->(contractProof["InputHashes"]===contractExternal["InputHashes"]),
 "TargetInputHash"->(contractProof["TargetInputHash"]===contractExternal["TargetInputHash"]),
 "NativeVersions"->(contractProof["NativeVersions"]===contractExternal["NativeVersions"]),
 "FamilyDefinitions"->(contractProof["OriginalFamilyDefinitions"]===contractScalar["FamilyDefinitions"]),
 "FixedDefinitions"->MapThread[SameQ,{contractProof["FixedDefinitions"],contractFixed}],
 "Families"->(contractInput["Families"]===contractGeometry["Families"]),
 "Denominators"->(contractInput["Denominators"]===contractGeometry["OnCutUncutPropagators"])|>;
contractDifferences=<|
 "FamilyEntries"->Association@KeyValueMap[Function[{key,value},If[value===contractGeometry["Families"][key],Nothing,
   key-><|"Saved"->value,"Production"->contractGeometry["Families"][key]|>]],contractInput["Families"]],
 "FixedDefinitions"->MapThread[If[#1===#2,Nothing,<|"Saved"->#1,"Production"->#2|>]&,
  {contractProof["FixedDefinitions"],contractFixed}],
 "FamilyDefinitions"->If[contractProof["OriginalFamilyDefinitions"]===contractScalar["FamilyDefinitions"],{},
  {contractProof["OriginalFamilyDefinitions"],contractScalar["FamilyDefinitions"]}]|>;
contractDirectory=FileNameJoin[{root,"Hgg","s08_affine_contract_result"}];
If[!DirectoryQ[contractDirectory],CreateDirectory[contractDirectory]];
contractResult=<|"Flags"->contractFlags,"Differences"->contractDifferences,"Checks"->checks,
 "SourceHash"->FileHash[contractSource,"SHA256"],"AcceptedPhysicsResult"->False|>;
contractPath=FileNameJoin[{contractDirectory,"s08_result.wl"}];Put[contractResult,contractPath];
gate["exact native contract report reload",Get[contractPath]===contractResult];
Print["AFFINE_CONTRACT_FLAGS ",InputForm[contractFlags]];
Print["AFFINE_CONTRACT_DIFFERENCES ",InputForm[contractDifferences]];
Print["PASS: s08_check_Hgg_affine_contract"];Quit[0];
