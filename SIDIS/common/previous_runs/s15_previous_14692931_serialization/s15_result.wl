<|"Masters" -> <|CutIntegral["R01", {1, 1, 0, 0}] -> 
    <|"Class" -> "cut_volume", "PrefactorSoftPower" -> -Global`eps, 
     "Prefactor" -> (2^(-2 + 2*Global`eps)*Pi^((2 - 2*Global`eps)/2))/
       (Global`w^Global`eps*Gamma[(2 - 2*Global`eps)/2]), 
     "ParameterLimits" -> <||>, "DivergentParameters" -> {}, 
     "TaylorDepth" -> 0, "CoefficientEpsilonMinimum" -> -1, 
     "CoefficientSoftMinimum" -> -1, "OrdinarySeriesOrder" -> 1|>, 
   CutIntegral["R01", {1, 1, 1, 1}] -> <|"Class" -> "cut_pair_massless", 
     "PrefactorSoftPower" -> -1 - Global`eps, "Prefactor" -> 
      (Pi^(1 - Global`eps)*Global`w^(-1 - Global`eps)*(-Global`t + Global`w)*
        Gamma[-Global`eps])/(2*(Global`t - Global`w)*(Q2 + Global`s + 
         Global`t - Global`w)*Gamma[-2*Global`eps]), 
     "ParameterLimits" -> <|zp -> Infinity|>, "DivergentParameters" -> {zp}, 
     "TaylorDepth" -> 0, "CoefficientEpsilonMinimum" -> 0, 
     "CoefficientSoftMinimum" -> 0, "OrdinarySeriesOrder" -> 0|>, 
   CutIntegral["R02", {1, 1, 1, 1}] -> <|"Class" -> "cut_pair_massless", 
     "PrefactorSoftPower" -> -Global`eps, "Prefactor" -> 
      -1/2*(Pi^(1 - Global`eps)*(-Global`t + Global`w)*Gamma[-Global`eps])/
        ((Global`t - Global`w)*Global`w^Global`eps*(Global`s*Global`t + 
          Q2*Global`w)*Gamma[-2*Global`eps]), "ParameterLimits" -> 
      <|zp -> 1|>, "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> -1, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R03", {1, 1, 0, 1}] -> 
    <|"Class" -> "cut_single_massive", "PrefactorSoftPower" -> -Global`eps, 
     "Prefactor" -> (2^(-1 + 2*Global`eps)*Pi^((2 - 2*Global`eps)/2))/
       ((-2*Q2 - Global`s - Global`t)*Global`w^Global`eps*
        Gamma[(2 - 2*Global`eps)/2]), "ParameterLimits" -> 
      <|Global`zz -> -1 + (2*(2*Q2 + Global`s + Global`t))/
          (2*Q2 + Global`s + Global`t + Abs[Global`s + Global`t])|>, 
     "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> -1, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R03", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "PrefactorSoftPower" -> -Global`eps, 
     "Prefactor" -> (Pi^(1 - Global`eps)*(2*Q2 + Global`s + Global`t)*
        Gamma[-Global`eps])/(2*(-2*Q2 - Global`s - Global`t)*
        Global`w^Global`eps*(Q2*Global`t - 2*Q2*Global`w - Global`s*Global`w)*
        Gamma[-2*Global`eps]), "ParameterLimits" -> 
      <|zm -> Piecewise[{{1, Global`s + Global`t >= 0}}, 
         (Q2 + Global`s + Global`t)/Q2], 
       zp -> (2*Q2 + Global`s + Global`t + Abs[Global`s + Global`t])/
         (2*Q2)|>, "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> 0, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R04", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "PrefactorSoftPower" -> -Global`eps, 
     "Prefactor" -> (Pi^(1 - Global`eps)*(2*Q2 + Global`s + Global`t)*
        Gamma[-Global`eps])/(2*(-2*Q2 - Global`s - Global`t)*Global`t*
        (Q2 + Global`s + Global`t - Global`w)*Global`w^Global`eps*
        Gamma[-2*Global`eps]), "ParameterLimits" -> 
      <|zm -> Piecewise[{{1, Global`s + Global`t < 0}}, 
         Q2/(Q2 + Global`s + Global`t)], 
       zp -> Piecewise[{{1, Global`s + Global`t >= 0}}, 
         Q2/(Q2 + Global`s + Global`t)]|>, "DivergentParameters" -> {}, 
     "TaylorDepth" -> 0, "CoefficientEpsilonMinimum" -> 0, 
     "CoefficientSoftMinimum" -> -1, "OrdinarySeriesOrder" -> 0|>, 
   CutIntegral["R09", {1, 1, 1, 1}] -> <|"Class" -> "cut_pair_one_massive", 
     "PrefactorSoftPower" -> -Global`eps, "Prefactor" -> 
      (Pi^(1 - Global`eps)*(2*Q2 + Global`s + Global`t)*Gamma[-Global`eps])/
       (2*(-2*Q2 - Global`s - Global`t)*Global`w^Global`eps*
        (Q2*Global`s - 2*Q2*Global`w - Global`t*Global`w)*
        Gamma[-2*Global`eps]), "ParameterLimits" -> 
      <|zm -> Piecewise[{{1, Global`s + Global`t >= 0}}, 
         (Q2 + Global`s + Global`t)/Q2], 
       zp -> (2*Q2 + Global`s + Global`t + Abs[Global`s + Global`t])/
         (2*Q2)|>, "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> 0, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R10", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "PrefactorSoftPower" -> -Global`eps, 
     "Prefactor" -> (Pi^(1 - Global`eps)*(2*Q2 + Global`s + Global`t)*
        Gamma[-Global`eps])/(2*Global`s*(-2*Q2 - Global`s - Global`t)*
        (Q2 + Global`s + Global`t - Global`w)*Global`w^Global`eps*
        Gamma[-2*Global`eps]), "ParameterLimits" -> 
      <|zm -> Piecewise[{{1, Global`s + Global`t < 0}}, 
         Q2/(Q2 + Global`s + Global`t)], 
       zp -> Piecewise[{{1, Global`s + Global`t >= 0}}, 
         Q2/(Q2 + Global`s + Global`t)]|>, "DivergentParameters" -> {}, 
     "TaylorDepth" -> 0, "CoefficientEpsilonMinimum" -> 0, 
     "CoefficientSoftMinimum" -> -1, "OrdinarySeriesOrder" -> 0|>|>, 
 "OrdinaryMasters" -> <|CutIntegral["R01", {1, 1, 0, 0}] -> 
    SeriesData[Global`eps, 0, {Pi/2, (2*Pi - EulerGamma*Pi - Pi*Log[Pi] - 
        Pi*Log[Global`w])/2}, 0, 2, 1], CutIntegral["R01", {1, 1, 1, 1}] -> 
    SeriesData[Global`eps, 0, 
     {-(Pi/(Global`w*(-Q2 - Global`s - Global`t + Global`w))), 
      (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[Global`w] - 
        Pi*Log[((Global`s - Global`w)*(-Global`t + Global`w))/
           ((Q2 + Global`s + Global`t - Global`w)*Global`w)])/
       (Global`w*(-Q2 - Global`s - Global`t + Global`w))}, -1, 1, 1], 
   CutIntegral["R02", {1, 1, 1, 1}] -> SeriesData[Global`eps, 0, 
     {-(Pi/(Global`s*Global`t + Q2*Global`w)), 
      (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[Global`w] - 
        Pi*Log[-(((Global`s - Global`w)*(-Global`t + Global`w))/
            (Global`s*Global`t + Q2*Global`w))])/(Global`s*Global`t + 
        Q2*Global`w)}, -1, 1, 1], CutIntegral["R03", {1, 1, 0, 1}] -> 
    SeriesData[Global`eps, 0, 
     {(Pi*Log[(1 - Sqrt[1 - (4*Q2*(Q2 + Global`s + Global`t - Global`w))/
              (2*Q2 + Global`s + Global`t)^2])/
          (1 + Sqrt[1 - (4*Q2*(Q2 + Global`s + Global`t - Global`w))/
              (2*Q2 + Global`s + Global`t)^2])])/
       (2*(2*Q2 + Global`s + Global`t)*
        Sqrt[(Global`s^2 + 2*Global`s*Global`t + Global`t^2 + 4*Q2*Global`w)/
          (2*Q2 + Global`s + Global`t)^2])}, 0, 1, 1], 
   CutIntegral["R03", {1, 1, 1, 1}] -> SeriesData[Global`eps, 0, 
     {Pi/(2*(Q2*Global`t - 2*Q2*Global`w - Global`s*Global`w)), 
      (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[Global`w] + 
        Pi*Log[((2*Q2 + Global`s + Global`t)^2*(Global`t - Global`w)^2*
            (1 - Sqrt[(Global`s^2 + 2*Global`s*Global`t + Global`t^2 + 
                4*Q2*Global`w)/(2*Q2 + Global`s + Global`t)^2])*
            (1 + Sqrt[(Global`s^2 + 2*Global`s*Global`t + Global`t^2 + 
                4*Q2*Global`w)/(2*Q2 + Global`s + Global`t)^2]))/
           (4*(Q2*Global`t - 2*Q2*Global`w - Global`s*Global`w)^2)])/
       (2*(Q2*Global`t - 2*Q2*Global`w - Global`s*Global`w))}, -1, 1, 1], 
   CutIntegral["R04", {1, 1, 1, 1}] -> SeriesData[Global`eps, 0, 
     {Pi/(2*Global`t*(Q2 + Global`s + Global`t - Global`w)), 
      (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[Global`w] + 
        Pi*Log[((2*Q2 + Global`s + Global`t)^2*(Global`t - Global`w)^2*
            (1 - Sqrt[(Global`s^2 + 2*Global`s*Global`t + Global`t^2 + 
                4*Q2*Global`w)/(2*Q2 + Global`s + Global`t)^2])*
            (1 + Sqrt[(Global`s^2 + 2*Global`s*Global`t + Global`t^2 + 
                4*Q2*Global`w)/(2*Q2 + Global`s + Global`t)^2]))/
           (4*Global`t^2*(Q2 + Global`s + Global`t - Global`w)^2)])/
       (2*Global`t*(Q2 + Global`s + Global`t - Global`w))}, -1, 1, 1], 
   CutIntegral["R09", {1, 1, 1, 1}] -> SeriesData[Global`eps, 0, 
     {Pi/(2*(Q2*Global`s - 2*Q2*Global`w - Global`t*Global`w)), 
      (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[Global`w] + 
        Pi*Log[((2*Q2 + Global`s + Global`t)^2*(Global`s - Global`w)^2*
            (1 - Sqrt[(Global`s^2 + 2*Global`s*Global`t + Global`t^2 + 
                4*Q2*Global`w)/(2*Q2 + Global`s + Global`t)^2])*
            (1 + Sqrt[(Global`s^2 + 2*Global`s*Global`t + Global`t^2 + 
                4*Q2*Global`w)/(2*Q2 + Global`s + Global`t)^2]))/
           (4*(Q2*Global`s - 2*Q2*Global`w - Global`t*Global`w)^2)])/
       (2*(Q2*Global`s - 2*Q2*Global`w - Global`t*Global`w))}, -1, 1, 1], 
   CutIntegral["R10", {1, 1, 1, 1}] -> SeriesData[Global`eps, 0, 
     {Pi/(2*Global`s*(Q2 + Global`s + Global`t - Global`w)), 
      (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[Global`w] + 
        Pi*Log[((2*Q2 + Global`s + Global`t)^2*(Global`s - Global`w)^2*
            (1 - Sqrt[(Global`s^2 + 2*Global`s*Global`t + Global`t^2 + 
                4*Q2*Global`w)/(2*Q2 + Global`s + Global`t)^2])*
            (1 + Sqrt[(Global`s^2 + 2*Global`s*Global`t + Global`t^2 + 
                4*Q2*Global`w)/(2*Q2 + Global`s + Global`t)^2]))/
           (4*Global`s^2*(Q2 + Global`s + Global`t - Global`w)^2)])/
       (2*Global`s*(Q2 + Global`s + Global`t - Global`w))}, -1, 1, 1]|>, 
 "RegionMasterMap" -> <|CutIntegral["R01", {1, 1, 1, 1}] -> 
    <|"ParameterDefinition" -> zp -> \[Lambda]^(-1), 
     "Regions" -> {{-1, -1}, {0, -1}}, "TaylorDepth" -> 0, 
     "Entries" -> {<|"Region" -> {0, -1}, "LambdaPower" -> -eps, 
        "IntegralID" -> "region_2de21a1690a6990f1b36b15c94f2c80c82fab018d3b87\
7cb1317f18cbaae2cf"|>}|>|>, "RegionValues" -> 
  <|
   "region_2de21a1690a6990f1b36b15c94f2c80c82fab018d3b877cb1317f18cbaae2cf" \
-> <|"Series" -> SeriesData[Global`eps, 0, {-1, 0, -1/6*Pi^2}, -1, 2, 1], 
     "Tuple" -> {1, u^eps/(1 + u), {u}, {}}, "Order" -> 1, 
     "InputHash" -> 318607043308081933126640570250270497772297982799728310914\
99528410315237073335, "RawOutputFile" -> "/u/scratch/r/rushil/AI_Assisted_SID\
IS/SIDIS_20260907/common/s15_cut_soft/46708504b0cfd3018765119d349407739668826\
fcaf8c6be51bab9cd7927a1b7/region_2de21a1690a6990f1b36b15c94f2c80c82fab018d3b8\
77cb1317f18cbaae2cf/s15_raw.wl", "AlgebraicLetterDefinitions" -> {}, 
     "Accepted" -> True|>|>, "InputHashes" -> 
  <|"s08_result.wl" -> 537005998558187005691005291732605032463386266422894682\
70548961267074622879573, "s10_result.wl" -> 
    9935675245460889407651453754557767720022143570864083265512395883964836188\
2195, "s11_result.wl" -> 
    8108728831168752611831698127268415791715859613867654342478311131209804481\
7653|>, "SourceHash" -> 
  926363619662699494455737778636286640509465665084895132010717069980235475186\
16, "InputHash" -> 
  318607043308081933126640570250270497772297982799728310914995284103152370733\
35, "WorkDirectory" -> "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/\
common/s15_cut_soft/46708504b0cfd3018765119d349407739668826fcaf8c6be51bab9cd7\
927a1b7", "PhysicalConditions" -> Q2 > 0 && Global`s > Global`w > 0 && 
   -Q2 - Global`s + Global`w < Global`t < -((Q2*Global`w)/Global`s), 
 "SoftPhysicalConditions" -> Q2 > 0 && Global`s > 0 && Global`t < 0 && 
   Q2 + Global`s + Global`t > 0, "AcceptedCutMasterRegions" -> True, 
 "EndpointDistributionsAssembled" -> False|>
