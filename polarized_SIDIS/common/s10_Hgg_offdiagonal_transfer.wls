(* Native off-diagonal transfers for Hgg, retaining the accepted S10 conventions. *)
$HistoryLength=0;offDiagonalSource=FileNameJoin[{Directory[],"common","s10_Hgg_offdiagonal_transfer.wls"}];
offDiagonalBase=FileNameJoin[{Directory[],"common","s10_dimensional_quark_gluon_transfer.wls"}];
offDiagonalText=Import[offDiagonalBase,"Text"];
offDiagonalBegin="a = ChangeDimension[amplitudes[\"qg\"], D]; b = a;";
offDiagonalEnd="inputPaths = DeleteDuplicates[Join[{dimensionalSource, baselineSource, acceptedPath},";
If[StringCount[offDiagonalText,offDiagonalBegin]=!=1||StringCount[offDiagonalText,offDiagonalEnd]=!=1||
 !SyntaxQ[Import[offDiagonalSource,"Text"]],Quit[1]];
offDiagonalPrefix=First[StringSplit[offDiagonalText,offDiagonalBegin]];
offDiagonalBody=offDiagonalBegin<>First[StringSplit[Last[StringSplit[offDiagonalText,offDiagonalBegin]],offDiagonalEnd]];
offDiagonalPrefixChanges={
 "s10_dimensional_quark_gluon_transfer.wls"->"s10_Hgg_offdiagonal_transfer.wls",
 "Environment[\\\"POLARIZED_SIDIS_CHANNEL\\\"] === \\\"Hqg\\\""->"Environment[\\\"POLARIZED_SIDIS_CHANNEL\\\"] === \\\"Hgg\\\""};
If[!And@@(StringCount[offDiagonalPrefix,First[#]]===1&/@offDiagonalPrefixChanges),Print["FAIL: off-diagonal prefix interfaces"];Quit[1]];
offDiagonalPrefixCandidate=StringReplace[offDiagonalPrefix,offDiagonalPrefixChanges];
If[!SyntaxQ[offDiagonalPrefixCandidate]||StringReplace[offDiagonalPrefixCandidate,Reverse/@offDiagonalPrefixChanges]=!=offDiagonalPrefix,Quit[1]];
ToExpression[offDiagonalPrefixCandidate,InputForm];
gate["Hgg off-diagonal owner",Environment["POLARIZED_SIDIS_CHANNEL"]==="Hgg"];
offDiagonalPaths={offDiagonalSource,offDiagonalBase,dimensionalSource,baselineSource,acceptedPath};
offDiagonalRead[relative_]:=Module[{path=FileNameJoin[{root,relative}]},AppendTo[offDiagonalPaths,path];
 If[StringEndsQ[relative,".json"],Import[path,"RawJSON"],Get[path]]];
offDiagonalOwnRelative="Hqg/s10_dimensional_quark_gluon_result/s10_result.wl";
offDiagonalOwn=offDiagonalRead[offDiagonalOwnRelative];
offDiagonalOwnReceipt=offDiagonalRead["Hqg/s10_dimensional_quark_gluon_result/s10_execution.json"];
gate["accepted entire native quark-gluon transfer",TrueQ[offDiagonalOwnReceipt["passed"]]&&
 offDiagonalOwnReceipt["result_sha256"][offDiagonalOwnRelative]===IntegerString[FileHash[FileNameJoin[{root,offDiagonalOwnRelative}],"SHA256"],16,64]&&
 offDiagonalOwn["Schema"]==="polarized-sidis-quark-gluon-transfer-v1"&&TrueQ[offDiagonalOwn["Accepted"]]&&
 And@@Values[offDiagonalOwn["Checks"]]&&offDiagonalOwn["SourceHash"]===FileHash[offDiagonalBase,"SHA256"]&&
 offDiagonalOwn["NativeVersions"]==={$Version,$FeynCalcVersion}&&offDiagonalOwn["IncomingSpinLabels"]===labels&&
 offDiagonalOwn["OutgoingSpinLabels"]===extendedLabels];
KeyValueMap[gate["unchanged native qg input "<>#1,FileHash[FileNameJoin[{root,#1}],"SHA256"]===#2]&,
 offDiagonalOwn["InputHashes"]];
offDiagonalAntifermions=DeleteDuplicates[Cases[amplitudes["aqg"],Spinor[-Momentum[mom_,___],___]:>mom,Infinity]];
gate["generated antiquark parent",MemberQ[offDiagonalAntifermions,p]];
offDiagonalBodyChanges={"[\"qg\"]"->"[\"aqg\"]",
 "spinNumerator[p, inVariables, {eX, eY}, False]"->
 "spinNumerator[p, inVariables, {eX, eY}, MemberQ[offDiagonalAntifermions,p]]"};
gate["complete native antiquark interface",StringCount[offDiagonalBody,First[Last[offDiagonalBodyChanges]]]===1];
offDiagonalCandidate=StringReplace[offDiagonalBody,offDiagonalBodyChanges];
gate["unchanged complete native trace and angular integration",SyntaxQ[offDiagonalCandidate]&&
 StringReplace[offDiagonalCandidate,Reverse/@offDiagonalBodyChanges]===offDiagonalBody];
ToExpression[offDiagonalCandidate,InputForm];
offDiagonalFields={"RawDimensionalKernel","PhysicalKernelD","LeadingKernel","CDRKernelD","CDRRegulatorRemainder","MSOperatorD","KernelDifferenceD"};
offDiagonalAnti=AssociationThread[offDiagonalFields,{rawKernel,physicalKernelD,leadingKernel,cdrKernelD,cdrRemainder,msOperatorD,kernelDifferenceD}];
gate["native full-dimensional charge-conjugate output comparison",And@@Table[
 zeroArray[offDiagonalAnti[field]-offDiagonalOwn[field]],{field,offDiagonalFields}]];
offDiagonalFF=<|"qg"->KeyTake[offDiagonalOwn,offDiagonalFields],"aqg"->offDiagonalAnti|>;
offDiagonalPDF=<||>;
offDiagonalPhysical=Flatten[FirstPosition[extendedLabels,#]&/@labels];
offDiagonalExtra=First[FirstPosition[extendedLabels,"E"]];
offDiagonalRank=gram[p][[uPosition,uPosition]];
offDiagonalExtraRank=gram[p][[offDiagonalExtra,offDiagonalExtra]];
offDiagonalAverage=Factor[offDiagonalRank/(offDiagonalRank+offDiagonalExtraRank)];
offDiagonalCompletion=Table[KroneckerDelta[k,offDiagonalPhysical[[i]]]+
 If[labels[[i]]==="U",KroneckerDelta[k,offDiagonalExtra],0],{i,Length[labels]},{k,Length[extendedLabels]}];
offDiagonalIncoming=Transpose[offDiagonalCompletion].DiagonalMatrix[If[#==="U",offDiagonalAverage,1]&/@labels];
Do[
 ffName=First[pair];pdfName=Last[pair];
 fermionLegs=DeleteDuplicates[Cases[amplitudes[ffName],Spinor[sign_. Momentum[mom_,___],___]:>mom,Infinity]];
 crossedLegs=Intersection[fermionLegs,{p,k1}];
 crossingSign=(-1)^(Length[crossedLegs]+1);
 crossing=Map[Factor,crossingSign z Transpose[offDiagonalFF[ffName]["RawDimensionalKernel"]/.z->1/z],{2}];
 crossingNormalization=Factor[accepted["Responses"][pdfName]["RealKernel"][[uPosition,uPosition]]/
  Limit[crossing[[uPosition,uPosition]],D->Length[pVector]]];
 gate[pdfName<>" reference-derived crossing normalization",FreeQ[crossingNormalization,z|D|_Real]&&crossingNormalization=!=0];
 crossing=Map[Factor,crossingNormalization crossing,{2}];
 physicalTransfer=crossing[[All,offDiagonalPhysical]];
 leadingTransfer=Map[Factor[Limit[#,D->Length[pVector]]]&,physicalTransfer,{2}];
 gate[pdfName<>" full physical crossing limit",zeroArray[leadingTransfer-accepted["Responses"][pdfName]["RealKernel"]]];
 cdrTransfer=Map[Factor,crossing.offDiagonalIncoming,{2}];
 cdrLimit=Map[Factor[Limit[#,D->Length[pVector]]]&,cdrTransfer,{2}];
 gate[pdfName<>" full CDR physical limit",zeroArray[cdrLimit-leadingTransfer]];
 remainder=Map[Factor,cdrTransfer-cdrLimit,{2}];
 operator=Map[Factor,physicalTransfer-remainder,{2}];
 difference=Map[Factor,operator-leadingTransfer,{2}];
 gate[pdfName<>" exact MS operator reconstruction",zeroArray[operator+remainder-physicalTransfer]];
 gate[pdfName<>" unchanged leading kernels",zeroArray[Map[Limit[#,D->Length[pVector]]&,difference,{2}]]];
 gate[pdfName<>" no new soft endpoint",zeroArray[Map[Limit[(1-z)#,z->1]&,difference,{2}]]];
 gate[pdfName<>" evaluated exact operators",scalarQ[{crossing,operator,difference}]&&
  FreeQ[{crossing,operator,difference},_Limit|_ConditionalExpression|_Piecewise|Indeterminate|_DirectedInfinity]];
 AssociateTo[offDiagonalPDF,pdfName-><|"CrossedRawDimensionalKernel"->crossing,"PhysicalKernelD"->physicalTransfer,
  "LeadingKernel"->leadingTransfer,"CDRKernelD"->cdrTransfer,"CDRRegulatorRemainder"->remainder,
  "MSOperatorD"->operator,"KernelDifferenceD"->difference,"CrossedFermionLegs"->crossedLegs,
  "CrossingNormalizationDerived"->crossingNormalization|>],{pair,{{"qg","gq"},{"aqg","gaq"}}}];
gate["native crossed charge conjugation",And@@Table[zeroArray[
 offDiagonalPDF["gq"][field]-offDiagonalPDF["gaq"][field]],
 {field,{"CrossedRawDimensionalKernel","MSOperatorD","KernelDifferenceD"}}]];
Print["HGG_NATIVE_OFFDIAGONAL_MS_DIFFERENCES ",InputForm[<|
 "PDF"->Map[#["KernelDifferenceD"]&,offDiagonalPDF],"FF"->Map[#["KernelDifferenceD"]&,offDiagonalFF]|>]];
offDiagonalPaths=DeleteDuplicates[Join[offDiagonalPaths,FileNameJoin[{root,#}]&/@Keys[offDiagonalOwn["InputHashes"]]]];
offDiagonalResult=<|"Schema"->"polarized-sidis-offdiagonal-transfer-v1","Channel"->"Hgg","SpinLabels"->labels,
 "PDF"->offDiagonalPDF,"FF"->offDiagonalFF,"IncomingCDRAverage"->offDiagonalAverage,
 "CrossingReference"->"arXiv:0807.4424 Eq. (33)","MSReference"->"arXiv:0807.4424 Eqs. (38)-(39)",
 "SourceHash"->FileHash[offDiagonalSource,"SHA256"],"BaseSourceHash"->FileHash[offDiagonalBase,"SHA256"],
 "InputHashes"->Association[(StringDrop[#,StringLength[root]+1]->FileHash[#,"SHA256"])&/@offDiagonalPaths],
 "NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"Accepted"->True,"FiniteNLOFHatsComputed"->False|>;
offDiagonalDirectory=FileNameJoin[{root,"Hgg","s10_offdiagonal_result"}];
If[!DirectoryQ[offDiagonalDirectory],CreateDirectory[offDiagonalDirectory]];
offDiagonalOutput=FileNameJoin[{offDiagonalDirectory,"s10_result.wl"}];put[offDiagonalResult,offDiagonalOutput];
gate["bounded native off-diagonal export",FileByteCount[offDiagonalOutput]<128*1024^2];
gate["exact native off-diagonal reload",Get[offDiagonalOutput]===offDiagonalResult];
Export[FileNameJoin[{offDiagonalDirectory,"s10_checks.json"}],<|"checks"->checks,
 "job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s10_Hgg_offdiagonal_transfer"];Quit[0];
