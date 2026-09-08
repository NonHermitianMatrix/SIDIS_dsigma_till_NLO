<|"BornPg" -> (-2*Q2^2 + D*Q2^2 - 8*Q2*s + 2*D*Q2*s - 2*s^2 + D*s^2 + 
    4*Q2*t + 4*s*t + 4*t^2)/(t*(Q2 + s + t)), "BornPpp" -> (4*s)/(-2 + D), 
 "AuxHqqBorn" -> <|"Pg" -> ((-2 + D)*(-1 + SUNN)*(1 + SUNN)*
      (4*Q2^2 + 4*Q2*s - 2*s^2 + D*s^2 + 4*Q2*t - 8*s*t + 2*D*s*t - 2*t^2 + 
       D*t^2))/(2*s*SUNN*t), "Ppp" -> ((-2 + D)*(-1 + SUNN)*(1 + SUNN)*
      (Q2 + s + t))/(2*SUNN)|>, "BornChecks" -> 
  <|"Hgq" -> <|"Pg" -> (-2*Q2^2 + D*Q2^2 - 8*Q2*s + 2*D*Q2*s - 2*s^2 + 
        D*s^2 + 4*Q2*t + 4*s*t + 4*t^2)/(t*(Q2 + s + t)), 
     "Ppp" -> (4*s)/(-2 + D), "PhotonWard" -> 0, "GluonWard" -> 0|>, 
   "AuxHqq" -> <|"Pg" -> ((-2 + D)*(-1 + SUNN)*(1 + SUNN)*
        (4*Q2^2 + 4*Q2*s - 2*s^2 + D*s^2 + 4*Q2*t - 8*s*t + 2*D*s*t - 2*t^2 + 
         D*t^2))/(2*s*SUNN*t), "Ppp" -> ((-2 + D)*(-1 + SUNN)*(1 + SUNN)*
        (Q2 + s + t))/(2*SUNN), "PhotonWard" -> 0, "GluonWard" -> 0|>|>, 
 "ModelChargeSquared" -> 4/9, "ColorConstants" -> 
  <|"CF" -> ((-1 + SUNN)*(1 + SUNN))/(2*SUNN), "TF" -> 1/2, "CA" -> SUNN|>, 
 "FundamentalDimension" -> SUNN, "AdjointDimension" -> -1 + SUNN^2, 
 "GluonSpinCount" -> -2 + D, "InitialAverages" -> 
  <|"Hgq" -> 1/((-2 + D)*(-1 + SUNN)*(1 + SUNN)), "AuxHqq" -> 1/(2*SUNN)|>, 
 "BornScalarProducts" -> {{p, p, 0}, {p, q, (Q2 + s)/2}, 
   {p, k1, (Q2 + s + t)/2}, {p, k2, -1/2*t}, {q, q, -Q2}, 
   {q, k1, (-Q2 - t)/2}, {q, k2, (s + t)/2}, {k1, k1, 0}, {k1, k2, s/2}, 
   {k2, k2, 0}}, "RealScalarProducts" -> {{p, p, 0}, {p, q, (Q2 + s)/2}, 
   {p, k1, (Q2 + s - s23 + t)/2}, {p, k2, (s23 - t + u3)/2}, 
   {p, k3, -1/2*u3}, {q, q, -Q2}, {q, k1, (-Q2 - t)/2}, 
   {q, k2, (a12 + t - u3)/2}, {q, k3, (-a12 + s + u3)/2}, {k1, k1, 0}, 
   {k1, k2, a12/2}, {k1, k3, (-a12 + s - s23)/2}, {k2, k2, 0}, 
   {k2, k3, s23/2}, {k3, k3, 0}}, "BornKinematics" -> 
  {xh -> Q2/(Q2 + s), zh -> (Q2 + s + t)/(Q2 + s), 
   qT2 -> -((s*t)/(Q2 + s + t))}, "BornU" -> -Q2 - s - t, 
 "ProjectorsD" -> {f1 -> -((-4*hpp*Q2 + hg*Q2^2 + 2*hg*Q2*s + hg*s^2)/
      ((-2 + D)*(Q2 + s)^2)), 
   f2 -> (-2*Q2*(4*hpp*Q2 - 4*D*hpp*Q2 + hg*Q2^2 + 2*hg*Q2*s + hg*s^2))/
     ((-2 + D)*(Q2 + s)^3)}, "ProjectorsEpsilon" -> 
  {f1 -> (-1/2*hg + (2*hpp*xh^2)/Q2)/(1 - eps), 
   f2 -> (-(hg*xh) + (4*(3 - 2*eps)*hpp*xh^3)/Q2)/(1 - eps)}, 
 "Dimension" -> D, "CouplingsRemoved" -> "eq^2 gs^2", 
 "AuthorsCoefficientsUsed" -> False, "InputHashes" -> 
  <|"s01_result.wl" -> 655471340322074087856599014813249585032429371163428251\
81730381327027082815723|>, "SourceHash" -> 
  347662555394261671985216935009174918922135522591926803852133385664679516863\
69|>
