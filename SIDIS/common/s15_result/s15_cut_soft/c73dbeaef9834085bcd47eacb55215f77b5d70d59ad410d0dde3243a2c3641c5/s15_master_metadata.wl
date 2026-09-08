<|"Masters" -> <|CutIntegral["R01", {1, 1, 0, 0}] -> 
    <|"Class" -> "cut_volume", "PrefactorSoftPower" -> -eps, 
     "Prefactor" -> (2^(-2 + 2*eps)*Pi^((2 - 2*eps)/2))/
       (w^eps*Gamma[(2 - 2*eps)/2]), "ParameterLimits" -> <||>, 
     "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> -1, "CoefficientSoftMinimum" -> -1, 
     "OrdinarySeriesOrder" -> 1|>, CutIntegral["R01", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_massless", "PrefactorSoftPower" -> -1 - eps, 
     "Prefactor" -> (Pi^(1 - eps)*w^(-1 - eps)*(-t + w)*Gamma[-eps])/
       (2*(t - w)*(Q2 + s + t - w)*Gamma[-2*eps]), "ParameterLimits" -> 
      <|zp -> Infinity|>, "DivergentParameters" -> {zp}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> 0, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R02", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_massless", "PrefactorSoftPower" -> -eps, 
     "Prefactor" -> -1/2*(Pi^(1 - eps)*(-t + w)*Gamma[-eps])/
        ((t - w)*w^eps*(s*t + Q2*w)*Gamma[-2*eps]), 
     "ParameterLimits" -> <|zp -> 1|>, "DivergentParameters" -> {}, 
     "TaylorDepth" -> 0, "CoefficientEpsilonMinimum" -> 0, 
     "CoefficientSoftMinimum" -> -1, "OrdinarySeriesOrder" -> 0|>, 
   CutIntegral["R03", {1, 1, 0, 1}] -> <|"Class" -> "cut_single_massive", 
     "PrefactorSoftPower" -> -eps, "Prefactor" -> 
      (2^(-1 + 2*eps)*Pi^((2 - 2*eps)/2))/((-2*Q2 - s - t)*w^eps*
        Gamma[(2 - 2*eps)/2]), "ParameterLimits" -> 
      <|zz -> -1 + (2*(2*Q2 + s + t))/(2*Q2 + s + t + Abs[s + t])|>, 
     "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> -1, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R03", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "PrefactorSoftPower" -> -eps, 
     "Prefactor" -> (Pi^(1 - eps)*(2*Q2 + s + t)*Gamma[-eps])/
       (2*(-2*Q2 - s - t)*w^eps*(Q2*t - 2*Q2*w - s*w)*Gamma[-2*eps]), 
     "ParameterLimits" -> <|zm -> Piecewise[{{1, s + t >= 0}}, 
         (Q2 + s + t)/Q2], zp -> (2*Q2 + s + t + Abs[s + t])/(2*Q2)|>, 
     "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> 0, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R04", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "PrefactorSoftPower" -> -eps, 
     "Prefactor" -> (Pi^(1 - eps)*(2*Q2 + s + t)*Gamma[-eps])/
       (2*(-2*Q2 - s - t)*t*(Q2 + s + t - w)*w^eps*Gamma[-2*eps]), 
     "ParameterLimits" -> <|zm -> Piecewise[{{1, s + t < 0}}, 
         Q2/(Q2 + s + t)], zp -> Piecewise[{{1, s + t >= 0}}, 
         Q2/(Q2 + s + t)]|>, "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> -1, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R09", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "PrefactorSoftPower" -> -eps, 
     "Prefactor" -> (Pi^(1 - eps)*(2*Q2 + s + t)*Gamma[-eps])/
       (2*(-2*Q2 - s - t)*w^eps*(Q2*s - 2*Q2*w - t*w)*Gamma[-2*eps]), 
     "ParameterLimits" -> <|zm -> Piecewise[{{1, s + t >= 0}}, 
         (Q2 + s + t)/Q2], zp -> (2*Q2 + s + t + Abs[s + t])/(2*Q2)|>, 
     "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> 0, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R10", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "PrefactorSoftPower" -> -eps, 
     "Prefactor" -> (Pi^(1 - eps)*(2*Q2 + s + t)*Gamma[-eps])/
       (2*s*(-2*Q2 - s - t)*(Q2 + s + t - w)*w^eps*Gamma[-2*eps]), 
     "ParameterLimits" -> <|zm -> Piecewise[{{1, s + t < 0}}, 
         Q2/(Q2 + s + t)], zp -> Piecewise[{{1, s + t >= 0}}, 
         Q2/(Q2 + s + t)]|>, "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> -1, 
     "OrdinarySeriesOrder" -> 0|>|>, "OrdinaryMasters" -> 
  <|CutIntegral["R01", {1, 1, 0, 0}] -> SeriesData[eps, 0, 
     {Pi/2, (2*Pi - EulerGamma*Pi - Pi*Log[Pi] - Pi*Log[w])/2}, 0, 2, 1], 
   CutIntegral["R01", {1, 1, 1, 1}] -> SeriesData[eps, 0, 
     {-(Pi/(w*(-Q2 - s - t + w))), (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
        Pi*Log[((s - w)*(-t + w))/((Q2 + s + t - w)*w)])/
       (w*(-Q2 - s - t + w))}, -1, 1, 1], CutIntegral["R02", {1, 1, 1, 1}] -> 
    SeriesData[eps, 0, {-(Pi/(s*t + Q2*w)), 
      (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
        Pi*Log[-(((s - w)*(-t + w))/(s*t + Q2*w))])/(s*t + Q2*w)}, -1, 1, 1], 
   CutIntegral["R03", {1, 1, 0, 1}] -> SeriesData[eps, 0, 
     {(Pi*Log[(1 - Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2])/
          (1 + Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2])])/
       (2*(2*Q2 + s + t)*Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
          (2*Q2 + s + t)^2])}, 0, 1, 1], CutIntegral["R03", {1, 1, 1, 1}] -> 
    SeriesData[eps, 0, {Pi/(2*(Q2*t - 2*Q2*w - s*w)), 
      (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
        Pi*Log[((2*Q2 + s + t)^2*(t - w)^2*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 
                4*Q2*w)/(2*Q2 + s + t)^2])*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 
                4*Q2*w)/(2*Q2 + s + t)^2]))/(4*(Q2*t - 2*Q2*w - s*w)^2)])/
       (2*(Q2*t - 2*Q2*w - s*w))}, -1, 1, 1], 
   CutIntegral["R04", {1, 1, 1, 1}] -> SeriesData[eps, 0, 
     {Pi/(2*t*(Q2 + s + t - w)), (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
        Pi*Log[((2*Q2 + s + t)^2*(t - w)^2*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 
                4*Q2*w)/(2*Q2 + s + t)^2])*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 
                4*Q2*w)/(2*Q2 + s + t)^2]))/(4*t^2*(Q2 + s + t - w)^2)])/
       (2*t*(Q2 + s + t - w))}, -1, 1, 1], 
   CutIntegral["R09", {1, 1, 1, 1}] -> SeriesData[eps, 0, 
     {Pi/(2*(Q2*s - 2*Q2*w - t*w)), (-(EulerGamma*Pi) - Pi*Log[Pi] - 
        Pi*Log[w] + Pi*Log[((2*Q2 + s + t)^2*(s - w)^2*
            (1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2])*
            (1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2]))/
           (4*(Q2*s - 2*Q2*w - t*w)^2)])/(2*(Q2*s - 2*Q2*w - t*w))}, -1, 1, 
     1], CutIntegral["R10", {1, 1, 1, 1}] -> SeriesData[eps, 0, 
     {Pi/(2*s*(Q2 + s + t - w)), (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
        Pi*Log[((2*Q2 + s + t)^2*(s - w)^2*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 
                4*Q2*w)/(2*Q2 + s + t)^2])*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 
                4*Q2*w)/(2*Q2 + s + t)^2]))/(4*s^2*(Q2 + s + t - w)^2)])/
       (2*s*(Q2 + s + t - w))}, -1, 1, 1]|>, "InputHash" -> 90119350588134857\
604969497815986677069761224423111236620466841344800923730373|>
