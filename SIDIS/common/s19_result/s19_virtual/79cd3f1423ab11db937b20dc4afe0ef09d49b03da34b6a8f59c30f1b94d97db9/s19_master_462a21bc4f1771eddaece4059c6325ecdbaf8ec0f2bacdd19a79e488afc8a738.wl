<|"Master" -> FeynCalc`GLI["V08", {1, 1, 1, 1}], 
 "Series" -> SeriesData[eps, 0, {((-2*I)*Pi^2)/(t*(Q2 + s + t)), 
    ((2*I)*EulerGamma*Pi^2)/(t*(Q2 + s + t)) + ((2*I)*Pi^2*Log[Pi])/
      (t*(Q2 + s + t)) + ((2*I)*Pi^2*Log[-t])/(t*(Q2 + s + t)) + 
     (I*Pi^2*Log[-(t/Q2)])/(t*(Q2 + s + t)) - (I*Pi^2*Log[Q2/(Q2 + s + t)])/
      (t*(Q2 + s + t)) - (I*Pi^2*Log[-(t/(Q2 + s + t))])/(t*(Q2 + s + t)), 
    ((-1/2*I)*Pi^2*(2*EulerGamma^2 - Pi^2))/(t*(Q2 + s + t)) - 
     (I*Pi^2*Log[Pi]^2)/(t*(Q2 + s + t)) - (I*Pi^2*Log[-t]^2)/
      (t*(Q2 + s + t)) - ((I/2)*Pi^2*Log[-(t/Q2)]^2)/(t*(Q2 + s + t)) + 
     (I*EulerGamma*Pi^2*Log[Q2/(Q2 + s + t)])/(t*(Q2 + s + t)) - 
     ((I/2)*Pi^2*Log[Q2/(Q2 + s + t)]^2)/(t*(Q2 + s + t)) + 
     Log[-(t/Q2)]*(((-I)*EulerGamma*Pi^2)/(t*(Q2 + s + t)) - 
       (I*Pi^2*Log[Q2/(Q2 + s + t)])/(t*(Q2 + s + t))) + 
     (I*EulerGamma*Pi^2*Log[-(t/(Q2 + s + t))])/(t*(Q2 + s + t)) + 
     ((I/2)*Pi^2*Log[-(t/(Q2 + s + t))]^2)/(t*(Q2 + s + t)) + 
     Log[-t]*(((-2*I)*EulerGamma*Pi^2)/(t*(Q2 + s + t)) - 
       (I*Pi^2*Log[-(t/Q2)])/(t*(Q2 + s + t)) + (I*Pi^2*Log[Q2/(Q2 + s + t)])/
        (t*(Q2 + s + t)) + (I*Pi^2*Log[-(t/(Q2 + s + t))])/
        (t*(Q2 + s + t))) + Log[Pi]*(((-2*I)*EulerGamma*Pi^2)/
        (t*(Q2 + s + t)) - ((2*I)*Pi^2*Log[-t])/(t*(Q2 + s + t)) - 
       (I*Pi^2*Log[-(t/Q2)])/(t*(Q2 + s + t)) + (I*Pi^2*Log[Q2/(Q2 + s + t)])/
        (t*(Q2 + s + t)) + (I*Pi^2*Log[-(t/(Q2 + s + t))])/
        (t*(Q2 + s + t))) - ((2*I)*Pi^2*PolyLog[2, (Q2 + t)/Q2])/
      (t*(Q2 + s + t)) + ((2*I)*Pi^2*PolyLog[2, (s + t)/(Q2 + s + t)])/
      (t*(Q2 + s + t))}, -2, 1, 1], "FunctionLimits" -> 
  {Log[c14] -> Log[-t], Log[c14/c23] -> Log[-(t/(Q2 + s + t))], 
   Log[c14/c34] -> Log[-(t/Q2)], Log[c34/c23] -> Log[Q2/(Q2 + s + t)], 
   Log[Pi] -> Log[Pi], PolyLog[2, 1 - c14/c34] -> PolyLog[2, (Q2 + t)/Q2], 
   PolyLog[2, 1 - c34/c23] -> PolyLog[2, (s + t)/(Q2 + s + t)]}, 
 "FeynmanDeformation" -> {c14 -> (-I)*eta - t, c23 -> (-I)*eta + Q2 + s + t, 
   c34 -> (-I)*eta + Q2}, "FeynmanPolynomial" -> 
  c23*x[2]*x[3] + c14*x[1]*x[4] + c34*x[3]*x[4], 
 "ImaginaryPart" -> -(eta*x[2]*x[3]) - eta*x[1]*x[4] - eta*x[3]*x[4], 
 "Conditions" -> Q2 > 0 && s > 0 && t < 0 && Q2 + s + t > 0 && mu > 0 && 
   FeynCalc`SUNN > 1, "InputHash" -> 5509249367982988715374144206503847618067\
2181974941233453711375385952425442745, 
 "SourceHash" -> 832456391997098265111269703459545717429344271676344692934636\
34383568810243695, "Accepted" -> True|>
