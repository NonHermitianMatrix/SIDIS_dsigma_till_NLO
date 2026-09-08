<|"Coefficients" -> <|GLI["VHqgPg15", {0, 1, 0, 0}] -> 
    ((I/8)*(-2 + D)*(-1 + SUNN)^2*(1 + SUNN)^2*(2*Q2 + s + 2*t)*
      (16*Q2 - 8*D*Q2 + D^2*Q2 + 12*s - 4*D*s + 20*t - 10*D*t + D^2*t))/
     (s*SUNN^2*(Q2 + s + t)^2), GLI["VHqgPg15", {1, 0, 0, 0}] -> 
    ((-1/8*I)*(-2 + D)*(-1 + SUNN)^2*(1 + SUNN)^2*(16*Q2^2 - 8*D*Q2^2 + 
       D^2*Q2^2 + 12*Q2*s - D^2*Q2*s + 4*s^2 + 20*Q2*t - 10*D*Q2*t + 
       D^2*Q2*t - 4*s*t + 6*D*s*t - D^2*s*t))/(s*SUNN^2*(Q2 + s + t)^2), 
   GLI["VHqgPg15", {1, 1, -1, 0}] -> ((-1/8*I)*(-2 + D)*(-1 + SUNN)^2*
      (1 + SUNN)^2*(-4*D*Q2*s + D^2*Q2*s - 4*s^2 + 16*Q2*t - 8*D*Q2*t + 
       D^2*Q2*t + 16*s*t - 10*D*s*t + D^2*s*t + 20*t^2 - 10*D*t^2 + D^2*t^2))/
     (s*SUNN^2*(Q2 + s + t)^2), GLI["VHqgPg15", {1, 1, 0, -1}] -> 
    ((-1/8*I)*(-2 + D)*(-1 + SUNN)^2*(1 + SUNN)^2*(16*Q2 - 8*D*Q2 + D^2*Q2 + 
       12*s - 4*D*s + 20*t - 10*D*t + D^2*t))/(s*SUNN^2*(Q2 + s + t)), 
   GLI["VHqgPg15", {1, 1, 0, 0}] -> ((-1/8*I)*(-2 + D)*(-1 + SUNN)^2*
      (1 + SUNN)^2*(32*Q2^2 - 16*D*Q2^2 + 2*D^2*Q2^2 + 24*Q2*s - 4*D*Q2*s - 
       D^2*Q2*s + 4*s^2 + 40*Q2*t - 20*D*Q2*t + 2*D^2*Q2*t - 4*s*t + 
       6*D*s*t - D^2*s*t))/(s*SUNN^2*(Q2 + s + t))|>, 
 "Topology" -> FCTopology["VHqgPg15", 
   {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell - k1 + p, D], 0, 0, {1, 1}]], 
    FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell + p, D], 0, 
      0, {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell + q, D], 0, 0, {1, 1}]]}, {ell}, {p, q, k1}, {}, {}], 
 "Targets" -> {GLI["VHqgPg15", {0, 1, 0, 0}], GLI["VHqgPg15", {1, 0, 0, 0}], 
   GLI["VHqgPg15", {1, 1, -1, 0}], GLI["VHqgPg15", {1, 1, 0, -1}], 
   GLI["VHqgPg15", {1, 1, 0, 0}]}, "NumeratorRules" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]] -> 
    GLI["VHqgPg15", {-1, 0, 0, 0}], 
   Pair[Momentum[ell, D], Momentum[k1, D]] -> (-Q2 - s - t)/2 - 
     GLI["VHqgPg15", {0, -1, 0, 0}]/2 + GLI["VHqgPg15", {0, 0, -1, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[p, D]] -> 
    -1/2*GLI["VHqgPg15", {-1, 0, 0, 0}] + GLI["VHqgPg15", {0, 0, -1, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[q, D]] -> 
    Q2/2 - GLI["VHqgPg15", {-1, 0, 0, 0}]/2 + GLI["VHqgPg15", {0, 0, 0, -1}]/
      2}, "ScalarProducts" -> {Pair[Momentum[ell, D], Momentum[ell, D]], 
   Pair[Momentum[ell, D], Momentum[k1, D]], Pair[Momentum[ell, D], 
    Momentum[p, D]], Pair[Momentum[ell, D], Momentum[q, D]]}, 
 "ReconstructionPassed" -> True, "InputHash" -> 40688990864694508320703191332\
938439914999930794861258715729277252001684918341, "Mode" -> "Pg", 
 "Diagram" -> 15, "ContractedIntegrand" -> 
  (9*((((-32*I)/9)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((16*I)/3)*D*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/3)*D^2*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((4*I)/9)*D^3*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((32*I)/9)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((16*I)/3)*D*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/3)*D^2*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((4*I)/9)*D^3*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((16*I)/9)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     (((8*I)/3)*D*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     (((4*I)/3)*D^2*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     (((2*I)/9)*D^3*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     (((16*I)/9)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     (((8*I)/3)*D*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     (((4*I)/3)*D^2*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     (((2*I)/9)*D^3*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     (((16*I)/9)*Q2*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/3)*D*Q2*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((4*I)/3)*D^2*Q2*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((2*I)/9)*D^3*Q2*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((16*I)/9)*s^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/3)*D*s^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((4*I)/3)*D^2*s^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((2*I)/9)*D^3*s^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((64*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((80*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((32*I)/9)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((4*I)/9)*D^3*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((64*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((80*I)/9)*D*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((32*I)/9)*D^2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((4*I)/9)*D^3*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((32*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^2) - 
     (((40*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^2) + 
     (((16*I)/9)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^2) - 
     (((2*I)/9)*D^3*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^2) + 
     (((32*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (SUNN^2*(-Q2 - s - t)^2) - (((40*I)/9)*D*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^2) + 
     (((16*I)/9)*D^2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^2) - 
     (((2*I)/9)*D^3*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^2) + 
     (((32*I)/9)*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((40*I)/9)*D*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/9)*D^2*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((2*I)/9)*D^3*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((32*I)/9)*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((40*I)/9)*D*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/9)*D^2*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((2*I)/9)*D^3*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((16*I)/9)*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((8*I)/3)*D*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((4*I)/3)*D^2*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((2*I)/9)*D^3*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((16*I)/3)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     ((8*I)*D*s*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     ((4*I)*D^2*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((2*I)/3)*D^3*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((8*I)/9)*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     (((4*I)/3)*D*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     (((2*I)/3)*D^2*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     ((I/9)*D^3*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     (((8*I)/3)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     ((4*I)*D*s*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (SUNN^2*(-Q2 - s - t)^3) + ((2*I)*D^2*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     ((I/3)*D^3*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     (((8*I)/9)*Q2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((4*I)/3)*D*Q2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((2*I)/3)*D^2*Q2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     ((I/9)*D^3*Q2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((8*I)/3)*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     ((4*I)*D*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     ((2*I)*D^2*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     ((I/3)*D^3*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((160*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((176*I)/9)*D*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((20*I)/3)*D^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((2*I)/3)*D^3*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((64*I)/9)*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) + 
     (((64*I)/9)*D*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) - 
     (((20*I)/9)*D^2*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) + 
     (((2*I)/9)*D^3*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) + 
     (((80*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (SUNN^2*(-Q2 - s - t)^2) - (((88*I)/9)*D*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^2) + 
     (((10*I)/3)*D^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^2) - 
     ((I/3)*D^3*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (SUNN^2*(-Q2 - s - t)^2) + (((32*I)/9)*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s*SUNN^2*(-Q2 - s - t)^2) - 
     (((32*I)/9)*D*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*SUNN^2*(-Q2 - s - t)^2) + 
     (((10*I)/9)*D^2*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*SUNN^2*(-Q2 - s - t)^2) - 
     ((I/9)*D^3*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*SUNN^2*(-Q2 - s - t)^2) + 
     (((80*I)/9)*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((88*I)/9)*D*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((10*I)/3)*D^2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     ((I/3)*D^3*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((32*I)/9)*Q2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) - 
     (((32*I)/9)*D*Q2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) + 
     (((10*I)/9)*D^2*Q2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) - 
     ((I/9)*D^3*Q2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) - 
     (((16*I)/9)*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((8*I)/3)*D*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((4*I)/3)*D^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((2*I)/9)*D^3*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((8*I)/9)*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     (((4*I)/3)*D*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     (((2*I)/3)*D^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     ((I/9)*D^3*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     (((8*I)/9)*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((4*I)/3)*D*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((2*I)/3)*D^2*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     ((I/9)*D^3*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((80*I)/9)*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) + 
     (((80*I)/9)*D*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) - 
     (((8*I)/3)*D^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) + 
     (((2*I)/9)*D^3*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) + 
     (((40*I)/9)*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*SUNN^2*(-Q2 - s - t)^2) - 
     (((40*I)/9)*D*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*SUNN^2*(-Q2 - s - t)^2) + 
     (((4*I)/3)*D^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*SUNN^2*(-Q2 - s - t)^2) - 
     ((I/9)*D^3*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*SUNN^2*(-Q2 - s - t)^2) + 
     (((40*I)/9)*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) - 
     (((40*I)/9)*D*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) + 
     (((4*I)/3)*D^2*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) - 
     ((I/9)*D^3*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*(-Q2 - s - t)^2) + 
     (((16*I)/9)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/3)*D*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((4*I)/3)*D^2*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((2*I)/9)*D^3*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((16*I)/9)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/3)*D*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((4*I)/3)*D^2*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((2*I)/9)*D^3*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/9)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     (((4*I)/3)*D*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     (((2*I)/3)*D^2*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     ((I/9)*D^3*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     (((8*I)/9)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     (((4*I)/3)*D*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     (((2*I)/3)*D^2*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     ((I/9)*D^3*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     (((8*I)/9)*Q2*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((4*I)/3)*D*Q2*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((2*I)/3)*D^2*Q2*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     ((I/9)*D^3*Q2*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/9)*s^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((4*I)/3)*D*s^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((2*I)/3)*D^2*s^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     ((I/9)*D^3*s^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((64*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((64*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((20*I)/9)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((2*I)/9)*D^3*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((64*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((64*I)/9)*D*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((20*I)/9)*D^2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((2*I)/9)*D^3*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((32*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^2) + 
     (((32*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^2) - 
     (((10*I)/9)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^2) + 
     ((I/9)*D^3*Q2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (SUNN^2*(-Q2 - s - t)^2) - (((32*I)/9)*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^2) + 
     (((32*I)/9)*D*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^2) - 
     (((10*I)/9)*D^2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^2) + 
     ((I/9)*D^3*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (SUNN^2*(-Q2 - s - t)^2) - (((32*I)/9)*Q2*SUNN^2*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D], 
         0]]*Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((32*I)/9)*D*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((10*I)/9)*D^2*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     ((I/9)*D^3*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((32*I)/9)*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((32*I)/9)*D*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((10*I)/9)*D^2*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     ((I/9)*D^3*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/9)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/3)*D*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((4*I)/3)*D^2*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((2*I)/9)*D^3*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/9)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     (((4*I)/3)*D*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     (((2*I)/3)*D^2*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^3) + 
     ((I/9)*D^3*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^3) - 
     (((8*I)/9)*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((4*I)/3)*D*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((2*I)/3)*D^2*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     ((I/9)*D^3*s*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((80*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((80*I)/9)*D*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/3)*D^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((2*I)/9)*D^3*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((40*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (SUNN^2*(-Q2 - s - t)^2) + (((40*I)/9)*D*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^2) - 
     (((4*I)/3)*D^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*(-Q2 - s - t)^2) + 
     ((I/9)*D^3*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (SUNN^2*(-Q2 - s - t)^2) - (((40*I)/9)*SUNN^2*t*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D], 
         0]]*Pair[Momentum[ell, D], Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((40*I)/9)*D*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((4*I)/3)*D^2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     ((I/9)*D^3*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((16*I)/9)*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((8*I)/3)*D*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((4*I)/3)*D^2*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((2*I)/9)*D^3*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((32*I)/9)*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((16*I)/3)*D*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((8*I)/3)*D^2*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((4*I)/9)*D^3*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((16*I)/9)*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((8*I)/3)*D*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((4*I)/3)*D^2*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((2*I)/9)*D^3*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((8*I)/9)*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) - (((4*I)/3)*D*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) + (((2*I)/3)*D^2*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) - ((I/9)*D^3*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) + (((16*I)/9)*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) - (((8*I)/3)*D*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) + (((4*I)/3)*D^2*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) - (((2*I)/9)*D^3*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) + (((8*I)/9)*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) - (((4*I)/3)*D*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) + (((2*I)/3)*D^2*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) - ((I/9)*D^3*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) + (((8*I)/9)*Q2^2*SUNN^2*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D], 
         0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(-Q2 - s - t)^3 - 
     (((4*I)/3)*D*Q2^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((2*I)/3)*D^2*Q2^2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - ((I/9)*D^3*Q2^2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((16*I)/9)*Q2*s*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((8*I)/3)*D*Q2*s*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((4*I)/3)*D^2*Q2*s*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((2*I)/9)*D^3*Q2*s*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((8*I)/9)*s^2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((4*I)/3)*D*s^2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((2*I)/3)*D^2*s^2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - ((I/9)*D^3*s^2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((128*I)/9)*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((128*I)/9)*D*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((40*I)/9)*D^2*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((4*I)/9)*D^3*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((64*I)/9)*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) + (((64*I)/9)*D*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) - (((20*I)/9)*D^2*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) + (((2*I)/9)*D^3*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) - (((64*I)/9)*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((64*I)/9)*D*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((20*I)/9)*D^2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((2*I)/9)*D^3*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((64*I)/9)*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^2) - (((64*I)/9)*D*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^2) + (((20*I)/9)*D^2*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^2) - (((2*I)/9)*D^3*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^2) + (((32*I)/9)*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*SUNN^2*(-Q2 - s - t)^2) - 
     (((32*I)/9)*D*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*SUNN^2*(-Q2 - s - t)^2) + (((10*I)/9)*D^2*Q2^2*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D], 
         0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(s*SUNN^2*(-Q2 - s - t)^2) - 
     ((I/9)*D^3*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*SUNN^2*(-Q2 - s - t)^2) + 
     (((32*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(SUNN^2*(-Q2 - s - t)^2) - 
     (((32*I)/9)*D*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^2) + (((10*I)/9)*D^2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^2) - 
     ((I/9)*D^3*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(SUNN^2*(-Q2 - s - t)^2) + 
     (((64*I)/9)*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((64*I)/9)*D*Q2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((20*I)/9)*D^2*Q2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((2*I)/9)*D^3*Q2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((32*I)/9)*Q2^2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) - (((32*I)/9)*D*Q2^2*SUNN^2*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D], 
         0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(s*(-Q2 - s - t)^2) + 
     (((10*I)/9)*D^2*Q2^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) - ((I/9)*D^3*Q2^2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) + (((32*I)/9)*s*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((32*I)/9)*D*s*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((10*I)/9)*D^2*s*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - ((I/9)*D^3*s*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((32*I)/9)*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((16*I)/3)*D*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((8*I)/3)*D^2*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((4*I)/9)*D^3*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((32*I)/9)*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((16*I)/3)*D*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((8*I)/3)*D^2*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((4*I)/9)*D^3*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((16*I)/9)*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) - (((8*I)/3)*D*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) + (((4*I)/3)*D^2*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) - (((2*I)/9)*D^3*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) + (((16*I)/9)*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) - (((8*I)/3)*D*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) + (((4*I)/3)*D^2*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) - (((2*I)/9)*D^3*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) + (((16*I)/9)*Q2*SUNN^2*t*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D], 
         0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(-Q2 - s - t)^3 - 
     (((8*I)/3)*D*Q2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((4*I)/3)*D^2*Q2*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((2*I)/9)*D^3*Q2*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((16*I)/9)*s*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((8*I)/3)*D*s*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((4*I)/3)*D^2*s*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((2*I)/9)*D^3*s*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - ((16*I)*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + ((16*I)*D*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((44*I)/9)*D^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((4*I)/9)*D^3*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - ((16*I)*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) + ((16*I)*D*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) - (((44*I)/9)*D^2*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) + (((4*I)/9)*D^3*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) + ((8*I)*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^2) - 
     ((8*I)*D*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(SUNN^2*(-Q2 - s - t)^2) + 
     (((22*I)/9)*D^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^2) - (((2*I)/9)*D^3*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^2) + 
     ((8*I)*Q2*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(s*SUNN^2*(-Q2 - s - t)^2) - 
     ((8*I)*D*Q2*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(s*SUNN^2*(-Q2 - s - t)^2) + 
     (((22*I)/9)*D^2*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*SUNN^2*(-Q2 - s - t)^2) - (((2*I)/9)*D^3*Q2*t*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D], 
         0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(s*SUNN^2*(-Q2 - s - t)^2) + 
     ((8*I)*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - ((8*I)*D*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((22*I)/9)*D^2*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((2*I)/9)*D^3*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + ((8*I)*Q2*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) - ((8*I)*D*Q2*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) + (((22*I)/9)*D^2*Q2*SUNN^2*t*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D], 
         0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(s*(-Q2 - s - t)^2) - 
     (((2*I)/9)*D^3*Q2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) - (((16*I)/9)*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((8*I)/3)*D*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((4*I)/3)*D^2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((2*I)/9)*D^3*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((8*I)/9)*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) - (((4*I)/3)*D*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) + (((2*I)/3)*D^2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) - ((I/9)*D^3*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*(-Q2 - s - t)^3) + (((8*I)/9)*SUNN^2*t^2*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D], 
         0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(-Q2 - s - t)^3 - 
     (((4*I)/3)*D*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((2*I)/3)*D^2*SUNN^2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - ((I/9)*D^3*SUNN^2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((80*I)/9)*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) + (((80*I)/9)*D*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) - (((8*I)/3)*D^2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) + (((2*I)/9)*D^3*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) + (((40*I)/9)*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*SUNN^2*(-Q2 - s - t)^2) - 
     (((40*I)/9)*D*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*SUNN^2*(-Q2 - s - t)^2) + 
     (((4*I)/3)*D^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*SUNN^2*(-Q2 - s - t)^2) - 
     ((I/9)*D^3*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*SUNN^2*(-Q2 - s - t)^2) + (((40*I)/9)*SUNN^2*t^2*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D], 
         0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(s*(-Q2 - s - t)^2) - 
     (((40*I)/9)*D*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2) + (((4*I)/3)*D^2*SUNN^2*t^2*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D], 
         0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(s*(-Q2 - s - t)^2) - 
     ((I/9)*D^3*SUNN^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*(-Q2 - s - t)^2)))/4|>
