(* Test memoization of unchanged native loop-monomial conversions. *)
$HistoryLength=0;
monomialSource=FileNameJoin[{Directory[],"common","s08_check_monomial_cache.wls"}];
setupPath=FileNameJoin[{Directory[],"common","s08_check_Hgg_reference_map.wls"}];
If[!SyntaxQ[ReadString[monomialSource]]||IntegerString[FileHash[setupPath,"SHA256"],16,64]=!="4261bb809315d37609ba424f0e59969730cf68374273b5a145e7fe6257180e15",Quit[1]];
setupText=ReadString[setupPath];boundary=StringPosition[setupText,"\nreferenceConfigPath="];
If[Length[boundary]=!=1,Quit[1]];setup=StringTake[setupText,First[First[boundary]]-1];
If[!SyntaxQ[setup],Quit[1]];ToExpression[setup,InputForm];
DownValues[externalOriginalMap]=referenceProof["OriginalAliasDefinitions"];
DownValues[mapExpression]=referenceProof["MappingDefinitions"];
originalFamily=DownValues[familyRows];originalDecompose=DownValues[decompose];
relative="Hgg/s08_shared_piece_cache_result/s08_result.wl";path=FileNameJoin[{root,relative}];
receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
gate["accepted own input and coefficients",TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
inputProof=Get[path];
gate["same actual own mapping contract",TrueQ[inputProof["OwnAcceptedComparison"]]&&And@@Values[inputProof["Checks"]]&&
 inputProof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&inputProof["InputHashes"]===record["InputHashes"]&&
 inputProof["TargetInputHash"]===record["TargetInputHash"]&&
 inputProof["AlgebraDefinitions"][[1;;3]]==={DownValues[mapExpression],DownValues[familyRows],DownValues[merge]}];
actual=inputProof["ActualInput"];pieces=actual["Pieces"];reference=inputProof["FreshCoefficients"];
gate["same complete saved equation pieces",Expand[Total[pieces]-actual["Equation"]]===0];
conversionOriginal="shiftRules=CoefficientRules[Expand[shifted],polynomialVariables];\n   shiftReconstruction=Total[(Last[#] Times@@MapThread[Power,{polynomialVariables,First[#]}])&/@shiftRules];\n   gate[\"loop monomial substitution reconstructs\",zero[shiftReconstruction-shifted]];";
gate["unique complete native conversion",StringQ[certificateFamilyCandidate]&&StringCount[certificateFamilyCandidate,conversionOriginal]===1];
ToExpression[certificateFamilyCandidate,InputForm];
gate["entire live family body is the accepted source",DownValues[familyRows]===originalFamily];
conversionRenames={"shiftRules"->"rules","shiftReconstruction"->"reconstruction","polynomialVariables"->"vars","shifted"->"value"};
conversionBody=StringReplace[conversionOriginal,conversionRenames];
gate["unchanged original conversion operations",StringReplace[conversionBody,Reverse/@conversionRenames]===conversionOriginal];
conversionSource="uncachedMonomialRules[value_,vars_]:=Module[{rules,reconstruction},"<>conversionBody<>"rules];";
gate["complete isolated conversion syntax",SyntaxQ[conversionSource]];ToExpression[conversionSource,InputForm];
monomialCache=<||>;monomialHits=0;monomialMisses=0;monomialEvictions=0;monomialCacheLimit=64*1024^2;
cachedMonomialRules[value_,vars_]:=Module[{input,binding,packet,rules,candidate},
 input={value,vars};binding=Hash[input,"SHA256"];packet=Lookup[monomialCache,binding,<||>];
 If[AssociationQ[packet]&&Lookup[packet,"Input",None]===input&&TrueQ[Lookup[packet,"Accepted",False]],
  monomialHits++;gate["cached monomial has exact accepted input",packet["Input"]===input];Return[packet["Rules"]]];
 monomialMisses++;rules=uncachedMonomialRules[value,vars];
 packet=<|"Input"->input,"Rules"->rules,"Accepted"->True|>;
 candidate=Append[monomialCache,binding->packet];
 If[ByteCount[candidate]>monomialCacheLimit,monomialEvictions++;candidate=<|binding->packet|>];
 If[ByteCount[candidate]<=monomialCacheLimit,monomialCache=candidate];rules];
familyCandidate=StringReplace[certificateFamilyCandidate,conversionOriginal->"shiftRules=cachedMonomialRules[shifted,polynomialVariables];"];
gate["only conversion dispatch changes",SyntaxQ[familyCandidate]&&
 StringReplace[familyCandidate,"shiftRules=cachedMonomialRules[shifted,polynomialVariables];"->conversionOriginal]===certificateFamilyCandidate];
mapPieces[]:=Module[{packets,rows},
 packets=Table[<|"Coefficients"->bounded[mapExpression[piece],"actual own monomial-cache piece"]|>,{piece,pieces}];
 rows=bounded[merge[Lookup[packets,"Coefficients"]],"actual own coefficient merge"];
 gate["complete own piece merge reconstructs",certifyGroupMerge[packets,rows]];rows];
sameRows[left_,right_]:=AssociationQ[left]&&AssociationQ[right]&&Sort[Keys[left]]===Sort[Keys[right]]&&
 And@@KeyValueMap[(#2===right[#1]||zero[#2-right[#1]])&,left];
Print["MONOMIAL_ORIGINAL_START"];ClearSystemCache[];
{originalSeconds,originalRows}=AbsoluteTiming[mapPieces[]];
gate["original reproduces own accepted output",sameRows[originalRows,reference]];
ToExpression[familyCandidate,InputForm];candidateFamily=DownValues[familyRows];DownValues[decompose]=originalDecompose;ClearSystemCache[];
Print["MONOMIAL_COLD_START"];
{coldSeconds,coldRows}=AbsoluteTiming[mapPieces[]];
gate["cold cache preserves every own coefficient",sameRows[coldRows,originalRows]];
coldCounts={monomialHits,monomialMisses,monomialEvictions};
DownValues[decompose]=originalDecompose;ClearSystemCache[];
Print["MONOMIAL_WARM_START"];
{warmSeconds,warmRows}=AbsoluteTiming[mapPieces[]];
gate["warm cache preserves every own coefficient",sameRows[warmRows,originalRows]];
gate["conversion cache actually reused",monomialHits>First[coldCounts]&&monomialMisses===coldCounts[[2]]&&monomialEvictions===0];
gate["bounded conversion cache",ByteCount[monomialCache]<=monomialCacheLimit];
useful=warmSeconds<9*originalSeconds/10;
result=<|"Schema"->"polarized-sidis-monomial-cache-comparison-v1","Channel"->channel,
 "SourceHash"->FileHash[monomialSource,"SHA256"],"SetupHash"->FileHash[setupPath,"SHA256"],"OwnProofHash"->FileHash[path,"SHA256"],
 "InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},
 "ActualInput"->actual,"OriginalFamilyDefinitions"->originalFamily,"FamilyDefinitions"->candidateFamily,
 "OriginalConversionSource"->conversionOriginal,"UncachedDefinitions"->DownValues[uncachedMonomialRules],"CachedDefinitions"->DownValues[cachedMonomialRules],
 "CacheLimit"->monomialCacheLimit,"OwnAcceptedComparison"->True,"UsefulSpeedupObserved"->useful,
 "OriginalSeconds"->originalSeconds,"ColdSeconds"->coldSeconds,"WarmSeconds"->warmSeconds,"ColdCounts"->coldCounts,
 "FinalCounts"->{monomialHits,monomialMisses,monomialEvictions},"CacheBytes"->ByteCount[monomialCache],
 "OriginalCoefficients"->originalRows,"CandidateCoefficients"->warmRows,"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
dir=FileNameJoin[{root,"Hgg","s08_monomial_cache_result"}];If[!DirectoryQ[dir],CreateDirectory[dir]];
saveNative[result,FileNameJoin[{dir,"s08_result.wl"}]];
Export[FileNameJoin[{dir,"s08_checks.json"}],<|"checks"->checks,"original_seconds"->originalSeconds,"cold_seconds"->coldSeconds,
 "warm_seconds"->warmSeconds,"useful_speedup_observed"->useful,"cold_counts"->coldCounts,
 "final_counts"->{monomialHits,monomialMisses,monomialEvictions},"cache_bytes"->ByteCount[monomialCache],"peak_kernel_memory_bytes"->MaxMemoryUsed[]|>,"RawJSON"];
Print["PASS: s08_check_monomial_cache"];Quit[0];
