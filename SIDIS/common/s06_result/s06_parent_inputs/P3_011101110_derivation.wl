<|"Representation" -> {(x[1] + x[2] + x[3])^(-1 + 2*eps)*
    (c12*x[1]*x[2] + c13*x[1]*x[3] + c23*x[2]*x[3])^(-1 - eps), 
   (-I)*Pi^(2 - eps)*Gamma[1 + eps], {x[1], x[2], x[3]}, 
   {x[1] + x[2] + x[3], c12*x[1]*x[2] + c13*x[1]*x[3] + c23*x[2]*x[3], 
    {{x[1], FeynAmpDenominator[StandardPropagatorDenominator[Momentum[r, D], 
        0, 0, {1, 1}]], 1}, {x[2], FeynAmpDenominator[
       StandardPropagatorDenominator[Momentum[pv2 + r, D], 0, 0, {1, 1}]], 
      1}, {x[3], FeynAmpDenominator[StandardPropagatorDenominator[
        Momentum[pv3 + r, D], 0, 0, {1, 1}]], 1}}, {{x[1] + x[2] + x[3]}}, 
    {-(Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv2, D]]*x[2]) - 
      Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv3, D]]*x[3]}, 
    -(c12*x[2]) - c13*x[3], 1, 0}}, "ParentGram" -> 
  {{-c12, (-c12 - c13 + c23)/2}, {(-c12 - c13 + c23)/2, -c13}}, 
 "Propagators" -> {SFAD[r], SFAD[pv2 + r], SFAD[pv3 + r]}, 
 "SourceHash" -> 104254329821002203018892098924143487469356335584655924171663\
692264865657824120|>
