(* Capture the actual failed master product using the unchanged stage inputs. *)
$HistoryLength=0;
reviewRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];
reviewSource=FileNameJoin[{reviewRoot,"misc","s23_inspect_Hgg_master_product.wls"}];
reviewParent=FileNameJoin[{reviewRoot,"misc","s11_assemble_Hgg_real.wls"}];
If[IntegerString[FileHash[reviewParent,"SHA256"],16,64]=!=
 "090263590df1e9c581f5bf934a622069a8a263e35b6c7aadef648817b34a517e",Quit[1]];
reviewParentText=ReadString[reviewParent];
reviewBoundary="\nreferenceSeriesControlCode = ";
If[StringCount[reviewParentText,reviewBoundary]=!=1,Quit[1]];
reviewInitialization=First[StringSplit[reviewParentText,reviewBoundary]];
If[!SyntaxQ[reviewInitialization]||!SyntaxQ[ReadString[reviewSource]],Quit[1]];
ToExpression[reviewInitialization,InputForm];
reviewIndices=Select[Range[Length[mapped["Components"]]],
 AnyTrue[Values[mapped["Components"][[#]]["ReducedCoefficients"]],#=!=0&]&];
reviewIndex=First[MinimalBy[reviewIndices,
 ByteCount[mapped["Components"][[#]]["ReducedCoefficients"]]&]];
reviewTask=mapped["Components"][[reviewIndex]];
reviewCoefficients=Select[reviewTask["ReducedCoefficients"],#=!=0&]/.transverseRule;
reviewMasters=Select[Keys[reviewCoefficients],#[[1]]==="R02"&];
gate["unique actual failed master family",Length[reviewMasters]===1];
reviewMaster=First[reviewMasters];
reviewCoefficient=reviewCoefficients[reviewMaster]/.D->4-2eps;
reviewCaptureTail="  <|\"Coefficient\"->coefficient,\"Master\"->master,\"Order\"->order,"<>
 "\"MasterPolynomial\"->polynomial,\"RationalPart\"->rationalPart,"<>
 "\"Answer\"->answer,\"Direct\"->direct,\"Residual\"->residual,"<>
 "\"ProductIdentity\"->productIdentity,"<>
 "\"RetainedResidual\"->Normal[Series[residual,{eps,0,order}]],"<>
 "\"RetainedIdentity\"->zeroCoefficient[Normal[Series[residual,{eps,0,order}]]]|>];";
reviewCaptureText=StringReplace[productText,productOldTail->reviewCaptureTail];
gate["capture preserves the entire failed calculation",
 SyntaxQ[reviewCaptureText]&&
 StringReplace[reviewCaptureText,reviewCaptureTail->productOldTail]===productText];
ToExpression[reviewCaptureText,InputForm];
{reviewSeconds,reviewPacket}=AbsoluteTiming[ordinaryMasterProduct[
 reviewCoefficient,regions["OrdinaryMasters"][reviewMaster],0,{reviewIndex,reviewMaster}]];
gate["complete failed-input capture",AssociationQ[reviewPacket]&&
 And@@(KeyExistsQ[reviewPacket,#]&/@{"Answer","Direct","Residual","RetainedResidual","RetainedIdentity"})];
reviewResidual=bounded[Factor[Together[reviewPacket["RetainedResidual"]]],"captured retained residual"];
reviewResult=<|"Schema"->"polarized-sidis-master-product-capture-v1",
 "Channel"->channel,"ComponentIndex"->reviewIndex,"Master"->reviewMaster,
 "ComponentHash"->Hash[reviewTask,"SHA256"],"InputHash"->inputHash,"InputHashes"->inputHashes,
 "ParentSourceHash"->FileHash[reviewParent,"SHA256"],"SourceHash"->FileHash[reviewSource,"SHA256"],
 "Packet"->reviewPacket,"FactoredRetainedResidual"->reviewResidual,
 "Seconds"->reviewSeconds,"NativeVersions"->{$Version,$FeynCalcVersion},
 "Checks"->checks,"ProductionAccepted"->False|>;
reviewOutput=FileNameJoin[{root,"misc","s23_result"}];
If[!DirectoryQ[reviewOutput],CreateDirectory[reviewOutput,CreateIntermediateDirectories->True]];
put[reviewResult,FileNameJoin[{reviewOutput,"s23_result.wl"}]];
Export[FileNameJoin[{reviewOutput,"s23_equations.wl"}],
 ToString[<|"Master"->regions["OrdinaryMasters"][reviewMaster],
 "RetainedResidual"->reviewResidual|>,InputForm],"Text"];
Export[FileNameJoin[{reviewOutput,"s23_checks.json"}],
 <|"checks"->checks,"component_index"->reviewIndex,"product_identity"->reviewPacket["ProductIdentity"],
 "retained_identity"->reviewPacket["RetainedIdentity"],"retained_residual_bytes"->ByteCount[reviewResidual],
 "seconds"->reviewSeconds,"production_accepted"->False|>,"RawJSON"];
Print["ACTUAL_FAILED_MASTER ",InputForm[reviewMaster]];
Print["ACTUAL_RETAINED_RESIDUAL ",InputForm[reviewResidual]];
Print["PASS: actual Hgg master product captured"];Quit[0];
