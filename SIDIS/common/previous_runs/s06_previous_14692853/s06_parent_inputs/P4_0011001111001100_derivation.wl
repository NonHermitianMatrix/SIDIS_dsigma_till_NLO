<|"Representation" -> {(x[1] + x[2] + x[3] + x[4])^(2*eps)*
    (c13*x[1]*x[3] + c23*x[2]*x[3] + c14*x[1]*x[4] + c24*x[2]*x[4])^
     (-2 - eps), I*Pi^(2 - eps)*Gamma[2 + eps], {x[1], x[2], x[3], x[4]}, 
   {x[1] + x[2] + x[3] + x[4], c13*x[1]*x[3] + c23*x[2]*x[3] + 
     c14*x[1]*x[4] + c24*x[2]*x[4], 
    {{x[1], FeynAmpDenominator[StandardPropagatorDenominator[Momentum[r, D], 
        0, 0, {1, 1}]], 1}, {x[2], FeynAmpDenominator[
       StandardPropagatorDenominator[Momentum[pv2 + r, D], 0, 0, {1, 1}]], 
      1}, {x[3], FeynAmpDenominator[StandardPropagatorDenominator[
        Momentum[pv3 + r, D], 0, 0, {1, 1}]], 1}, 
     {x[4], FeynAmpDenominator[StandardPropagatorDenominator[
        Momentum[pv4 + r, D], 0, 0, {1, 1}]], 1}}, 
    {{x[1] + x[2] + x[3] + x[4]}}, 
    {-(Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv2, D]]*x[2]) - 
      Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv3, D]]*x[3] - 
      Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv4, D]]*x[4]}, 
    -(c13*x[3]) - c14*x[4], 1, 0}}, "ParentGram" -> 
  {{0, (-c13 + c23)/2, (-c14 + c24)/2}, {(-c13 + c23)/2, -c13, 
    (-c13 - c14)/2}, {(-c14 + c24)/2, (-c13 - c14)/2, -c14}}, 
 "Propagators" -> {SFAD[r], SFAD[pv2 + r], SFAD[pv3 + r], SFAD[pv4 + r]}, 
 "SourceHash" -> 754455607885607874663970769876000331062930188582699813579310\
68676826413468759|>
