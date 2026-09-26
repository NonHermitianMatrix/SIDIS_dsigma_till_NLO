(* Reuse accepted scalar certificates in the complete, ordered Hqg workflow. *)
$HistoryLength=0;
hqgScalarSource=FileNameJoin[{Directory[],"common","s08_resume_Hqg_certified_maps.wls"}];
hqgScalarBase=FileNameJoin[{Directory[],"common","s08_resume_Hqg_ordered_packets.wls"}];
If[!SyntaxQ[Import[hqgScalarSource,"Text"]]||IntegerString[FileHash[hqgScalarBase,"SHA256"],16,64]=!=
 "3257bf9b22ee906fa9a08543eb807860096598015bc721c4d10e7bae83ea6653",Quit[1]];
hqgScalarInstall[]:=Module[{relative,path,receipt,proof,atomPath,atom,ownPath,ownReceipt,own},
 relative="Hgg/s08_scalar_certificate_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 gate["accepted complete scalar certificate execution",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 proof=Get[path];
 gate["same original scalar coefficient implementation",channel==="Hqg"&&
  proof["Schema"]==="polarized-sidis-scalar-reconstruction-certificates-v1"&&proof["Channel"]==="Hgg"&&
  TrueQ[proof["OwnAcceptedComparison"]]&&TrueQ[proof["ActualAcceptedComparison"]]&&And@@Values[proof["Checks"]]&&
  proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  proof["OriginalFamilyDefinitions"]===DownValues[familyRows]&&proof["OriginalMappingDefinitions"]===DownValues[mapExpression]&&
  KeyDrop[proof["InputHashes"],"Hgg/s05_result/s05_result.wl"]===KeyDrop[inputHashes,"Hqg/s05_result/s05_result.wl"]&&
  proof["MapperHash"]===FileHash[targetMapperPath,"SHA256"]&&
  proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_scalar_reconstruction_certificates.wls"}],"SHA256"]&&
  proof["PolynomialProofHash"]===FileHash[FileNameJoin[{root,"Hqg","s08_polynomial_group_result","s08_result.wl"}],"SHA256"]];
 atomPath=FileNameJoin[{root,"Hgg","s08_factored_atom_certificate_result","s08_result.wl"}];atom=Get[atomPath];
 gate["same executed exact atom reconstruction functions",proof["AtomProofHash"]===FileHash[atomPath,"SHA256"]&&
  proof["AtomReceiptHash"]===FileHash[FileNameJoin[{DirectoryName[atomPath],"s08_execution.json"}],"SHA256"]&&
  DownValues[extractAtoms]===atom["DispatchDefinitions"]&&DownValues[factoredAtoms]===atom["FactoredExtractionDefinitions"]&&
  DownValues[factoredAtomCertificate]===atom["AtomCertificateDefinitions"]&&atomVariables===atom["Variables"]];
 hqgScalarEvidence=<|"SourceHash"->FileHash[hqgScalarSource,"SHA256"],"ProofHash"->FileHash[path,"SHA256"],
  "ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],
  "InputHashes"->inputHashes,"TargetInputHash"->targetInputHash|>;
 If[!TrueQ[numericPhaseControlOnly],
  relative="Hqg/s08_scalar_control_result/s08_result.wl";ownPath=FileNameJoin[{root,relative}];
  ownReceipt=Import[FileNameJoin[{DirectoryName[ownPath],"s08_execution.json"}],"RawJSON"];
  gate["accepted entire own scalar-certificate control",TrueQ[ownReceipt["passed"]]&&
   ownReceipt["result_sha256"][relative]===IntegerString[FileHash[ownPath,"SHA256"],16,64]];
  own=Get[ownPath];
  gate["same entire own coefficient comparison and source",own["Schema"]==="polarized-sidis-numeric-phase-control-v1"&&
   TrueQ[own["Evidence"]["OwnAcceptedComparison"]]&&And@@Values[own["Checks"]]&&
   own["ScalarReconstruction"]===hqgScalarEvidence&&own["InputHashes"]===inputHashes&&own["TargetInputHash"]===targetInputHash&&
   own["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&own["DispatchHash"]===Hash[hqgScalarRun,"SHA256"]];
  AssociateTo[hqgScalarEvidence,"OwnProofHash"->FileHash[ownPath,"SHA256"]]];
 DownValues[familyRows]=proof["FamilyDefinitions"];DownValues[mapExpression]=proof["MappingDefinitions"];
 DownValues[certifyFamilyLaurent]=proof["FamilyCertificateDefinitions"];
 DownValues[certifyScalarReconstruction]=proof["MappingCertificateDefinitions"];
 gate["exact executed reconstruction definitions installed",{
  DownValues[familyRows],DownValues[mapExpression],DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction]}===
  Lookup[proof,{"FamilyDefinitions","MappingDefinitions","FamilyCertificateDefinitions","MappingCertificateDefinitions"}]];
 AssociateTo[polynomialEvidence,"ScalarReconstruction"->hqgScalarEvidence];
 If[TrueQ[numericPhaseControlOnly],
  groupCache=FileNameJoin[{root,"cache","s08_Hqg_scalar_control",IntegerString[FileHash[hqgScalarSource,"SHA256"],16]}];
  If[!DirectoryQ[groupCache],CreateDirectory[groupCache,CreateIntermediateDirectories->True]];
  pieceScientificHash=Hash[{pieceScientificHash,hqgScalarEvidence},"SHA256"]]];
hqgScalarLaunchText[text_String]:=Module[{old,new,changed},
 old="\"TimeConstraint\" -> 60]], 60, $Failed";
 new="\"TimeConstraint\" -> 300]], 300, $Failed";
 orderedGate["one bounded native worker launch",StringCount[text,old]===1];
 changed=StringReplace[text,old->new];
 orderedGate["only worker startup time allowance changes",SyntaxQ[changed]&&StringReplace[changed,new->old]===text];changed];
hqgScalarLaunchInstall[]:=(groupPacketCandidateTail=hqgScalarLaunchText[groupPacketCandidateTail]);
hqgScalarBaseText=StringTrim[Import[hqgScalarBase,"Text"]];
hqgScalarTerminal="ToExpression[orderedRun,InputForm];";
If[!StringEndsQ[hqgScalarBaseText,hqgScalarTerminal],Quit[1]];
hqgScalarPrefix=StringDrop[hqgScalarBaseText,-StringLength[hqgScalarTerminal]];
If[!SyntaxQ[hqgScalarPrefix],Quit[1]];ToExpression[hqgScalarPrefix,InputForm];
hqgScalarPacketPath=FileNameJoin[{Directory[],"common","s08_map_Hqg_target_packets.wls"}];
orderedGate["unchanged original packet launch source",IntegerString[FileHash[hqgScalarPacketPath,"SHA256"],16,64]===
 "2be9cfe584e8b1714827d89db0e75c542a31a96bf8e1b413bb767324a61551a4"];
hqgScalarLaunchText[Import[hqgScalarPacketPath,"Text"]];
hqgScalarEdits={
 "hqgInstallFactoredGroups[];installNumericPhase[]"->"hqgInstallFactoredGroups[];hqgScalarInstall[];installNumericPhase[]",
 "DistributeDefinitions[factoredAtoms,"->"DistributeDefinitions[certifyFamilyLaurent,certifyScalarReconstruction,factoredAtoms,",
 "installPacketOrdering[]];"->"installPacketOrdering[];hqgScalarLaunchInstall[]];",
 "phaseDirectory=FileNameJoin[{root,\"Hqg\",\"s08_factored_control_result\"}];"->
  "phaseDirectory=FileNameJoin[{root,\"Hqg\",\"s08_scalar_control_result\"}];",
 "\"Evidence\"->numericPhaseEvidence,\"Checks\"->checks"->
  "\"Evidence\"->numericPhaseEvidence,\"ScalarReconstruction\"->hqgScalarEvidence,\"DispatchHash\"->Hash[hqgScalarRun,\"SHA256\"],\"Checks\"->checks"};
orderedGate["unique complete scalar-certificate handoffs",And@@(StringCount[orderedRun,First[#]]===1&/@hqgScalarEdits)];
hqgScalarRun=StringReplace[orderedRun,hqgScalarEdits];
orderedGate["original complete coefficient workflow restored",SyntaxQ[hqgScalarRun]&&
 StringReplace[hqgScalarRun,Reverse/@hqgScalarEdits]===orderedRun];
ToExpression[hqgScalarRun,InputForm];
