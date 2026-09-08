(* Inspect frozen numerical-consumer interfaces without changing coefficients. *)
$HistoryLength = 0;
$LoadAddOns = {};
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root = DirectoryName[$InputFileName];
manifest = Import[FileNameJoin[{root, "s01_result"}], "RawJSON"];
cache = FileNameJoin[{root, "s03_cache"}];
If[!DirectoryQ[cache], CreateDirectory[cache]];
sourceHash = IntegerString[FileHash[$InputFileName, "SHA256"], 16, 64];
require[b_,msg_] := If[!TrueQ[b],Print["S03_FATAL ",msg];Quit[1]];
(* Prove homogeneity by traversing only variable-containing factors.
   Exponent would expand the unrelated large kinematic coefficients. *)
ClearAll[homogeneousDegree];
homogeneousDegree[e_, variable_] := Module[{degrees},
  If[FreeQ[e, variable], Return[0]];
  If[e === variable, Return[1]];
  Which[
    Head[e] === Times,
      Total[homogeneousDegree[#, variable]& /@ (List@@e)],
    Head[e] === Plus,
      degrees=DeleteDuplicates[homogeneousDegree[#, variable]& /@ (List@@e)];
      require[Length[degrees]===1,"inhomogeneous coupling sum"];First[degrees],
    Head[e] === Power && IntegerQ[e[[2]]],
      e[[2]] homogeneousDegree[e[[1]], variable],
    True, require[False,"unsupported coupling-containing head"]; $Failed]
];
boundedDegree[e_,variable_] := Module[{degree},
  degree=TimeConstrained[homogeneousDegree[e,variable],30,$Failed];
  require[IntegerQ[degree],"bounded structural coupling proof"];degree];
previousPath=FileNameJoin[{root,"previous_Hgq_v3","s03_result"}];
previous=If[FileExistsQ[previousPath],Import[previousPath,"RawJSON"],<||>];
keyText[k_] := If[StringQ[k], k, ToString[k, InputForm]];
ClearAll[describe, scalar];
scalar[e_] := Module[{n, syms, custom, small},
  n = LeafCount[e];
  syms = DeleteDuplicates[Cases[e,
    s_Symbol /; Context[s] =!= "System`" :> ToString[s, InputForm],
    Infinity, Heads -> True]];
  custom = DeleteDuplicates[Cases[e,
    x_ /; (!AtomQ[x] && !MemberQ[{Plus, Times, Power, List, Association,
      Rule, RuleDelayed, Log, PolyLog, Rational, Complex, Sqrt}, Head[x]]) :>
      ToString[Head[x], InputForm], Infinity]];
  small = If[n < 160, ToString[e, InputForm], "omitted: large expression"];
  <|"Head" -> ToString[Head[e], InputForm], "LeafCount" -> n,
    "Symbols" -> Sort[syms], "AdditionalHeads" -> Sort[custom],
    "SmallExpression" -> small|>
];
describe[e_Association, depth_:0] := Association@KeyValueMap[
  (keyText[#1] -> If[depth < 3, describe[#2, depth + 1], scalar[#2]]) &, e];
describe[e_, depth_:0] := scalar[e];
results = <||>;
Do[
  channel = entry["channel"];
  Print["S03_CHANNEL_START ", channel];
  files = Select[entry["files"], #["role"] === "terminal_fhat_payload" &];
  output = FileNameJoin[{cache, channel <> ".json"}];
  If[KeyExistsQ[entry,"snapshot_reused_from"] && KeyExistsQ[Lookup[previous,"Channels",<||>],channel],
    record=previous["Channels"][channel];
    require[And@@Table[record["Files"][file["copy"]]["SHA256"]===file["sha256"],{file,files}],"reused schema input hashes"];
    AssociateTo[record,"ReusedFrom"-><|"Path"->"previous_Hgq_v3/s03_result",
      "SHA256"->FileHash[previousPath,"SHA256","HexString"]|>];
    Export[output,record,"RawJSON"];AssociateTo[results,channel->record];
    Print["S03_CHANNEL_REUSED ",channel];Continue[]];
  record = <|"Channel" -> channel, "SourceHash" -> sourceHash, "Files" -> <||>|>;
  Do[
    path = FileNameJoin[{root, file["copy"]}];
    actual = IntegerString[FileHash[path, "SHA256"], 16, 64];
    If[actual =!= file["sha256"], Print["S03_FATAL hash ", path]; Quit[1]];
    Print["S03_LOAD ", file["copy"]];
    value = Get[path];
    Print["S03_LOADED ",file["copy"]," memory=",MemoryInUse[]];
    If[value === $Failed, Print["S03_FATAL Get ", path]; Quit[1]];
    If[MemberQ[{"Hqq_v4","Hgq_v4","Hqg_v3"},channel],
      stage=If[channel==="Hqg_v3","s12","s10"];
      poles=Get[FileNameJoin[{root,"Fhats",channel,stage<>"_poles.wl"}]];
      sourcePath=FileNameJoin[{root,"Fhats",channel,stage<>"_final_hats.wl"}];
      checks=<|"source_hash"->If[channel==="Hqg_v3",value["InputHash"]===Hash[{FileHash[sourcePath,"SHA256"],value["InputHashes"]},"SHA256"],value["SourceHash"]===FileHash[sourcePath,"SHA256"]],
        "regulator_cancellation"->TrueQ[value["RegulatorCancellationPassed"]],
        "pole_acceptance"->TrueQ[poles["Accepted"]],
        "pole_input_identity"->(poles["InputHash"]===value["InputHash"]),
        "all_pole_residues_zero"->And@@(#===0&/@Flatten[Values/@Values[poles["PoleResidues"]]])|>;
      require[And@@Values[checks],"current frozen acceptance contract "<>ToString[checks,InputForm]];
      Print["S03_V4_ACCEPTANCE_PASSED"];
      plusObjects=DeleteDuplicates@Cases[Values[value["StructureFunctions"]],
        x_/;(!AtomQ[x] && SymbolName[Head[x]]==="PlusDistribution"):>x,Infinity];
      logArguments=DeleteDuplicates@Flatten[Cases[First[#],Log[a_]:>a,Infinity]&/@plusObjects];
      require[Length[logArguments]===1 && Length[plusObjects]>0,"v4 plus logarithm identity"];
      logarithmicPlus=SelectFirst[plusObjects,!FreeQ[First[#],Log]&];
      normalized=Together[First[logArguments]/(logarithmicPlus[[2,1]]/logarithmicPlus[[2,3]])]===1;
      require[normalized && logarithmicPlus[[2,2]]===0,"v4 normalized bounded plus definition"];
      Print["S03_V4_PLUS_PASSED ",InputForm[logArguments]];
      loExpressions=value["Hats"][#]["LODelta"]&/@Keys[value["Hats"]];
      nloExpressions=Flatten[Table[Values[value["Hats"][hat]["NLO"][branch]],
        {hat,Keys[value["Hats"]]},{branch,Keys[value["BranchCoordinates"]]}]];
      nonzero=Select[Join[loExpressions,nloExpressions],#=!=0&];
      chargeDegrees=If[channel==="Hqq_v4",{},DeleteDuplicates[boundedDegree[#,eq]&/@nonzero]];
      Print["S03_V4_CHARGE_DEGREES ",InputForm[chargeDegrees]];
      loDegrees=DeleteDuplicates[boundedDegree[#,alphaS]&/@Select[loExpressions,#=!=0&]];
      Print["S03_V4_LO_DEGREES ",InputForm[loDegrees]];
      nloDegrees=DeleteDuplicates[boundedDegree[#,alphaS]&/@Select[nloExpressions,#=!=0&]];
      require[(channel==="Hqq_v4" || Length[chargeDegrees]===1) && Length[loDegrees]===1 && Length[nloDegrees]===1,"v4 coupling coverage"];
      consumer=<|"Status"->"Complete","InputSHA256"->actual,"Checks"->checks,
        "PlusDefinition"->ToString[value["PlusDefinition"],InputForm],
        "PlusLogArgument"->StringReplace[ToString[First[logArguments]/.s23->ss,InputForm],"^"->"**"],
        "NormalizedPlusLogarithm"->normalized,
        "BranchCoordinates"->ToString[value["BranchCoordinates"],InputForm],
        "BranchDomains"->ToString[value["BranchDomains"],InputForm],
        "CoordinateBoundaryPresent"->KeyExistsQ[value,"BoundaryAtTEqualsMinusS"],
        "ChargeDegree"->If[chargeDegrees==={},Null,First[chargeDegrees]],"LOAlphaDegree"->First[loDegrees],"NLOAlphaDegree"->First[nloDegrees]|>;
      
      If[channel==="Hqq_v4",
        allHats=Join[nonzero,Flatten[Values/@Values[value["BoundaryAtTEqualsMinusS"]]]];
        flavorChecks=<|"odd_moment_absent"->FreeQ[allHats,otherChargeMoment[1]],
          "charge_conjugation"->((allHats/.eq->-eq)===allHats),
          "flavor_count_reduction"->(value["FlavorCountReduction"]["Counterexample"]===False)|>;
        require[And@@Values[flavorChecks],"Hqq current flavor contract"];
        momentRows=Association@Table[ToString[n]->Table[
          chargeSymbols=Table[Symbol["charge"<>ToString[k]],{k,n}];
          ordered=Prepend[Delete[chargeSymbols,j],chargeSymbols[[j]]];
          Clear[flavorCharge];flavorCharge[k_Integer]:=ordered[[k]];
          moments=Map[Expand[Activate[#/.Nf->n]]&,value["OtherChargeMomentDefinitions"]];
          require[FreeQ[moments,_Sum|_Inactive|_KroneckerDelta|flavorCharge],"evaluated defining moments"];
          <|"ObservedIndex"->(j-1),"Moments"->Association@KeyValueMap[
            ToString[#1]->StringReplace[ToString[#2,InputForm],"^"->"**"]&,moments]|>,{j,n}],{n,{4,5}}];
        Clear[flavorCharge];
        AssociateTo[consumer,{"Checks"->Join[checks,flavorChecks],
          "FlavorMomentDefinitions"->ToString[value["OtherChargeMomentDefinitions"],InputForm],
          "FlavorDomain"->ToString[value["FlavorDomain"],InputForm],"FlavorMoments"->momentRows}]];
      AssociateTo[consumer,{"JacobianAlreadyIncluded"->False,
        "PartonicVariableGate"->FreeQ[value["Hats"],zH|PHT2|xi|xB|zeta]}];
      require[consumer["PartonicVariableGate"],"partonic variables"];
      Export[FileNameJoin[{cache,channel<>"_consumer_contract"}],consumer,"RawJSON"];
      Print["S03_V4_CONSUMER ",InputForm[consumer]]];

    If[MemberQ[{"Hgg_v2","Hqqbar_v2","Hqqprime_v2"},channel],
      expressions=Values[value["Fhats"]];
      poles=Get[FileNameJoin[{root,"Fhats",channel,"s05_result","pole_residues.wl"}]];
      checks=<|"pole_residues_zero"->(Values[value["pole_residues"]]==={0,0} && poles===value["pole_residues"]),
        "regular_only"->(value["delta"]==={0,0} && value["plus"]==={0,0}),
        "positive_rho_branch"->(value["rho_branch"]==="positive"),
        "partonic_variables"->FreeQ[expressions,zH|PHT2|xi|xB|zeta],
        "finite_coefficients"->FreeQ[expressions,eps|_Integrate|_SeriesData|Indeterminate|ComplexInfinity]|>;
      require[And@@Values[checks],"current regular-only contract"];
      alphaDegrees=DeleteDuplicates[boundedDegree[#,alphaS]&/@expressions];
      require[Length[alphaDegrees]===1,"regular-only alpha degree"];
      consumer=<|"Status"->"Complete","Channel"->channel,"InputSHA256"->actual,"Checks"->checks,
        "JacobianAlreadyIncluded"->False,"NLOAlphaDegree"->First[alphaDegrees],
        "RhoSquared"->ToString[value["rho_squared"],InputForm],
        "HatVariableRules"->ToString[value["hat_variable_rules"],InputForm]|>;
      If[channel==="Hqqprime_v2",
        AssociateTo[consumer,"ChargeMonomials"->Map[StringReplace[ToString[#,InputForm],"^"->"**"]&,value["charge_monomials"]]],
        variable=If[channel==="Hgg_v2",chargeSum,eq2];
        chargeDegrees=DeleteDuplicates[boundedDegree[#,variable]&/@expressions];
        require[Length[chargeDegrees]===1,"charge parameter degree"];
        AssociateTo[consumer,{"ChargeParameter"->ToString[variable,InputForm],"ChargeParameterDegree"->First[chargeDegrees]}]];
      Export[FileNameJoin[{cache,channel<>"_consumer_contract"}],consumer,"RawJSON"]];
    AssociateTo[record["Files"], file["copy"] -> <|"SHA256" -> actual,
      "Schema" -> describe[value]|>];
    Print["S03_INSPECTED ", file["copy"], " memory=", MemoryInUse[]];
    Clear[value]; ClearSystemCache[],
    {file, files}];
  Export[output, record, "RawJSON"];
  AssociateTo[results, channel -> record];
  Clear[record]; ClearSystemCache[];
  Print["S03_CHANNEL_DONE ", channel],
  {entry, manifest["channels"]}];
Export[FileNameJoin[{root, "s03_result"}],
  <|"Stage" -> "s03", "Status" -> "Complete", "SourceHash" -> sourceHash,
    "Runtime" -> $Version, "Channels" -> results|>, "RawJSON"];
Print["S03_SUCCESS"];
Quit[0];
