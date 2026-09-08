<|"Masters" -> <|CutIntegral["R01", {1, 1, 0, 0}] -> 
    <|"Class" -> "cut_volume", "EffectiveVectors" -> {}, 
     "RegulatedPrefactor" -> (2^(-2 + 2*eps)*Pi^((2 - 2*eps)/2))/
       (w^eps*Gamma[(2 - 2*eps)/2]), "PhysicalSubstitutions" -> {}, 
     "RequiredOrder" -> 2, "CutEnergyConditions" -> 
      {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "ParameterConditions" -> True, "AcceptedRepresentation" -> True, 
     "IntegralEvaluationPerformed" -> False|>, 
   CutIntegral["R01", {1, 1, 1, 1}] -> <|"Class" -> "cut_pair_massless", 
     "EffectiveVectors" -> {<|"Position" -> 3, "Vector" -> -p, 
        "Scale" -> (t - w)/2, "NormalizedMassSquared" -> 0, "Power" -> 1|>, 
       <|"Position" -> 4, "Vector" -> k1, "Scale" -> (s - w)/2, 
        "NormalizedMassSquared" -> 0, "Power" -> 1|>}, 
     "RegulatedPrefactor" -> (Pi^(1 - eps)*w^(-1 - eps)*(-t + w)*
        Gamma[1 - 2*eps])/(2*(t - w)*(Q2 + s + t - w)*Gamma[-2*eps]), 
     "PhysicalSubstitutions" -> {zp -> ((s - w)*(-t + w))/
         ((Q2 + s + t - w)*w)}, "RequiredOrder" -> 1, 
     "CutEnergyConditions" -> {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "ParameterConditions" -> ((s - w)*(-t + w))/((Q2 + s + t - w)*w) >= 0, 
     "AcceptedRepresentation" -> True, "IntegralEvaluationPerformed" -> 
      False|>, CutIntegral["R02", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_massless", "EffectiveVectors" -> 
      {<|"Position" -> 3, "Vector" -> -p, "Scale" -> (t - w)/2, 
        "NormalizedMassSquared" -> 0, "Power" -> 1|>, 
       <|"Position" -> 4, "Vector" -> -p - q - (k1*s)/w + (p*s)/w + (q*s)/w, 
        "Scale" -> (s - w)/2, "NormalizedMassSquared" -> 0, "Power" -> 1|>}, 
     "RegulatedPrefactor" -> -1/2*(Pi^(1 - eps)*(-t + w)*Gamma[1 - 2*eps])/
        ((t - w)*w^eps*(s*t + Q2*w)*Gamma[-2*eps]), 
     "PhysicalSubstitutions" -> {zp -> -(((s - w)*(-t + w))/(s*t + Q2*w))}, 
     "RequiredOrder" -> 1, "CutEnergyConditions" -> 
      {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "ParameterConditions" -> -(((s - w)*(-t + w))/(s*t + Q2*w)) >= 0, 
     "AcceptedRepresentation" -> True, "IntegralEvaluationPerformed" -> 
      False|>, CutIntegral["R03", {1, 1, 0, 1}] -> 
    <|"Class" -> "cut_single_massive", "EffectiveVectors" -> 
      {<|"Position" -> 4, "Vector" -> -q + (k1*Q2)/w - (p*Q2)/w - (q*Q2)/w, 
        "Scale" -> (-2*Q2 - s - t)/2, "NormalizedMassSquared" -> 
         (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2, "Power" -> 1|>}, 
     "RegulatedPrefactor" -> (2^(-1 + 2*eps)*Pi^((2 - 2*eps)/2))/
       ((-2*Q2 - s - t)*w^eps*Gamma[(2 - 2*eps)/2]), 
     "PhysicalSubstitutions" -> 
      {zz -> (1 - Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2])/
         (1 + Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2])}, 
     "RequiredOrder" -> 1, "CutEnergyConditions" -> 
      {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "ParameterConditions" -> 
      (1 - Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2])/
        (1 + Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2]) >= 0, 
     "AcceptedRepresentation" -> True, "IntegralEvaluationPerformed" -> 
      False|>, CutIntegral["R03", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "EffectiveVectors" -> 
      {<|"Position" -> 3, "Vector" -> -p, "Scale" -> (t - w)/2, 
        "NormalizedMassSquared" -> 0, "Power" -> 1|>, 
       <|"Position" -> 4, "Vector" -> -q + (k1*Q2)/w - (p*Q2)/w - (q*Q2)/w, 
        "Scale" -> (-2*Q2 - s - t)/2, "NormalizedMassSquared" -> 
         (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2, "Power" -> 1|>}, 
     "RegulatedPrefactor" -> (Pi^(1 - eps)*(2*Q2 + s + t)*Gamma[1 - 2*eps])/
       (2*(-2*Q2 - s - t)*w^eps*(Q2*t - 2*Q2*w - s*w)*Gamma[-2*eps]), 
     "PhysicalSubstitutions" -> 
      {zm -> ((2*Q2 + s + t)*(t - w)*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*(Q2*t - 2*Q2*w - s*w)), 
       zp -> ((2*Q2 + s + t)*(t - w)*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*(Q2*t - 2*Q2*w - s*w))}, 
     "RequiredOrder" -> 1, "CutEnergyConditions" -> 
      {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "ParameterConditions" -> 
      ((2*Q2 + s + t)*(t - w)*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*(Q2*t - 2*Q2*w - s*w)) >= 0 && 
       ((2*Q2 + s + t)*(t - w)*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*(Q2*t - 2*Q2*w - s*w)) >= 0, 
     "AcceptedRepresentation" -> True, "IntegralEvaluationPerformed" -> 
      False|>, CutIntegral["R04", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "EffectiveVectors" -> 
      {<|"Position" -> 3, "Vector" -> -p, "Scale" -> (t - w)/2, 
        "NormalizedMassSquared" -> 0, "Power" -> 1|>, 
       <|"Position" -> 4, "Vector" -> q + (k1*Q2)/w - (p*Q2)/w - (q*Q2)/w + 
          (k1*s)/w - (p*s)/w - (q*s)/w + (k1*t)/w - (p*t)/w - (q*t)/w, 
        "Scale" -> (-2*Q2 - s - t)/2, "NormalizedMassSquared" -> 
         (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2, "Power" -> 1|>}, 
     "RegulatedPrefactor" -> (Pi^(1 - eps)*(2*Q2 + s + t)*Gamma[1 - 2*eps])/
       (2*(-2*Q2 - s - t)*t*(Q2 + s + t - w)*w^eps*Gamma[-2*eps]), 
     "PhysicalSubstitutions" -> 
      {zm -> ((2*Q2 + s + t)*(t - w)*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*t*(Q2 + s + t - w)), 
       zp -> ((2*Q2 + s + t)*(t - w)*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*t*(Q2 + s + t - w))}, 
     "RequiredOrder" -> 1, "CutEnergyConditions" -> 
      {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "ParameterConditions" -> 
      ((2*Q2 + s + t)*(t - w)*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*t*(Q2 + s + t - w)) >= 0 && 
       ((2*Q2 + s + t)*(t - w)*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*t*(Q2 + s + t - w)) >= 0, 
     "AcceptedRepresentation" -> True, "IntegralEvaluationPerformed" -> 
      False|>, CutIntegral["R09", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "EffectiveVectors" -> 
      {<|"Position" -> 3, "Vector" -> k1, "Scale" -> (s - w)/2, 
        "NormalizedMassSquared" -> 0, "Power" -> 1|>, 
       <|"Position" -> 4, "Vector" -> -q + (k1*Q2)/w - (p*Q2)/w - (q*Q2)/w, 
        "Scale" -> (-2*Q2 - s - t)/2, "NormalizedMassSquared" -> 
         (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2, "Power" -> 1|>}, 
     "RegulatedPrefactor" -> (Pi^(1 - eps)*(2*Q2 + s + t)*Gamma[1 - 2*eps])/
       (2*(-2*Q2 - s - t)*w^eps*(Q2*s - 2*Q2*w - t*w)*Gamma[-2*eps]), 
     "PhysicalSubstitutions" -> 
      {zm -> ((2*Q2 + s + t)*(s - w)*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*(Q2*s - 2*Q2*w - t*w)), 
       zp -> ((2*Q2 + s + t)*(s - w)*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*(Q2*s - 2*Q2*w - t*w))}, 
     "RequiredOrder" -> 1, "CutEnergyConditions" -> 
      {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "ParameterConditions" -> 
      ((2*Q2 + s + t)*(s - w)*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*(Q2*s - 2*Q2*w - t*w)) >= 0 && 
       ((2*Q2 + s + t)*(s - w)*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*(Q2*s - 2*Q2*w - t*w)) >= 0, 
     "AcceptedRepresentation" -> True, "IntegralEvaluationPerformed" -> 
      False|>, CutIntegral["R10", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "EffectiveVectors" -> 
      {<|"Position" -> 3, "Vector" -> k1, "Scale" -> (s - w)/2, 
        "NormalizedMassSquared" -> 0, "Power" -> 1|>, 
       <|"Position" -> 4, "Vector" -> q + (k1*Q2)/w - (p*Q2)/w - (q*Q2)/w + 
          (k1*s)/w - (p*s)/w - (q*s)/w + (k1*t)/w - (p*t)/w - (q*t)/w, 
        "Scale" -> (-2*Q2 - s - t)/2, "NormalizedMassSquared" -> 
         (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2, "Power" -> 1|>}, 
     "RegulatedPrefactor" -> (Pi^(1 - eps)*(2*Q2 + s + t)*Gamma[1 - 2*eps])/
       (2*s*(-2*Q2 - s - t)*(Q2 + s + t - w)*w^eps*Gamma[-2*eps]), 
     "PhysicalSubstitutions" -> 
      {zm -> ((2*Q2 + s + t)*(s - w)*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*s*(Q2 + s + t - w)), 
       zp -> ((2*Q2 + s + t)*(s - w)*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*s*(Q2 + s + t - w))}, 
     "RequiredOrder" -> 1, "CutEnergyConditions" -> 
      {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "ParameterConditions" -> 
      ((2*Q2 + s + t)*(s - w)*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*s*(Q2 + s + t - w)) >= 0 && 
       ((2*Q2 + s + t)*(s - w)*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
             (2*Q2 + s + t)^2]))/(2*s*(Q2 + s + t - w)) >= 0, 
     "AcceptedRepresentation" -> True, "IntegralEvaluationPerformed" -> 
      False|>|>, "Classes" -> 
  <|"cut_volume" -> <|"SubTropicaInput" -> 
      {1, (2^(1 - 2*eps)*(1 + u)^(-2 + 2*eps))/u^eps, {u}, {}}, "Order" -> 2, 
     "SourceHash" -> 29399538990692434528628861934829765077020120295748338601\
421787125666088039966|>, "cut_pair_massless" -> 
    <|"SubTropicaInput" -> {1, (1 + u*zp)^eps/(1 + u), {u}, {zp}}, 
     "Order" -> 1, "SourceHash" -> 293995389906924345286288619348297650770201\
20295748338601421787125666088039966|>, "cut_single_massive" -> 
    <|"SubTropicaInput" -> {1, ((1 + u)^(-1 + 2*eps)*(1 + zz))/
        (4^eps*u^eps*(u + zz)), {u}, {zz}}, "Order" -> 1, 
     "SourceHash" -> 29399538990692434528628861934829765077020120295748338601\
421787125666088039966|>, "cut_pair_one_massive" -> 
    <|"SubTropicaInput" -> {1, ((1 + u*zm)*(1 + u*zp))^eps/(1 + u), {u}, 
       {zm, zp}}, "Order" -> 1, "SourceHash" -> 29399538990692434528628861934\
829765077020120295748338601421787125666088039966|>|>, 
 "PositiveCutSolution" -> {en -> Sqrt[w]/2, rad -> Sqrt[w]/2}, 
 "CutJacobian" -> -2*w, "RadialPrefactor" -> 2^(-3 + 2*eps)/w^eps, 
 "SphereAreaDefinition" -> (2*Pi^(nn/2))/Gamma[nn/2], 
 "CosineMap" -> (1 - u)/(1 + u), "AppellEulerDefinition" -> 
  {2^(2 - 2*eps - jj - kk)*Pi^(1 - eps), Gamma[2 - 2*eps - kk]/
    (Gamma[jj]*Gamma[2 - 2*eps - jj - kk]), (1 - tau)^(1 - 2*eps - jj - kk)*
    tau^(-1 + jj)*(1 - tau*(1 - zm))^(-1 + eps + kk)*
    (1 - tau*(1 - zp))^(-1 + eps + kk)}, "MasterMeasure" -> 
  "d^D r delta_plus(r^2) delta_plus((P-r)^2); no 2 pi factors", 
 "RepresentationReference" -> 
  "https://arxiv.org/abs/1101.3557 Eqs (7),(56), Appendix B", 
 "SourceHash" -> 293995389906924345286288619348297650770201202957483386014217\
87125666088039966, "ReductionHash" -> 
  540324767422391340294569867359158398448513257314091386192956326179182189693\
60, "AcceptedRepresentations" -> True, "IntegralEvaluationPerformed" -> 
  False|>
