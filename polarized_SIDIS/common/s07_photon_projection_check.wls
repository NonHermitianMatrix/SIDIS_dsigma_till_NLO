(* Native check of physical photon projection on the actual failing tensor. *)
$HistoryLength=0;root=Directory[];
ownSource=FileNameJoin[{root,"common","s07_photon_projection_check.wls"}];
productionPath=FileNameJoin[{root,"common","s07_virtual_spin_response.wls"}];
If[IntegerString[FileHash[productionPath,"SHA256"],16,64]=!=
  "77525d42492206f7e81802ff7bc0f8d8994969a2681518175200f76199c0f2e5",Quit[1]];
text=Import[productionPath,"Text"];
ToExpression[StringTake[text,First[First[StringPosition[text,"diagrams = {};\n"]]]-1]];
gate["comparison source syntax",SyntaxQ[Import[ownSource,"Text"]]];
diagnosticPath=FileNameJoin[{root,channel,"s07_incomplete_interface_result","s07_result.wl"}];
diagnostic=Get[diagnosticPath];
gate["actual failing interface binding",diagnostic["InputHash"]===inputHash&&
  diagnostic["ProductionSourceHash"]===sourceHash&&diagnostic["ResidualObjects"]=!={}];
completePhotonProject[tensor_,leftAxis_,rightAxis_] := tensor/.
  {LorentzIndex[mu,D]->Momentum[leftAxis],LorentzIndex[nu,D]->Momentum[rightAxis],
   LorentzIndex[mu]->Momentum[leftAxis],LorentzIndex[nu]->Momentum[rightAxis],
   LorentzIndex[mu,D-4]->Momentum[leftAxis,D-4],LorentzIndex[nu,D-4]->Momentum[rightAxis,D-4]};
projectionDefinitions=DownValues[completePhotonProject];
axes=Join[photonSymbols,{p,q}];
Do[gate["native photon interface "<>ToString[{dimLeft,dimRight,leftAxis,rightAxis},InputForm],
  DiracSimplify[completePhotonProject[FCI[DiracGamma[LorentzIndex[mu,dimLeft],dimLeft].
      DiracGamma[LorentzIndex[nu,dimRight],dimRight]],leftAxis,rightAxis]-
    Contract[FCI[DiracGamma[LorentzIndex[mu,dimLeft],dimLeft].DiracGamma[LorentzIndex[nu,dimRight],dimRight]
      FV[leftAxis,mu]FV[rightAxis,nu]]]]===0],
  {dimLeft,{4,D,D-4}},{dimRight,{4,D,D-4}},{leftAxis,axes},{rightAxis,axes}];
acceptedTensor=bounded[buildTensor[First[virtualAmplitudes]],"accepted diagram closure"];
Do[gate["accepted virtual projection unchanged "<>ToString[{a,b},InputForm],
  bounded[DiracSimplify[Contract[completePhotonProject[acceptedTensor,a,b]-photonProject[acceptedTensor,a,b]]],
    "accepted virtual projection comparison"]===0],{a,axes},{b,axes}];
failedIndex=First[diagnostic["Task"]];
failedTensor=bounded[buildTensor[virtualAmplitudes[[failedIndex]]],"failing diagram closure"];
Do[gate["failing diagram explicit contraction "<>ToString[{a,b},InputForm],
  bounded[DiracSimplify[Contract[completePhotonProject[failedTensor,a,b]-
    failedTensor FV[a,mu]FV[b,nu]]],"explicit failing-diagram photon comparison"]===0],{a,axes},{b,axes}];
failedValue=bounded[traceScalar[completePhotonProject[failedTensor,
  photonSymbols[[diagnostic["Task"][[2]]]],photonSymbols[[diagnostic["Task"][[3]]]]]],"corrected failing projection"];
gate["failing projection now fully scalar",FreeQ[failedValue,_Pair|_Eps|_LorentzIndex|_DiracGamma|_DiracTrace|_Spinor]];
resultDir=FileNameJoin[{root,channel,"s07_photon_projection_result"}];
If[!DirectoryQ[resultDir],CreateDirectory[resultDir,CreateIntermediateDirectories->True]];
put[<|"Schema"->"polarized-sidis-complete-photon-projection-v1","Channel"->channel,
  "InputHash"->inputHash,"InputHashes"->inputHashes,"ProductionSourceHash"->sourceHash,
  "SourceHash"->FileHash[ownSource,"SHA256"],"DiagnosticHash"->FileHash[diagnosticPath,"SHA256"],
  "ProjectionDefinitions"->projectionDefinitions,"FailingTask"->diagnostic["Task"],
  "CorrectedProjection"->failedValue,"Checks"->checks,"FiniteNLOFHatsComputed"->False|>,
  FileNameJoin[{resultDir,"s07_result.wl"}]];
Print["PASS: s07_photon_projection_check"];Quit[0];
