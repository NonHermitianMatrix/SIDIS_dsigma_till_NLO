(* Compare complete own rational maps through their derived loop polynomial. *)
$HistoryLength=0;
polynomialEqualitySource=FileNameJoin[{Directory[],"common","s08_check_Hqg_polynomial_equality.wls"}];
polynomialEqualityParent=FileNameJoin[{Directory[],"common","s08_check_Hqg_grouped_mapping.wls"}];
If[IntegerString[FileHash[polynomialEqualityParent,"SHA256"],16,64]=!=
 "186ba59d98cdc9c5ad8c4c107243085cdd3537f1a4325b63d54be1ddc76dba12"||
 !SyntaxQ[Import[polynomialEqualitySource,"Text"]],Quit[1]];
polynomialEqualityText=Import[polynomialEqualityParent,"Text"];
polynomialEqualityBoundary=StringPosition[polynomialEqualityText,"\n{ownSeconds,ownCoefficients}="];
If[Length[polynomialEqualityBoundary]=!=1,Quit[1]];
polynomialEqualityPrefix=StringTake[polynomialEqualityText,First[First[polynomialEqualityBoundary]]-1];
If[!SyntaxQ[polynomialEqualityPrefix],Quit[1]];ToExpression[polynomialEqualityPrefix,InputForm];

completePolynomialEquality[left_,right_] := Module[{keys,coefficients,powerRows,commonPowers,commonDenominator,
 positions,familyDenominators,exponents,powers,kernel,cleared,rows,reconstruction,polynomialRows,packets={},
 count=0,residuals=<||>,seconds,residual,formal,formalReconstruction},
 keys=Union[Keys[left],Keys[right]];
 coefficients=Association@Table[key->(Lookup[left,key,0]-Lookup[right,key,0]),{key,keys}];
 gate["complete own comparison integral inventory",Keys[coefficients]===keys&&AssociationQ[left]&&AssociationQ[right]];
 gate["all map coefficients independent of loop coordinates",FreeQ[Values[coefficients],a|b]];
 powerRows=Association@Table[
   familyDenominators=families[key[[1]]]["OnCutUncutPropagators"];
   exponents=Drop[key[[2]],Length[geometry["CutMomenta"]]];
   gate["own mapped cuts and complete family powers",Take[key[[2]],Length[geometry["CutMomenta"]]]===
     ConstantArray[1,Length[geometry["CutMomenta"]]]&&Length[exponents]===Length[familyDenominators]&&VectorQ[exponents,IntegerQ]];
   positions=Table[SelectFirst[Range[Length[denominators]],denominators[[#]]===propagator&,Missing["Propagator"]],
     {propagator,familyDenominators}];
   gate["every actual family propagator is the identical common propagator",FreeQ[positions,_Missing]];
   powers=ConstantArray[0,Length[denominators]];
   MapThread[(powers[[#1]]+=#2)&,{positions,exponents}];
   kernel=Times@@MapThread[Power,{familyDenominators,-exponents}];
   gate["every complete own integral kernel reconstructed",bounded[
     zero[kernel-Times@@MapThread[Power,{denominators,-powers}]],"own integral kernel identity"]];
   key->powers,{key,keys}];
 commonPowers=Max/@Transpose[Prepend[Values[powerRows],ConstantArray[0,Length[denominators]]]];
 commonDenominator=Times@@MapThread[Power,{denominators,commonPowers}];
 gate["derived common denominator is a nonzero loop polynomial",commonDenominator=!=0&&PolynomialQ[commonDenominator,{a,b}]];
 Do[
   powers=commonPowers-powerRows[key];
   gate["cleared own kernel has nonnegative integer powers",VectorQ[powers,IntegerQ[#]&&#>=0&]];
   cleared=Times@@MapThread[Power,{denominators,powers}];
   gate["exact common-denominator clearing of own kernel",bounded[
     zero[cleared/commonDenominator-Times@@MapThread[Power,{denominators,-powerRows[key]}]],"own denominator clearing"]];
   rows=CoefficientRules[Expand[cleared],{a,b}];
   reconstruction=Total[Map[(Last[#] Times@@MapThread[Power,{{a,b},First[#]}])&,rows]];
   gate["every complete cleared kernel polynomial reconstructs",Expand[cleared-reconstruction]===0&&FreeQ[Last/@rows,a|b]];
   AppendTo[packets,Association[Map[First[#]->coefficients[key]Last[#]&,rows]]],{key,keys}];
 polynomialRows=Merge[packets,Total];
 formal=Table[Unique["ownMapCoefficient"],{Length[keys]}];
 formalReconstruction=Total[MapThread[#1 Times@@MapThread[Power,{denominators,commonPowers-#2}]&,{formal,Values[powerRows]}]];
 gate["all own map terms retained by polynomial collection",Length[packets]===Length[keys]&&
   Expand[formalReconstruction-Total[MapThread[#1 Sum[Last[row] Times@@MapThread[Power,{{a,b},First[row]}],
      {row,CoefficientRules[Expand[Times@@MapThread[Power,{denominators,commonPowers-#2}]],{a,b}]}]&,
     {formal,Values[powerRows]}]]]===0];
 Print["OWN_POLYNOMIAL_INPUT ",InputForm[<|"MapTerms"->Length[keys],"CommonPowers"->commonPowers,
   "PolynomialCoefficients"->Length[polynomialRows],"CoefficientBytes"->ByteCount[polynomialRows]|>]];
 KeyValueMap[Function[{monomial,coefficient},
   count++;Print["OWN_POLYNOMIAL_COEFFICIENT ",count,"/",Length[polynomialRows]," ",monomial];
   {seconds,residual}=AbsoluteTiming[If[coefficient===0,0,bounded[Factor[Together[coefficient]],
      {"own full map polynomial coefficient",monomial}]]];
   AssociateTo[residuals,monomial->residual];
   gate["own complete map polynomial coefficient zero "<>ToString[monomial,InputForm],residual===0];
   Print["OWN_POLYNOMIAL_COEFFICIENT_SECONDS ",seconds]],polynomialRows];
 polynomialEqualityEvidence=<|"CommonDenominator"->commonDenominator,"CommonPowers"->commonPowers,
   "IntegralPowers"->powerRows,"CoefficientCount"->Length[polynomialRows],"ExactResiduals"->residuals,
   "AllOwnCoefficientsCompared"->True|>;
 And@@(#===0&/@Values[residuals])];

polynomialEqualityTail=StringDrop[polynomialEqualityText,First[First[polynomialEqualityBoundary]]-1];
polynomialEqualityEdits={
 "zero[pairReconstruct[ownCoefficients]-pairReconstruct[ownControl[\"Coefficients\"]]]"->
   "completePolynomialEquality[ownCoefficients,ownControl[\"Coefficients\"]]",
 "\"Checks\"->checks,\"FiniteNLOFHatsComputed\"->False|>;"->
   "\"Checks\"->checks,\"PolynomialComparison\"->polynomialEqualityEvidence,\"ComparisonDispatchHash\"->FileHash[polynomialEqualitySource,\"SHA256\"],\"EqualityDefinitions\"->DownValues[completePolynomialEquality],\"FiniteNLOFHatsComputed\"->False|>;",
 "\"s08_grouped_comparison_result\""->"\"s08_polynomial_comparison_result\""
};
gate["unique own polynomial comparison edits",And@@(StringCount[polynomialEqualityTail,First[#]]===1&/@polynomialEqualityEdits)];
polynomialEqualityRun=StringReplace[polynomialEqualityTail,polynomialEqualityEdits];
gate["all own mapping equations and acceptance gates retained",SyntaxQ[polynomialEqualityRun]&&
 StringReplace[polynomialEqualityRun,Reverse/@polynomialEqualityEdits]===polynomialEqualityTail];
polynomialEqualityEvidence=<|"IdenticalCompleteMaps"->True|>;
ToExpression[polynomialEqualityRun,InputForm];
