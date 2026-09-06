<|"sub" -> 
  <|"g" -> <|"I_gg" -> <|"delta" -> -1/16*((2 - 2*eps)*eq^2*gs^2*
           ((11*Nc)/3 - (2*nf)/3)*((2 - 2*eps)*Q2^2 - 4*eps*Q2*s + 
            (2 - 2*eps)*s^2 + 4*Q2*u + 4*s*u + 4*u^2))/((-1 + eps)*Pi^3*u*
           (Q2 + s + u)), "sing" -> 
        -((eq^2*gs^2*Nc*(2*Q2^4 + 2*Q2^3*(2*s + t + 2*u) + 
            t^2*(-((-1 + eps)*s^2) + 2*s*u + 2*u^2) + 
            Q2^2*(2*s^2 + t^2 - eps*t^2 + 2*t*u + 2*u^2 + 4*s*(t + u)) + 
            2*Q2*t*(s^2 + t*u + s*(t - eps*t + u))))/(Pi^3*t^3*u*
           (Q2 + s + u))), "reg" -> 
        -((eq^2*gs^2*Nc*(-1 - (Q2 + s + t + u)/t - (t*(Q2 + s + t + u))/
             (Q2 + s + u)^2)*(-(t^2*((-1 + eps)*s^2 - 2*s*u - 2*u^2)) + 
            2*Q2*t*(-((-1 + eps)*s*t) + t*u + s*(Q2 + s + u)) + 
            Q2^2*(-((-1 + eps)*t^2) + 2*t*(Q2 + s + u) + 2*(Q2 + s + u)^2)))/
          (Pi^3*t^3*u*(Q2 + s + u)))|>, 
     "I_qg" -> <|"delta" -> 0, "sing" -> 0, 
       "reg" -> -1/4*((-1 + eps)*eq^2*gs^2*(-1 + Nc^2)*
           (1 + (2*t^2)/(Q2 + s + u)^2 + (2*t)/(Q2 + s + u))*
           (t^2*(2*s^2 + 2*s*u - (-1 + eps)*u^2) + 
            Q2^2*(2*t^2 + 2*t*(Q2 + s + u) + (Q2 + s + u)^2 - 
              eps*(Q2 + s + u)^2) + 2*Q2*t*(2*s*t + s*(Q2 + s + u) + 
              u*(Q2 + s + t + u + eps*(Q2 + s + u)))))/(Nc*Pi^3*t^2*
           (Q2 + s + u)*(Q2^2 + s*t + Q2*(s + t + u)))|>, 
     "F_qq" -> <|"delta" -> (-3*(2 - 2*eps)*eq^2*gs^2*(-1 + Nc^2)*
          ((2 - 2*eps)*Q2^2 - 4*eps*Q2*s + (2 - 2*eps)*s^2 + 4*Q2*u + 4*s*u + 
           4*u^2))/(32*(-1 + eps)*Nc*Pi^3*u*(Q2 + s + u)), 
       "sing" -> (eq^2*gs^2*(-1 + Nc^2)*s*(2*u^2 - 
           (2*(Q2 + s)*u*(Q2 + t + u))/s - (((-1 + eps)*Q2^2 + 2*eps*Q2*s + 
              (-1 + eps)*s^2)*(Q2 + t + u)^2)/s^2))/(2*Nc*Pi^3*u*(Q2 + t + u)*
          (Q2^2 + s*t + Q2*(s + t + u))), 
       "reg" -> (eq^2*gs^2*(-1 + Nc^2)*(Q2 - s + t + u)*
          (2*u^2 - (2*(Q2 + s)*u*(Q2 + t + u))/s - 
           (((-1 + eps)*Q2^2 + 2*eps*Q2*s + (-1 + eps)*s^2)*(Q2 + t + u)^2)/
            s^2))/(4*Nc*Pi^3*u*(Q2 + t + u)*(Q2^2 + s*t + 
           Q2*(s + t + u)))|>|>, 
   "pp" -> <|"I_gg" -> <|"delta" -> -1/4*(eq^2*gs^2*((11*Nc)/3 - (2*nf)/3)*s)/
          ((-1 + eps)*Pi^3), "sing" -> -((eq^2*gs^2*Nc*(Q2 + s + u)*
           (Q2^2 + s*t + Q2*(s + t + u)))/((-1 + eps)*Pi^3*t^3)), 
       "reg" -> -((eq^2*gs^2*Nc*(Q2 + s + u)*(Q2^2 + s*t + Q2*(s + t + u))*
           (-1 - (Q2 + s + t + u)/t - (t*(Q2 + s + t + u))/(Q2 + s + u)^2))/
          ((-1 + eps)*Pi^3*t^3))|>, "I_qg" -> <|"delta" -> 0, "sing" -> 0, 
       "reg" -> ((-1 + eps)*eq^2*gs^2*(-1 + Nc^2)*u*(Q2 + s + u)*
          (1 + (2*t^2)/(Q2 + s + u)^2 + (2*t)/(Q2 + s + u)))/
         (8*Nc*Pi^3*t^2)|>, "F_qq" -> 
      <|"delta" -> (-3*eq^2*gs^2*(-1 + Nc^2)*s)/(8*(-1 + eps)*Nc*Pi^3), 
       "sing" -> (eq^2*gs^2*(-1 + Nc^2)*s)/(2*(-1 + eps)*Nc*Pi^3*
          (Q2 + t + u)), "reg" -> (eq^2*gs^2*(-1 + Nc^2)*(Q2 - s + t + u))/
         (4*(-1 + eps)*Nc*Pi^3*(Q2 + t + u))|>|>|>, 
 "xi0" -> -(t/(Q2 + s + u)), "zt0" -> (-Q2 - t - u)/s, "jacI" -> Q2 + s + u, 
 "jacF" -> -(s^2/(Q2 + t + u)), 
 "inv" -> {xh -> Q2/(Q2 + s), zh -> -(u/(Q2 + s)), 
   kT2 -> (u*(Q2^2 + Q2*s + Q2*t + s*t + Q2*u))/(Q2 + s)^2}, 
 "LOgq" -> <|"g" -> -1/16*((2 - 2*eps)*eq^2*gs^2*((2 - 2*eps)*Q2^2 - 
        4*eps*Q2*s + (2 - 2*eps)*s^2 + 4*Q2*u + 4*s*u + 4*u^2))/
      ((-1 + eps)*Pi^3*u*(Q2 + s + u)), 
   "pp" -> -1/4*(eq^2*gs^2*s)/((-1 + eps)*Pi^3)|>, 
 "LOqq" -> <|"g" -> -1/16*((2 - 2*eps)*eq^2*gs^2*(-1 + Nc^2)*
       ((2 - 2*eps)*Q2^2 + 4*Q2*s + 4*s^2 - 4*eps*Q2*u + 4*s*u + 
        (2 - 2*eps)*u^2))/(Nc*Pi^3*s*(Q2 + s + u)), 
   "pp" -> -1/16*((2 - 2*eps)*eq^2*gs^2*(-1 + Nc^2)*u)/(Nc*Pi^3)|>, 
 "P" -> <|"qq" -> <|"reg" -> ((-1 + Nc^2)*(-1 - xx))/Nc, 
     "plus" -> (2*(-1 + Nc^2))/Nc, "delta" -> (3*(-1 + Nc^2))/(2*Nc)|>, 
   "qg" -> <|"reg" -> (1 - xx)^2 + xx^2, "plus" -> 0, "delta" -> 0|>, 
   "gg" -> <|"reg" -> 4*Nc*(-1 + (1 - xx)/xx + (1 - xx)*xx), "plus" -> 4*Nc, 
     "delta" -> (11*Nc)/3 - (2*nf)/3|>|>|>
