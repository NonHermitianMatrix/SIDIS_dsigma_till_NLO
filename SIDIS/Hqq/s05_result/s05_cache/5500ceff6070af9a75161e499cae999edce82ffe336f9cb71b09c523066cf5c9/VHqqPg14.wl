<|"Coefficients" -> <|GLI["VHqqPg14", {0, 1, 0, 0}] -> 
    ((I/8)*(-2 + D)^2*(-1 + SUNN)^2*(1 + SUNN)^2*(4*Q2^2 + 26*Q2*s - 
       2*D*Q2*s + 26*s^2 - 3*D*s^2 + 10*Q2*t - 2*D*Q2*t + 16*s*t - 2*D*s*t - 
       2*t^2 + D*t^2))/(s^2*SUNN^2*t), GLI["VHqqPg14", {1, 0, 0, 0}] -> 
    ((-1/8*I)*(-2 + D)^2*(-1 + SUNN)^2*(1 + SUNN)^2*(6*Q2^2 + 16*Q2*s - 
       D*Q2*s + 10*s^2 - D*s^2 + 8*Q2*t - D*Q2*t + 4*s*t - 2*t^2 + D*t^2))/
     (s^2*SUNN^2*t), GLI["VHqqPg14", {1, 1, -1, 0}] -> 
    ((I/8)*(-2 + D)^2*(-1 + SUNN)^2*(1 + SUNN)^2*(-6*Q2 - 10*s + D*s - 6*t + 
       D*t))/(s*SUNN^2*t), GLI["VHqqPg14", {1, 1, 0, -1}] -> 
    ((I/8)*(-2 + D)^2*(-1 + SUNN)^2*(1 + SUNN)^2*(2*Q2^2 - 4*Q2*s + D*Q2*s - 
       6*s^2 + D*s^2 - 2*Q2*t + D*Q2*t - 6*s*t + D*s*t))/(s^2*SUNN^2*t), 
   GLI["VHqqPg14", {1, 1, 0, 0}] -> ((-1/8*I)*(-2 + D)^2*(-1 + SUNN)^2*
      (1 + SUNN)^2*(-6*Q2^2 - 16*Q2*s + D*Q2*s - 10*s^2 + D*s^2 - 8*Q2*t + 
       D*Q2*t - 4*s*t + 2*t^2 - D*t^2))/(s*SUNN^2*t)|>, 
 "Topology" -> FCTopology["VHqqPg14", 
   {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell - p - q, D], 0, 0, {1, 1}]], FeynAmpDenominator[
     StandardPropagatorDenominator[Momentum[ell + p, D], 0, 0, {1, 1}]], 
    FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell + k1, D], 
      0, 0, {1, 1}]]}, {ell}, {p, q, k1}, {}, {}], 
 "Targets" -> {GLI["VHqqPg14", {0, 1, 0, 0}], GLI["VHqqPg14", {1, 0, 0, 0}], 
   GLI["VHqqPg14", {1, 1, -1, 0}], GLI["VHqqPg14", {1, 1, 0, -1}], 
   GLI["VHqqPg14", {1, 1, 0, 0}]}, "NumeratorRules" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]] -> 
    GLI["VHqqPg14", {-1, 0, 0, 0}], 
   Pair[Momentum[ell, D], Momentum[k1, D]] -> 
    -1/2*GLI["VHqqPg14", {-1, 0, 0, 0}] + GLI["VHqqPg14", {0, 0, 0, -1}]/2, 
   Pair[Momentum[ell, D], Momentum[p, D]] -> 
    -1/2*GLI["VHqqPg14", {-1, 0, 0, 0}] + GLI["VHqqPg14", {0, 0, -1, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[q, D]] -> 
    s/2 + GLI["VHqqPg14", {-1, 0, 0, 0}] - GLI["VHqqPg14", {0, -1, 0, 0}]/2 - 
     GLI["VHqqPg14", {0, 0, -1, 0}]/2}, "ScalarProducts" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]], Pair[Momentum[ell, D], 
    Momentum[p, D]], Pair[Momentum[ell, D], Momentum[q, D]], 
   Pair[Momentum[ell, D], Momentum[k1, D]]}, "ReconstructionPassed" -> True, 
 "InputHash" -> 3844802077426781830277475924677623546914522826366929382960339\
4814776422757833, "Mode" -> "Pg", "Diagram" -> 14, 
 "ContractedIntegrand" -> 
  (9*((((-16*I)/3)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s^2 + 
     (((16*I)/3)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s^2 - 
     (((4*I)/3)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s^2 + 
     (((16*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/s - (((8*I)/3)*D*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/s + 
     (((4*I)/3)*D^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s - 
     (((2*I)/9)*D^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s + 
     (((8*I)/3)*Q2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s^2*SUNN^2) - 
     (((8*I)/3)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s^2*SUNN^2) + 
     (((2*I)/3)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s^2*SUNN^2) - 
     (((8*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*SUNN^2) + 
     (((4*I)/3)*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*SUNN^2) - 
     (((2*I)/3)*D^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s*SUNN^2) + 
     ((I/9)*D^3*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s*SUNN^2) + 
     (((8*I)/3)*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s^2 - 
     (((8*I)/3)*D*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s^2 + 
     (((2*I)/3)*D^2*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s^2 - 
     (((8*I)/9)*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s + 
     (((4*I)/3)*D*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s - 
     (((2*I)/3)*D^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s + 
     ((I/9)*D^3*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s - 
     (((32*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/t + (((32*I)/9)*D*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/t - 
     (((8*I)/9)*D^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/t - 
     (((64*I)/9)*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s^2*t) + 
     (((64*I)/9)*D*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s^2*t) - 
     (((16*I)/9)*D^2*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s^2*t) - 
     (((32*I)/3)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s*t) + 
     (((32*I)/3)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s*t) - 
     (((8*I)/3)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s*t) + 
     (((16*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*t) - 
     (((16*I)/9)*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(SUNN^2*t) + 
     (((4*I)/9)*D^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(SUNN^2*t) + 
     (((32*I)/9)*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s^2*SUNN^2*t) - 
     (((32*I)/9)*D*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s^2*SUNN^2*t) + 
     (((8*I)/9)*D^2*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s^2*SUNN^2*t) + 
     (((16*I)/3)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s*SUNN^2*t) - 
     (((16*I)/3)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s*SUNN^2*t) + 
     (((4*I)/3)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s*SUNN^2*t) + 
     (((16*I)/9)*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/t - 
     (((16*I)/9)*D*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/t + 
     (((4*I)/9)*D^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/t + 
     (((32*I)/9)*Q2^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s^2*t) - 
     (((32*I)/9)*D*Q2^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s^2*t) + 
     (((8*I)/9)*D^2*Q2^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s^2*t) + 
     (((16*I)/3)*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s*t) - 
     (((16*I)/3)*D*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s*t) + 
     (((4*I)/3)*D^2*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s*t) + 
     (((16*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/s^2 - (((8*I)/3)*D*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*Pair[Momentum[ell, D], Momentum[k1, D]])/s^2 + 
     (((4*I)/3)*D^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s^2 - 
     (((2*I)/9)*D^3*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s^2 - 
     (((8*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s^2*SUNN^2) + 
     (((4*I)/3)*D*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s^2*SUNN^2) - 
     (((2*I)/3)*D^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/(s^2*SUNN^2) + 
     ((I/9)*D^3*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[k1, D]])/(s^2*SUNN^2) - 
     (((8*I)/9)*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s^2 + 
     (((4*I)/3)*D*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s^2 - 
     (((2*I)/3)*D^2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s^2 + 
     ((I/9)*D^3*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[k1, D]])/s^2 + 
     (((16*I)/3)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/s - (((56*I)/9)*D*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/s + 
     (((20*I)/9)*D^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/s - 
     (((2*I)/9)*D^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/s - 
     (((8*I)/3)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(s*SUNN^2) + 
     (((28*I)/9)*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(s*SUNN^2) - 
     (((10*I)/9)*D^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(s*SUNN^2) + 
     ((I/9)*D^3*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(s*SUNN^2) - 
     (((8*I)/3)*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/s + 
     (((28*I)/9)*D*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/s - 
     (((10*I)/9)*D^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/s + 
     ((I/9)*D^3*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/s + 
     (((80*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/t - (((88*I)/9)*D*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]])/t + 
     (((28*I)/9)*D^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/t - 
     (((2*I)/9)*D^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/t + 
     (((16*I)/3)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(s*t) - 
     (((16*I)/3)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(s*t) + 
     (((4*I)/3)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(s*t) - 
     (((40*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*t) + 
     (((44*I)/9)*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*t) - 
     (((14*I)/9)*D^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(SUNN^2*t) + 
     ((I/9)*D^3*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(SUNN^2*t) - 
     (((8*I)/3)*Q2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]])/(s*SUNN^2*t) + 
     (((8*I)/3)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(s*SUNN^2*t) - 
     (((2*I)/3)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(s*SUNN^2*t) - 
     (((40*I)/9)*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/t + 
     (((44*I)/9)*D*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/t - 
     (((14*I)/9)*D^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/t + 
     ((I/9)*D^3*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/t - 
     (((8*I)/3)*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(s*t) + 
     (((8*I)/3)*D*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(s*t) - 
     (((2*I)/3)*D^2*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]])/(s*t) - 
     (((64*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s^2 + 
     ((8*I)*D*Q2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s^2 - 
     (((8*I)/3)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s^2 + 
     (((2*I)/9)*D^3*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s^2 - 
     (((32*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s + 
     (((32*I)/9)*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s - 
     (((8*I)/9)*D^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s + 
     (((32*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s^2*SUNN^2) - ((4*I)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s^2*SUNN^2) + (((4*I)/3)*D^2*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(s^2*SUNN^2) - 
     ((I/9)*D^3*Q2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s^2*SUNN^2) + (((16*I)/9)*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*SUNN^2) - (((16*I)/9)*D*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*SUNN^2) + (((4*I)/9)*D^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*SUNN^2) + (((32*I)/9)*Q2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/s^2 - ((4*I)*D*Q2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/s^2 + (((4*I)/3)*D^2*Q2*SUNN^2*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s^2 - 
     ((I/9)*D^3*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s^2 + 
     (((16*I)/9)*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s - 
     (((16*I)/9)*D*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s + 
     (((4*I)/9)*D^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s - 
     (((80*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t + 
     (((88*I)/9)*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t - 
     (((28*I)/9)*D^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t + 
     (((2*I)/9)*D^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t - 
     (((16*I)/3)*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s^2*t) + 
     (((16*I)/3)*D*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s^2*t) - 
     (((4*I)/3)*D^2*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s^2*t) - 
     (((128*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s*t) + 
     (((136*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s*t) - 
     (((40*I)/9)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s*t) + 
     (((2*I)/9)*D^3*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s*t) + 
     (((40*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*t) - (((44*I)/9)*D*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*t) + (((14*I)/9)*D^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*t) - ((I/9)*D^3*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*t) + (((8*I)/3)*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s^2*SUNN^2*t) - (((8*I)/3)*D*Q2^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(s^2*SUNN^2*t) + 
     (((2*I)/3)*D^2*Q2^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s^2*SUNN^2*t) + (((64*I)/9)*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(s*SUNN^2*t) - 
     (((68*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*SUNN^2*t) + (((20*I)/9)*D^2*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(s*SUNN^2*t) - 
     ((I/9)*D^3*Q2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s*SUNN^2*t) + (((40*I)/9)*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/t - (((44*I)/9)*D*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/t + (((14*I)/9)*D^2*SUNN^2*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t - 
     ((I/9)*D^3*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t + 
     (((8*I)/3)*Q2^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s^2*t) - 
     (((8*I)/3)*D*Q2^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s^2*t) + 
     (((2*I)/3)*D^2*Q2^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s^2*t) + 
     (((64*I)/9)*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s*t) - 
     (((68*I)/9)*D*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s*t) + 
     (((20*I)/9)*D^2*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s*t) - 
     ((I/9)*D^3*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/(s*t) + 
     (((16*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s^2 - 
     (((8*I)/3)*D*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s^2 + 
     (((4*I)/3)*D^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s^2 - 
     (((2*I)/9)*D^3*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s^2 - 
     (((8*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s^2*SUNN^2) + (((4*I)/3)*D*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s^2*SUNN^2) - (((2*I)/3)*D^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(s^2*SUNN^2) + 
     ((I/9)*D^3*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (s^2*SUNN^2) - (((8*I)/9)*SUNN^2*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - k1, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/s^2 + (((4*I)/3)*D*SUNN^2*t*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - k1, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s^2 - 
     (((2*I)/3)*D^2*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s^2 + 
     ((I/9)*D^3*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - k1, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/s^2))/4|>
