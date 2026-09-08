<|"Coefficients" -> <|GLI["VHgqPpp15", {0, 1, 0, 0}] -> 
    ((I/2)*(-1 + SUNN)*(1 + SUNN)*(2*Q2 + s + 2*t))/(SUNN*(Q2 + s + t)), 
   GLI["VHgqPpp15", {1, 0, 0, 0}] -> ((-1/2*I)*(Q2 + s)*(-1 + SUNN)*
      (1 + SUNN))/(SUNN*(Q2 + s + t)), GLI["VHgqPpp15", {1, 1, -1, 0}] -> 
    ((I/2)*(-1 + SUNN)*(1 + SUNN)*(s - t))/(SUNN*(Q2 + s + t)), 
   GLI["VHgqPpp15", {1, 1, 0, -1}] -> ((-1/2*I)*(-1 + SUNN)*(1 + SUNN))/SUNN, 
   GLI["VHgqPpp15", {1, 1, 0, 0}] -> ((-1/2*I)*(2*Q2 + s)*(-1 + SUNN)*
      (1 + SUNN))/SUNN|>, "Topology" -> FCTopology["VHgqPpp15", 
   {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell - k1 + p, D], 0, 0, {1, 1}]], 
    FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell + p, D], 0, 
      0, {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell + q, D], 0, 0, {1, 1}]]}, {ell}, {p, q, k1}, {}, {}], 
 "Targets" -> {GLI["VHgqPpp15", {0, 1, 0, 0}], 
   GLI["VHgqPpp15", {1, 0, 0, 0}], GLI["VHgqPpp15", {1, 1, -1, 0}], 
   GLI["VHgqPpp15", {1, 1, 0, -1}], GLI["VHgqPpp15", {1, 1, 0, 0}]}, 
 "NumeratorRules" -> {Pair[Momentum[ell, D], Momentum[ell, D]] -> 
    GLI["VHgqPpp15", {-1, 0, 0, 0}], 
   Pair[Momentum[ell, D], Momentum[k1, D]] -> (-Q2 - s - t)/2 - 
     GLI["VHgqPpp15", {0, -1, 0, 0}]/2 + GLI["VHgqPpp15", {0, 0, -1, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[p, D]] -> 
    -1/2*GLI["VHgqPpp15", {-1, 0, 0, 0}] + GLI["VHgqPpp15", {0, 0, -1, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[q, D]] -> 
    Q2/2 - GLI["VHgqPpp15", {-1, 0, 0, 0}]/2 + 
     GLI["VHgqPpp15", {0, 0, 0, -1}]/2}, "ScalarProducts" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]], Pair[Momentum[ell, D], 
    Momentum[k1, D]], Pair[Momentum[ell, D], Momentum[p, D]], 
   Pair[Momentum[ell, D], Momentum[q, D]]}, "ReconstructionPassed" -> True, 
 "InputHash" -> 5318216869545931721581447367381958202130882020399509584197426\
2384370639246079, "Mode" -> "Ppp", "Diagram" -> 15, 
 "ContractedIntegrand" -> 
  (9*((((4*I)/9)*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^2) + 
     (((4*I)/9)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^2) - 
     (((4*I)/9)*Q2*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((4*I)/9)*s*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((4*I)/9)*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^2) - 
     (((4*I)/9)*SUNN*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((4*I)/9)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2) - 
     (((4*I)/9)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2) + 
     (((4*I)/9)*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((4*I)/9)*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((4*I)/9)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2) + 
     (((4*I)/9)*s*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((4*I)/9)*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2) + (((8*I)/9)*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2) + (((4*I)/9)*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2) - (((4*I)/9)*Q2^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((8*I)/9)*Q2*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((4*I)/9)*s^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((8*I)/9)*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2) + (((8*I)/9)*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2) - (((8*I)/9)*Q2*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((8*I)/9)*s*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((4*I)/9)*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2) - (((4*I)/9)*SUNN*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2))/4|>
