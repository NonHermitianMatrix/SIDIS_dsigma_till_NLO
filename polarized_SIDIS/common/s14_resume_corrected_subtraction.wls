(* Reuse unchanged integrated pieces after the checked S11 correction. *)
$HistoryLength=0;resumeRoot=Directory[];
resumeSource=FileNameJoin[{resumeRoot,"common","s14_resume_corrected_subtraction.wls"}];
resumePhaseSource=FileNameJoin[{resumeRoot,"common","s14_check_phase_series.wls"}];
If[IntegerString[FileHash[resumePhaseSource,"SHA256"],16,64]=!=
  "cb02337e0b7b4e6734a6d34fe452f90af7fbf29c40a0b6f38e076fad778176ce",Quit[1]];
resumePrefix=First[StringSplit[Import[resumePhaseSource,"Text"],"\nphaseControlLabels="]];
If[!SyntaxQ[resumePrefix]||!SyntaxQ[Import[resumeSource,"Text"]],Quit[1]];
ToExpression[resumePrefix,InputForm];
gate["corrected subtraction continuation channel",channel==="Hqqprime"&&!core];
resumeResidualPath=FileNameJoin[{root,channel,"s14_reference_residual_result","s14_result.wl"}];
gate["original checkpoint identity source",IntegerString[FileHash[resumeResidualPath,"SHA256"],16,64]===
  "a92ec00fbd123a2c27126eeb077e1086991cec9332753667e5ae30cd0818f28a"];
resumeResidual=Get[resumeResidualPath];
resumeSubtractionRelative=channel<>"/s11_result/s11_result.wl";
gate["only subtraction input changed",KeyDrop[inputHashes,resumeSubtractionRelative]===
  KeyDrop[resumeResidual["InputHashes"],resumeSubtractionRelative]&&sourceHash===resumeResidual["BaselineSourceHash"]];
resumePreviousPath=FileNameJoin[{root,channel,"s11_result","reference","before_dimensional_completion","s11_result.wl"}];
gate["exact preceding subtraction",FileHash[resumePreviousPath,"SHA256"]===
  resumeResidual["InputHashes"][resumeSubtractionRelative]&&
  subtraction["PreviousSubtractionHash"]===FileHash[resumePreviousPath,"SHA256"]];
resumePrevious=Get[resumePreviousPath];
resumeCompletionPath=FileNameJoin[{root,channel,"s11_dimensional_result","s11_result.wl"}];
gate["accepted completion proof identity",IntegerString[FileHash[resumeCompletionPath,"SHA256"],16,64]===
  "3c76ab221bf3c99ba7c35223b26ca10ec527596dc2f60307d5cc7e508dbc411c"&&
  subtraction["DimensionalCompletionValidationHash"]===FileHash[resumeCompletionPath,"SHA256"]];
resumeCompletion=Get[resumeCompletionPath];
gate["executed complete finite correction",TrueQ[resumeCompletion["Accepted"]]&&And@@Values[resumeCompletion["Checks"]]];
resumeDifferences=Association@Table[distribution->If[distribution==="L1",
  ConstantArray[0,Dimensions[subtraction["Counterterms"]["Regular"]]],
  Map[Factor,subtraction["Counterterms"][distribution]-resumePrevious["Counterterms"][distribution],{3}]],
  {distribution,distributions}];
gate["every counterterm difference is finite",FreeQ[resumeDifferences,eps|D|_Missing|_Series|_SeriesData|_Real|$Failed|$Aborted]];
gate["correction equals complete executed spin comparison",And@@
  (Factor[Together[#]]===0&/@Flatten[resumeDifferences["Regular"]-resumeCompletion["CountertermCorrection"]])];
resumeOldHash=resumeResidual["InputHash"];
resumeOldCache=FileNameJoin[{root,"cache","s14_before_dimensional",channel,IntegerString[resumeOldHash,16]}];
gate["prior finite values isolated from current cache",DirectoryQ[resumeOldCache]&&resumeOldCache=!=cache];
resumeFile[directory_,label_] := FileNameJoin[{directory,"finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];
resumeAssumptions[label_] := (If[Last[label]==="Regular",physical,softPhysical]/.t->label[[2]]omega-s)&&
  If[label[[2]]===0,True,omega>0]&&flavorDomain;
resumeOld[label_] := Module[{path,saved},path=resumeFile[resumeOldCache,label];
  gate["old component checkpoint exists",FileExistsQ[path]];saved=Get[path];
  gate["old component input label and pole acceptance",saved["InputHash"]===resumeOldHash&&
    saved["Label"]===label&&TrueQ[saved["Accepted"]]];
  gate["old component poles exactly zero",And@@(bounded[zero[#,resumeAssumptions[label]],
    {label,"prior pole verification"}]&/@Values[saved["PoleResiduals"]])];saved];
resumeValue[label_,saved_] := saved["Finite"]+
  (Extract[resumeDifferences[Last[label]],First[label]]/.t->label[[2]]omega-s);
resumeControlLabels={{{1,1,1},1,"Regular"},{{1,4,4},-1,"Regular"},{{3,4,4},-1,"Regular"}};
resumeControls=Table[
  saved=resumeOld[label];index=First[label];sign=label[[2]];distribution=Last[label];
  assumptions=resumeAssumptions[label];Print["CORRECTED_ASSEMBLY_CONTROL ",label];
  timing=AbsoluteTiming[finitePart[{phaseProduct[strongFactor realBranch[index,sign,distribution],phase,0,label],
    subtractionValue[index,distribution]/.t->sign omega-s},label,assumptions]];
  gate["fresh corrected assembly equals transferred finite value",bounded[
    zero[timing[[2]]-resumeValue[label,saved],assumptions],{label,"corrected assembly comparison"}]];
  <|"Label"->label,"Seconds"->timing[[1]],"CurrentCheckpointHash"->FileHash[resumeFile[cache,label],"SHA256"]|>,
  {label,resumeControlLabels}];
resumeAssemblyText=Import[sourcePath,"Text"];
resumeIndexDefinition=StringCases[resumeAssemblyText,RegularExpression["(?m)^indices=Tuples[^\\n]+;"]];
gate["unique original index inventory",Length[resumeIndexDefinition]===1];
ToExpression[First[resumeIndexDefinition],InputForm];
resumeLabels=Flatten[Table[{index,sign,distribution},{index,indices},{sign,{1,-1,0}},{distribution,distributions}],2];
resumeRows=Table[
  saved=resumeOld[label];value=resumeValue[label,saved];
  gate["corrected checkpoint is finite",FreeQ[value,eps|_Missing|_Series|_SeriesData|_Integrate|_Limit|_Real|$Failed|$Aborted|Indeterminate|_DirectedInfinity]];
  path=resumeFile[cache,label];oldPath=resumeFile[resumeOldCache,label];
  If[FileExistsQ[path],current=Get[path];
    gate["existing corrected checkpoint identity",current["InputHash"]===inputHash&&current["Label"]===label&&TrueQ[current["Accepted"]]];
    gate["existing corrected checkpoint value",bounded[zero[current["Finite"]-value,resumeAssumptions[label]],label]],
    put[<|"Label"->label,"InputHash"->inputHash,"Accepted"->True,"Finite"->value,
      "PoleResiduals"->saved["PoleResiduals"],"PreviousCheckpointHash"->FileHash[oldPath,"SHA256"],
      "SubtractionCompletionHash"->FileHash[resumeCompletionPath,"SHA256"]|>,path]];
  <|"Label"->label,"PreviousHash"->FileHash[oldPath,"SHA256"],"CurrentHash"->FileHash[path,"SHA256"]|>,
  {label,resumeLabels}];
SetAttributes[finitePart,HoldFirst];
resumeProbeLabel=First[resumeControlLabels];resumeTouched=False;
resumeProbe=finitePart[(resumeTouched=True;$Failed),resumeProbeLabel,resumeAssumptions[resumeProbeLabel]];
gate["validated cached parts are read before recomputation",!resumeTouched&&
  resumeProbe===Get[resumeFile[cache,resumeProbeLabel]]["Finite"]];
resumeProof=<|"Schema"->"polarized-sidis-corrected-subtraction-resume-v1","Channel"->channel,
  "SourceHash"->FileHash[resumeSource,"SHA256"],"BaselineSourceHash"->sourceHash,
  "PreviousInputHash"->resumeOldHash,"InputHash"->inputHash,"InputHashes"->inputHashes,
  "PreviousSubtractionHash"->FileHash[resumePreviousPath,"SHA256"],
  "CompletionHash"->FileHash[resumeCompletionPath,"SHA256"],"Controls"->resumeControls,"CheckpointRows"->resumeRows,
  "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
resumeDirectory=FileNameJoin[{root,channel,"s14_resume_result"}];
If[!DirectoryQ[resumeDirectory],CreateDirectory[resumeDirectory,CreateIntermediateDirectories->True]];
resumeProofPath=FileNameJoin[{resumeDirectory,"s14_result.wl"}];put[resumeProof,resumeProofPath];
gate["exact corrected resume record reload",Get[resumeProofPath]===resumeProof];
Print["CORRECTED_SUBTRACTION_CHECKPOINTS_ACCEPTED ",Length[resumeRows]];
resumeTail="indices=Tuples"<>Last[StringSplit[resumeAssemblyText,"\nindices=Tuples"]];
resumeExport="put[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
gate["unique original export",StringCount[resumeTail,resumeExport]===1];
resumeTail=StringReplace[resumeTail,resumeExport->
  "AssociateTo[result,{\"DispatchSourceHash\"->FileHash[resumeSource,\"SHA256\"],\"SubtractionResumeHash\"->FileHash[resumeProofPath,\"SHA256\"]}];"<>resumeExport];
gate["unchanged final assembly tail syntax",SyntaxQ[resumeTail]];
ToExpression[resumeTail,InputForm];
