<|"Coefficients" -> <|GLI["VHqqPpp04", {-1, 1, 1, 0}] -> 
    ((-1/2*I)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*(Q2 + s + t))/t, 
   GLI["VHqqPpp04", {0, 0, 1, 0}] -> ((I/2)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*
      (Q2 + s + t))/t, GLI["VHqqPpp04", {0, 1, 0, 0}] -> 
    ((I/2)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*(Q2 + s + t))/t, 
   GLI["VHqqPpp04", {0, 1, 1, 0}] -> (-1/4*I)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*
     (Q2 + s + t), GLI["VHqqPpp04", {1, 0, 0, 0}] -> 
    ((-1/2*I)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*(Q2 + s + t))/t, 
   GLI["VHqqPpp04", {1, 0, 1, 0}] -> (-1/4*I)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*
     (Q2 + s + t), GLI["VHqqPpp04", {1, 1, 0, 0}] -> 
    (-1/2*I)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*(Q2 + s + t), 
   GLI["VHqqPpp04", {1, 1, 1, 0}] -> (I/2)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*t*
     (Q2 + s + t)|>, "Topology" -> FCTopology["VHqqPpp04", 
   {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[ell, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell - p, D], 0, 0, {1, 1}]], FeynAmpDenominator[
     StandardPropagatorDenominator[Momentum[ell + k1 - p - q, D], 0, 0, 
      {1, 1}]], FeynAmpDenominator[StandardPropagatorDenominator[
      Momentum[ell + q, D], 0, 0, {1, 1}]]}, {ell}, {p, q, k1}, {}, 
   {FCGV["BasisCompletion"]}], "Targets" -> {GLI["VHqqPpp04", {-1, 1, 1, 0}], 
   GLI["VHqqPpp04", {0, 0, 1, 0}], GLI["VHqqPpp04", {0, 1, 0, 0}], 
   GLI["VHqqPpp04", {0, 1, 1, 0}], GLI["VHqqPpp04", {1, 0, 0, 0}], 
   GLI["VHqqPpp04", {1, 0, 1, 0}], GLI["VHqqPpp04", {1, 1, 0, 0}], 
   GLI["VHqqPpp04", {1, 1, 1, 0}]}, "NumeratorRules" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]] -> GLI["VHqqPpp04", 
     {-1, 0, 0, 0}], Pair[Momentum[ell, D], Momentum[k1, D]] -> 
    Q2/2 - GLI["VHqqPpp04", {-1, 0, 0, 0}]/2 - 
     GLI["VHqqPpp04", {0, -1, 0, 0}]/2 + GLI["VHqqPpp04", {0, 0, -1, 0}]/2 + 
     GLI["VHqqPpp04", {0, 0, 0, -1}]/2, 
   Pair[Momentum[ell, D], Momentum[p, D]] -> 
    GLI["VHqqPpp04", {-1, 0, 0, 0}]/2 - GLI["VHqqPpp04", {0, -1, 0, 0}]/2, 
   Pair[Momentum[ell, D], Momentum[q, D]] -> 
    Q2/2 - GLI["VHqqPpp04", {-1, 0, 0, 0}]/2 + 
     GLI["VHqqPpp04", {0, 0, 0, -1}]/2}, "ScalarProducts" -> 
  {Pair[Momentum[ell, D], Momentum[ell, D]], Pair[Momentum[ell, D], 
    Momentum[p, D]], Pair[Momentum[ell, D], Momentum[k1, D]], 
   Pair[Momentum[ell, D], Momentum[q, D]]}, "ReconstructionPassed" -> True, 
 "InputHash" -> 7318436666729967439235702616519765295263678676750814402491329\
8561726715917172, "Mode" -> "Ppp", "Diagram" -> 4, 
 "ContractedIntegrand" -> 
  (9*(((4*I)/9)*Q2*t*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]] - 
     ((2*I)/9)*D*Q2*t*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]] + 
     ((4*I)/9)*s*t*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]] - ((2*I)/9)*D*s*t*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]] - ((4*I)/9)*Q2*SUNN^2*t*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]] + ((2*I)/9)*D*Q2*SUNN^2*t*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]] - ((4*I)/9)*s*SUNN^2*t*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]] + ((2*I)/9)*D*s*SUNN^2*t*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]] + ((4*I)/9)*t^2*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]] - ((2*I)/9)*D*t^2*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]] - ((4*I)/9)*SUNN^2*t^2*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]] + ((2*I)/9)*D*SUNN^2*t^2*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]] - ((8*I)/9)*Q2*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] + ((4*I)/9)*D*Q2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] - ((8*I)/9)*s*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] + ((4*I)/9)*D*s*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] + ((8*I)/9)*Q2*SUNN^2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] - ((4*I)/9)*D*Q2*SUNN^2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] + ((8*I)/9)*s*SUNN^2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] - ((4*I)/9)*D*s*SUNN^2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] - ((8*I)/9)*t*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] + ((4*I)/9)*D*t*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] + ((8*I)/9)*SUNN^2*t*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] - ((4*I)/9)*D*SUNN^2*t*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[ell, D]] + ((4*I)/9)*Q2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[p, D]] - ((2*I)/9)*D*Q2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[p, D]] + ((4*I)/9)*s*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[p, D]] - ((2*I)/9)*D*s*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[p, D]] - ((4*I)/9)*Q2*SUNN^2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[p, D]] + ((2*I)/9)*D*Q2*SUNN^2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[p, D]] - ((4*I)/9)*s*SUNN^2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[p, D]] + ((2*I)/9)*D*s*SUNN^2*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[p, D]] + ((4*I)/9)*t*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[p, D]] - ((2*I)/9)*D*t*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[p, D]] - ((4*I)/9)*SUNN^2*t*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[p, D]] + ((2*I)/9)*D*SUNN^2*t*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
       PropagatorDenominator[Momentum[ell - p, D], 0]]*
      FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
       Momentum[p, D]] + ((8*I)/9)*Q2*FeynAmpDenominator[
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
     ((8*I)/9)*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) + 
     ((4*I)/9)*D*Q2*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     ((8*I)/9)*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) + 
     ((4*I)/9)*D*s*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) + 
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
     ((8*I)/9)*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) + 
     ((4*I)/9)*D*SUNN^2*t*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     ((16*I)/9)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) + 
     ((8*I)/9)*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
        0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
         Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], Momentum[p, D]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) + 
     ((16*I)/9)*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
      Pair[Momentum[ell, D], Momentum[p, D]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     ((8*I)/9)*D*SUNN^2*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
        Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
      Pair[Momentum[ell, D], Momentum[p, D]]*
      (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
        Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]) - 
     (((16*I)/9)*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t + 
     (((8*I)/9)*D*Q2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell - p, D], 0]]*FeynAmpDenominator[PropagatorDenominator[
         Momentum[ell, D] - Momentum[-k1 + p + q, D], 0]]*
       Pair[Momentum[ell, D], Momentum[p, D]]*
       (-Pair[Momentum[ell, D], Momentum[k1, D]] + Pair[Momentum[ell, D], 
         Momentum[p, D]] + Pair[Momentum[ell, D], Momentum[q, D]]))/t - 
     (((16*I)/9)*s*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 
         0]]*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/t + (((8*I)/9)*D*s*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/t + (((16*I)/9)*Q2*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/t - (((8*I)/9)*D*Q2*SUNN^2*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/t + (((16*I)/9)*s*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/t - (((8*I)/9)*D*s*SUNN^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell, D], 0]]*FeynAmpDenominator[
        PropagatorDenominator[Momentum[ell - p, D], 0]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D] - 
          Momentum[-k1 + p + q, D], 0]]*Pair[Momentum[ell, D], 
        Momentum[p, D]]*(-Pair[Momentum[ell, D], Momentum[k1, D]] + 
        Pair[Momentum[ell, D], Momentum[p, D]] + Pair[Momentum[ell, D], 
         Momentum[q, D]]))/t))/4|>
