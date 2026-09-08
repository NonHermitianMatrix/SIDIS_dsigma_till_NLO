<|"Coefficients" -> <|GLI["VHgqPpp02", {-1, 1, 1, 0}] -> ((-I)*Q2*SUNN)/t, 
   GLI["VHgqPpp02", {0, 0, 1, 0}] -> ((-I)*SUNN*(s - t))/t, 
   GLI["VHgqPpp02", {0, 1, 0, 0}] -> (I*(2*Q2 + s)*SUNN)/t, 
   GLI["VHgqPpp02", {0, 1, 1, -1}] -> (-I)*SUNN, 
   GLI["VHgqPpp02", {0, 1, 1, 0}] -> ((-1/2*I)*(-3*Q2 + 2*D*Q2 - 2*s)*SUNN)/
     (-2 + D), GLI["VHgqPpp02", {1, 0, 0, 0}] -> (I*SUNN*(s - t))/t, 
   GLI["VHgqPpp02", {1, 0, 1, 0}] -> ((-1/2*I)*SUNN*(3*s - t))/(-2 + D), 
   GLI["VHgqPpp02", {1, 1, -1, 0}] -> ((-I)*(Q2 + s)*SUNN)/t, 
   GLI["VHgqPpp02", {1, 1, 0, -1}] -> I*SUNN, 
   GLI["VHgqPpp02", {1, 1, 0, 0}] -> ((I/2)*(-3*Q2 + 2*D*Q2 - 7*s)*SUNN)/
     (-2 + D), GLI["VHgqPpp02", {1, 1, 1, -1}] -> ((-1/2*I)*SUNN*t)/(-2 + D), 
   GLI["VHgqPpp02", {1, 1, 1, 0}] -> ((I/2)*(-Q2 + 4*s)*SUNN*t)/(-2 + D)|>, 
 "Topology" -> FCTopology["VHgqPpp02", 
   {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell - p, D], 0, 0, {1, 1}]], FeynAmpDenominator[
     StandardPropagatorDenominator[Momentum[ell + k1 - p - q, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell + q, D], 0, 0, {1, 1}]]}, {ell}, {p, q, k1}, {}, {}], 
 "Targets" -> {GLI["VHgqPpp02", {-1, 1, 1, 0}], 
   GLI["VHgqPpp02", {0, 0, 1, 0}], GLI["VHgqPpp02", {0, 1, 0, 0}], 
   GLI["VHgqPpp02", {0, 1, 1, -1}], GLI["VHgqPpp02", {0, 1, 1, 0}], 
   GLI["VHgqPpp02", {1, 0, 0, 0}], GLI["VHgqPpp02", {1, 0, 1, 0}], 
   GLI["VHgqPpp02", {1, 1, -1, 0}], GLI["VHgqPpp02", {1, 1, 0, -1}], 
   GLI["VHgqPpp02", {1, 1, 0, 0}], GLI["VHgqPpp02", {1, 1, 1, -1}], 
   GLI["VHgqPpp02", {1, 1, 1, 0}]}, "NumeratorRules" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]] -> GLI["VHgqPpp02", 
     {-1, 0, 0, 0}], Pair[Momentum[ell, D], Momentum[k1, D]] -> 
    Q2/2 - GLI["VHgqPpp02", {-1, 0, 0, 0}]/2 - 
     GLI["VHgqPpp02", {0, -1, 0, 0}]/2 + GLI["VHgqPpp02", {0, 0, -1, 0}]/2 + 
     GLI["VHgqPpp02", {0, 0, 0, -1}]/2, 
   Pair[Momentum[ell, D], Momentum[p, D]] -> 
    GLI["VHgqPpp02", {-1, 0, 0, 0}]/2 - GLI["VHgqPpp02", {0, -1, 0, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[q, D]] -> 
    Q2/2 - GLI["VHgqPpp02", {-1, 0, 0, 0}]/2 + 
     GLI["VHgqPpp02", {0, 0, 0, -1}]/2}, "ScalarProducts" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]], Pair[Momentum[ell, D], 
    Momentum[p, D]], Pair[Momentum[ell, D], Momentum[k1, D]], 
   Pair[Momentum[ell, D], Momentum[q, D]]}, "ReconstructionPassed" -> True, 
 "InputHash" -> 5318216869545931721581447367381958202130882020399509584197426\
2384370639246079, "Mode" -> "Ppp", "Diagram" -> 2, 
 "ContractedIntegrand" -> 
  (9*((((-8*I)/9)*s*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]])/(2 - D) + 
     (((16*I)/9)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(2 - D) + 
     (((4*I)/9)*Q2*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*(Q2 + s + t)) + 
     (((4*I)/9)*s*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*(Q2 + s + t)) + 
     (((4*I)/9)*SUNN*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*(Q2 + s + t)) - 
     (((8*I)/3)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(2 - D) + 
     (((4*I)/3)*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*(Q2 + s + t)) + 
     (((4*I)/3)*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*(Q2 + s + t)) + 
     (((4*I)/3)*s*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*(Q2 + s + t)) + 
     (((16*I)/9)*Q2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(2 - D) - 
     (((16*I)/9)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(2 - D) + 
     (((16*I)/9)*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(2 - D) - 
     (((4*I)/3)*Q2^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) - (((8*I)/3)*Q2*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) - (((4*I)/3)*s^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) - (((8*I)/3)*Q2*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) - (((8*I)/3)*s*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) - (((4*I)/3)*SUNN*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) - (((32*I)/9)*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(2 - D) + 
     (((16*I)/9)*D*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(2 - D) + 
     (((32*I)/9)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*t) - (((16*I)/9)*D*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/((2 - D)*t) - 
     (((32*I)/9)*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
          Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]])^2)/
      (2 - D) + (((16*I)/9)*D*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
          Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]])^2)/
      (2 - D) - (((32*I)/9)*Q2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
          Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]])^2)/
      ((2 - D)*t) + (((16*I)/9)*D*Q2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
          Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]])^2)/
      ((2 - D)*t) - (((32*I)/9)*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
          Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]])^2)/
      ((2 - D)*t) + (((16*I)/9)*D*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
          Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]])^2)/
      ((2 - D)*t)))/4|>
