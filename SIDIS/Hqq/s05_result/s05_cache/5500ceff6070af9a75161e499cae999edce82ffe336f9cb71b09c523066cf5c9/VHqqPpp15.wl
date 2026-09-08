<|"Coefficients" -> <|GLI["VHqqPpp15", {1, 0, 0, 0}] -> 
    ((-1/4*I)*(-2 + D)^2*(-1 + SUNN)^2*(1 + SUNN)^2*(Q2 + s + t))/(SUNN^2*t), 
   GLI["VHqqPpp15", {1, 1, -1, 0}] -> ((I/4)*(-2 + D)^2*(-1 + SUNN)^2*
      (1 + SUNN)^2*(Q2 + s + t))/(SUNN^2*t), 
   GLI["VHqqPpp15", {1, 1, 0, 0}] -> ((I/4)*(-2 + D)^2*(-1 + SUNN)^2*
      (1 + SUNN)^2*(Q2 + s + t))/SUNN^2|>, 
 "Topology" -> FCTopology["VHqqPpp15", 
   {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell + k1 - q, D], 0, 0, {1, 1}]], 
    FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell + p, D], 0, 
      0, {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell + q, D], 0, 0, {1, 1}]]}, {ell}, {p, q, k1}, {}, {}], 
 "Targets" -> {GLI["VHqqPpp15", {1, 0, 0, 0}], 
   GLI["VHqqPpp15", {1, 1, -1, 0}], GLI["VHqqPpp15", {1, 1, 0, 0}]}, 
 "NumeratorRules" -> {Pair[Momentum[ell, D], Momentum[ell, D]] -> 
    GLI["VHqqPpp15", {-1, 0, 0, 0}], 
   Pair[Momentum[ell, D], Momentum[k1, D]] -> 
    (Q2 - t)/2 - GLI["VHqqPpp15", {-1, 0, 0, 0}] + 
     GLI["VHqqPpp15", {0, -1, 0, 0}]/2 + GLI["VHqqPpp15", {0, 0, 0, -1}]/2, 
   Pair[Momentum[ell, D], Momentum[p, D]] -> 
    -1/2*GLI["VHqqPpp15", {-1, 0, 0, 0}] + GLI["VHqqPpp15", {0, 0, -1, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[q, D]] -> 
    Q2/2 - GLI["VHqqPpp15", {-1, 0, 0, 0}]/2 + 
     GLI["VHqqPpp15", {0, 0, 0, -1}]/2}, "ScalarProducts" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]], Pair[Momentum[ell, D], 
    Momentum[k1, D]], Pair[Momentum[ell, D], Momentum[q, D]], 
   Pair[Momentum[ell, D], Momentum[p, D]]}, "ReconstructionPassed" -> True, 
 "InputHash" -> 3844802077426781830277475924677623546914522826366929382960339\
4814776422757833, "Mode" -> "Ppp", "Diagram" -> 15, 
 "ContractedIntegrand" -> 
  (9*(((-16*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
         Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) + 
     ((16*I)/9)*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
         Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     ((4*I)/9)*D^2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
         Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) + 
     (((8*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/SUNN^2 - 
     (((8*I)/9)*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/SUNN^2 + 
     (((2*I)/9)*D^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/SUNN^2 + 
     ((8*I)/9)*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     ((8*I)/9)*D*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) + 
     ((2*I)/9)*D^2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     (((16*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t + 
     (((16*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t - 
     (((4*I)/9)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t - 
     (((16*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t + 
     (((16*I)/9)*D*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t - 
     (((4*I)/9)*D^2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t + 
     (((8*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*t) - (((8*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*t) + (((2*I)/9)*D^2*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell + p, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(SUNN^2*t) + 
     (((8*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*t) - (((8*I)/9)*D*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*t) + (((2*I)/9)*D^2*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*t) + (((8*I)/9)*Q2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell + p, D] - Momentum[-k1 + p + q, 
           D], 0]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/t - (((8*I)/9)*D*Q2*SUNN^2*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell + p, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t + 
     (((2*I)/9)*D^2*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t + 
     (((8*I)/9)*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t - 
     (((8*I)/9)*D*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t + 
     (((2*I)/9)*D^2*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell + p, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t))/4|>
