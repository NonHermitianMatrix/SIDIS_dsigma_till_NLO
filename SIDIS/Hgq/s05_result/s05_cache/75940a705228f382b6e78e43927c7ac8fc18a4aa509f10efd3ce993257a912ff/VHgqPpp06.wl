<|"Coefficients" -> <|GLI["VHgqPpp06", {-1, 1, 1, 0}] -> 
    ((I/2)*(-1 + SUNN)*(1 + SUNN)*(Q2^2 - Q2*s + Q2*t - 4*s*t))/
     (SUNN*t*(Q2 + s + t)), GLI["VHgqPpp06", {0, 0, 1, 0}] -> 
    ((-1/2*I)*(-1 + SUNN)*(1 + SUNN)*(Q2^2 - s^2 + Q2*t - 3*s*t))/
     (SUNN*t*(Q2 + s + t)), GLI["VHgqPpp06", {0, 1, 0, 0}] -> 
    ((I/2)*(-1 + SUNN)*(1 + SUNN)*(Q2 - s + t))/(SUNN*t), 
   GLI["VHgqPpp06", {0, 1, 1, -1}] -> ((-1/2*I)*(-1 + SUNN)*(1 + SUNN)*
      (2*Q2^2 - 2*Q2*s + 3*Q2*t - 5*s*t + t^2))/(SUNN*t*(Q2 + s + t)), 
   GLI["VHgqPpp06", {0, 1, 1, 0}] -> ((-1/2*I)*(-1 + SUNN)*(1 + SUNN)*
      (6*Q2^3 - 2*D*Q2^3 - 6*Q2*s^2 + 2*D*Q2*s^2 + 8*Q2^2*t - 3*D*Q2^2*t - 
       12*Q2*s*t + 5*D*Q2*s*t - 4*s^2*t + 4*D*s^2*t + 2*Q2*t^2 - D*Q2*t^2 - 
       12*s*t^2 + 4*D*s*t^2))/((-2 + D)*SUNN*t*(Q2 + s + t)), 
   GLI["VHgqPpp06", {1, 0, 1, -1}] -> ((I/2)*(-1 + SUNN)*(1 + SUNN)*
      (Q2^2 - s^2 + Q2*t - 3*s*t))/(SUNN*t*(Q2 + s + t)), 
   GLI["VHgqPpp06", {1, 0, 1, 0}] -> ((I/2)*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
      (4*Q2^2 - D*Q2^2 - 4*s^2 + D*s^2 + 4*Q2*t - D*Q2*t + D*s*t))/
     ((-2 + D)*SUNN*t*(Q2 + s + t)), GLI["VHgqPpp06", {1, 1, 0, -1}] -> 
    ((-1/2*I)*(-1 + SUNN)*(1 + SUNN)*(Q2 - s + t))/(SUNN*t), 
   GLI["VHgqPpp06", {1, 1, 0, 0}] -> ((-1/2*I)*(-1 + SUNN)*(1 + SUNN)*
      (4*Q2^2 - D*Q2^2 - 4*s^2 + D*s^2 + 4*Q2*t - D*Q2*t + D*s*t))/
     ((-2 + D)*SUNN*t), GLI["VHgqPpp06", {1, 1, 1, -2}] -> 
    ((I/2)*(-1 + SUNN)*(1 + SUNN)*(Q2 + t)*(Q2 - s + t))/
     (SUNN*t*(Q2 + s + t)), GLI["VHgqPpp06", {1, 1, 1, -1}] -> 
    ((I/2)*(-1 + SUNN)*(1 + SUNN)*(6*Q2^3 - 2*D*Q2^3 - 6*Q2*s^2 + 
       2*D*Q2*s^2 + 12*Q2^2*t - 4*D*Q2^2*t - 4*Q2*s*t + D*Q2*s*t + D*s^2*t + 
       6*Q2*t^2 - 2*D*Q2*t^2 - 4*s*t^2 + D*s*t^2))/
     ((-2 + D)*SUNN*t*(Q2 + s + t)), GLI["VHgqPpp06", {1, 1, 1, 0}] -> 
    ((I/2)*Q2*(-1 + SUNN)*(1 + SUNN)*(-4*Q2^2 + D*Q2^2 + 4*s^2 - D*s^2 - 
       4*Q2*t + D*Q2*t - D*s*t))/((-2 + D)*SUNN*t)|>, 
 "Topology" -> FCTopology["VHgqPpp06", 
   {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell - k1, D], 0, 0, {1, 1}]], FeynAmpDenominator[
     StandardPropagatorDenominator[Momentum[ell - q, D], 0, 0, {1, 1}]], 
    FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell + p, D], 0, 
      0, {1, 1}]]}, {ell}, {p, q, k1}, {}, {}], 
 "Targets" -> {GLI["VHgqPpp06", {-1, 1, 1, 0}], 
   GLI["VHgqPpp06", {0, 0, 1, 0}], GLI["VHgqPpp06", {0, 1, 0, 0}], 
   GLI["VHgqPpp06", {0, 1, 1, -1}], GLI["VHgqPpp06", {0, 1, 1, 0}], 
   GLI["VHgqPpp06", {1, 0, 1, -1}], GLI["VHgqPpp06", {1, 0, 1, 0}], 
   GLI["VHgqPpp06", {1, 1, 0, -1}], GLI["VHgqPpp06", {1, 1, 0, 0}], 
   GLI["VHgqPpp06", {1, 1, 1, -2}], GLI["VHgqPpp06", {1, 1, 1, -1}], 
   GLI["VHgqPpp06", {1, 1, 1, 0}]}, "NumeratorRules" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]] -> GLI["VHgqPpp06", 
     {-1, 0, 0, 0}], Pair[Momentum[ell, D], Momentum[k1, D]] -> 
    GLI["VHgqPpp06", {-1, 0, 0, 0}]/2 - GLI["VHgqPpp06", {0, -1, 0, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[p, D]] -> 
    -1/2*GLI["VHgqPpp06", {-1, 0, 0, 0}] + GLI["VHgqPpp06", {0, 0, 0, -1}]/2, 
   Pair[Momentum[ell, D], Momentum[q, D]] -> 
    -1/2*Q2 + GLI["VHgqPpp06", {-1, 0, 0, 0}]/2 - 
     GLI["VHgqPpp06", {0, 0, -1, 0}]/2}, "ScalarProducts" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]], Pair[Momentum[ell, D], 
    Momentum[k1, D]], Pair[Momentum[ell, D], Momentum[q, D]], 
   Pair[Momentum[ell, D], Momentum[p, D]]}, "ReconstructionPassed" -> True, 
 "InputHash" -> 5318216869545931721581447367381958202130882020399509584197426\
2384370639246079, "Mode" -> "Ppp", "Diagram" -> 6, 
 "ContractedIntegrand" -> 
  (9*((((16*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/((2 - D)*SUNN) - 
     (((8*I)/9)*D*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/((2 - D)*SUNN) - 
     (((16*I)/9)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(2 - D) + 
     (((8*I)/9)*D*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(2 - D) - 
     (((64*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN) + 
     (((16*I)/9)*D*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN) + 
     (((64*I)/9)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(2 - D) - 
     (((16*I)/9)*D*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(2 - D) + 
     (((16*I)/9)*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((4*I)/9)*D*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((64*I)/9)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((16*I)/9)*D*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((16*I)/3)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((4*I)/3)*D*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((16*I)/9)*Q2^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*(Q2 + s + t)) + 
     (((4*I)/9)*D*Q2^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*(Q2 + s + t)) - 
     (((64*I)/9)*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*(Q2 + s + t)) + 
     (((16*I)/9)*D*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*(Q2 + s + t)) - 
     (((16*I)/3)*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*(Q2 + s + t)) + 
     (((4*I)/3)*D*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*(Q2 + s + t)) + 
     (((16*I)/9)*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((4*I)/9)*D*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((64*I)/9)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((4*I)/3)*D*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((16*I)/9)*Q2*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*(Q2 + s + t)) + 
     (((4*I)/9)*D*Q2*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*(Q2 + s + t)) - 
     (((64*I)/9)*s*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*(Q2 + s + t)) + 
     (((4*I)/3)*D*s*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/((2 - D)*(Q2 + s + t)) - 
     (((16*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*SUNN) + 
     (((16*I)/9)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(2 - D) - 
     (((16*I)/9)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((4*I)/9)*D*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((32*I)/9)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((4*I)/9)*D*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((16*I)/9)*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*(Q2 + s + t)) - 
     (((4*I)/9)*D*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*(Q2 + s + t)) - 
     (((32*I)/9)*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*(Q2 + s + t)) + 
     (((4*I)/9)*D*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*(Q2 + s + t)) - 
     (((16*I)/9)*Q2^2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*SUNN*t*
       (Q2 + s + t)) + (((4*I)/9)*D*Q2^2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*SUNN*t*(Q2 + s + t)) + 
     (((16*I)/9)*s^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*SUNN*t*
       (Q2 + s + t)) - (((4*I)/9)*D*s^3*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*SUNN*t*(Q2 + s + t)) + 
     (((16*I)/9)*Q2^2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*t*(Q2 + s + t)) - 
     (((4*I)/9)*D*Q2^2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*t*(Q2 + s + t)) - 
     (((16*I)/9)*s^3*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*t*(Q2 + s + t)) + 
     (((4*I)/9)*D*s^3*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/((2 - D)*t*(Q2 + s + t)) - 
     (((16*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((8*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) - 
     (((16*I)/3)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((8*I)/3)*D*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((16*I)/9)*Q2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*(Q2 + s + t)) - 
     (((8*I)/9)*D*Q2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*(Q2 + s + t)) + 
     (((16*I)/3)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*(Q2 + s + t)) - 
     (((8*I)/3)*D*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*(Q2 + s + t)) - 
     (((16*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((8*I)/9)*D*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((16*I)/9)*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*(Q2 + s + t)) - 
     (((8*I)/9)*D*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((2 - D)*(Q2 + s + t)) + 
     (((16*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]^2)/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((8*I)/9)*D*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]^2)/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((16*I)/9)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]^2)/((2 - D)*(Q2 + s + t)) + 
     (((8*I)/9)*D*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]^2)/((2 - D)*(Q2 + s + t)) + 
     (((16*I)/9)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]^2)/((2 - D)*SUNN*t*
       (Q2 + s + t)) - (((8*I)/9)*D*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
         Momentum[p, D]]^2)/((2 - D)*SUNN*t*(Q2 + s + t)) - 
     (((16*I)/9)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]^2)/((2 - D)*SUNN*t*
       (Q2 + s + t)) + (((8*I)/9)*D*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
         Momentum[p, D]]^2)/((2 - D)*SUNN*t*(Q2 + s + t)) - 
     (((16*I)/9)*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]^2)/((2 - D)*t*(Q2 + s + t)) + 
     (((8*I)/9)*D*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]^2)/((2 - D)*t*(Q2 + s + t)) + 
     (((16*I)/9)*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]^2)/((2 - D)*t*(Q2 + s + t)) - 
     (((8*I)/9)*D*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]^2)/((2 - D)*t*(Q2 + s + t)) + 
     (((32*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN) - (((32*I)/9)*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(2 - D) + 
     (((32*I)/9)*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((8*I)/9)*D*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((16*I)/9)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((16*I)/3)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) + 
     (((8*I)/9)*D*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - (((32*I)/9)*Q2^2*SUNN*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) + (((8*I)/9)*D*Q2^2*SUNN*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) + (((16*I)/9)*Q2*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) + (((16*I)/3)*s^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) - (((8*I)/9)*D*s^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) + (((16*I)/9)*Q2^3*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*t*(Q2 + s + t)) - 
     (((4*I)/9)*D*Q2^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*t*(Q2 + s + t)) + 
     (((16*I)/9)*Q2^2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*t*(Q2 + s + t)) - 
     (((4*I)/9)*D*Q2^2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*t*(Q2 + s + t)) - 
     (((16*I)/9)*Q2*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*t*(Q2 + s + t)) + 
     (((4*I)/9)*D*Q2*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*t*(Q2 + s + t)) - 
     (((16*I)/9)*s^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*t*(Q2 + s + t)) + 
     (((4*I)/9)*D*s^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*t*(Q2 + s + t)) - 
     (((16*I)/9)*Q2^3*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*t*(Q2 + s + t)) + (((4*I)/9)*D*Q2^3*SUNN*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*t*(Q2 + s + t)) - (((16*I)/9)*Q2^2*s*SUNN*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*t*(Q2 + s + t)) + (((4*I)/9)*D*Q2^2*s*SUNN*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*t*(Q2 + s + t)) + (((16*I)/9)*Q2*s^2*SUNN*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*t*(Q2 + s + t)) - (((4*I)/9)*D*Q2*s^2*SUNN*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*t*(Q2 + s + t)) + (((16*I)/9)*s^3*SUNN*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*t*(Q2 + s + t)) - (((4*I)/9)*D*s^3*SUNN*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*t*(Q2 + s + t)) + (((16*I)/9)*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((4*I)/9)*D*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - 
     (((32*I)/9)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) + 
     (((4*I)/9)*D*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) - (((16*I)/9)*Q2*SUNN*t*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) + (((4*I)/9)*D*Q2*SUNN*t*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) + (((32*I)/9)*s*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) - (((4*I)/9)*D*s*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) - (((32*I)/9)*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/((2 - D)*SUNN*(Q2 + s + t)) + 
     (((16*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) + 
     (((32*I)/9)*Q2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) - (((16*I)/9)*D*Q2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/((2 - D)*(Q2 + s + t)) - 
     (((16*I)/9)*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*t*(Q2 + s + t)) + 
     (((8*I)/9)*D*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*t*(Q2 + s + t)) + 
     (((16*I)/9)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*t*(Q2 + s + t)) - 
     (((8*I)/9)*D*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*t*(Q2 + s + t)) + 
     (((16*I)/9)*Q2^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*t*(Q2 + s + t)) - (((8*I)/9)*D*Q2^2*SUNN*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/((2 - D)*t*(Q2 + s + t)) - 
     (((16*I)/9)*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*t*(Q2 + s + t)) + (((8*I)/9)*D*s^2*SUNN*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/((2 - D)*t*(Q2 + s + t)) - 
     (((16*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) + 
     (((8*I)/9)*D*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*SUNN*(Q2 + s + t)) + 
     (((16*I)/9)*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((2 - D)*(Q2 + s + t)) - (((8*I)/9)*D*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/((2 - D)*(Q2 + s + t))))/4|>
