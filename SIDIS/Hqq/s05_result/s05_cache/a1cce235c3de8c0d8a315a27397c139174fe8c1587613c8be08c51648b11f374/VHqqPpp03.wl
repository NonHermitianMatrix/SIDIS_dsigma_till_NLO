<|"Coefficients" -> <|GLI["VHqqPpp03", {-1, 1, 1, 0}] -> 
    ((-1/2*I)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*(Q2 + s + t))/(SUNN^2*t), 
   GLI["VHqqPpp03", {0, 0, 1, 0}] -> ((I/2)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*
      (Q2 + s + t))/(SUNN^2*t), GLI["VHqqPpp03", {0, 1, 0, 0}] -> 
    ((I/2)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*(Q2 + s + t))/(SUNN^2*t), 
   GLI["VHqqPpp03", {0, 1, 1, 0}] -> ((I/4)*(-6 + D)*(-2 + D)*(-1 + SUNN)*
      (1 + SUNN)*(Q2 + s + t))/SUNN^2, GLI["VHqqPpp03", {1, 0, 0, 0}] -> 
    ((-1/2*I)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*(Q2 + s + t))/(SUNN^2*t), 
   GLI["VHqqPpp03", {1, 1, 0, 0}] -> ((I/2)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*
      (Q2 + s + t))/SUNN^2|>, "Topology" -> FCTopology["VHqqPpp03", 
   {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell - p, D], 0, 0, {1, 1}]], FeynAmpDenominator[
     StandardPropagatorDenominator[Momentum[ell + k1 - p - q, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell + q, D], 0, 0, {1, 1}]]}, {ell}, {p, q, k1}, {}, 
   {FCGV["BasisCompletion"]}], "Targets" -> {GLI["VHqqPpp03", {-1, 1, 1, 0}], 
   GLI["VHqqPpp03", {0, 0, 1, 0}], GLI["VHqqPpp03", {0, 1, 0, 0}], 
   GLI["VHqqPpp03", {0, 1, 1, 0}], GLI["VHqqPpp03", {1, 0, 0, 0}], 
   GLI["VHqqPpp03", {1, 1, 0, 0}]}, "NumeratorRules" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]] -> GLI["VHqqPpp03", 
     {-1, 0, 0, 0}], Pair[Momentum[ell, D], Momentum[k1, D]] -> 
    Q2/2 - GLI["VHqqPpp03", {-1, 0, 0, 0}]/2 - 
     GLI["VHqqPpp03", {0, -1, 0, 0}]/2 + GLI["VHqqPpp03", {0, 0, -1, 0}]/2 + 
     GLI["VHqqPpp03", {0, 0, 0, -1}]/2, 
   Pair[Momentum[ell, D], Momentum[p, D]] -> 
    GLI["VHqqPpp03", {-1, 0, 0, 0}]/2 - GLI["VHqqPpp03", {0, -1, 0, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[q, D]] -> 
    Q2/2 - GLI["VHqqPpp03", {-1, 0, 0, 0}]/2 + 
     GLI["VHqqPpp03", {0, 0, 0, -1}]/2}, "ScalarProducts" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]], Pair[Momentum[ell, D], 
    Momentum[p, D]], Pair[Momentum[ell, D], Momentum[k1, D]], 
   Pair[Momentum[ell, D], Momentum[q, D]]}, "ReconstructionPassed" -> True, 
 "InputHash" -> 7318436666729967439235702616519765295263678676750814402491329\
8561726715917172, "Mode" -> "Ppp", "Diagram" -> 3, 
 "ContractedIntegrand" -> 
  (9*(((8*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] - ((2*I)/3)*D*Q2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] + (I/9)*D^2*Q2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] + ((8*I)/9)*s*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] - ((2*I)/3)*D*s*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] + (I/9)*D^2*s*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] - (((8*I)/9)*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[ell, D]])/SUNN^2 + 
     (((2*I)/3)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/SUNN^2 - 
     ((I/9)*D^2*Q2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[ell, D]])/SUNN^2 - 
     (((8*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[ell, D]])/SUNN^2 + 
     (((2*I)/3)*D*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/SUNN^2 - 
     ((I/9)*D^2*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[ell, D]])/SUNN^2 + ((8*I)/9)*t*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] - ((2*I)/3)*D*t*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] + (I/9)*D^2*t*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] - (((8*I)/9)*t*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[ell, D]])/SUNN^2 + 
     (((2*I)/3)*D*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[ell, D]])/SUNN^2 - 
     ((I/9)*D^2*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[ell, D]])/SUNN^2 + ((8*I)/9)*Q2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     ((4*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) + 
     ((8*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     ((4*I)/9)*D*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     (((8*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/SUNN^2 + 
     (((4*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/SUNN^2 - 
     (((8*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/SUNN^2 + 
     (((4*I)/9)*D*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/SUNN^2 + 
     ((8*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     ((4*I)/9)*D*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     (((8*I)/9)*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/SUNN^2 + 
     (((4*I)/9)*D*t*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/SUNN^2 + 
     ((16*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     ((8*I)/9)*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     (((16*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/SUNN^2 + 
     (((8*I)/9)*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/SUNN^2 + 
     (((16*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t - 
     (((8*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t + 
     (((16*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/t - (((8*I)/9)*D*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/t - (((16*I)/9)*Q2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/(SUNN^2*t) + 
     (((8*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*t) - (((16*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*t) + (((8*I)/9)*D*s*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/
      (SUNN^2*t)))/4|>
