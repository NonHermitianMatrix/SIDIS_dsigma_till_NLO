<|"ColorAverage" -> ((-1 + SUNN)*(1 + SUNN))/(2*SUNN), 
 "BornPg" -> -1/2*((-2 + D)*(-1 + SUNN)*(1 + SUNN)*
     (-2*Q2^2 + D*Q2^2 + 4*Q2*s + 4*s^2 - 8*Q2*t + 2*D*Q2*t + 4*s*t - 2*t^2 + 
      D*t^2))/(s*SUNN*(Q2 + s + t)), 
 "BornPpp" -> -1/2*((-2 + D)*(-1 + SUNN)*(1 + SUNN)*t)/SUNN, 
 "BornKinematics" -> {xh -> Q2/(Q2 + s), zh -> (Q2 + s + t)/(Q2 + s), 
   qT2 -> -((s*t)/(Q2 + s + t))}, "BornInvariants" -> 
  {pq -> (Q2 + s)/2, qk -> (-Q2 - t)/2, pk -> (Q2 + s + t)/2, 
   u -> -Q2 - s - t}, "ProjectorsD" -> 
  {f1 -> -((-4*hpp*Q2 + hg*Q2^2 + 2*hg*Q2*s + hg*s^2)/((-2 + D)*(Q2 + s)^2)), 
   f2 -> (-2*Q2*(4*hpp*Q2 - 4*D*hpp*Q2 + hg*Q2^2 + 2*hg*Q2*s + hg*s^2))/
     ((-2 + D)*(Q2 + s)^3)}, "ProjectorsEpsilon" -> 
  {f1 -> (-1/2*hg + (2*hpp*xh^2)/Q2)/(1 - eps), 
   f2 -> (-(hg*xh) + (4*(3 - 2*eps)*hpp*xh^3)/Q2)/(1 - eps)}, 
 "Inputs" -> "QCD tree vertices, paper invariant definitions and tensor \
decomposition; no authors coefficient input", 
 "Checks" -> <|"PhotonWard" -> 0, "GluonWard" -> 0|>|>
