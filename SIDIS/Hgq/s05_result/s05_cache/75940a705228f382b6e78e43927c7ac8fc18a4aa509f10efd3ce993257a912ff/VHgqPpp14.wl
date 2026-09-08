<|"Coefficients" -> <|GLI["VHgqPpp14", {0, 1, 0, 0}] -> 
    ((I/2)*(-1 + SUNN)*(1 + SUNN)*(s + 2*t))/(SUNN*t), 
   GLI["VHgqPpp14", {1, 0, 0, 0}] -> ((-1/2*I)*(-Q2 + 3*s)*(-1 + SUNN)*
      (1 + SUNN))/(SUNN*t), GLI["VHgqPpp14", {1, 1, -1, 0}] -> 
    ((I/2)*(-1 + SUNN)*(1 + SUNN)*(-Q2 + 2*s - t))/(SUNN*t), 
   GLI["VHgqPpp14", {1, 1, 0, -1}] -> ((-1/2*I)*(-1 + SUNN)*(1 + SUNN))/SUNN, 
   GLI["VHgqPpp14", {1, 1, 0, 0}] -> ((I/2)*(-2*Q2 + 3*s)*(-1 + SUNN)*
      (1 + SUNN))/SUNN|>, "Topology" -> FCTopology["VHgqPpp14", 
   {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell + k1 - q, D], 0, 0, {1, 1}]], 
    FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell + p, D], 0, 
      0, {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell + q, D], 0, 0, {1, 1}]]}, {ell}, {p, q, k1}, {}, {}], 
 "Targets" -> {GLI["VHgqPpp14", {0, 1, 0, 0}], 
   GLI["VHgqPpp14", {1, 0, 0, 0}], GLI["VHgqPpp14", {1, 1, -1, 0}], 
   GLI["VHgqPpp14", {1, 1, 0, -1}], GLI["VHgqPpp14", {1, 1, 0, 0}]}, 
 "NumeratorRules" -> {Pair[Momentum[ell, D], Momentum[ell, D]] -> 
    GLI["VHgqPpp14", {-1, 0, 0, 0}], 
   Pair[Momentum[ell, D], Momentum[k1, D]] -> 
    (Q2 - t)/2 - GLI["VHgqPpp14", {-1, 0, 0, 0}] + 
     GLI["VHgqPpp14", {0, -1, 0, 0}]/2 + GLI["VHgqPpp14", {0, 0, 0, -1}]/2, 
   Pair[Momentum[ell, D], Momentum[p, D]] -> 
    -1/2*GLI["VHgqPpp14", {-1, 0, 0, 0}] + GLI["VHgqPpp14", {0, 0, -1, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[q, D]] -> 
    Q2/2 - GLI["VHgqPpp14", {-1, 0, 0, 0}]/2 + 
     GLI["VHgqPpp14", {0, 0, 0, -1}]/2}, "ScalarProducts" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]], Pair[Momentum[ell, D], 
    Momentum[k1, D]], Pair[Momentum[ell, D], Momentum[q, D]], 
   Pair[Momentum[ell, D], Momentum[p, D]]}, "ReconstructionPassed" -> True, 
 "InputHash" -> 5318216869545931721581447367381958202130882020399509584197426\
2384370639246079, "Mode" -> "Ppp", "Diagram" -> 14, 
 "ContractedIntegrand" -> 
  (9*((((4*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(SUNN*(Q2 + s + t)) + 
     (((4*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(Q2 + s + t)) - 
     (((4*I)/9)*Q2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(Q2 + s + t) - 
     (((4*I)/9)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(Q2 + s + t) + 
     (((4*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(Q2 + s + t)) - 
     (((4*I)/9)*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(Q2 + s + t) + 
     (((8*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*t) - 
     (((8*I)/9)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/t - 
     (((4*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(Q2 + s + t)) + 
     (((4*I)/9)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(Q2 + s + t) - 
     (((4*I)/9)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(SUNN*t*(Q2 + s + t)) - 
     (((4*I)/9)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(SUNN*t*(Q2 + s + t)) + 
     (((4*I)/9)*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(t*(Q2 + s + t)) + 
     (((4*I)/9)*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(t*(Q2 + s + t)) - 
     (((16*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*t) + (((16*I)/9)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t + 
     (((8*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(Q2 + s + t)) + (((8*I)/9)*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell + p, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(SUNN*(Q2 + s + t)) - 
     (((8*I)/9)*Q2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (Q2 + s + t) - (((8*I)/9)*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell + p, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(Q2 + s + t) + 
     (((4*I)/9)*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*t*(Q2 + s + t)) + (((8*I)/9)*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell + p, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(SUNN*t*(Q2 + s + t)) + 
     (((4*I)/9)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*t*(Q2 + s + t)) - (((4*I)/9)*Q2^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell + p, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(t*(Q2 + s + t)) - 
     (((8*I)/9)*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (t*(Q2 + s + t)) - (((4*I)/9)*s^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell + p, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(t*(Q2 + s + t)) + 
     (((4*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(Q2 + s + t)) - (((4*I)/9)*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell + p, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(Q2 + s + t)))/4|>
