If[!TrueQ[SyntaxQ[Import[$InputFileName,"Text"]]],Print["FAILED source syntax"];Exit[1]];
$HistoryLength=0;$MaxExtraPrecision=2000;
root=DirectoryName[$InputFileName];scripts=DirectoryName[root];SetDirectory[root];
comparisonSource=FileNameJoin[{root,"s05_compare_distributions.wl"}];
previousSource=FileNameJoin[{root,"s05_provenance","s05_before_endpoint_partition.wl"}];
previousSources=FileNames["s05_before_*.wl",FileNameJoin[{root,"s05_provenance"}]];
log[x_]:=Print[DateString[{"ISODate","T","Time"}]," ",x];
gate[n_,v_]:=If[!TrueQ[v],Throw[<|"FailedGate"->n,"Value"->v|>,"stage"]];
SetAttributes[bounded,HoldFirst];
bounded[e_,n_]:=TimeConstrained[MemoryConstrained[e,2000000000,Throw[<|"FailedGate"->n,"Reason"->"memory bound"|>,"stage"]],600,Throw[<|"FailedGate"->n,"Reason"->"time bound"|>,"stage"]];
dilogarithms=Get[FileNameJoin[{scripts,"Hqg_v3","s13_dilogarithms.wl"}]];

unitDilogarithm[argument_, assumptions_] := Module[{identity, candidates, chosen},
  identity = dilogarithms["Identities"]["Complement"];
  candidates = SortBy[DeleteDuplicates[{argument, Factor[identity["Argument"] /. z -> argument]}],
    {LeafCount, ToString[#, InputForm] &}];
  chosen = First[candidates];
  If[chosen === argument, Return[PolyLog[2, argument]]];
  gate["complement dilogarithm argument reconstructs", Factor[
    (identity["Argument"] /. z -> chosen) - argument] === 0];
  identity["Value"] /. z -> chosen];

reduceDilogarithm[argument_, assumptions_] := Module[{arg, identity, kind, solutions, rule},
  arg = Factor[argument];
  If[TrueQ[FullSimplify[0 < arg < 1, assumptions]], Return[unitDilogarithm[arg, assumptions]]];
  kind = Which[TrueQ[FullSimplify[arg < 0, assumptions]], "Mobius",
    TrueQ[FullSimplify[arg > 1, assumptions]], "Inverse", True, None];
  If[kind === None, Return[PolyLog[2, arg]]];
  identity = dilogarithms["Identities"][kind];
  solutions = Solve[identity["Argument"] == arg, z];
  gate["dilogarithm transformation has a unique inverse", Length[solutions] === 1];
  rule = First[solutions] /. Rule[a_, b_] :> Rule[a, Factor[b]];
  gate["dilogarithm transformation domain", FullSimplify[identity["Domain"] /. rule, assumptions] === True];
  gate["dilogarithm transformation reconstructs its argument", Factor[(identity["Argument"] /. rule) - arg] === 0];
  (identity["Value"] /. rule) /. PolyLog[2, a_] :> unitDilogarithm[Factor[a], assumptions]];

reduceFunction[function_, assumptions_] := Module[{file, saved, value, unitFunctions, realSlots, realRules, domain},
  file = FileNameJoin[{cache, "Function_" <> IntegerString[Hash[{function, assumptions}, "SHA256"], 16, 64] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file];
    If[MemberQ[acceptedInputHashes, saved["InputHash"]], Return[saved["Value"]]]];
  value = function /. PolyLog[2, a_] :> reduceDilogarithm[a, assumptions];
  unitFunctions = Select[DeleteDuplicates[Cases[value, _PolyLog, {0, Infinity}]],
    TrueQ[FullSimplify[0 < #[[2]] < 1, assumptions]] &];
  realSlots = Array[realDilogarithm, Length[unitFunctions]];
  realRules = Thread[unitFunctions -> realSlots];
  domain = assumptions && Element[realSlots, Reals];
  value = value /. {Arg[a_] :> Arg[Factor[a]], Abs[a_] :> Abs[Factor[a]], Sign[a_] :> Sign[Factor[a]]};
  value = Refine[PowerExpand[(value /. realRules) /. Log[a_] :> Log[Factor[a]],
    Assumptions -> domain], domain] /. Thread[realSlots -> unitFunctions];
  If[MatchQ[function, _Arg | _Abs | _Sign], value = FullSimplify[value, assumptions]];
  gate["function normalization is finite", FreeQ[value, Indeterminate | _DirectedInfinity]];
  Put[<|"InputHash" -> inputHash, "Function" -> function, "Assumptions" -> assumptions,
    "Value" -> value|>, file]; value];

reduceAlgebraic[expression_, assumptions_] := Module[{file, saved, terms, value,groups},
  file = FileNameJoin[{cache, "Algebraic_" <> IntegerString[Hash[{expression, assumptions}, "SHA256"], 16, 64] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file];
    If[MemberQ[acceptedInputHashes, saved["InputHash"]], Return[saved["Value"]]]];
  terms = If[Head[expression] === Plus, List @@ expression, {expression}];
  Print["Factor ", Length[terms], " rational summands"];
  terms = MapIndexed[Function[{term, index},
    With[{answer = bounded[Factor[term], {"rational summand", First[index]}]},
      If[Mod[First[index], 100] === 0, ClearSystemCache[];
        Print["Factored summand ", First[index], "/", Length[terms]]]; answer]], terms];
  groups=GatherBy[terms,Denominator];
  gate["denominator grouping preserves every summand",Sort[Flatten[groups,1]]===Sort[terms]];
  Print["Combine ",Length[terms]," summands in ",Length[groups]," denominator groups"];
  terms=Map[Function[group,Cancel[Total[group]]],groups];
  Print["Combine rational summands; leaves = ", LeafCount[Total[terms]]];
  value = bounded[Together[Total[terms]], "exact rational coefficient"];
  gate["rational coefficient reduction is finite", FreeQ[value, Indeterminate | _DirectedInfinity]];
  Put[<|"InputHash" -> inputHash, "ExpressionHash" -> Hash[{expression, assumptions}, "SHA256"],
    "Value" -> value|>, file]; value];

expandCoth[input_, assumptions_] := Module[{functions, rules, expanded},
  functions = DeleteDuplicates[Cases[input, _ArcCoth, Infinity]];
  rules = Table[
    expanded = bounded[Refine[ComplexExpand[function], assumptions], "inverse hyperbolic conversion"];
    gate["inverse hyperbolic conversion is evaluated", FreeQ[expanded, _ArcCoth | _ComplexExpand]];
    gate["inverse hyperbolic identity holds in the physical domain", bounded[
      FullSimplify[expanded - function, assumptions] === 0, "inverse hyperbolic identity"]];
    function -> expanded, {function, functions}];
  input /. rules];

normalize[input_, assumptions_] := Module[{value, roots, rules, functions, phases, slots, formal, coefficients,
  coefficientFile, saved, terms, rows, groups, answer, result},
  value = expandCoth[input, assumptions] /. a_ArcTanh :> ComplexExpand[a];
  roots = DeleteDuplicates[Cases[value, Power[_, power_Rational] /; Denominator[power] === 2, Infinity]];
  Print["Normalize ", Length[roots], " radicals"];
  rules = Table[radical -> bounded[FullSimplify[radical, assumptions], "one radical"], {radical, roots}];
  value = value /. rules;
  functions = DeleteDuplicates[Cases[value, _Log | _PolyLog | _ArcTan | _ArcTanh | _Re | _Im, Infinity]];
  Print["Normalize ", Length[functions], " distinct functions"];
  rules = Table[
    With[{answer = bounded[reduceFunction[functions[[j]], assumptions], {"one function", j}]},
      If[Mod[j, 10] === 0, ClearSystemCache[]; Print["Normalized function ", j, "/", Length[functions]]];
      functions[[j]] -> answer], {j, Length[functions]}];
  value = value /. rules;
  phases = DeleteDuplicates[Cases[value, _Arg | _Abs | _Sign, Infinity]];
  Print["Normalize ", Length[phases], " phase functions"];
  rules = Table[phase -> bounded[reduceFunction[phase, assumptions], "one phase function"], {phase, phases}];
  value = value /. rules;
  gate["normalized function assembly is finite", FreeQ[value, Indeterminate | _DirectedInfinity]];
  functions = DeleteDuplicates[Cases[value, _Log | _PolyLog | _ArcTan | _ArcTanh | _Re | _Im, Infinity]];
  If[functions === {}, Return[Factor[value]]];
  slots = Array[formalFunction, Length[functions]];
  formal = Expand[value /. Thread[functions -> slots], Alternatives @@ slots];
  gate["comparison is polynomial in its formal functions", PolynomialQ[formal, slots]];
  Print["Factored formal input leaves = ", LeafCount[formal]];
  coefficientFile = FileNameJoin[{cache, "GroupedCoefficients_" <>
    IntegerString[Hash[{formal, slots, assumptions}, "SHA256"], 16, 64] <> ".wl"}];
  saved = If[FileExistsQ[coefficientFile], Get[coefficientFile], <||>];
  coefficients = If[MemberQ[acceptedInputHashes, saved["InputHash"]], saved["Value"],
    terms = If[Head[formal] === Plus, List @@ formal, {formal}];
    rows = Map[Function[term, With[{factors = If[Head[term] === Times, List @@ term, {term}]},
      {Times @@ Select[factors, !FreeQ[#, Alternatives @@ slots] &],
       Times @@ Select[factors, FreeQ[#, Alternatives @@ slots] &]}]], terms];
    gate["term factors reconstruct exactly", And @@ MapThread[SameQ, {Times @@@ rows, terms}]];
    groups = GatherBy[rows, First];
    answer = ({#[[1, 1]], Total[#[[All, 2]]]} &) /@ groups;
    gate["grouping preserves every original factor row", Sort[Flatten[groups, 1]] === Sort[rows]];
    gate["each coefficient group has one common monomial",
      And @@ (SameQ @@ #[[All, 1]] & /@ groups)];
    gate["scalar coefficient grouping is exactly distributive",
      Expand[groupMonomial (coefficientA + coefficientB) -
        groupMonomial coefficientA - groupMonomial coefficientB] === 0];
    Put[<|"InputHash" -> inputHash, "Value" -> answer|>, coefficientFile]; answer];
  Print["Reduce ", Length[coefficients], " algebraic coefficients"];
  result = Table[
    Print["Reduce coefficient ", j, "/", Length[coefficients], "; leaves = ", LeafCount[Last[coefficients[[j]]]]];
    With[{coefficient = bounded[Factor[reduceAlgebraic[Last[coefficients[[j]]], assumptions]],
        {"compact completed coefficient", j}]},
      ClearSystemCache[]; Print["Saved coefficient ", j, "/", Length[coefficients], "; zero = ", coefficient === 0];
      coefficient (First[coefficients[[j]]] /. Thread[slots -> functions])],
    {j, Length[coefficients]}];
  Total[result]];



splitChains[e_]:=e/.{h:(Greater|GreaterEqual|Less|LessEqual)[items__]/;Length[{items}]>2:>And@@(Apply[Head[h],#]&/@Partition[List@@h,2,1])};
canonicalEndpoint[e_]:=e/.{Power[a_,b_Rational]:>Power[Factor[a],b],Log[a_]:>Log[Factor[a]]};
seriesEndpoint[e_,ass_]:=Module[{terms,seriesTerms,combined,value,exponents,poles,seriesPath,seriesSaved,normalized},
  seriesPath=FileNameJoin[{cache,"EndpointSeries_"<>IntegerString[Hash[{e,ass},"SHA256"],16,64]<>".wl"}];
  seriesSaved=If[FileExistsQ[seriesPath],Get[seriesPath],<||>];
 terms=If[Head[e]===Plus,List@@e,{e}];
 log[{"combined endpoint series",Length[terms]}];
 seriesTerms=If[AssociationQ[seriesSaved]&&seriesSaved["Input"]===e&&seriesSaved["Assumptions"]===ass,seriesSaved["TermSeries"],MapIndexed[Function[{term,index},
 If[Mod[First[index],10]===1,log[{"endpoint series term",First[index],Length[terms]}]];
 bounded[canonicalEndpoint[Refine[Normal[Series[canonicalEndpoint[term],{s23,0,0},Assumptions->ass&&s23>0]],ass&&s23>0]],{"endpoint series",First[index]}]],terms]];
 gate["all endpoint series evaluated",FreeQ[seriesTerms,_Series|_SeriesData|_Derivative|Indeterminate|_DirectedInfinity|_Real]];
 combined=canonicalEndpoint[Total[seriesTerms]];
 Put[<|"InputHash"->inputHash,"Input"->e,"Assumptions"->ass,"TermSeries"->seriesTerms,"CombinedSeries"->combined|>,seriesPath];
  log[{"normalize combined endpoint series",LeafCount[combined]}];
  normalized=bounded[normalize[combined,ass&&s23>0],"normalize endpoint series"];
  Put[<|"InputHash"->inputHash,"Input"->e,"Assumptions"->ass,"TermSeries"->seriesTerms,"CombinedSeries"->combined,"NormalizedSeries"->normalized|>,seriesPath];
  log[{"normalized endpoint series",LeafCount[normalized],FreeQ[normalized,s23]}];
  value=If[FreeQ[normalized,s23],normalized,bounded[canonicalEndpoint[Limit[Cancel[normalized],s23->0,Direction->"FromAbove",Assumptions->ass]],"combined finite endpoint"]];
 gate["sum of singular endpoint terms has a finite limit",FreeQ[value,_Limit|_ConditionalExpression|Indeterminate|_DirectedInfinity|_Real]];
 Put[<|"InputHash"->inputHash,"Input"->e,"Assumptions"->ass,"TermSeries"->seriesTerms,"CombinedSeries"->combined,"Limit"->value|>,
 FileNameJoin[{cache,"EndpointSeries_"<>IntegerString[Hash[e,"SHA256"],16,64]<>".wl"}]];
 value
];
endpoint[e_,ass_]:=Module[{v,terms,values},
 terms=If[Head[e]===Plus,List@@e,{e}];
 values=MapIndexed[Function[{term,index},
 v=Quiet[canonicalEndpoint[Refine[canonicalEndpoint[term/.s23->0],ass]],{Power::infy,Infinity::indet}];
 If[!FreeQ[v,Indeterminate|_DirectedInfinity],
 log[{"endpoint limit",First[index],Length[terms]}];
 v=bounded[canonicalEndpoint[Limit[Cancel[canonicalEndpoint[term]],s23->0,Direction->"FromAbove",Assumptions->ass]],"singular endpoint term"]];
 If[!FreeQ[v,$Failed|_Limit|_ConditionalExpression|Indeterminate|_DirectedInfinity|_Real],
 Put[<|"TermIndex"->First[index],"Term"->term,"Value"->v,"Assumptions"->ass|>,FileNameJoin[{cache,"EndpointFailure.wl"}]]];
 v],terms];
 If[!FreeQ[values,$Failed|_Limit|_ConditionalExpression|Indeterminate|_DirectedInfinity|_Real],Return[seriesEndpoint[e,ass]]];
 canonicalEndpoint[Total[values]]
];
distributionTask[task_]:=Module[{ch,mode,sign,dst,parent,manifest,production,reference,driver,soft,physical,common,
 scriptText,assembly,branchRule,norm,ownNorm,weights,raw,converted,p10,p20,projectorMatrix,rows=<||>,local,ref,diff,red,
 label,dir,path,hash,oldHash,oldHashes,all,radicals,radicalBase,map={},domain,reduced,output,coefficient,referenceInput,prior,priorInput,
 originalModel,originalManifest,flavor,chargeList,moments,flavorRules,flavorChecks},
 {ch,mode,sign}=task;dst=FileNameJoin[{root,ch}];parent=FileNameJoin[{scripts,ch}];
 label=mode<>"_"<>ToString[sign];dir=FileNameJoin[{dst,"s02_cache_"<>label}];
 If[!DirectoryQ[dir],CreateDirectory[dir]];
 hash=Hash[{FileHash[comparisonSource,"SHA256"],FileHash[FileNameJoin[{dst,"s01_inputs.json"}],"SHA256"]},"SHA256"];
 oldHash=Hash[{FileHash[previousSource,"SHA256"],FileHash[FileNameJoin[{dst,"s01_inputs.json"}],"SHA256"]},"SHA256"];
 oldHashes=Hash[{FileHash[#,"SHA256"],FileHash[FileNameJoin[{dst,"s01_inputs.json"}],"SHA256"]},"SHA256"]&/@previousSources;
 output=Block[{cache=dir,inputHash=hash,acceptedInputHashes=Prepend[oldHashes,hash]},Catch[
 log[{"distribution comparison start",task}];
 manifest=Import[FileNameJoin[{dst,"s01_inputs.json"}],"RawJSON"];
 gate["source identity",FileHash[FileNameJoin[{scripts,manifest["Production"]}],"SHA256","HexString"]===manifest["ProductionSHA256"]];
 production=Get[FileNameJoin[{scripts,manifest["Production"]}]];
 gate["independently accepted terminal result",production["RegulatorCancellationPassed"]===True&&production["AuthorsCoefficientsUsed"]===False];
 reference=Get[FileNameJoin[{dst,"s01_reconstructed.wl"}]]/.w->s23;
 driver=Get[FileNameJoin[{dst,"s01_driver.wl"}]];
 born=Get[FileNameJoin[{parent,"s02_result.wl"}]];finite=production["FiniteContractions"];
 scriptText=Import[FileNameJoin[{parent,"s10_final_hats.wl"}],"Text"];
 assembly=StringTake[scriptText,{First[First[StringPosition[scriptText,"projectors = born"]]],First[First[StringPosition[scriptText,"regularSeries["]]]-1}];
 ToExpression[assembly];
 gate["replayed current-channel finite projection equals saved F hats",hats===production["Hats"]];
 common={Q2->Q^2,SUNN->3,Nf->nf};
 ownNorm=eq^2 couplingSquare^2 hardNormalization;
 norm=Cancel[(Last[driver["factor"]]/lum)/(z jac/(xi zeta^2))/.zh->z/zeta]/.gs2->(First[driver["gs2"]]/.sourceAlphaS[_]->alphaS);
 projectorMatrix=Table[Coefficient[(symbol/.projectors),h],{symbol,{f1,f2}},{h,{hg,hpp}}]/.common;
 gate["driver projection equals current-channel projection",And@@Table[
 Together[projectorMatrix[[i]].{Fg,Fpp}-((First[driver[{"F1h","F2h"}[[i]]]]/.born["BornKinematics"])/.common)]===0,{i,2}]];
 branchRule=First[Solve[omega==(omega/.production["BranchCoordinates"][sign]),t]];
 physical=splitChains[production["PhysicalRegion"]/.common];
 soft=((physical/.{Greater[s23,0]->GreaterEqual[s23,0],Less[0,s23]->LessEqual[0,s23]})/.s23->0)/.branchRule;
 soft=soft&&Q>0&&omega>0&&Element[nf,Integers]&&nf>=1&&alphaS>0&&Element[{eq,otherChargeMoment[1],otherChargeMoment[2]},Reals];
 gate["nonempty soft domain",soft=!=False];
 physical=(physical/.branchRule)&&Q>0&&omega>0&&Element[nf,Integers]&&nf>=1&&alphaS>0&&Element[{eq,otherChargeMoment[1],otherChargeMoment[2]},Reals];
 weights=If[ch==="Hqq_v4",<|"A"->eq^2,"B"->0,"C"->otherChargeMoment[2]|>,<|"A"->eq^2|>];
 If[ch==="Hqq_v4",
 originalManifest=Import[FileNameJoin[{parent,"bigTMD_check","s01_result.json"}],"RawJSON"];
 gate["original charge model identity",originalManifest["ResultSHA256"]===FileHash[FileNameJoin[{parent,"bigTMD_check","s01_result.wl"}],"SHA256","HexString"]];
 originalModel=Get[FileNameJoin[{parent,"bigTMD_check","s01_result.wl"}]];
 flavorChecks=Table[
 flavor=originalModel["Flavors"][f];chargeList=Insert[flavor["OtherCharges"],flavor["Charge"],production["ObservedFlavor"]];
 moments=Map[Activate[#/.Nf->flavor["Nf"],Sum]/.flavorCharge[n_Integer]:>chargeList[[n]]&,production["OtherChargeMomentDefinitions"]];
 flavorRules=Join[{eq->flavor["Charge"]},KeyValueMap[otherChargeMoment[#1]->#2&,moments]];
 And@@Table[Together[(weights[c]/.flavorRules)-flavor["Weights"][c]]===0,{c,Keys[weights]}],{f,Keys[originalModel["Flavors"]]}];
 gate["formal charge decomposition reproduces every pinned driver flavor case",And@@flavorChecks]];
 raw=Association@Table[k->Total[Table[weights[c] reference[mode][c][k],{c,Keys[weights]}]],{k,{"regular","delta","plus1B","plus2B"}}]/.branchRule;
 p10=Total[Table[weights[c] bounded[endpoint[reference[mode][c]["plus1B"]/.branchRule,soft],{"plus1 endpoint",task,c}],{c,Keys[weights]}]];
 p20=Total[Table[weights[c] bounded[endpoint[reference[mode][c]["plus2B"]/.branchRule,soft],{"plus2 endpoint",task,c}],{c,Keys[weights]}]];
 deltaEnd=Total[Table[weights[c] bounded[endpoint[reference[mode][c]["delta"]/.branchRule,soft],{"delta endpoint",task,c}],{c,Keys[weights]}]];
 shift=FullSimplify[Log[s23]-Log[s23/B],B>0&&s23>0];
 converted=<|"Delta"->deltaEnd,"L0"->p10+shift p20,"L1"->p20,
 "Regular"->raw["regular"]+(raw["plus1B"]-p10)/s23+(raw["plus2B"]-p20)Log[s23]/s23|>;
 gate["ordinary distribution identity",Together[converted["Regular"]+converted["L0"]/s23+converted["L1"](Log[s23]-Log[B])/s23-
 raw["regular"]-raw["plus1B"]/s23-raw["plus2B"]Log[s23]/s23]===0];
 Put[<|"InputHash"->hash,"CanonicalReference"->converted,"ReferenceNormalization"->norm,"IndependentNormalization"->ownNorm,
 "ChargeWeights"->weights,"ProjectorMatrix"->projectorMatrix,"PhysicalDomain"->physical,"SoftDomain"->soft,
 "BranchRule"->branchRule,"ProjectionReplayedExactly"->True|>,FileNameJoin[{dst,"s02_"<>label<>"_canonical.wl"}]];
 Do[
 path=FileNameJoin[{dst,"s02_"<>label<>"_"<>component<>"_result.wl"}];
 local=ownNorm production["FiniteContractions"][mode][sign][component]/.common;
 ref=norm converted[component];diff=local-ref;domain=If[component==="Regular",physical,soft];map={};
 If[component==="Regular",
 radicals=DeleteDuplicates[Cases[diff,(Power[rad_,power_Rational]/;Denominator[power]===2&&!FreeQ[rad,s23]&&PolynomialQ[rad,s23]&&Exponent[rad,s23]===1):>rad,Infinity]];
 If[radicals=!={},radicalBase=First[SortBy[radicals,LeafCount]];
 gate["comparison radical positive on the physical branch",bounded[FullSimplify[radicalBase>0,domain],"positive radical"]===True];
 map=First[Solve[radius^2==radicalBase,s23]];
 gate["radical map reconstructs",Together[(radicalBase/.map)-radius^2]===0];
 domain=(domain/.map)&&radius>0]];
 priorInput=If[FileExistsQ[FileNameJoin[{dst,"s02_"<>label<>"_"<>component<>"_input.wl"}]],Get[FileNameJoin[{dst,"s02_"<>label<>"_"<>component<>"_input.wl"}]],<||>];
 prior=If[FileExistsQ[path],Get[path],<||>];
 If[AssociationQ[prior]&&TrueQ[prior["Completed"]]&&MemberQ[acceptedInputHashes,prior["InputHash"]]&&priorInput["Difference"]===diff&&prior["Assumptions"]===domain,
 AssociateTo[rows,component->prior];log[{"reused identical exact coefficient",task,component}];Continue[]];
 Put[<|"InputHash"->hash,"Difference"->diff,"Assumptions"->If[component==="Regular",physical,soft],"AlgebraicMap"->map|>,FileNameJoin[{dst,"s02_"<>label<>"_"<>component<>"_input.wl"}]];
 log[{"normalize distribution",task,component,LeafCount[diff]}];
 red=bounded[normalize[diff/.map,domain],{task,component}];
 Put[<|"InputHash"->hash,"Difference"->red,"Assumptions"->domain,"AlgebraicMap"->map|>,FileNameJoin[{dst,"s02_"<>label<>"_"<>component<>"_reduced.wl"}]];
 reduced=If[red===0,0,bounded[FullSimplify[red,domain],{task,component,"final identity"}]];
 coefficient=<|"InputHash"->hash,"Channel"->ch,"Tensor"->mode,"Branch"->sign,"Component"->component,
 "Difference"->reduced,"Equal"->TrueQ[reduced===0],"AlgebraicMap"->map,"Assumptions"->domain,
 "Completed"->True,"Direction"->"independent minus reconstructed BigTMD"|>;
 Put[coefficient,path];AssociateTo[rows,component->coefficient];
 log[{"distribution finished",task,component,coefficient["Equal"],LeafCount[reduced]}],
 {component,{"L1","L0","Delta","Regular"}}];
 <|"Task"->task,"InputHash"->hash,"Completed"->True,"Results"->rows|>,"stage"]];
 If[!AssociationQ[output]||!TrueQ[output["Completed"]],output=<|"Task"->task,"InputHash"->hash,"Completed"->False,"Failure"->output,"CompletedCoefficients"->rows|>];
 Put[output,FileNameJoin[{dst,"s02_"<>label<>"_result.wl"}]];log[{"distribution task finished",task,output["Completed"]}];output
];
tasks=Flatten[Table[{ch,m,sgn},{ch,{"Hgq_v4","Hqq_v4"}},{m,{"Pg","Ppp"}},{sgn,{1,-1}}],2];
selector=Environment["SIDIS_COMPARE_TASKS"];
If[StringQ[selector]&&StringLength[selector]>0,tasks=ImportString[selector,"RawJSON"]];
configuration=KernelConfiguration["localhost","KernelCommand"->"/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel","KernelCount"->Min[4,Length[tasks]],"TimeConstraint"->60];
LaunchKernels[configuration];If[Length[Kernels[]]===0,log["FAILED no workers"];Exit[1]];
ParallelEvaluate[$HistoryLength=0;$MaxExtraPrecision=2000];
DistributeDefinitions[root,scripts,comparisonSource,previousSource,previousSources,log,gate,bounded,dilogarithms,unitDilogarithm,reduceDilogarithm,reduceFunction,reduceAlgebraic,expandCoth,normalize,splitChains,canonicalEndpoint,seriesEndpoint,endpoint,distributionTask];
results=ParallelMap[distributionTask,tasks,Method->"FinestGrained"];
Put[results,FileNameJoin[{root,"s05_result.wl"}]];CloseKernels[];
log[{"S05_DISTRIBUTION_COMPARISONS_FINISHED",AllTrue[results,TrueQ[#["Completed"]]&]}];
Exit[If[AllTrue[results,TrueQ[#["Completed"]]&],0,1]];
