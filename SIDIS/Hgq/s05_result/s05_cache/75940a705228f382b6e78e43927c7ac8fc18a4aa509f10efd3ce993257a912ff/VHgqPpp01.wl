<|"Coefficients" -> <|GLI["VHgqPpp01", {-1, 1, 1, 0}] -> ((-I)*Q2)/(SUNN*t), 
   GLI["VHgqPpp01", {0, 0, 1, 0}] -> ((-I)*(s - t))/(SUNN*t), 
   GLI["VHgqPpp01", {0, 1, 0, 0}] -> (I*(2*Q2 + s))/(SUNN*t), 
   GLI["VHgqPpp01", {0, 1, 1, -1}] -> (-I)/SUNN, 
   GLI["VHgqPpp01", {0, 1, 1, 0}] -> ((-1/2*I)*(3*Q2 - 2*s))/SUNN, 
   GLI["VHgqPpp01", {1, 0, 0, 0}] -> (I*(s - t))/(SUNN*t), 
   GLI["VHgqPpp01", {1, 0, 1, 0}] -> ((I/2)*(s + t))/SUNN, 
   GLI["VHgqPpp01", {1, 1, -1, 0}] -> ((-I)*(Q2 + s))/(SUNN*t), 
   GLI["VHgqPpp01", {1, 1, 0, -1}] -> I/SUNN, 
   GLI["VHgqPpp01", {1, 1, 0, 0}] -> ((I/2)*(3*Q2 + s))/SUNN, 
   GLI["VHgqPpp01", {1, 1, 1, -1}] -> ((-1/2*I)*t)/SUNN, 
   GLI["VHgqPpp01", {1, 1, 1, 0}] -> ((-1/2*I)*Q2*t)/SUNN|>, 
 "Topology" -> FCTopology["VHgqPpp01", 
   {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell - p, D], 0, 0, {1, 1}]], FeynAmpDenominator[
     StandardPropagatorDenominator[Momentum[ell + k1 - p - q, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell + q, D], 0, 0, {1, 1}]]}, {ell}, {p, q, k1}, {}, {}], 
 "Targets" -> {GLI["VHgqPpp01", {-1, 1, 1, 0}], 
   GLI["VHgqPpp01", {0, 0, 1, 0}], GLI["VHgqPpp01", {0, 1, 0, 0}], 
   GLI["VHgqPpp01", {0, 1, 1, -1}], GLI["VHgqPpp01", {0, 1, 1, 0}], 
   GLI["VHgqPpp01", {1, 0, 0, 0}], GLI["VHgqPpp01", {1, 0, 1, 0}], 
   GLI["VHgqPpp01", {1, 1, -1, 0}], GLI["VHgqPpp01", {1, 1, 0, -1}], 
   GLI["VHgqPpp01", {1, 1, 0, 0}], GLI["VHgqPpp01", {1, 1, 1, -1}], 
   GLI["VHgqPpp01", {1, 1, 1, 0}]}, "NumeratorRules" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]] -> GLI["VHgqPpp01", 
     {-1, 0, 0, 0}], Pair[Momentum[ell, D], Momentum[k1, D]] -> 
    Q2/2 - GLI["VHgqPpp01", {-1, 0, 0, 0}]/2 - 
     GLI["VHgqPpp01", {0, -1, 0, 0}]/2 + GLI["VHgqPpp01", {0, 0, -1, 0}]/2 + 
     GLI["VHgqPpp01", {0, 0, 0, -1}]/2, 
   Pair[Momentum[ell, D], Momentum[p, D]] -> 
    GLI["VHgqPpp01", {-1, 0, 0, 0}]/2 - GLI["VHgqPpp01", {0, -1, 0, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[q, D]] -> 
    Q2/2 - GLI["VHgqPpp01", {-1, 0, 0, 0}]/2 + 
     GLI["VHgqPpp01", {0, 0, 0, -1}]/2}, "ScalarProducts" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]], Pair[Momentum[ell, D], 
    Momentum[p, D]], Pair[Momentum[ell, D], Momentum[k1, D]], 
   Pair[Momentum[ell, D], Momentum[q, D]]}, "ReconstructionPassed" -> True, 
 "InputHash" -> 5318216869545931721581447367381958202130882020399509584197426\
2384370639246079, "Mode" -> "Ppp", "Diagram" -> 1, 
 "ContractedIntegrand" -> 
  (9*((((8*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[ell, D]])/SUNN - 
     (((8*I)/9)*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((4*I)/9)*D*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((8*I)/9)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((4*I)/9)*D*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((8*I)/9)*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((4*I)/9)*D*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((16*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*SUNN) - 
     (((8*I)/3)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((4*I)/9)*D*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((8*I)/3)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((4*I)/9)*D*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((8*I)/3)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((4*I)/9)*D*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((32*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN) + (((8*I)/9)*D*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN) - (((32*I)/9)*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN) + (((8*I)/9)*D*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN) - (((32*I)/9)*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN) + (((8*I)/9)*D*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN) + (((8*I)/3)*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((4*I)/9)*D*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) + 
     (((16*I)/3)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((8*I)/9)*D*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) + 
     (((8*I)/3)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((4*I)/9)*D*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) + 
     (((16*I)/3)*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((8*I)/9)*D*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) + 
     (((16*I)/3)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((8*I)/9)*D*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) + 
     (((8*I)/3)*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((4*I)/9)*D*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((16*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/SUNN + 
     (((16*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(SUNN*t) - 
     (((16*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
          Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]])^2)/SUNN - 
     (((16*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
          Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]])^2)/
      (SUNN*t) - (((16*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
          Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]])^2)/
      (SUNN*t)))/4|>
