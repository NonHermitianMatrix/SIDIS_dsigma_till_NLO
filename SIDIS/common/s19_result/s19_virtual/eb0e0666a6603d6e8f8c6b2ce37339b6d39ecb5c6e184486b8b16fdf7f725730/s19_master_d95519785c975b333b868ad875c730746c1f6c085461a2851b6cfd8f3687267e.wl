<|"Master" -> FeynCalc`GLI["V06", {1, 1, 1, 1}], 
 "Series" -> SeriesData[eps, 0, {((2*I)*Pi^2)/(s*t), 
    ((-2*I)*(EulerGamma - I*Pi)*Pi^2)/(s*t) - ((2*I)*Pi^2*Log[Pi])/(s*t) + 
     (I*Pi^2*Log[Q2/s])/(s*t) - ((2*I)*Pi^2*Log[-t])/(s*t) - 
     (I*Pi^2*Log[-(t/Q2)])/(s*t) + (I*Pi^2*Log[-(t/s)])/(s*t), 
    (Pi^2*((2*I)*EulerGamma^2 + 4*EulerGamma*Pi - I*Pi^2))/(2*s*t) + 
     (I*Pi^2*Log[Pi]^2)/(s*t) + ((I/2)*Pi^2*Log[Q2/s]^2)/(s*t) + 
     (I*Pi^2*Log[-t]^2)/(s*t) + (I*(EulerGamma + I*Pi)*Pi^2*Log[-(t/Q2)])/
      (s*t) + ((I/2)*Pi^2*Log[-(t/Q2)]^2)/(s*t) + 
     Log[Q2/s]*(((-I)*(EulerGamma - I*Pi)*Pi^2)/(s*t) - 
       (I*Pi^2*Log[-t])/(s*t) + (I*Pi^2*Log[-(t/Q2)])/(s*t)) + 
     (Pi^2*((-I)*EulerGamma + Pi)*Log[-(t/s)])/(s*t) - 
     ((I/2)*Pi^2*Log[-(t/s)]^2)/(s*t) + 
     Log[-t]*((2*Pi^2*(I*EulerGamma + Pi))/(s*t) + (I*Pi^2*Log[-(t/Q2)])/
        (s*t) - (I*Pi^2*Log[-(t/s)])/(s*t)) + 
     Log[Pi]*((2*Pi^2*(I*EulerGamma + Pi))/(s*t) - (I*Pi^2*Log[Q2/s])/(s*t) + 
       ((2*I)*Pi^2*Log[-t])/(s*t) + (I*Pi^2*Log[-(t/Q2)])/(s*t) - 
       (I*Pi^2*Log[-(t/s)])/(s*t)) - ((2*I)*Pi^2*PolyLog[2, (Q2 + s)/s])/
      (s*t) + ((2*I)*Pi^2*PolyLog[2, (Q2 + t)/Q2])/(s*t)}, -2, 1, 1], 
 "FunctionLimits" -> {Log[c14] -> Log[-t], Log[c14/c23] -> 
    I*Pi + Log[-(t/s)], Log[c14/c34] -> Log[-(t/Q2)], 
   Log[c34/c23] -> I*Pi + Log[Q2/s], Log[Pi] -> Log[Pi], 
   PolyLog[2, 1 - c14/c34] -> PolyLog[2, (Q2 + t)/Q2], 
   PolyLog[2, 1 - c34/c23] -> PolyLog[2, (Q2 + s)/s]}, 
 "FeynmanDeformation" -> {c14 -> (-I)*eta - t, c23 -> (-I)*eta - s, 
   c34 -> (-I)*eta + Q2}, "FeynmanPolynomial" -> 
  c23*x[2]*x[3] + c14*x[1]*x[4] + c34*x[3]*x[4], 
 "ImaginaryPart" -> -(eta*x[2]*x[3]) - eta*x[1]*x[4] - eta*x[3]*x[4], 
 "Conditions" -> Q2 > 0 && s > 0 && t < 0 && Q2 + s + t > 0 && mu > 0 && 
   FeynCalc`SUNN > 1, "InputHash" -> 1063182994538885706846712193346240578114\
28017438232371861006084351120804828976, "SourceHash" -> 108962781665913047106\
377405721414951605651829272962170432160691405977789261788, 
 "Accepted" -> True|>
