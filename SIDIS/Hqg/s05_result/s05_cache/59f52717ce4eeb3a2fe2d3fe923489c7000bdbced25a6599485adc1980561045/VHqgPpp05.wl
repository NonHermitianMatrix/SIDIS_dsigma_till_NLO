<|"Coefficients" -> <|GLI["VHqgPpp05", {-1, 1, 1, 0}] -> 
    ((-1/2*I)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*t)/(Q2 + s + t), 
   GLI["VHqgPpp05", {0, 0, 1, 0}] -> ((I/2)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*
      t)/(Q2 + s + t), GLI["VHqgPpp05", {0, 1, 0, 0}] -> 
    ((I/2)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*t)/(Q2 + s + t), 
   GLI["VHqgPpp05", {0, 1, 1, 0}] -> (I/4)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*t, 
   GLI["VHqgPpp05", {1, 0, 0, 0}] -> ((-1/2*I)*(-2 + D)*(-1 + SUNN)*
      (1 + SUNN)*t)/(Q2 + s + t), GLI["VHqgPpp05", {1, 0, 1, 0}] -> 
    (I/2)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*t, 
   GLI["VHqgPpp05", {1, 1, 0, 0}] -> (I/4)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*t, 
   GLI["VHqgPpp05", {1, 1, 1, 0}] -> (I/2)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*t*
     (Q2 + s + t)|>, "Topology" -> FCTopology["VHqgPpp05", 
   {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell - k1, D], 0, 0, {1, 1}]], FeynAmpDenominator[
     StandardPropagatorDenominator[Momentum[ell - p, D], 0, 0, {1, 1}]], 
    FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell + q, D], 0, 
      0, {1, 1}]]}, {ell}, {p, q, k1}, {}, {}], 
 "Targets" -> {GLI["VHqgPpp05", {-1, 1, 1, 0}], 
   GLI["VHqgPpp05", {0, 0, 1, 0}], GLI["VHqgPpp05", {0, 1, 0, 0}], 
   GLI["VHqgPpp05", {0, 1, 1, 0}], GLI["VHqgPpp05", {1, 0, 0, 0}], 
   GLI["VHqgPpp05", {1, 0, 1, 0}], GLI["VHqgPpp05", {1, 1, 0, 0}], 
   GLI["VHqgPpp05", {1, 1, 1, 0}]}, "NumeratorRules" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]] -> GLI["VHqgPpp05", 
     {-1, 0, 0, 0}], Pair[Momentum[ell, D], Momentum[k1, D]] -> 
    GLI["VHqgPpp05", {-1, 0, 0, 0}]/2 - GLI["VHqgPpp05", {0, -1, 0, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[p, D]] -> 
    GLI["VHqgPpp05", {-1, 0, 0, 0}]/2 - GLI["VHqgPpp05", {0, 0, -1, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[q, D]] -> 
    Q2/2 - GLI["VHqgPpp05", {-1, 0, 0, 0}]/2 + 
     GLI["VHqgPpp05", {0, 0, 0, -1}]/2}, "ScalarProducts" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]], Pair[Momentum[ell, D], 
    Momentum[k1, D]], Pair[Momentum[ell, D], Momentum[p, D]], 
   Pair[Momentum[ell, D], Momentum[q, D]]}, "ReconstructionPassed" -> True, 
 "InputHash" -> 4068899086469450832070319133293843991499993079486125871572927\
7252001684918341, "Mode" -> "Ppp", "Diagram" -> 5, 
 "ContractedIntegrand" -> 
  (9*((((4*I)/9)*Q2^3*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((2*I)/9)*D*Q2^3*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((4*I)/3)*Q2^2*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((2*I)/3)*D*Q2^2*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((4*I)/3)*Q2*s^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((2*I)/3)*D*Q2*s^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((4*I)/9)*s^3*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((2*I)/9)*D*s^3*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((4*I)/9)*Q2^3*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((2*I)/9)*D*Q2^3*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((4*I)/3)*Q2^2*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((2*I)/3)*D*Q2^2*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((4*I)/3)*Q2*s^2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((2*I)/3)*D*Q2*s^2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((4*I)/9)*s^3*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((2*I)/9)*D*s^3*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((4*I)/3)*Q2^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((2*I)/3)*D*Q2^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((8*I)/3)*Q2*s*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((4*I)/3)*D*Q2*s*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((4*I)/3)*s^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((2*I)/3)*D*s^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((4*I)/3)*Q2^2*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((2*I)/3)*D*Q2^2*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((8*I)/3)*Q2*s*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((4*I)/3)*D*Q2*s*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((4*I)/3)*s^2*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((2*I)/3)*D*s^2*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((4*I)/3)*Q2*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((2*I)/3)*D*Q2*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((4*I)/3)*s*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((2*I)/3)*D*s*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((4*I)/3)*Q2*SUNN^2*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((2*I)/3)*D*Q2*SUNN^2*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((4*I)/3)*s*SUNN^2*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((2*I)/3)*D*s*SUNN^2*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((4*I)/9)*t^4*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((2*I)/9)*D*t^4*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 - 
     (((4*I)/9)*SUNN^2*t^4*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((2*I)/9)*D*SUNN^2*t^4*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]])/(-Q2 - s - t)^2 + 
     (((8*I)/9)*Q2^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[ell, D]])/
      (-Q2 - s - t)^2 - (((4*I)/9)*D*Q2^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/9)*Q2*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[ell, D]])/
      (-Q2 - s - t)^2 - (((8*I)/9)*D*Q2*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/9)*s^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[ell, D]])/
      (-Q2 - s - t)^2 - (((4*I)/9)*D*s^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*Q2^2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[ell, D]])/
      (-Q2 - s - t)^2 + (((4*I)/9)*D*Q2^2*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(-Q2 - s - t)^2 - 
     (((16*I)/9)*Q2*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[ell, D]])/
      (-Q2 - s - t)^2 + (((8*I)/9)*D*Q2*s*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*s^2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[ell, D]])/
      (-Q2 - s - t)^2 + (((4*I)/9)*D*s^2*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/9)*Q2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[ell, D]])/
      (-Q2 - s - t)^2 - (((8*I)/9)*D*Q2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/9)*s*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[ell, D]])/
      (-Q2 - s - t)^2 - (((8*I)/9)*D*s*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(-Q2 - s - t)^2 - 
     (((16*I)/9)*Q2*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[ell, D]])/
      (-Q2 - s - t)^2 + (((8*I)/9)*D*Q2*SUNN^2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(-Q2 - s - t)^2 - 
     (((16*I)/9)*s*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[ell, D]])/
      (-Q2 - s - t)^2 + (((8*I)/9)*D*s*SUNN^2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/9)*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[ell, D]])/
      (-Q2 - s - t)^2 - (((4*I)/9)*D*t^3*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*SUNN^2*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[ell, D]])/
      (-Q2 - s - t)^2 + (((4*I)/9)*D*SUNN^2*t^3*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*Q2^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (-Q2 - s - t)^2 + (((4*I)/9)*D*Q2^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((16*I)/9)*Q2*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (-Q2 - s - t)^2 + (((8*I)/9)*D*Q2*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*s^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (-Q2 - s - t)^2 + (((4*I)/9)*D*s^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/9)*Q2^2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (-Q2 - s - t)^2 - (((4*I)/9)*D*Q2^2*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/9)*Q2*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (-Q2 - s - t)^2 - (((8*I)/9)*D*Q2*s*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/9)*s^2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (-Q2 - s - t)^2 - (((4*I)/9)*D*s^2*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((16*I)/9)*Q2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (-Q2 - s - t)^2 + (((8*I)/9)*D*Q2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((16*I)/9)*s*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (-Q2 - s - t)^2 + (((8*I)/9)*D*s*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/9)*Q2*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (-Q2 - s - t)^2 - (((8*I)/9)*D*Q2*SUNN^2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/9)*s*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (-Q2 - s - t)^2 - (((8*I)/9)*D*s*SUNN^2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (-Q2 - s - t)^2 + (((4*I)/9)*D*t^3*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/9)*SUNN^2*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (-Q2 - s - t)^2 - (((4*I)/9)*D*SUNN^2*t^3*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((4*I)/9)*Q2^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (-Q2 - s - t)^2 + (((2*I)/9)*D*Q2^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*Q2*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (-Q2 - s - t)^2 + (((4*I)/9)*D*Q2*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((4*I)/9)*s^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (-Q2 - s - t)^2 + (((2*I)/9)*D*s^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((4*I)/9)*Q2^2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (-Q2 - s - t)^2 - (((2*I)/9)*D*Q2^2*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/9)*Q2*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (-Q2 - s - t)^2 - (((4*I)/9)*D*Q2*s*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((4*I)/9)*s^2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (-Q2 - s - t)^2 - (((2*I)/9)*D*s^2*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*Q2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (-Q2 - s - t)^2 + (((4*I)/9)*D*Q2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*s*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (-Q2 - s - t)^2 + (((4*I)/9)*D*s*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/9)*Q2*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (-Q2 - s - t)^2 - (((4*I)/9)*D*Q2*SUNN^2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/9)*s*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (-Q2 - s - t)^2 - (((4*I)/9)*D*s*SUNN^2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((4*I)/9)*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (-Q2 - s - t)^2 + (((2*I)/9)*D*t^3*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((4*I)/9)*SUNN^2*t^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (-Q2 - s - t)^2 - (((2*I)/9)*D*SUNN^2*t^3*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((16*I)/9)*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/9)*D*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((16*I)/9)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/9)*D*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/9)*Q2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*D*Q2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/9)*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*D*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((16*I)/9)*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/9)*D*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/9)*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*D*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2))/4|>
