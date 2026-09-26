(* Keep all S14 equations; compare exact rational charge reconstruction canonically. *)
$HistoryLength=0;
exactChargeSource=FileNameJoin[{Directory[],"common","s14_assemble_finite_exact_charge.wls"}];
exactChargeParent=FileNameJoin[{Directory[],"common","s14_assemble_finite_projected_frame.wls"}];
If[IntegerString[FileHash[exactChargeParent,"SHA256"],16,64]=!=
  "b4ea25b660b0fc445ecbc302668a20436435f2b2cc9b6a6ac59871ec051faf2a"||
  !SyntaxQ[Import[exactChargeSource,"Text"]],Print["FAIL: exact charge source identity"];Quit[1]];
exactChargeProofLoaded=False;
exactChargeZero[value_] := Module[{residual},
  If[!TrueQ[exactChargeProofLoaded],
    exactChargeProofPath=FileNameJoin[{root,channel,"s14_charge_result","s14_result.wl"}];
    exactChargeReceiptPath=FileNameJoin[{root,channel,"s14_charge_result","s14_execution.json"}];
    exactChargeReceipt=Import[exactChargeReceiptPath,"RawJSON"];
    gate["accepted own charge comparison receipt",TrueQ[exactChargeReceipt["passed"]]];
    KeyValueMap[gate["bound charge comparison "<>#1,
      IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,exactChargeReceipt["result_sha256"]];
    exactChargeProof=Get[exactChargeProofPath];
    gate["accepted actual failed-expression reconstruction",exactChargeProof["Schema"]==="polarized-sidis-charge-reconstruction-v1"&&
      exactChargeProof["Channel"]===channel&&TrueQ[exactChargeProof["Accepted"]]&&And@@Values[exactChargeProof["Checks"]]&&
      exactChargeProof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
      exactChargeProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_check_charge_reconstruction.wls"}],"SHA256"]&&
      exactChargeProof["RealHash"]===FileHash[FileNameJoin[{root,channel,"s12_result","s12_result.wl"}],"SHA256"]&&
      exactChargeProof["ProducerReceiptHash"]===FileHash[FileNameJoin[{root,channel,"s12_result","s12_execution.json"}],"SHA256"]&&
      Count[Lookup[exactChargeProof["Comparisons"],"OriginalPredicatePassed"],False]>0&&
      AllTrue[exactChargeProof["Comparisons"],TrueQ[#["Accepted"]]&&#["ExactResidual"]===0&]];
    exactChargeProofLoaded=True;Clear[exactChargeProof];ClearSystemCache[]];
  residual=Expand[value];residual===0||bounded[Together[residual],"exact rational charge reconstruction"]===0];
exactChargePrefix[] := Module[{anchor,replacement,original},
  anchor="gate[\"exact charge decomposition\",Expand[expression-Total[MapThread[Times,{Last/@rows,monomials}]]]===0];";
  replacement="gate[\"exact charge decomposition\",exactChargeZero[expression-Total[MapThread[Times,{Last/@rows,monomials}]]]];";
  If[StringCount[phaseRunPrefix,anchor]=!=1,Print["FAIL: unique charge reconstruction predicate"];Quit[1]];
  original=phaseRunPrefix;phaseRunPrefix=StringReplace[phaseRunPrefix,anchor->replacement];
  If[StringReplace[phaseRunPrefix,replacement->anchor]=!=original||!SyntaxQ[phaseRunPrefix],
    Print["FAIL: unchanged charge coefficients and weights"];Quit[1]]];
exactChargeInstall[] := Module[{anchor,replacement,original},
  anchor="projectedReplaceInput[];ToExpression[phaseRunPrefix,InputForm];";
  replacement="projectedReplaceInput[];exactChargePrefix[];ToExpression[phaseRunPrefix,InputForm];";
  If[StringCount[compactAssemblyInitialization,anchor]=!=1,Print["FAIL: unique exact input initialization"];Quit[1]];
  original=compactAssemblyInitialization;compactAssemblyInitialization=StringReplace[original,anchor->replacement];
  If[StringReplace[compactAssemblyInitialization,replacement->anchor]=!=original||!SyntaxQ[compactAssemblyInitialization],Quit[1]]];
exactChargeRecord[] := Module[{anchor,replacement,original},
  anchor="compactAssemblyWrite[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
  replacement="AssociateTo[result,{\"ChargeComparisonSourceHash\"->FileHash[exactChargeSource,\"SHA256\"],\"ChargeComparisonHash\"->FileHash[exactChargeProofPath,\"SHA256\"]}];"<>anchor;
  gate["unique charge proof export",StringCount[phaseRunTail,anchor]===1];original=phaseRunTail;
  phaseRunTail=StringReplace[phaseRunTail,anchor->replacement];
  gate["unchanged final finite export",StringReplace[phaseRunTail,replacement->anchor]===original&&SyntaxQ[phaseRunTail]]];
exactChargeText=StringTrim[Import[exactChargeParent,"Text"]];exactChargeTerminal="ToExpression[projectedRunText,InputForm];";
If[!StringEndsQ[exactChargeText,exactChargeTerminal],Quit[1]];
exactChargeBootstrap=StringDrop[exactChargeText,-StringLength[exactChargeTerminal]];
If[!SyntaxQ[exactChargeBootstrap],Quit[1]];ToExpression[exactChargeBootstrap,InputForm];
exactChargeChanges={
  "projectedInstallReader[];ToExpression[compactAssemblyInitialization,InputForm];"->
    "projectedInstallReader[];exactChargeInstall[];ToExpression[compactAssemblyInitialization,InputForm];",
  "\nprojectedRecordEvidence[];ToExpression[phaseRunTail,InputForm];"->
    "\nprojectedRecordEvidence[];exactChargeRecord[];ToExpression[phaseRunTail,InputForm];"};
If[!And@@(StringCount[projectedRunText,First[#]]===1&/@exactChargeChanges),Print["FAIL: exact charge entry interfaces"];Quit[1]];
exactChargeRun=StringReplace[projectedRunText,exactChargeChanges];
If[!SyntaxQ[exactChargeRun]||StringReplace[exactChargeRun,Reverse/@exactChargeChanges]=!=projectedRunText,Quit[1]];
ToExpression[exactChargeRun,InputForm];
