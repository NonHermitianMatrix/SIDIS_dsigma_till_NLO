(* Read accepted finite checkpoints before evaluating their phase inputs. *)
$HistoryLength=0;
cachedPartsSource=FileNameJoin[{Directory[],"common","s14_assemble_finite_cached_parts.wls"}];
cachedPartsParent=FileNameJoin[{Directory[],"common","s14_assemble_finite_exact_charge.wls"}];
If[IntegerString[FileHash[cachedPartsParent,"SHA256"],16,64]=!=
 "1901b5568f4dedf9422c31e06d7b7eabad15be68bdaf2c97f6f31ebe50e487d8"||
 !SyntaxQ[Import[cachedPartsSource,"Text"]],Quit[1]];
cachedPartsText=StringTrim[Import[cachedPartsParent,"Text"]];
cachedPartsTerminal="ToExpression[exactChargeRun,InputForm];";
If[!StringEndsQ[cachedPartsText,cachedPartsTerminal],Quit[1]];
cachedPartsPrefix=StringDrop[cachedPartsText,-StringLength[cachedPartsTerminal]];
If[!SyntaxQ[cachedPartsPrefix],Quit[1]];ToExpression[cachedPartsPrefix,InputForm];
SetAttributes[cachedFinitePart,HoldFirst];
cachedFinitePart[parts_,label_,assumptions_] := Module[{file,saved},
 file=FileNameJoin[{cache,"finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];
 saved=If[FileExistsQ[file],Get[file],<||>];
 If[Lookup[saved,"InputHash",None]===inputHash&&TrueQ[Lookup[saved,"Accepted",False]],
   gate["accepted cached label unchanged",saved["Label"]===label&&KeyExistsQ[saved,"Finite"]];
   AssociateTo[cachedPartsReused,file->FileHash[file,"SHA256"]];
   Return[saved["Finite"]]];
 finitePart[parts,label,assumptions]];
cachedPartsInstall[] := Module[{definition,replacement,files,record=None,original,candidate,triggered=False,seconds},
 cachedPartsReused=<||>;
 gate["finite cache wrapper holds phase input",MemberQ[Attributes[cachedFinitePart],HoldFirst]];
 files=FileNames["finite_*.wl",cache];
 Do[record=Get[file];If[Lookup[record,"InputHash",None]===inputHash&&TrueQ[Lookup[record,"Accepted",False]],Break[]];record=None,{file,files}];
 gate["own accepted finite comparison exists",AssociationQ[record]&&KeyExistsQ[record,"Finite"]];
 original=finitePart[{},record["Label"],True];
 {seconds,candidate}=AbsoluteTiming[cachedFinitePart[(triggered=True;{}),record["Label"],True]];
 gate["own complete finite output unchanged without phase reevaluation",!triggered&&candidate===original&&candidate===record["Finite"]];
 cachedPartsComparison=<|"Label"->record["Label"],"InputHash"->inputHash,
   "FiniteHash"->Hash[candidate,"SHA256"],"ExactOwnComparisonPassed"->True,"PhaseInputEvaluated"->triggered,"Seconds"->seconds|>;
 definition=DownValues[assemble];replacement=definition/.finitePart->cachedFinitePart;
 gate["only finite checkpoint dispatch changes",!FreeQ[definition,finitePart]&&
   (replacement/.cachedFinitePart->finitePart)===definition];
 DownValues[assemble]=replacement;
 gate["complete cached assembly definition installed",DownValues[assemble]===replacement];
 gate["exact charge proof remains bound",exactChargeZero[0]];
 Print["S14_CACHED_PARTS_COMPARISON ",InputForm[cachedPartsComparison]]];
cachedPartsRecord[] := Module[{anchor,replacement,old},
 anchor="compactAssemblyWrite[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
 replacement="AssociateTo[result,\"FiniteCheckpointReuse\"-><|\"SourceHash\"->FileHash[cachedPartsSource,\"SHA256\"],\"OwnComparison\"->cachedPartsComparison,\"ReusedFiles\"->cachedPartsReused|>];"<>anchor;
 gate["unique cached finite output interface",StringCount[phaseRunTail,anchor]===1];
 old=phaseRunTail;phaseRunTail=StringReplace[old,anchor->replacement];
 gate["all final finite gates retained",SyntaxQ[phaseRunTail]&&StringReplace[phaseRunTail,replacement->anchor]===old]];
cachedPartsAnchor="exactChargeRecord[];ToExpression[phaseRunTail,InputForm];";
cachedPartsReplacement="exactChargeRecord[];cachedPartsInstall[];cachedPartsRecord[];ToExpression[phaseRunTail,InputForm];";
If[StringCount[exactChargeRun,cachedPartsAnchor]=!=1,Print["FAIL: unique cached finite installation"];Quit[1]];
cachedPartsRun=StringReplace[exactChargeRun,cachedPartsAnchor->cachedPartsReplacement];
If[!SyntaxQ[cachedPartsRun]||StringReplace[cachedPartsRun,cachedPartsReplacement->cachedPartsAnchor]=!=exactChargeRun,Quit[1]];
ToExpression[cachedPartsRun,InputForm];
