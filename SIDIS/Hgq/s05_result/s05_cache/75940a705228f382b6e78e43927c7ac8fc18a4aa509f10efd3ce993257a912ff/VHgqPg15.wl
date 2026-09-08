<|"Coefficients" -> <|GLI["VHgqPg15", {0, 1, 0, 0}] -> 
    ((-1/4*I)*(-1 + SUNN)*(1 + SUNN)*(32*Q2^2 - 16*D*Q2^2 + 2*D^2*Q2^2 + 
       56*Q2*s - 28*D*Q2*s + 3*D^2*Q2*s + 20*s^2 - 10*D*s^2 + D^2*s^2 + 
       40*Q2*t - 12*D*Q2*t + 28*s*t - 8*D*s*t + 16*t^2 - 4*D*t^2))/
     (SUNN*t*(Q2 + s + t)^2), GLI["VHgqPg15", {1, 0, 0, 0}] -> 
    ((I/4)*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*(16*Q2 - 8*D*Q2 + D^2*Q2 + 20*s - 
       10*D*s + D^2*s + 12*t - 4*D*t))/(SUNN*t*(Q2 + s + t)^2), 
   GLI["VHgqPg15", {1, 1, -1, 0}] -> ((-1/4*I)*(-1 + SUNN)*(1 + SUNN)*
      (16*Q2*s - 8*D*Q2*s + D^2*Q2*s + 20*s^2 - 10*D*s^2 + D^2*s^2 - 
       4*D*Q2*t + D^2*Q2*t + 16*s*t - 10*D*s*t + D^2*s*t - 4*t^2))/
     (SUNN*t*(Q2 + s + t)^2), GLI["VHgqPg15", {1, 1, 0, -1}] -> 
    ((I/4)*(-1 + SUNN)*(1 + SUNN)*(16*Q2 - 8*D*Q2 + D^2*Q2 + 20*s - 10*D*s + 
       D^2*s + 12*t - 4*D*t))/(SUNN*t*(Q2 + s + t)), 
   GLI["VHgqPg15", {1, 1, 0, 0}] -> ((I/4)*(2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
      (16*Q2 - 8*D*Q2 + D^2*Q2 + 20*s - 10*D*s + D^2*s + 12*t - 4*D*t))/
     (SUNN*t*(Q2 + s + t))|>, "Topology" -> FCTopology["VHgqPg15", 
   {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell - k1 + p, D], 0, 0, {1, 1}]], 
    FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell + p, D], 0, 
      0, {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell + q, D], 0, 0, {1, 1}]]}, {ell}, {p, q, k1}, {}, {}], 
 "Targets" -> {GLI["VHgqPg15", {0, 1, 0, 0}], GLI["VHgqPg15", {1, 0, 0, 0}], 
   GLI["VHgqPg15", {1, 1, -1, 0}], GLI["VHgqPg15", {1, 1, 0, -1}], 
   GLI["VHgqPg15", {1, 1, 0, 0}]}, "NumeratorRules" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]] -> 
    GLI["VHgqPg15", {-1, 0, 0, 0}], 
   Pair[Momentum[ell, D], Momentum[k1, D]] -> (-Q2 - s - t)/2 - 
     GLI["VHgqPg15", {0, -1, 0, 0}]/2 + GLI["VHgqPg15", {0, 0, -1, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[p, D]] -> 
    -1/2*GLI["VHgqPg15", {-1, 0, 0, 0}] + GLI["VHgqPg15", {0, 0, -1, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[q, D]] -> 
    Q2/2 - GLI["VHgqPg15", {-1, 0, 0, 0}]/2 + GLI["VHgqPg15", {0, 0, 0, -1}]/
      2}, "ScalarProducts" -> {Pair[Momentum[ell, D], Momentum[ell, D]], 
   Pair[Momentum[ell, D], Momentum[k1, D]], Pair[Momentum[ell, D], 
    Momentum[p, D]], Pair[Momentum[ell, D], Momentum[q, D]]}, 
 "ReconstructionPassed" -> True, "InputHash" -> 53182168695459317215814473673\
819582021308820203995095841974262384370639246079, "Mode" -> "Pg", 
 "Diagram" -> 15, "ContractedIntegrand" -> 
  (9*((((-32*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^2) + 
     (((16*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^2) - 
     (((2*I)/9)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^2) - 
     (((40*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (SUNN*(-Q2 - s - t)^2) + (((20*I)/9)*D*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^2) - 
     (((2*I)/9)*D^2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^2) + 
     (((32*I)/9)*Q2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((16*I)/9)*D*Q2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((2*I)/9)*D^2*Q2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((40*I)/9)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((20*I)/9)*D*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((2*I)/9)*D^2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^3) + 
     (((8*I)/9)*D*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^3) - 
     (((2*I)/9)*D^2*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^3) - 
     (((8*I)/9)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^3) + 
     (((8*I)/9)*D*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^3) - 
     (((2*I)/9)*D^2*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^3) + 
     (((8*I)/9)*Q2*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/9)*D*Q2*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((2*I)/9)*D^2*Q2*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((8*I)/9)*s*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/9)*D*s*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((2*I)/9)*D^2*s*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((32*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/
      (SUNN*(-Q2 - s - t)^2) + (((16*I)/9)*D*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^2) - 
     (((2*I)/9)*D^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^2) + 
     (((32*I)/9)*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((16*I)/9)*D*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 + 
     (((2*I)/9)*D^2*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^2 - 
     (((8*I)/9)*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^3) + 
     (((8*I)/9)*D*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^3) - 
     (((2*I)/9)*D^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN*(-Q2 - s - t)^3) + 
     (((8*I)/9)*SUNN*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/9)*D*SUNN*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((2*I)/9)*D^2*SUNN*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(-Q2 - s - t)^3 + 
     (((8*I)/9)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) - 
     (((8*I)/9)*D*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) + 
     (((2*I)/9)*D^2*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) + 
     (((8*I)/9)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) - 
     (((8*I)/9)*D*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) + 
     (((2*I)/9)*D^2*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) - 
     (((8*I)/9)*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((8*I)/9)*D*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((2*I)/9)*D^2*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/9)*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((8*I)/9)*D*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((2*I)/9)*D^2*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((32*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2) - 
     (((8*I)/3)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2) + 
     (((4*I)/9)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2) + 
     (((80*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (SUNN*(-Q2 - s - t)^2) - (((16*I)/3)*D*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2) + 
     (((2*I)/3)*D^2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2) - 
     (((32*I)/9)*Q2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/3)*D*Q2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((4*I)/9)*D^2*Q2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((80*I)/9)*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/3)*D*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((2*I)/3)*D^2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((32*I)/9)*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2*t) - 
     (((16*I)/9)*D*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2*t) + 
     (((2*I)/9)*D^2*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2*t) + 
     (((40*I)/9)*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2*t) - 
     (((20*I)/9)*D*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2*t) + 
     (((2*I)/9)*D^2*s^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2*t) - 
     (((32*I)/9)*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((-Q2 - s - t)^2*t) + 
     (((16*I)/9)*D*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((-Q2 - s - t)^2*t) - 
     (((2*I)/9)*D^2*Q2*s*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((-Q2 - s - t)^2*t) - 
     (((40*I)/9)*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((-Q2 - s - t)^2*t) + 
     (((20*I)/9)*D*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((-Q2 - s - t)^2*t) - 
     (((2*I)/9)*D^2*s^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/((-Q2 - s - t)^2*t) + 
     (((16*I)/9)*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) - 
     (((16*I)/9)*D*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) + 
     (((4*I)/9)*D^2*Q2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) + 
     (((8*I)/3)*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) - 
     (((8*I)/3)*D*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) + 
     (((2*I)/3)*D^2*s*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) - 
     (((16*I)/9)*Q2*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((16*I)/9)*D*Q2*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((4*I)/9)*D^2*Q2*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/3)*s*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((8*I)/3)*D*s*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((2*I)/3)*D^2*s*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((32*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/
      (SUNN*(-Q2 - s - t)^2) - (((8*I)/3)*D*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2) + 
     (((4*I)/9)*D^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^2) - 
     (((32*I)/9)*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((8*I)/3)*D*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 - 
     (((4*I)/9)*D^2*SUNN*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^2 + 
     (((16*I)/9)*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) - 
     (((16*I)/9)*D*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) + 
     (((4*I)/9)*D^2*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN*(-Q2 - s - t)^3) - 
     (((16*I)/9)*SUNN*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 + 
     (((16*I)/9)*D*SUNN*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((4*I)/9)*D^2*SUNN*t^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(-Q2 - s - t)^3 - 
     (((8*I)/9)*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) + (((8*I)/9)*D*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) - (((2*I)/9)*D^2*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) - (((16*I)/9)*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) + (((16*I)/9)*D*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) - (((4*I)/9)*D^2*Q2*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) - (((8*I)/9)*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) + (((8*I)/9)*D*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) - (((2*I)/9)*D^2*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) + (((8*I)/9)*Q2^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((8*I)/9)*D*Q2^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((2*I)/9)*D^2*Q2^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((16*I)/9)*Q2*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((16*I)/9)*D*Q2*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((4*I)/9)*D^2*Q2*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((8*I)/9)*s^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((8*I)/9)*D*s^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((2*I)/9)*D^2*s^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((64*I)/9)*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2) + (((32*I)/9)*D*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2) - (((4*I)/9)*D^2*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2) - 
     ((8*I)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D], 
         0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(SUNN*(-Q2 - s - t)^2) + 
     ((4*I)*D*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(SUNN*(-Q2 - s - t)^2) - 
     (((4*I)/9)*D^2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2) + (((64*I)/9)*Q2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((32*I)/9)*D*Q2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((4*I)/9)*D^2*Q2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + ((8*I)*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - ((4*I)*D*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((4*I)/9)*D^2*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((32*I)/9)*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2*t) + (((16*I)/9)*D*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2*t) - (((2*I)/9)*D^2*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2*t) - 
     ((8*I)*Q2*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(SUNN*(-Q2 - s - t)^2*t) + 
     ((4*I)*D*Q2*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, 
          D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(SUNN*(-Q2 - s - t)^2*t) - 
     (((4*I)/9)*D^2*Q2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2*t) - (((40*I)/9)*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2*t) + (((20*I)/9)*D*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2*t) - (((2*I)/9)*D^2*s^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2*t) + (((32*I)/9)*Q2^2*SUNN*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1 + p, D], 
         0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/((-Q2 - s - t)^2*t) - 
     (((16*I)/9)*D*Q2^2*SUNN*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((-Q2 - s - t)^2*t) + (((2*I)/9)*D^2*Q2^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((-Q2 - s - t)^2*t) + ((8*I)*Q2*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((-Q2 - s - t)^2*t) - ((4*I)*D*Q2*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((-Q2 - s - t)^2*t) + (((4*I)/9)*D^2*Q2*s*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((-Q2 - s - t)^2*t) + (((40*I)/9)*s^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((-Q2 - s - t)^2*t) - (((20*I)/9)*D*s^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((-Q2 - s - t)^2*t) + (((2*I)/9)*D^2*s^2*SUNN*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      ((-Q2 - s - t)^2*t) - (((16*I)/9)*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) + (((16*I)/9)*D*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) - (((4*I)/9)*D^2*Q2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) - (((16*I)/9)*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) + (((16*I)/9)*D*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) - (((4*I)/9)*D^2*s*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) + (((16*I)/9)*Q2*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((16*I)/9)*D*Q2*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((4*I)/9)*D^2*Q2*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((16*I)/9)*s*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((16*I)/9)*D*s*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((4*I)/9)*D^2*s*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((32*I)/9)*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2) + (((16*I)/9)*D*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2) - (((2*I)/9)*D^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^2) + (((32*I)/9)*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((16*I)/9)*D*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 + (((2*I)/9)*D^2*SUNN*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^2 - (((8*I)/9)*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) + (((8*I)/9)*D*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) - (((2*I)/9)*D^2*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN*(-Q2 - s - t)^3) + (((8*I)/9)*SUNN*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 - (((8*I)/9)*D*SUNN*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3 + (((2*I)/9)*D^2*SUNN*t^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1 + p, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (-Q2 - s - t)^3))/4|>
