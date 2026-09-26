<|"Task" -> <|"Sector" -> "Real", "Kind" -> "PhotonMetricD", "Index" -> {}|>, 
 "RejectedTerm" -> {}, "Numerator" -> {}, "Denominator" -> {}, 
 "NonPolynomialPowers" -> {}, "Variables" -> {a, b}, 
 "Denominators" -> {a, -a - s23 + t, b, -b + s - s23, -a - b - Q^2 - s23, 
   a + b - Q^2 - s + s23 - t}, "OriginalExtractionDefinitions" -> 
  {HoldPattern[extractAtoms[expression_]] :> 
    Module[{rational, factors, powers, found, ratio, prefactor}, 
     rational = Together[expression]; factors = 
       Rest[FactorList[Denominator[rational]]]; 
      powers = ConstantArray[0, Length[denominators]]; 
      Do[If[ !FreeQ[factor[[1]], a | b], 
        found = SelectFirst[Range[Length[denominators]], Function[index, 
            ratio = Cancel[factor[[1]]/denominators[[index]]]; 
             ratio =!= 0 && FreeQ[ratio, a | b]], 
           Missing["UnknownPropagator"]]; If[MissingQ[found], 
          Print["UNKNOWN_PROPAGATOR ", InputForm[factor[[1]]]]]; 
         gate["every loop-dependent factor is a generated propagator", 
           !MissingQ[found]]; powers[[found]] += factor[[2]]], 
       {factor, factors}]; prefactor = 
       Cancel[rational*Times @@ MapThread[Power, {denominators, powers}]]; 
      gate["atom extraction leaves a polynomial numerator", 
       FreeQ[Denominator[Together[prefactor]], a | b]]; 
      {powers, prefactor}]}, "FactoredExtractionDefinitions" -> 
  {HoldPattern[factoredAtoms[expression_]] :> 
    Module[{numerator, denominator, factors, powers, found, ratio, product, 
      scale, prefactor}, numerator = Numerator[expression]; 
      denominator = Denominator[expression]; 
      gate["original explicit rational input reconstructs", 
       numerator/denominator === expression]; 
      gate["explicit numerator is a loop polynomial", PolynomialQ[numerator, 
        atomVariables]]; gate["explicit denominator is a loop polynomial", 
       PolynomialQ[denominator, atomVariables]]; 
      factors = Rest[FactorList[denominator]]; 
      powers = ConstantArray[0, Length[denominators]]; 
      Do[If[ !FreeQ[factor[[1]], Alternatives @@ atomVariables], 
        found = SelectFirst[Range[Length[denominators]], Function[index, 
            ratio = Cancel[factor[[1]]/denominators[[index]]]; 
             ratio =!= 0 && FreeQ[ratio, Alternatives @@ atomVariables]], 
           Missing["UnknownPropagator"]]; 
         gate["every loop-dependent factor is a generated propagator", 
           !MissingQ[found]]; powers[[found]] += factor[[2]]], 
       {factor, factors}]; product = Times @@ MapThread[Power, 
         {denominators, powers}]; scale = Cancel[product/denominator]; 
      gate["denominator ratio is loop independent", 
       FreeQ[scale, Alternatives @@ atomVariables]]; 
      gate["complete denominator scale reconstructs", 
       zero[scale*denominator - product]]; prefactor = scale*numerator; 
      gate["atom extraction leaves a polynomial numerator", 
       PolynomialQ[prefactor, atomVariables]]; {powers, prefactor}]}|>
