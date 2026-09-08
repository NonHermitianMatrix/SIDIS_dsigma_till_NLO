<|"Original" -> (-1/4*I)*
   ((4*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
       PropagatorDenominator[Momentum[ell, D] - Momentum[q, D], 0]]*
      Pair[Momentum[ell, D], Momentum[q, D]])/(Q2*SUNN) - 
    (2*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
       PropagatorDenominator[Momentum[ell, D] - Momentum[q, D], 0]]*
      Pair[Momentum[ell, D], Momentum[q, D]])/(Q2*SUNN) - 
    (4*SUNN*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
       PropagatorDenominator[Momentum[ell, D] - Momentum[q, D], 0]]*
      Pair[Momentum[ell, D], Momentum[q, D]])/Q2 + 
    (2*D*SUNN*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
       PropagatorDenominator[Momentum[ell, D] - Momentum[q, D], 0]]*
      Pair[Momentum[ell, D], Momentum[q, D]])/Q2), 
 "RoutingCandidates" -> 
  <|"ell -> -ell" -> ((-1/2*I)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*uvx[3])/
     (Q2*SUNN*uvx[1]*(Q2 - uvx[1] - 2*uvx[3])), 
   "ell -> ell" -> ((I/2)*(-2 + D)*(-1 + SUNN)*(1 + SUNN)*uvx[3])/
     (Q2*SUNN*uvx[1]*(Q2 - uvx[1] + 2*uvx[3]))|>, 
 "ValidRoutings" -> {ell -> -ell}|>
