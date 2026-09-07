<|"Tensor" -> "RealSame_Charge0__Pg", "Branch" -> -1, "Power" -> {1, -2}, 
 "Residual" -> 0, "Assumptions" -> Q2 > 0 && s > 0 && omega > 0 && mu > 0 && 
   SUNN > 1 && B > 0 && -Q2 - s < -omega - s < 0, 
 "InputRows" -> 
  {{1, -1, -1/4*((-Q2 + eps*EulerGamma*Q2 - s - eps*s + eps*EulerGamma*s)*
        (-1 + SUNN)*(1 + SUNN))/(Pi*s*SUNN^2) + 
     (eps*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[2])/(2*Pi*s*SUNN^2) + 
     (eps*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(2*Pi*s*SUNN^2) + 
     (eps*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(4*Pi*s*SUNN^2)}, 
   {1, -1, ((-Q2 + eps*EulerGamma*Q2 - s - eps*s + eps*EulerGamma*s)*
       (-1 + SUNN)*(1 + SUNN))/(4*Pi*s*SUNN^2) - 
     (eps*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[2])/(2*Pi*s*SUNN^2) - 
     (eps*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(2*Pi*s*SUNN^2) - 
     (eps*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(4*Pi*s*SUNN^2)}, 
   {1, -1, ((-1 + eps*EulerGamma)*(2*Q2 + s)*(-1 + SUNN)*(1 + SUNN))/
      (8*Pi*s*SUNN^2) - (eps*(2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (4*Pi*s*SUNN^2) - (eps*(2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (4*Pi*s*SUNN^2) - (eps*(2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (8*Pi*s*SUNN^2)}, 
   {1, -1, -1/8*((-1 + eps*EulerGamma)*(omega + 2*Q2 + 2*s)*(-1 + SUNN)*
        (1 + SUNN))/(Pi*s*SUNN^2) + (eps*(omega + 2*Q2 + 2*s)*(-1 + SUNN)*
       (1 + SUNN)*Log[2])/(4*Pi*s*SUNN^2) + 
     (eps*(omega + 2*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (4*Pi*s*SUNN^2) + (eps*(omega + 2*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*
       Log[Pi])/(8*Pi*s*SUNN^2)}, 
   {1, -1, ((-1 + eps*EulerGamma)*(omega + s)*(-1 + SUNN)*(1 + SUNN))/
      (8*Pi*s*SUNN^2) - (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (4*Pi*s*SUNN^2) - (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (4*Pi*s*SUNN^2) - (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (8*Pi*s*SUNN^2)}, 
   {1, -1, -1/12*((-9*omega^2 - 9*eps*omega^2 + 9*eps*EulerGamma*omega^2 + 
         2*eps*omega^2*Pi^2 + 6*omega*Q2 + 6*eps*omega*Q2 - 
         6*eps*EulerGamma*omega*Q2 - 4*eps*omega*Pi^2*Q2 + 2*eps*Pi^2*Q2^2)*s*
        (-1 + SUNN)*(1 + SUNN))/(omega^3*Pi*SUNN^2) + 
     (eps*(3*omega - 2*Q2)*s*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (2*omega^2*Pi*SUNN^2) + (eps*(3*omega - 2*Q2)*s*(-1 + SUNN)*(1 + SUNN)*
       Log[mu])/(2*omega^2*Pi*SUNN^2) + (eps*(3*omega - 2*Q2)*s*(-1 + SUNN)*
       (1 + SUNN)*Log[Pi])/(4*omega^2*Pi*SUNN^2) - 
     (eps*(omega - Q2)^2*s*(-1 + SUNN)*(1 + SUNN)*Log[Q2]^2)/
      (4*omega^3*Pi*SUNN^2) + (3*eps*(omega - Q2)^2*s*(-1 + SUNN)*(1 + SUNN)*
       Log[-omega + Q2]^2)/(4*omega^3*Pi*SUNN^2) + 
     Log[Q2]*((eps*(omega - Q2)^2*s*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
        (omega^3*Pi*SUNN^2) + (eps*(omega - Q2)^2*s*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(omega^3*Pi*SUNN^2) + (eps*(omega - Q2)^2*s*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(2*omega^3*Pi*SUNN^2) - 
       (eps*(omega - Q2)^2*s*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/
        (2*omega^3*Pi*SUNN^2) + ((omega - Q2)^2*s*(-1 + SUNN)*(1 + SUNN)*
         (1 - eps - 2*eps*EulerGamma + (2*I)*eps*Pi - eps*PolyGamma[0, 1/2]))/
        (2*omega^3*Pi*SUNN^2)) + Log[-omega + Q2]*
      (-((eps*(omega - Q2)^2*s*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
         (omega^3*Pi*SUNN^2)) - (eps*(omega - Q2)^2*s*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(omega^3*Pi*SUNN^2) - (eps*(omega - Q2)^2*s*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(2*omega^3*Pi*SUNN^2) + 
       ((omega - Q2)^2*s*(-1 + SUNN)*(1 + SUNN)*(-1 + eps + 
          2*eps*EulerGamma - (2*I)*eps*Pi + eps*PolyGamma[0, 1/2]))/
        (2*omega^3*Pi*SUNN^2)) + (eps*(omega - Q2)^2*s*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, -(Q2/(omega - Q2))])/(omega^3*Pi*SUNN^2)}, 
   {1, -1, -1/4*((-1 - eps + eps*EulerGamma)*(-1 + SUNN)*(1 + SUNN))/
       (Pi*SUNN^2) + (eps*(-1 + SUNN)*(1 + SUNN)*Log[2])/(2*Pi*SUNN^2) + 
     (eps*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(2*Pi*SUNN^2) + 
     (eps*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(4*Pi*SUNN^2)}, 
   {1, -1, -1/6*((-3*omega^2 - 6*eps*omega^2 + 3*eps*EulerGamma*omega^2 + 
         eps*omega^2*Pi^2 + 6*omega*Q2 + 9*eps*omega*Q2 - 
         6*eps*EulerGamma*omega*Q2 - 3*eps*omega*Pi^2*Q2 + 2*eps*Pi^2*Q2^2 + 
         3*omega*s + 3*eps*omega*s - 3*eps*EulerGamma*omega*s - 
         eps*omega*Pi^2*s + eps*Pi^2*Q2*s)*(-1 + SUNN)*(1 + SUNN))/
       (omega^2*Pi*SUNN^2) + (eps*(omega - 2*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*
       Log[2])/(omega*Pi*SUNN^2) + (eps*(omega - 2*Q2 - s)*(-1 + SUNN)*
       (1 + SUNN)*Log[mu])/(omega*Pi*SUNN^2) + 
     (eps*(omega - 2*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (2*omega*Pi*SUNN^2) - (eps*(omega - Q2)*(omega - 2*Q2 - s)*(-1 + SUNN)*
       (1 + SUNN)*Log[Q2]^2)/(4*omega^2*Pi*SUNN^2) + 
     (3*eps*(omega - Q2)*(omega - 2*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*
       Log[-omega + Q2]^2)/(4*omega^2*Pi*SUNN^2) + 
     Log[-omega + Q2]*(-((eps*(omega - Q2)*(omega - 2*Q2 - s)*(-1 + SUNN)*
          (1 + SUNN)*Log[mu])/(omega^2*Pi*SUNN^2)) - 
       (eps*(omega - Q2)*(omega - 2*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(omega^2*Pi*SUNN^2) - 
       (eps*(omega - Q2)*(omega - 2*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (2*omega^2*Pi*SUNN^2) + ((omega - Q2)*(-1 + SUNN)*(1 + SUNN)*
         (-omega + 2*eps*EulerGamma*omega - (2*I)*eps*omega*Pi + 2*Q2 - 
          eps*Q2 - 4*eps*EulerGamma*Q2 + (4*I)*eps*Pi*Q2 + s - eps*s - 
          2*eps*EulerGamma*s + (2*I)*eps*Pi*s + eps*omega*PolyGamma[0, 1/2] - 
          2*eps*Q2*PolyGamma[0, 1/2] - eps*s*PolyGamma[0, 1/2]))/
        (2*omega^2*Pi*SUNN^2)) + 
     Log[Q2]*((eps*(omega - Q2)*(omega - 2*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*
         Log[mu])/(omega^2*Pi*SUNN^2) + (eps*(omega - Q2)*(omega - 2*Q2 - s)*
         (-1 + SUNN)*(1 + SUNN)*Log[omega])/(omega^2*Pi*SUNN^2) + 
       (eps*(omega - Q2)*(omega - 2*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (2*omega^2*Pi*SUNN^2) - (eps*(omega - Q2)*(omega - 2*Q2 - s)*
         (-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/(2*omega^2*Pi*SUNN^2) + 
       ((omega - Q2)*(-1 + SUNN)*(1 + SUNN)*(omega - 2*eps*EulerGamma*omega + 
          (2*I)*eps*omega*Pi - 2*Q2 + eps*Q2 + 4*eps*EulerGamma*Q2 - 
          (4*I)*eps*Pi*Q2 - s + eps*s + 2*eps*EulerGamma*s - (2*I)*eps*Pi*s - 
          eps*omega*PolyGamma[0, 1/2] + 2*eps*Q2*PolyGamma[0, 1/2] + 
          eps*s*PolyGamma[0, 1/2]))/(2*omega^2*Pi*SUNN^2)) + 
     (eps*(omega - Q2)*(omega - 2*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, -(Q2/(omega - Q2))])/(omega^2*Pi*SUNN^2)}, 
   {1, -1, -1/4*((-1 - eps + eps*EulerGamma)*(omega - 2*Q2)*(-1 + SUNN)*
        (1 + SUNN))/(Pi*s*SUNN^2) + (eps*(omega - 2*Q2)*(-1 + SUNN)*
       (1 + SUNN)*Log[2])/(2*Pi*s*SUNN^2) + 
     (eps*(omega - 2*Q2)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(2*Pi*s*SUNN^2) + 
     (eps*(omega - 2*Q2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(4*Pi*s*SUNN^2)}, 
   {1, -1, -1/12*(eps*Pi*(omega^2 - 2*omega*Q2 + 2*Q2^2 - omega*s + 2*Q2*s)*
        (-1 + SUNN)*(1 + SUNN))/(omega*s*SUNN^2) - 
     (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 - omega*s + 2*Q2*s)*(-1 + SUNN)*
       (1 + SUNN)*Log[Q2]^2)/(8*omega*Pi*s*SUNN^2) + 
     (3*eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 - omega*s + 2*Q2*s)*(-1 + SUNN)*
       (1 + SUNN)*Log[-omega + Q2]^2)/(8*omega*Pi*s*SUNN^2) + 
     Log[Q2]*((eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 - omega*s + 2*Q2*s)*
         (-1 + SUNN)*(1 + SUNN)*Log[mu])/(2*omega*Pi*s*SUNN^2) + 
       (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 - omega*s + 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[omega])/(2*omega*Pi*s*SUNN^2) + 
       (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 - omega*s + 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(4*omega*Pi*s*SUNN^2) - 
       (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 - omega*s + 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[-omega + Q2])/(4*omega*Pi*s*SUNN^2) + 
       ((-1 + SUNN)*(1 + SUNN)*(omega^2 - 2*eps*omega^2 - 
          2*eps*EulerGamma*omega^2 + (2*I)*eps*omega^2*Pi - 2*omega*Q2 + 
          2*eps*omega*Q2 + 4*eps*EulerGamma*omega*Q2 - (4*I)*eps*omega*Pi*
           Q2 + 2*Q2^2 - 2*eps*Q2^2 - 4*eps*EulerGamma*Q2^2 + 
          (4*I)*eps*Pi*Q2^2 - omega*s - eps*omega*s + 2*eps*EulerGamma*omega*
           s - (2*I)*eps*omega*Pi*s + 2*Q2*s - 4*eps*EulerGamma*Q2*s + 
          (4*I)*eps*Pi*Q2*s - eps*omega^2*PolyGamma[0, 1/2] + 
          2*eps*omega*Q2*PolyGamma[0, 1/2] - 2*eps*Q2^2*PolyGamma[0, 1/2] + 
          eps*omega*s*PolyGamma[0, 1/2] - 2*eps*Q2*s*PolyGamma[0, 1/2]))/
        (4*omega*Pi*s*SUNN^2)) + Log[-omega + Q2]*
      (-1/2*(eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 - omega*s + 2*Q2*s)*
          (-1 + SUNN)*(1 + SUNN)*Log[mu])/(omega*Pi*s*SUNN^2) - 
       (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 - omega*s + 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[omega])/(2*omega*Pi*s*SUNN^2) - 
       (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 - omega*s + 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(4*omega*Pi*s*SUNN^2) + 
       ((-1 + SUNN)*(1 + SUNN)*(-omega^2 + 2*eps*omega^2 + 
          2*eps*EulerGamma*omega^2 - (2*I)*eps*omega^2*Pi + 2*omega*Q2 - 
          2*eps*omega*Q2 - 4*eps*EulerGamma*omega*Q2 + (4*I)*eps*omega*Pi*
           Q2 - 2*Q2^2 + 2*eps*Q2^2 + 4*eps*EulerGamma*Q2^2 - 
          (4*I)*eps*Pi*Q2^2 + omega*s + eps*omega*s - 2*eps*EulerGamma*omega*
           s + (2*I)*eps*omega*Pi*s - 2*Q2*s + 4*eps*EulerGamma*Q2*s - 
          (4*I)*eps*Pi*Q2*s + eps*omega^2*PolyGamma[0, 1/2] - 
          2*eps*omega*Q2*PolyGamma[0, 1/2] + 2*eps*Q2^2*PolyGamma[0, 1/2] - 
          eps*omega*s*PolyGamma[0, 1/2] + 2*eps*Q2*s*PolyGamma[0, 1/2]))/
        (4*omega*Pi*s*SUNN^2)) + (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 - 
        omega*s + 2*Q2*s)*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, -(Q2/(omega - Q2))])/(2*omega*Pi*s*SUNN^2)}, 
   {1, -1, -1/16*((-4*omega - 4*eps^2*omega + 4*eps*EulerGamma*omega - 
         2*eps^2*EulerGamma^2*omega + eps^2*omega*Pi^2 + 4*Q2 - 4*eps*Q2 - 
         4*eps*EulerGamma*Q2 + 4*eps^2*EulerGamma*Q2 + 2*eps^2*EulerGamma^2*
          Q2 - eps^2*Pi^2*Q2)*(-1 + SUNN)*(1 + SUNN))/(eps*Pi*s*SUNN^2) + 
     (eps*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*Log[2]^2)/(2*Pi*s*SUNN^2) + 
     (eps*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*Log[mu]^2)/(2*Pi*s*SUNN^2) - 
     ((-omega + eps*EulerGamma*omega + Q2 - eps*Q2 - eps*EulerGamma*Q2)*
       (-1 + SUNN)*(1 + SUNN)*Log[Pi])/(4*Pi*s*SUNN^2) + 
     (eps*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi]^2)/(8*Pi*s*SUNN^2) + 
     Log[mu]*(-1/2*((-omega + eps*EulerGamma*omega + Q2 - eps*Q2 - 
           eps*EulerGamma*Q2)*(-1 + SUNN)*(1 + SUNN))/(Pi*s*SUNN^2) + 
       (eps*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(2*Pi*s*SUNN^2)) + 
     Log[2]*(-1/2*((-omega + eps*EulerGamma*omega + Q2 - eps*Q2 - 
           eps*EulerGamma*Q2)*(-1 + SUNN)*(1 + SUNN))/(Pi*s*SUNN^2) + 
       (eps*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(Pi*s*SUNN^2) + 
       (eps*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(2*Pi*s*SUNN^2))}, 
   {1, -1, -1/16*((4*eps*omega - 4*eps^2*omega - 4*eps^2*EulerGamma*omega - 
         4*Q2 + 4*eps*Q2 + 4*eps*EulerGamma*Q2 - 4*eps^2*EulerGamma*Q2 - 
         2*eps^2*EulerGamma^2*Q2 + eps^2*Pi^2*Q2 - 4*s + 4*eps*s + 
         4*eps^2*s + 4*eps*EulerGamma*s - 4*eps^2*EulerGamma*s - 
         2*eps^2*EulerGamma^2*s + eps^2*Pi^2*s)*(-1 + SUNN)*(1 + SUNN))/
       (eps*Pi*s*SUNN^2) + (eps*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[2]^2)/
      (2*Pi*s*SUNN^2) + (eps*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[mu]^2)/
      (2*Pi*s*SUNN^2) - ((eps*omega - Q2 + eps*Q2 + eps*EulerGamma*Q2 - s + 
        eps*s + eps*EulerGamma*s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*Pi*s*SUNN^2) + (eps*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi]^2)/
      (8*Pi*s*SUNN^2) + Log[mu]*
      (-1/2*((eps*omega - Q2 + eps*Q2 + eps*EulerGamma*Q2 - s + eps*s + 
           eps*EulerGamma*s)*(-1 + SUNN)*(1 + SUNN))/(Pi*s*SUNN^2) + 
       (eps*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(2*Pi*s*SUNN^2)) + 
     Log[2]*(-1/2*((eps*omega - Q2 + eps*Q2 + eps*EulerGamma*Q2 - s + eps*s + 
           eps*EulerGamma*s)*(-1 + SUNN)*(1 + SUNN))/(Pi*s*SUNN^2) + 
       (eps*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(Pi*s*SUNN^2) + 
       (eps*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(2*Pi*s*SUNN^2))}, 
   {1, -1, ((-12*omega + 24*eps*omega - 12*eps^2*omega + 
        12*eps*EulerGamma*omega - 24*eps^2*EulerGamma*omega - 
        6*eps^2*EulerGamma^2*omega + eps^2*omega*Pi^2 - 12*s + 12*eps*s + 
        12*eps^2*s + 12*eps*EulerGamma*s - 12*eps^2*EulerGamma*s - 
        6*eps^2*EulerGamma^2*s + eps^2*Pi^2*s)*(-1 + SUNN)*(1 + SUNN))/
      (48*eps*Pi*s*SUNN^2) - (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*
       Log[2]^2)/(2*Pi*s*SUNN^2) - (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*
       Log[mu]^2)/(2*Pi*s*SUNN^2) - (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*
       Log[Pi]^2)/(8*Pi*s*SUNN^2) + 
     (((-omega + 2*eps*omega + eps*EulerGamma*omega - s + eps*s + 
          eps*EulerGamma*s)*(-1 + SUNN)*(1 + SUNN))/(4*Pi*s*SUNN^2) - 
       (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[omega])/(4*Pi*s*SUNN^2))*
      Log[Q2] + (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[Q2]^2)/
      (8*Pi*s*SUNN^2) + 
     (-1/4*((-omega + 2*eps*omega + eps*EulerGamma*omega - s + eps*s + 
           eps*EulerGamma*s)*(-1 + SUNN)*(1 + SUNN))/(Pi*s*SUNN^2) + 
       (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[omega])/(4*Pi*s*SUNN^2))*
      Log[-omega + Q2] - (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*
       Log[-omega + Q2]^2)/(8*Pi*s*SUNN^2) + 
     Log[Pi]*(((-omega + 2*eps*omega + eps*EulerGamma*omega - s + eps*s + 
          eps*EulerGamma*s)*(-1 + SUNN)*(1 + SUNN))/(4*Pi*s*SUNN^2) - 
       (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[Q2])/(4*Pi*s*SUNN^2) + 
       (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/
        (4*Pi*s*SUNN^2)) + Log[mu]*
      (((-omega + 2*eps*omega + eps*EulerGamma*omega - s + eps*s + 
          eps*EulerGamma*s)*(-1 + SUNN)*(1 + SUNN))/(2*Pi*s*SUNN^2) - 
       (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(2*Pi*s*SUNN^2) - 
       (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[Q2])/(2*Pi*s*SUNN^2) + 
       (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/
        (2*Pi*s*SUNN^2)) + 
     Log[2]*(((-omega + 2*eps*omega + eps*EulerGamma*omega - s + eps*s + 
          eps*EulerGamma*s)*(-1 + SUNN)*(1 + SUNN))/(2*Pi*s*SUNN^2) - 
       (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(Pi*s*SUNN^2) - 
       (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(2*Pi*s*SUNN^2) - 
       (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[Q2])/(2*Pi*s*SUNN^2) + 
       (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/
        (2*Pi*s*SUNN^2)) + (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, 1 - omega/Q2])/(4*Pi*s*SUNN^2) - 
     (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*PolyLog[2, omega/Q2])/
      (4*Pi*s*SUNN^2)}, {1, -1, ((-1 - eps + eps*EulerGamma)*(omega - 2*Q2)*
       (-1 + SUNN)*(1 + SUNN))/(4*Pi*s*SUNN^2) - 
     (eps*(omega - 2*Q2)*(-1 + SUNN)*(1 + SUNN)*Log[2])/(2*Pi*s*SUNN^2) - 
     (eps*(omega - 2*Q2)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(2*Pi*s*SUNN^2) - 
     (eps*(omega - 2*Q2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(4*Pi*s*SUNN^2)}, 
   {1, -1, ((-4*omega^2 - 2*eps*omega^2 - 8*eps^2*omega^2 + 
        4*eps*EulerGamma*omega^2 + 2*eps^2*EulerGamma*omega^2 - 
        2*eps^2*EulerGamma^2*omega^2 + eps^2*omega^2*Pi^2 + 8*omega*Q2 - 
        2*eps*omega*Q2 + 6*eps^2*omega*Q2 - 8*eps*EulerGamma*omega*Q2 + 
        2*eps^2*EulerGamma*omega*Q2 + 4*eps^2*EulerGamma^2*omega*Q2 - 
        2*eps^2*omega*Pi^2*Q2 - 4*Q2^2 + 4*eps*Q2^2 + 4*eps*EulerGamma*Q2^2 - 
        4*eps^2*EulerGamma*Q2^2 - 2*eps^2*EulerGamma^2*Q2^2 + 
        eps^2*Pi^2*Q2^2 - 2*eps*omega*s - 4*eps^2*omega*s + 
        2*eps^2*EulerGamma*omega*s + 2*eps*Q2*s + 2*eps^2*Q2*s - 
        2*eps^2*EulerGamma*Q2*s)*(-1 + SUNN)*(1 + SUNN))/
      (8*eps*Pi*s*(omega + s)*SUNN^2) - (eps*(omega - Q2)^2*(-1 + SUNN)*
       (1 + SUNN)*Log[2]^2)/(Pi*s*(omega + s)*SUNN^2) - 
     (eps*(omega - Q2)^2*(-1 + SUNN)*(1 + SUNN)*Log[mu]^2)/
      (Pi*s*(omega + s)*SUNN^2) + ((omega - Q2)*(-2*omega - eps*omega + 
        2*eps*EulerGamma*omega + 2*Q2 - 2*eps*Q2 - 2*eps*EulerGamma*Q2 - 
        eps*s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(4*Pi*s*(omega + s)*SUNN^2) - 
     (eps*(omega - Q2)^2*(-1 + SUNN)*(1 + SUNN)*Log[Pi]^2)/
      (4*Pi*s*(omega + s)*SUNN^2) + 
     Log[mu]*(((omega - Q2)*(-2*omega - eps*omega + 2*eps*EulerGamma*omega + 
          2*Q2 - 2*eps*Q2 - 2*eps*EulerGamma*Q2 - eps*s)*(-1 + SUNN)*
         (1 + SUNN))/(2*Pi*s*(omega + s)*SUNN^2) - 
       (eps*(omega - Q2)^2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (Pi*s*(omega + s)*SUNN^2)) + 
     Log[2]*(((omega - Q2)*(-2*omega - eps*omega + 2*eps*EulerGamma*omega + 
          2*Q2 - 2*eps*Q2 - 2*eps*EulerGamma*Q2 - eps*s)*(-1 + SUNN)*
         (1 + SUNN))/(2*Pi*s*(omega + s)*SUNN^2) - 
       (2*eps*(omega - Q2)^2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
        (Pi*s*(omega + s)*SUNN^2) - (eps*(omega - Q2)^2*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(Pi*s*(omega + s)*SUNN^2))}, 
   {1, -1, ((-1 - eps + eps*EulerGamma)*(omega + s)*(-1 + SUNN)*(1 + SUNN))/
      (2*Pi*s*SUNN^2) - (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (Pi*s*SUNN^2) - (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (Pi*s*SUNN^2) - (eps*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (2*Pi*s*SUNN^2)}, 
   {1, -1, -1/4*((-8*omega - 11*eps*omega + 8*eps*EulerGamma*omega + 8*Q2 + 
         10*eps*Q2 - 8*eps*EulerGamma*Q2 - 2*s - 2*eps*s + 
         2*eps*EulerGamma*s)*(-1 + SUNN)*(1 + SUNN))/(Pi*s*SUNN^2) + 
     (eps*(4*omega - 4*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[2])/(Pi*s*SUNN^2) + 
     (eps*(4*omega - 4*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (Pi*s*SUNN^2) + (eps*(4*omega - 4*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
       Log[Pi])/(2*Pi*s*SUNN^2)}, 
   {1, -1, -1/8*((-8*omega^2 + 6*eps*omega^2 - 8*eps^2*omega^2 + 
         8*eps*EulerGamma*omega^2 - 6*eps^2*EulerGamma*omega^2 - 
         4*eps^2*EulerGamma^2*omega^2 + 2*eps^2*omega^2*Pi^2 + 16*omega*Q2 - 
         10*eps*omega*Q2 + 2*eps^2*omega*Q2 - 16*eps*EulerGamma*omega*Q2 + 
         10*eps^2*EulerGamma*omega*Q2 + 8*eps^2*EulerGamma^2*omega*Q2 - 
         4*eps^2*omega*Pi^2*Q2 - 8*Q2^2 + 8*eps*Q2^2 + 8*eps*EulerGamma*
          Q2^2 - 8*eps^2*EulerGamma*Q2^2 - 4*eps^2*EulerGamma^2*Q2^2 + 
         2*eps^2*Pi^2*Q2^2 - 4*omega*s + 4*eps*omega*s - 12*eps^2*omega*s + 
         4*eps*EulerGamma*omega*s - 4*eps^2*EulerGamma*omega*s - 
         2*eps^2*EulerGamma^2*omega*s + eps^2*omega*Pi^2*s + 4*Q2*s + 
         2*eps*Q2*s + 2*eps^2*Q2*s - 4*eps*EulerGamma*Q2*s - 
         2*eps^2*EulerGamma*Q2*s + 2*eps^2*EulerGamma^2*Q2*s - 
         eps^2*Pi^2*Q2*s + 2*eps*s^2 - 4*eps^2*s^2 - 2*eps^2*EulerGamma*s^2)*
        (-1 + SUNN)*(1 + SUNN))/(eps*Pi*s*(omega + s)*SUNN^2) + 
     (eps*(omega - Q2)*(2*omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[2]^2)/
      (Pi*s*(omega + s)*SUNN^2) + (eps*(omega - Q2)*(2*omega - 2*Q2 + s)*
       (-1 + SUNN)*(1 + SUNN)*Log[mu]^2)/(Pi*s*(omega + s)*SUNN^2) - 
     ((-4*omega^2 + 3*eps*omega^2 + 4*eps*EulerGamma*omega^2 + 8*omega*Q2 - 
        5*eps*omega*Q2 - 8*eps*EulerGamma*omega*Q2 - 4*Q2^2 + 4*eps*Q2^2 + 
        4*eps*EulerGamma*Q2^2 - 2*omega*s + 2*eps*omega*s + 
        2*eps*EulerGamma*omega*s + 2*Q2*s + eps*Q2*s - 2*eps*EulerGamma*Q2*
         s + eps*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*Pi*s*(omega + s)*SUNN^2) + (eps*(omega - Q2)*(2*omega - 2*Q2 + s)*
       (-1 + SUNN)*(1 + SUNN)*Log[Pi]^2)/(4*Pi*s*(omega + s)*SUNN^2) + 
     Log[mu]*(-1/2*((-4*omega^2 + 3*eps*omega^2 + 4*eps*EulerGamma*omega^2 + 
           8*omega*Q2 - 5*eps*omega*Q2 - 8*eps*EulerGamma*omega*Q2 - 4*Q2^2 + 
           4*eps*Q2^2 + 4*eps*EulerGamma*Q2^2 - 2*omega*s + 2*eps*omega*s + 
           2*eps*EulerGamma*omega*s + 2*Q2*s + eps*Q2*s - 2*eps*EulerGamma*Q2*
            s + eps*s^2)*(-1 + SUNN)*(1 + SUNN))/(Pi*s*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)*(2*omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (Pi*s*(omega + s)*SUNN^2)) + 
     Log[2]*(-1/2*((-4*omega^2 + 3*eps*omega^2 + 4*eps*EulerGamma*omega^2 + 
           8*omega*Q2 - 5*eps*omega*Q2 - 8*eps*EulerGamma*omega*Q2 - 4*Q2^2 + 
           4*eps*Q2^2 + 4*eps*EulerGamma*Q2^2 - 2*omega*s + 2*eps*omega*s + 
           2*eps*EulerGamma*omega*s + 2*Q2*s + eps*Q2*s - 2*eps*EulerGamma*Q2*
            s + eps*s^2)*(-1 + SUNN)*(1 + SUNN))/(Pi*s*(omega + s)*SUNN^2) + 
       (2*eps*(omega - Q2)*(2*omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
         Log[mu])/(Pi*s*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)*(2*omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (Pi*s*(omega + s)*SUNN^2))}, 
   {1, -1, -1/12*((-9*omega^2 - 9*eps*omega^2 + 9*eps*EulerGamma*omega^2 + 
         2*eps*omega^2*Pi^2 + 6*omega*Q2 + 6*eps*omega*Q2 - 
         6*eps*EulerGamma*omega*Q2 - 4*eps*omega*Pi^2*Q2 + 2*eps*Pi^2*Q2^2)*
        (omega + s)^2*(-1 + SUNN)*(1 + SUNN))/(omega^3*Pi*s*SUNN^2) + 
     (eps*(3*omega - 2*Q2)*(omega + s)^2*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (2*omega^2*Pi*s*SUNN^2) + (eps*(3*omega - 2*Q2)*(omega + s)^2*
       (-1 + SUNN)*(1 + SUNN)*Log[mu])/(2*omega^2*Pi*s*SUNN^2) + 
     (eps*(3*omega - 2*Q2)*(omega + s)^2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*omega^2*Pi*s*SUNN^2) - (eps*(omega - Q2)^2*(omega + s)^2*(-1 + SUNN)*
       (1 + SUNN)*Log[Q2]^2)/(4*omega^3*Pi*s*SUNN^2) + 
     (3*eps*(omega - Q2)^2*(omega + s)^2*(-1 + SUNN)*(1 + SUNN)*
       Log[-omega + Q2]^2)/(4*omega^3*Pi*s*SUNN^2) + 
     Log[Q2]*((eps*(omega - Q2)^2*(omega + s)^2*(-1 + SUNN)*(1 + SUNN)*
         Log[mu])/(omega^3*Pi*s*SUNN^2) + (eps*(omega - Q2)^2*(omega + s)^2*
         (-1 + SUNN)*(1 + SUNN)*Log[omega])/(omega^3*Pi*s*SUNN^2) + 
       (eps*(omega - Q2)^2*(omega + s)^2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (2*omega^3*Pi*s*SUNN^2) - (eps*(omega - Q2)^2*(omega + s)^2*
         (-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/(2*omega^3*Pi*s*SUNN^2) + 
       ((omega - Q2)^2*(omega + s)^2*(-1 + SUNN)*(1 + SUNN)*
         (1 - eps - 2*eps*EulerGamma + (2*I)*eps*Pi - eps*PolyGamma[0, 1/2]))/
        (2*omega^3*Pi*s*SUNN^2)) + Log[-omega + Q2]*
      (-((eps*(omega - Q2)^2*(omega + s)^2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
         (omega^3*Pi*s*SUNN^2)) - (eps*(omega - Q2)^2*(omega + s)^2*
         (-1 + SUNN)*(1 + SUNN)*Log[omega])/(omega^3*Pi*s*SUNN^2) - 
       (eps*(omega - Q2)^2*(omega + s)^2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (2*omega^3*Pi*s*SUNN^2) + ((omega - Q2)^2*(omega + s)^2*(-1 + SUNN)*
         (1 + SUNN)*(-1 + eps + 2*eps*EulerGamma - (2*I)*eps*Pi + 
          eps*PolyGamma[0, 1/2]))/(2*omega^3*Pi*s*SUNN^2)) + 
     (eps*(omega - Q2)^2*(omega + s)^2*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, -(Q2/(omega - Q2))])/(omega^3*Pi*s*SUNN^2)}, 
   {1, -1, ((omega + s)*(-9*omega^2 - 12*eps*omega^2 + 
        9*eps*EulerGamma*omega^2 + 3*eps*omega^2*Pi^2 + 9*omega*Q2 + 
        12*eps*omega*Q2 - 9*eps*EulerGamma*omega*Q2 - 6*eps*omega*Pi^2*Q2 + 
        3*eps*Pi^2*Q2^2 - 3*omega*s - 3*eps*omega*s + 3*eps*EulerGamma*omega*
         s + eps*omega*Pi^2*s - eps*Pi^2*Q2*s)*(-1 + SUNN)*(1 + SUNN))/
      (6*omega^2*Pi*s*SUNN^2) - (eps*(omega + s)*(3*omega - 3*Q2 + s)*
       (-1 + SUNN)*(1 + SUNN)*Log[2])/(omega*Pi*s*SUNN^2) - 
     (eps*(omega + s)*(3*omega - 3*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (omega*Pi*s*SUNN^2) - (eps*(omega + s)*(3*omega - 3*Q2 + s)*(-1 + SUNN)*
       (1 + SUNN)*Log[Pi])/(2*omega*Pi*s*SUNN^2) + 
     (eps*(omega - Q2)*(omega + s)*(3*omega - 3*Q2 + s)*(-1 + SUNN)*
       (1 + SUNN)*Log[Q2]^2)/(4*omega^2*Pi*s*SUNN^2) - 
     (3*eps*(omega - Q2)*(omega + s)*(3*omega - 3*Q2 + s)*(-1 + SUNN)*
       (1 + SUNN)*Log[-omega + Q2]^2)/(4*omega^2*Pi*s*SUNN^2) + 
     Log[-omega + Q2]*((eps*(omega - Q2)*(omega + s)*(3*omega - 3*Q2 + s)*
         (-1 + SUNN)*(1 + SUNN)*Log[mu])/(omega^2*Pi*s*SUNN^2) + 
       (eps*(omega - Q2)*(omega + s)*(3*omega - 3*Q2 + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[omega])/(omega^2*Pi*s*SUNN^2) + 
       (eps*(omega - Q2)*(omega + s)*(3*omega - 3*Q2 + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(2*omega^2*Pi*s*SUNN^2) + 
       ((omega - Q2)*(omega + s)*(-1 + SUNN)*(1 + SUNN)*
         (3*omega - 2*eps*omega - 6*eps*EulerGamma*omega + 
          (6*I)*eps*omega*Pi - 3*Q2 + 2*eps*Q2 + 6*eps*EulerGamma*Q2 - 
          (6*I)*eps*Pi*Q2 + s - eps*s - 2*eps*EulerGamma*s + (2*I)*eps*Pi*s - 
          3*eps*omega*PolyGamma[0, 1/2] + 3*eps*Q2*PolyGamma[0, 1/2] - 
          eps*s*PolyGamma[0, 1/2]))/(2*omega^2*Pi*s*SUNN^2)) + 
     Log[Q2]*(-((eps*(omega - Q2)*(omega + s)*(3*omega - 3*Q2 + s)*
          (-1 + SUNN)*(1 + SUNN)*Log[mu])/(omega^2*Pi*s*SUNN^2)) - 
       (eps*(omega - Q2)*(omega + s)*(3*omega - 3*Q2 + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[omega])/(omega^2*Pi*s*SUNN^2) - 
       (eps*(omega - Q2)*(omega + s)*(3*omega - 3*Q2 + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(2*omega^2*Pi*s*SUNN^2) + 
       (eps*(omega - Q2)*(omega + s)*(3*omega - 3*Q2 + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[-omega + Q2])/(2*omega^2*Pi*s*SUNN^2) + 
       ((omega - Q2)*(omega + s)*(-1 + SUNN)*(1 + SUNN)*
         (-3*omega + 2*eps*omega + 6*eps*EulerGamma*omega - 
          (6*I)*eps*omega*Pi + 3*Q2 - 2*eps*Q2 - 6*eps*EulerGamma*Q2 + 
          (6*I)*eps*Pi*Q2 - s + eps*s + 2*eps*EulerGamma*s - (2*I)*eps*Pi*s + 
          3*eps*omega*PolyGamma[0, 1/2] - 3*eps*Q2*PolyGamma[0, 1/2] + 
          eps*s*PolyGamma[0, 1/2]))/(2*omega^2*Pi*s*SUNN^2)) - 
     (eps*(omega - Q2)*(omega + s)*(3*omega - 3*Q2 + s)*(-1 + SUNN)*
       (1 + SUNN)*PolyLog[2, -(Q2/(omega - Q2))])/(omega^2*Pi*s*SUNN^2)}, 
   {1, -1, -1/6*(eps*Pi*(omega - Q2)*(3*omega - 3*Q2 + 2*s)*(-1 + SUNN)*
        (1 + SUNN))/(omega*s*SUNN^2) - 
     (eps*(omega - Q2)*(3*omega - 3*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*
       Log[Q2]^2)/(4*omega*Pi*s*SUNN^2) + 
     (3*eps*(omega - Q2)*(3*omega - 3*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*
       Log[-omega + Q2]^2)/(4*omega*Pi*s*SUNN^2) + 
     Log[-omega + Q2]*(-((eps*(omega - Q2)*(3*omega - 3*Q2 + 2*s)*(-1 + SUNN)*
          (1 + SUNN)*Log[mu])/(omega*Pi*s*SUNN^2)) - 
       (eps*(omega - Q2)*(3*omega - 3*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(omega*Pi*s*SUNN^2) - 
       (eps*(omega - Q2)*(3*omega - 3*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*
         Log[Pi])/(2*omega*Pi*s*SUNN^2) + ((-1 + SUNN)*(1 + SUNN)*
         (-6*omega^2 + 4*eps*omega^2 + 12*eps*EulerGamma*omega^2 - 
          (12*I)*eps*omega^2*Pi + 12*omega*Q2 - 6*eps*omega*Q2 - 
          24*eps*EulerGamma*omega*Q2 + (24*I)*eps*omega*Pi*Q2 - 6*Q2^2 + 
          4*eps*Q2^2 + 12*eps*EulerGamma*Q2^2 - (12*I)*eps*Pi*Q2^2 - 
          4*omega*s + 3*eps*omega*s + 8*eps*EulerGamma*omega*s - 
          (8*I)*eps*omega*Pi*s + 4*Q2*s - 2*eps*Q2*s - 8*eps*EulerGamma*Q2*
           s + (8*I)*eps*Pi*Q2*s + 6*eps*omega^2*PolyGamma[0, 1/2] - 
          12*eps*omega*Q2*PolyGamma[0, 1/2] + 6*eps*Q2^2*PolyGamma[0, 1/2] + 
          4*eps*omega*s*PolyGamma[0, 1/2] - 4*eps*Q2*s*PolyGamma[0, 1/2]))/
        (4*omega*Pi*s*SUNN^2)) + 
     Log[Q2]*((eps*(omega - Q2)*(3*omega - 3*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*
         Log[mu])/(omega*Pi*s*SUNN^2) + 
       (eps*(omega - Q2)*(3*omega - 3*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(omega*Pi*s*SUNN^2) + 
       (eps*(omega - Q2)*(3*omega - 3*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*
         Log[Pi])/(2*omega*Pi*s*SUNN^2) - 
       (eps*(omega - Q2)*(3*omega - 3*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*
         Log[-omega + Q2])/(2*omega*Pi*s*SUNN^2) + 
       ((-1 + SUNN)*(1 + SUNN)*(6*omega^2 - 4*eps*omega^2 - 
          12*eps*EulerGamma*omega^2 + (12*I)*eps*omega^2*Pi - 12*omega*Q2 + 
          6*eps*omega*Q2 + 24*eps*EulerGamma*omega*Q2 - (24*I)*eps*omega*Pi*
           Q2 + 6*Q2^2 - 4*eps*Q2^2 - 12*eps*EulerGamma*Q2^2 + 
          (12*I)*eps*Pi*Q2^2 + 4*omega*s - 3*eps*omega*s - 
          8*eps*EulerGamma*omega*s + (8*I)*eps*omega*Pi*s - 4*Q2*s + 
          2*eps*Q2*s + 8*eps*EulerGamma*Q2*s - (8*I)*eps*Pi*Q2*s - 
          6*eps*omega^2*PolyGamma[0, 1/2] + 12*eps*omega*Q2*
           PolyGamma[0, 1/2] - 6*eps*Q2^2*PolyGamma[0, 1/2] - 
          4*eps*omega*s*PolyGamma[0, 1/2] + 4*eps*Q2*s*PolyGamma[0, 1/2]))/
        (4*omega*Pi*s*SUNN^2)) + (eps*(omega - Q2)*(3*omega - 3*Q2 + 2*s)*
       (-1 + SUNN)*(1 + SUNN)*PolyLog[2, -(Q2/(omega - Q2))])/
      (omega*Pi*s*SUNN^2)}, 
   {1, -1, ((-12*omega^2 + 12*eps*omega^2 - 18*eps^2*omega^2 + 
        12*eps*EulerGamma*omega^2 - 12*eps^2*EulerGamma*omega^2 - 
        6*eps^2*EulerGamma^2*omega^2 + eps^2*omega^2*Pi^2 + 24*omega*Q2 - 
        12*eps*omega*Q2 - 24*eps*EulerGamma*omega*Q2 + 12*eps^2*EulerGamma*
         omega*Q2 + 12*eps^2*EulerGamma^2*omega*Q2 - 2*eps^2*omega*Pi^2*Q2 - 
        12*Q2^2 + 12*eps*Q2^2 + 12*eps*EulerGamma*Q2^2 - 
        12*eps^2*EulerGamma*Q2^2 - 6*eps^2*EulerGamma^2*Q2^2 + 
        eps^2*Pi^2*Q2^2 - 12*omega*s + 18*eps*omega*s - 30*eps^2*omega*s + 
        12*eps*EulerGamma*omega*s - 18*eps^2*EulerGamma*omega*s - 
        6*eps^2*EulerGamma^2*omega*s + eps^2*omega*Pi^2*s + 12*Q2*s - 
        12*eps*EulerGamma*Q2*s + 6*eps^2*EulerGamma^2*Q2*s - 
        eps^2*Pi^2*Q2*s + 6*eps*s^2 - 12*eps^2*s^2 - 6*eps^2*EulerGamma*s^2)*
       (-1 + SUNN)*(1 + SUNN))/(24*eps*Pi*s*(omega + s)*SUNN^2) - 
     (eps*(omega - Q2)*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[2]^2)/
      (Pi*s*(omega + s)*SUNN^2) - (eps*(omega - Q2)*(omega - Q2 + s)*
       (-1 + SUNN)*(1 + SUNN)*Log[mu]^2)/(Pi*s*(omega + s)*SUNN^2) - 
     (eps*(omega - Q2)*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi]^2)/
      (4*Pi*s*(omega + s)*SUNN^2) + 
     (((-2*omega^2 + 2*eps*omega^2 + 2*eps*EulerGamma*omega^2 + 4*omega*Q2 - 
          2*eps*omega*Q2 - 4*eps*EulerGamma*omega*Q2 - 2*Q2^2 + 2*eps*Q2^2 + 
          2*eps*EulerGamma*Q2^2 - 2*omega*s + 3*eps*omega*s + 
          2*eps*EulerGamma*omega*s + 2*Q2*s - 2*eps*EulerGamma*Q2*s + 
          eps*s^2)*(-1 + SUNN)*(1 + SUNN))/(4*Pi*s*(omega + s)*SUNN^2) - 
       (eps*(omega - Q2)*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[omega])/
        (2*Pi*s*(omega + s)*SUNN^2))*Log[Q2] + 
     (eps*(omega - Q2)*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Q2]^2)/
      (4*Pi*s*(omega + s)*SUNN^2) + 
     (-1/4*((-2*omega^2 + 2*eps*omega^2 + 2*eps*EulerGamma*omega^2 + 
           4*omega*Q2 - 2*eps*omega*Q2 - 4*eps*EulerGamma*omega*Q2 - 2*Q2^2 + 
           2*eps*Q2^2 + 2*eps*EulerGamma*Q2^2 - 2*omega*s + 3*eps*omega*s + 
           2*eps*EulerGamma*omega*s + 2*Q2*s - 2*eps*EulerGamma*Q2*s + 
           eps*s^2)*(-1 + SUNN)*(1 + SUNN))/(Pi*s*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[omega])/
        (2*Pi*s*(omega + s)*SUNN^2))*Log[-omega + Q2] - 
     (eps*(omega - Q2)*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
       Log[-omega + Q2]^2)/(4*Pi*s*(omega + s)*SUNN^2) + 
     Log[Pi]*(((-2*omega^2 + 2*eps*omega^2 + 2*eps*EulerGamma*omega^2 + 
          4*omega*Q2 - 2*eps*omega*Q2 - 4*eps*EulerGamma*omega*Q2 - 2*Q2^2 + 
          2*eps*Q2^2 + 2*eps*EulerGamma*Q2^2 - 2*omega*s + 3*eps*omega*s + 
          2*eps*EulerGamma*omega*s + 2*Q2*s - 2*eps*EulerGamma*Q2*s + 
          eps*s^2)*(-1 + SUNN)*(1 + SUNN))/(4*Pi*s*(omega + s)*SUNN^2) - 
       (eps*(omega - Q2)*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Q2])/
        (2*Pi*s*(omega + s)*SUNN^2) + (eps*(omega - Q2)*(omega - Q2 + s)*
         (-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/(2*Pi*s*(omega + s)*
         SUNN^2)) + Log[mu]*
      (((-2*omega^2 + 2*eps*omega^2 + 2*eps*EulerGamma*omega^2 + 4*omega*Q2 - 
          2*eps*omega*Q2 - 4*eps*EulerGamma*omega*Q2 - 2*Q2^2 + 2*eps*Q2^2 + 
          2*eps*EulerGamma*Q2^2 - 2*omega*s + 3*eps*omega*s + 
          2*eps*EulerGamma*omega*s + 2*Q2*s - 2*eps*EulerGamma*Q2*s + 
          eps*s^2)*(-1 + SUNN)*(1 + SUNN))/(2*Pi*s*(omega + s)*SUNN^2) - 
       (eps*(omega - Q2)*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (Pi*s*(omega + s)*SUNN^2) - (eps*(omega - Q2)*(omega - Q2 + s)*
         (-1 + SUNN)*(1 + SUNN)*Log[Q2])/(Pi*s*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
         Log[-omega + Q2])/(Pi*s*(omega + s)*SUNN^2)) + 
     Log[2]*(((-2*omega^2 + 2*eps*omega^2 + 2*eps*EulerGamma*omega^2 + 
          4*omega*Q2 - 2*eps*omega*Q2 - 4*eps*EulerGamma*omega*Q2 - 2*Q2^2 + 
          2*eps*Q2^2 + 2*eps*EulerGamma*Q2^2 - 2*omega*s + 3*eps*omega*s + 
          2*eps*EulerGamma*omega*s + 2*Q2*s - 2*eps*EulerGamma*Q2*s + 
          eps*s^2)*(-1 + SUNN)*(1 + SUNN))/(2*Pi*s*(omega + s)*SUNN^2) - 
       (2*eps*(omega - Q2)*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
        (Pi*s*(omega + s)*SUNN^2) - (eps*(omega - Q2)*(omega - Q2 + s)*
         (-1 + SUNN)*(1 + SUNN)*Log[Pi])/(Pi*s*(omega + s)*SUNN^2) - 
       (eps*(omega - Q2)*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Q2])/
        (Pi*s*(omega + s)*SUNN^2) + (eps*(omega - Q2)*(omega - Q2 + s)*
         (-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/(Pi*s*(omega + s)*
         SUNN^2)) + (eps*(omega - Q2)*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, 1 - omega/Q2])/(2*Pi*s*(omega + s)*SUNN^2) - 
     (eps*(omega - Q2)*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, omega/Q2])/(2*Pi*s*(omega + s)*SUNN^2)}, 
   {1, -2, -1/36*((-6 - 7*eps + 6*eps*EulerGamma)*Q2*(-1 + SUNN)*(1 + SUNN))/
       (Pi*SUNN) + (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[2])/(3*Pi*SUNN) + 
     (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(3*Pi*SUNN) + 
     (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(6*Pi*SUNN)}, 
   {1, -1, ((-6 - 7*eps + 6*eps*EulerGamma)*(2*omega*Q2 + 2*Q2*s + s^2)*
       (-1 + SUNN)*(1 + SUNN))/(36*Pi*s*(omega + s)*SUNN) - 
     (eps*(2*omega*Q2 + 2*Q2*s + s^2)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (3*Pi*s*(omega + s)*SUNN) - (eps*(2*omega*Q2 + 2*Q2*s + s^2)*
       (-1 + SUNN)*(1 + SUNN)*Log[mu])/(3*Pi*s*(omega + s)*SUNN) - 
     (eps*(2*omega*Q2 + 2*Q2*s + s^2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (6*Pi*s*(omega + s)*SUNN)}, 
   {1, -2, -1/18*((-3 - 2*eps + 3*eps*EulerGamma)*Q2*(-1 + SUNN)*(1 + SUNN))/
       (Pi*SUNN) + (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[2])/(3*Pi*SUNN) + 
     (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(3*Pi*SUNN) + 
     (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(6*Pi*SUNN)}, 
   {1, -1, ((-6*omega*Q2 - 7*eps*omega*Q2 + 6*eps*EulerGamma*omega*Q2 + 
        3*Q2^2 + 5*eps*Q2^2 - 3*eps*EulerGamma*Q2^2 + 3*eps*omega*s + 
        3*eps*s^2)*(-1 + SUNN)*(1 + SUNN))/(18*Pi*s*(omega + s)*SUNN) - 
     (eps*(2*omega - Q2)*Q2*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (3*Pi*s*(omega + s)*SUNN) - (eps*(2*omega - Q2)*Q2*(-1 + SUNN)*
       (1 + SUNN)*Log[mu])/(3*Pi*s*(omega + s)*SUNN) - 
     (eps*(2*omega - Q2)*Q2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (6*Pi*s*(omega + s)*SUNN)}, 
   {1, -2, ((-1 - eps + eps*EulerGamma)*Q2*(-1 + SUNN)*(1 + SUNN))/
      (2*Pi*SUNN) - (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[2])/(Pi*SUNN) - 
     (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(Pi*SUNN) - 
     (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(2*Pi*SUNN)}, 
   {1, -1, -1/4*((-3*omega*Q2 - 3*eps*omega*Q2 + 3*eps*EulerGamma*omega*Q2 + 
         eps*omega*s - 2*Q2*s - 2*eps*Q2*s + 2*eps*EulerGamma*Q2*s - s^2 + 
         eps*EulerGamma*s^2)*(-1 + SUNN)*(1 + SUNN))/(Pi*s*(omega + s)*
        SUNN) + (eps*(3*omega*Q2 + 2*Q2*s + s^2)*(-1 + SUNN)*(1 + SUNN)*
       Log[2])/(2*Pi*s*(omega + s)*SUNN) + 
     (eps*(3*omega*Q2 + 2*Q2*s + s^2)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (2*Pi*s*(omega + s)*SUNN) + (eps*(3*omega*Q2 + 2*Q2*s + s^2)*
       (-1 + SUNN)*(1 + SUNN)*Log[Pi])/(4*Pi*s*(omega + s)*SUNN)}, 
   {1, -2, ((-1 - eps + eps*EulerGamma)*Q2*(-1 + SUNN)*(1 + SUNN))/
      (2*Pi*SUNN) - (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[2])/(Pi*SUNN) - 
     (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(Pi*SUNN) - 
     (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(2*Pi*SUNN)}, 
   {1, -1, -1/4*((-omega^2 - eps*omega^2 + eps*EulerGamma*omega^2 - 
         omega*Q2 - eps*omega*Q2 + eps*EulerGamma*omega*Q2 - 2*omega*s - 
         eps*omega*s + 2*eps*EulerGamma*omega*s + 2*Q2*s + 2*eps*Q2*s - 
         2*eps*EulerGamma*Q2*s - s^2 + eps*EulerGamma*s^2)*(-1 + SUNN)*
        (1 + SUNN))/(Pi*s*(omega + s)*SUNN) + 
     (eps*(omega^2 + omega*Q2 + 2*omega*s - 2*Q2*s + s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[2])/(2*Pi*s*(omega + s)*SUNN) + 
     (eps*(omega^2 + omega*Q2 + 2*omega*s - 2*Q2*s + s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[mu])/(2*Pi*s*(omega + s)*SUNN) + 
     (eps*(omega^2 + omega*Q2 + 2*omega*s - 2*Q2*s + s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[Pi])/(4*Pi*s*(omega + s)*SUNN)}, 
   {1, -2, -1/2*((-1 - eps + eps*EulerGamma)*Q2*(-1 + SUNN)*(1 + SUNN))/
       (Pi*SUNN) + (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[2])/(Pi*SUNN) + 
     (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(Pi*SUNN) + 
     (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(2*Pi*SUNN)}, 
   {1, -1, ((-omega^2 + eps*EulerGamma*omega^2 - 2*Q2^2 - 2*eps*Q2^2 + 
        2*eps*EulerGamma*Q2^2 - 2*omega*s + 2*eps*EulerGamma*omega*s - 
        2*s^2 + 2*eps*EulerGamma*s^2)*(-1 + SUNN)*(1 + SUNN))/
      (4*Pi*s*(omega + s)*SUNN) - (eps*(omega^2 + 2*Q2^2 + 2*omega*s + 2*s^2)*
       (-1 + SUNN)*(1 + SUNN)*Log[2])/(2*Pi*s*(omega + s)*SUNN) - 
     (eps*(omega^2 + 2*Q2^2 + 2*omega*s + 2*s^2)*(-1 + SUNN)*(1 + SUNN)*
       Log[mu])/(2*Pi*s*(omega + s)*SUNN) - 
     (eps*(omega^2 + 2*Q2^2 + 2*omega*s + 2*s^2)*(-1 + SUNN)*(1 + SUNN)*
       Log[Pi])/(4*Pi*s*(omega + s)*SUNN)}, 
   {1, -1, ((-1 + eps*EulerGamma)*(omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN))/
      (8*Pi*(omega + s)*SUNN^2) - (eps*(omega - 2*Q2 + s)*(-1 + SUNN)*
       (1 + SUNN)*Log[2])/(4*Pi*(omega + s)*SUNN^2) - 
     (eps*(omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (4*Pi*(omega + s)*SUNN^2) - (eps*(omega - 2*Q2 + s)*(-1 + SUNN)*
       (1 + SUNN)*Log[Pi])/(8*Pi*(omega + s)*SUNN^2)}, 
   {1, -1, -1/8*((-1 + eps*EulerGamma)*(omega - 2*Q2 + 2*s)*(-1 + SUNN)*
        (1 + SUNN))/(Pi*(omega + s)*SUNN^2) + 
     (eps*(omega - 2*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (4*Pi*(omega + s)*SUNN^2) + (eps*(omega - 2*Q2 + 2*s)*(-1 + SUNN)*
       (1 + SUNN)*Log[mu])/(4*Pi*(omega + s)*SUNN^2) + 
     (eps*(omega - 2*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (8*Pi*(omega + s)*SUNN^2)}, 
   {1, -1, -1/4*((-omega - eps*omega + eps*EulerGamma*omega + Q2 - 
         eps*EulerGamma*Q2 - s - eps*s + eps*EulerGamma*s)*(-1 + SUNN)*
        (1 + SUNN))/(Pi*(omega + s)*SUNN^2) + 
     (eps*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (2*Pi*(omega + s)*SUNN^2) + (eps*(omega - Q2 + s)*(-1 + SUNN)*
       (1 + SUNN)*Log[mu])/(2*Pi*(omega + s)*SUNN^2) + 
     (eps*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*Pi*(omega + s)*SUNN^2)}, 
   {1, -1, ((-1 + eps*EulerGamma)*s*(-1 + SUNN)*(1 + SUNN))/
      (8*Pi*(omega + s)*SUNN^2) - (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (4*Pi*(omega + s)*SUNN^2) - (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (4*Pi*(omega + s)*SUNN^2) - (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (8*Pi*(omega + s)*SUNN^2)}, 
   {1, -1, ((-omega - eps*omega + eps*EulerGamma*omega + Q2 - 
        eps*EulerGamma*Q2 - s - eps*s + eps*EulerGamma*s)*(-1 + SUNN)*
       (1 + SUNN))/(4*Pi*(omega + s)*SUNN^2) - 
     (eps*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (2*Pi*(omega + s)*SUNN^2) - (eps*(omega - Q2 + s)*(-1 + SUNN)*
       (1 + SUNN)*Log[mu])/(2*Pi*(omega + s)*SUNN^2) - 
     (eps*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*Pi*(omega + s)*SUNN^2)}, 
   {1, -2, -1/36*((-6 - 7*eps + 6*eps*EulerGamma)*Q2*(-1 + SUNN)*(1 + SUNN))/
       (Pi*SUNN) + (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[2])/(3*Pi*SUNN) + 
     (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(3*Pi*SUNN) + 
     (eps*Q2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(6*Pi*SUNN)}, 
   {1, -1, ((-6 - 7*eps + 6*eps*EulerGamma)*(omega^2 + 2*omega*s - 2*Q2*s + 
        s^2)*(-1 + SUNN)*(1 + SUNN))/(36*Pi*s*(omega + s)*SUNN) - 
     (eps*(omega^2 + 2*omega*s - 2*Q2*s + s^2)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (3*Pi*s*(omega + s)*SUNN) - (eps*(omega^2 + 2*omega*s - 2*Q2*s + s^2)*
       (-1 + SUNN)*(1 + SUNN)*Log[mu])/(3*Pi*s*(omega + s)*SUNN) - 
     (eps*(omega^2 + 2*omega*s - 2*Q2*s + s^2)*(-1 + SUNN)*(1 + SUNN)*
       Log[Pi])/(6*Pi*s*(omega + s)*SUNN)}, 
   {1, -1, ((omega - 2*Q2)*(-omega - eps*omega + eps*EulerGamma*omega + 
        2*Q2 + 2*eps*Q2 - 2*eps*EulerGamma*Q2 - 2*s - 4*eps*s + 
        2*eps*EulerGamma*s)*(-1 + SUNN)*(1 + SUNN))/(8*Pi*(omega - Q2)*
       (omega + s)*SUNN) - (eps*(omega - 2*Q2)*(omega - 2*Q2 + 2*s)*
       (-1 + SUNN)*(1 + SUNN)*Log[2])/(4*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(omega - 2*Q2)*(omega - 2*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (4*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(omega - 2*Q2)*(omega - 2*Q2 + 2*s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (8*Pi*(omega - Q2)*(omega + s)*SUNN)}, 
   {1, -1, ((-6 - 13*eps + 6*eps*EulerGamma)*(omega - s)*s*(-1 + SUNN)*
       (1 + SUNN))/(18*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (2*eps*(omega - s)*s*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (3*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (2*eps*(omega - s)*s*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (3*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(omega - s)*s*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (3*Pi*(omega - Q2)*(omega + s)*SUNN)}, 
   {1, -1, -1/8*((-omega^2 - eps*omega^2 + eps*EulerGamma*omega^2 + 
         2*omega*Q2 + 2*eps*omega*Q2 - 2*eps*EulerGamma*omega*Q2 - 8*Q2*s - 
         16*eps*Q2*s + 8*eps*EulerGamma*Q2*s + 4*s^2 + 8*eps*s^2 - 
         4*eps*EulerGamma*s^2)*(-1 + SUNN)*(1 + SUNN))/
       (Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega^2 - 2*omega*Q2 + 8*Q2*s - 4*s^2)*(-1 + SUNN)*(1 + SUNN)*
       Log[2])/(4*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega^2 - 2*omega*Q2 + 8*Q2*s - 4*s^2)*(-1 + SUNN)*(1 + SUNN)*
       Log[mu])/(4*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega^2 - 2*omega*Q2 + 8*Q2*s - 4*s^2)*(-1 + SUNN)*(1 + SUNN)*
       Log[Pi])/(8*Pi*(omega - Q2)*(omega + s)*SUNN)}, 
   {1, -1, -1/8*((-2*omega^2 - eps*omega^2 + 2*eps*EulerGamma*omega^2 + 
         6*omega*Q2 + 6*eps*omega*Q2 - 6*eps*EulerGamma*omega*Q2 - 8*Q2^2 - 
         8*eps*Q2^2 + 8*eps*EulerGamma*Q2^2 - 4*omega*s - 4*eps*omega*s + 
         4*eps*EulerGamma*omega*s + 8*Q2*s + 16*eps*Q2*s - 
         8*eps*EulerGamma*Q2*s - 4*s^2 - 4*eps*s^2 + 4*eps*EulerGamma*s^2)*
        (-1 + SUNN)*(1 + SUNN))/(Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega^2 - 3*omega*Q2 + 4*Q2^2 + 2*omega*s - 4*Q2*s + 2*s^2)*
       (-1 + SUNN)*(1 + SUNN)*Log[2])/(2*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega^2 - 3*omega*Q2 + 4*Q2^2 + 2*omega*s - 4*Q2*s + 2*s^2)*
       (-1 + SUNN)*(1 + SUNN)*Log[mu])/(2*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega^2 - 3*omega*Q2 + 4*Q2^2 + 2*omega*s - 4*Q2*s + 2*s^2)*
       (-1 + SUNN)*(1 + SUNN)*Log[Pi])/(4*Pi*(omega - Q2)*(omega + s)*SUNN)}, 
   {1, -1, -1/18*((6*omega^3 + 13*eps*omega^3 - 6*eps*EulerGamma*omega^3 + 
         9*omega^2*Q2 + 18*eps*omega^2*Q2 - 9*eps*EulerGamma*omega^2*Q2 + 
         18*omega*Q2^2 + 36*eps*omega*Q2^2 - 18*eps*EulerGamma*omega*Q2^2 + 
         6*eps*Pi^2*Q2^3)*s^2*(-1 + SUNN)*(1 + SUNN))/
       (omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(2*omega^2 + 3*omega*Q2 + 6*Q2^2)*s^2*(-1 + SUNN)*(1 + SUNN)*
       Log[2])/(3*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(2*omega^2 + 3*omega*Q2 + 6*Q2^2)*s^2*(-1 + SUNN)*(1 + SUNN)*
       Log[mu])/(3*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(2*omega^2 + 3*omega*Q2 + 6*Q2^2)*s^2*(-1 + SUNN)*(1 + SUNN)*
       Log[Pi])/(6*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*Q2^3*s^2*(-1 + SUNN)*(1 + SUNN)*Log[Q2]^2)/
      (2*omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (3*eps*Q2^3*s^2*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2]^2)/
      (2*omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     Log[Q2]*((2*eps*Q2^3*s^2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
        (omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (2*eps*Q2^3*s^2*(-1 + SUNN)*(1 + SUNN)*Log[omega])/
        (omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (eps*Q2^3*s^2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(omega^3*Pi*(omega - Q2)*
         (omega + s)*SUNN) - (eps*Q2^3*s^2*(-1 + SUNN)*(1 + SUNN)*
         Log[-omega + Q2])/(omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (Q2^3*s^2*(-1 + SUNN)*(1 + SUNN)*(1 - 2*eps*EulerGamma + 
          (2*I)*eps*Pi - eps*PolyGamma[0, 1/2]))/(omega^3*Pi*(omega - Q2)*
         (omega + s)*SUNN)) + Log[-omega + Q2]*
      ((-2*eps*Q2^3*s^2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
        (omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) - 
       (2*eps*Q2^3*s^2*(-1 + SUNN)*(1 + SUNN)*Log[omega])/
        (omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) - 
       (eps*Q2^3*s^2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(omega^3*Pi*(omega - Q2)*
         (omega + s)*SUNN) + (Q2^3*s^2*(-1 + SUNN)*(1 + SUNN)*
         (-1 + 2*eps*EulerGamma - (2*I)*eps*Pi + eps*PolyGamma[0, 1/2]))/
        (omega^3*Pi*(omega - Q2)*(omega + s)*SUNN)) + 
     (2*eps*Q2^3*s^2*(-1 + SUNN)*(1 + SUNN)*PolyLog[2, -(Q2/(omega - Q2))])/
      (omega^3*Pi*(omega - Q2)*(omega + s)*SUNN)}, 
   {1, -1, -1/12*((-3*omega^2 - 6*eps*omega^2 + 3*eps*EulerGamma*omega^2 - 
         6*omega*Q2 - 12*eps*omega*Q2 + 6*eps*EulerGamma*omega*Q2 - 
         2*eps*Pi^2*Q2^2)*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 2*Q2*s)*
        (-1 + SUNN)*(1 + SUNN))/(omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega + 2*Q2)*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 2*Q2*s)*
       (-1 + SUNN)*(1 + SUNN)*Log[2])/(2*omega^2*Pi*(omega - Q2)*(omega + s)*
       SUNN) + (eps*(omega + 2*Q2)*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 
        2*Q2*s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(2*omega^2*Pi*(omega - Q2)*
       (omega + s)*SUNN) + (eps*(omega + 2*Q2)*s*(omega^2 - 2*omega*Q2 + 
        2*omega*s + 2*Q2*s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*Q2^2*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 2*Q2*s)*(-1 + SUNN)*
       (1 + SUNN)*Log[Q2]^2)/(4*omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (3*eps*Q2^2*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 2*Q2*s)*(-1 + SUNN)*
       (1 + SUNN)*Log[-omega + Q2]^2)/(4*omega^3*Pi*(omega - Q2)*(omega + s)*
       SUNN) + Log[-omega + Q2]*
      ((eps*Q2^2*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[mu])/(omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (eps*Q2^2*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[omega])/(omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (eps*Q2^2*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(2*omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (Q2^2*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*(1 - 2*eps*EulerGamma + (2*I)*eps*Pi - 
          eps*PolyGamma[0, 1/2]))/(2*omega^3*Pi*(omega - Q2)*(omega + s)*
         SUNN)) + Log[Q2]*(-((eps*Q2^2*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 
           2*Q2*s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(omega^3*Pi*(omega - Q2)*
          (omega + s)*SUNN)) - (eps*Q2^2*s*(omega^2 - 2*omega*Q2 + 
          2*omega*s + 2*Q2*s)*(-1 + SUNN)*(1 + SUNN)*Log[omega])/
        (omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) - 
       (eps*Q2^2*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(2*omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (eps*Q2^2*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[-omega + Q2])/(2*omega^3*Pi*(omega - Q2)*(omega + s)*
         SUNN) + (Q2^2*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 2*Q2*s)*
         (-1 + SUNN)*(1 + SUNN)*(-1 + 2*eps*EulerGamma - (2*I)*eps*Pi + 
          eps*PolyGamma[0, 1/2]))/(2*omega^3*Pi*(omega - Q2)*(omega + s)*
         SUNN)) - (eps*Q2^2*s*(omega^2 - 2*omega*Q2 + 2*omega*s + 2*Q2*s)*
       (-1 + SUNN)*(1 + SUNN)*PolyLog[2, -(Q2/(omega - Q2))])/
      (omega^3*Pi*(omega - Q2)*(omega + s)*SUNN)}, 
   {1, -1, ((-6*omega^4 - 3*eps*omega^4 + 6*eps*EulerGamma*omega^4 + 
        12*omega^3*Q2 + 12*eps*omega^3*Q2 - 12*eps*EulerGamma*omega^3*Q2 - 
        2*eps*omega^3*Pi^2*Q2 - 12*omega^2*Q2^2 - 12*eps*omega^2*Q2^2 + 
        12*eps*EulerGamma*omega^2*Q2^2 + 4*eps*omega^2*Pi^2*Q2^2 - 
        4*eps*omega*Pi^2*Q2^3 - 12*omega^3*s - 12*eps*omega^3*s + 
        12*eps*EulerGamma*omega^3*s - 4*eps*omega^2*Pi^2*Q2*s + 
        24*omega*Q2^2*s + 48*eps*omega*Q2^2*s - 24*eps*EulerGamma*omega*Q2^2*
         s + 8*eps*Pi^2*Q2^3*s - 12*omega^2*s^2 - 12*eps*omega^2*s^2 + 
        12*eps*EulerGamma*omega^2*s^2 - 24*omega*Q2*s^2 - 
        48*eps*omega*Q2*s^2 + 24*eps*EulerGamma*omega*Q2*s^2 - 
        4*eps*omega*Pi^2*Q2*s^2 - 8*eps*Pi^2*Q2^2*s^2)*(-1 + SUNN)*
       (1 + SUNN))/(24*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 + 2*omega^2*s - 4*Q2^2*s + 
        2*omega*s^2 + 4*Q2*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (2*omega*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 + 2*omega^2*s - 4*Q2^2*s + 
        2*omega*s^2 + 4*Q2*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (2*omega*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 + 2*omega^2*s - 4*Q2^2*s + 
        2*omega*s^2 + 4*Q2*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*omega*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*Q2*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 + 2*omega^2*s - 
        4*Q2^2*s + 2*omega*s^2 + 4*Q2*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[Q2]^2)/
      (8*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (3*eps*Q2*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 + 2*omega^2*s - 
        4*Q2^2*s + 2*omega*s^2 + 4*Q2*s^2)*(-1 + SUNN)*(1 + SUNN)*
       Log[-omega + Q2]^2)/(8*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     Log[Q2]*((eps*Q2*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 + 2*omega^2*s - 
          4*Q2^2*s + 2*omega*s^2 + 4*Q2*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
        (2*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (eps*Q2*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 + 2*omega^2*s - 
          4*Q2^2*s + 2*omega*s^2 + 4*Q2*s^2)*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(2*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (eps*Q2*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 + 2*omega^2*s - 
          4*Q2^2*s + 2*omega*s^2 + 4*Q2*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (4*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) - 
       (eps*Q2*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 + 2*omega^2*s - 
          4*Q2^2*s + 2*omega*s^2 + 4*Q2*s^2)*(-1 + SUNN)*(1 + SUNN)*
         Log[-omega + Q2])/(4*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (Q2*(-1 + SUNN)*(1 + SUNN)*(2*omega^3 - 3*eps*omega^3 - 
          4*eps*EulerGamma*omega^3 + (4*I)*eps*omega^3*Pi - 4*omega^2*Q2 + 
          4*eps*omega^2*Q2 + 8*eps*EulerGamma*omega^2*Q2 - 
          (8*I)*eps*omega^2*Pi*Q2 + 4*omega*Q2^2 - 4*eps*omega*Q2^2 - 
          8*eps*EulerGamma*omega*Q2^2 + (8*I)*eps*omega*Pi*Q2^2 + 
          4*omega^2*s - 4*eps*omega^2*s - 8*eps*EulerGamma*omega^2*s + 
          (8*I)*eps*omega^2*Pi*s - 8*Q2^2*s + 16*eps*EulerGamma*Q2^2*s - 
          (16*I)*eps*Pi*Q2^2*s + 4*omega*s^2 - 4*eps*omega*s^2 - 
          8*eps*EulerGamma*omega*s^2 + (8*I)*eps*omega*Pi*s^2 + 8*Q2*s^2 - 
          16*eps*EulerGamma*Q2*s^2 + (16*I)*eps*Pi*Q2*s^2 - 
          2*eps*omega^3*PolyGamma[0, 1/2] + 4*eps*omega^2*Q2*
           PolyGamma[0, 1/2] - 4*eps*omega*Q2^2*PolyGamma[0, 1/2] - 
          4*eps*omega^2*s*PolyGamma[0, 1/2] + 8*eps*Q2^2*s*
           PolyGamma[0, 1/2] - 4*eps*omega*s^2*PolyGamma[0, 1/2] - 
          8*eps*Q2*s^2*PolyGamma[0, 1/2]))/(8*omega^2*Pi*(omega - Q2)*
         (omega + s)*SUNN)) + Log[-omega + Q2]*
      (-1/2*(eps*Q2*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 + 2*omega^2*s - 
           4*Q2^2*s + 2*omega*s^2 + 4*Q2*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
         (omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) - 
       (eps*Q2*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 + 2*omega^2*s - 
          4*Q2^2*s + 2*omega*s^2 + 4*Q2*s^2)*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(2*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) - 
       (eps*Q2*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 + 2*omega^2*s - 
          4*Q2^2*s + 2*omega*s^2 + 4*Q2*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (4*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (Q2*(-1 + SUNN)*(1 + SUNN)*(-2*omega^3 + 3*eps*omega^3 + 
          4*eps*EulerGamma*omega^3 - (4*I)*eps*omega^3*Pi + 4*omega^2*Q2 - 
          4*eps*omega^2*Q2 - 8*eps*EulerGamma*omega^2*Q2 + 
          (8*I)*eps*omega^2*Pi*Q2 - 4*omega*Q2^2 + 4*eps*omega*Q2^2 + 
          8*eps*EulerGamma*omega*Q2^2 - (8*I)*eps*omega*Pi*Q2^2 - 
          4*omega^2*s + 4*eps*omega^2*s + 8*eps*EulerGamma*omega^2*s - 
          (8*I)*eps*omega^2*Pi*s + 8*Q2^2*s - 16*eps*EulerGamma*Q2^2*s + 
          (16*I)*eps*Pi*Q2^2*s - 4*omega*s^2 + 4*eps*omega*s^2 + 
          8*eps*EulerGamma*omega*s^2 - (8*I)*eps*omega*Pi*s^2 - 8*Q2*s^2 + 
          16*eps*EulerGamma*Q2*s^2 - (16*I)*eps*Pi*Q2*s^2 + 
          2*eps*omega^3*PolyGamma[0, 1/2] - 4*eps*omega^2*Q2*
           PolyGamma[0, 1/2] + 4*eps*omega*Q2^2*PolyGamma[0, 1/2] + 
          4*eps*omega^2*s*PolyGamma[0, 1/2] - 8*eps*Q2^2*s*
           PolyGamma[0, 1/2] + 4*eps*omega*s^2*PolyGamma[0, 1/2] + 
          8*eps*Q2*s^2*PolyGamma[0, 1/2]))/(8*omega^2*Pi*(omega - Q2)*
         (omega + s)*SUNN)) + (eps*Q2*(omega^3 - 2*omega^2*Q2 + 
        2*omega*Q2^2 + 2*omega^2*s - 4*Q2^2*s + 2*omega*s^2 + 4*Q2*s^2)*
       (-1 + SUNN)*(1 + SUNN)*PolyLog[2, -(Q2/(omega - Q2))])/
      (2*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN)}, 
   {1, -1, (eps*Pi*Q2*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*omega*s - 2*Q2*s + 
        2*s^2)*(-1 + SUNN)*(1 + SUNN))/(12*omega*(omega - Q2)*(omega + s)*
       SUNN) + (eps*Q2*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*omega*s - 2*Q2*s + 
        2*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[Q2]^2)/(8*omega*Pi*(omega - Q2)*
       (omega + s)*SUNN) - (3*eps*Q2*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 
        2*omega*s - 2*Q2*s + 2*s^2)*(-1 + SUNN)*(1 + SUNN)*
       Log[-omega + Q2]^2)/(8*omega*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     Log[-omega + Q2]*((eps*Q2*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*omega*s - 
          2*Q2*s + 2*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
        (2*omega*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (eps*Q2*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*omega*s - 2*Q2*s + 2*s^2)*
         (-1 + SUNN)*(1 + SUNN)*Log[omega])/(2*omega*Pi*(omega - Q2)*
         (omega + s)*SUNN) + (eps*Q2*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 
          2*omega*s - 2*Q2*s + 2*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (4*omega*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (Q2*(-1 + SUNN)*(1 + SUNN)*(2*omega^2 - 3*eps*omega^2 - 
          4*eps*EulerGamma*omega^2 + (4*I)*eps*omega^2*Pi - 4*omega*Q2 + 
          4*eps*omega*Q2 + 8*eps*EulerGamma*omega*Q2 - (8*I)*eps*omega*Pi*
           Q2 + 4*Q2^2 - 4*eps*Q2^2 - 8*eps*EulerGamma*Q2^2 + 
          (8*I)*eps*Pi*Q2^2 + 4*omega*s - 4*eps*omega*s - 
          8*eps*EulerGamma*omega*s + (8*I)*eps*omega*Pi*s - 4*Q2*s + 
          8*eps*EulerGamma*Q2*s - (8*I)*eps*Pi*Q2*s + 4*s^2 - 4*eps*s^2 - 
          8*eps*EulerGamma*s^2 + (8*I)*eps*Pi*s^2 - 2*eps*omega^2*
           PolyGamma[0, 1/2] + 4*eps*omega*Q2*PolyGamma[0, 1/2] - 
          4*eps*Q2^2*PolyGamma[0, 1/2] - 4*eps*omega*s*PolyGamma[0, 1/2] + 
          4*eps*Q2*s*PolyGamma[0, 1/2] - 4*eps*s^2*PolyGamma[0, 1/2]))/
        (8*omega*Pi*(omega - Q2)*(omega + s)*SUNN)) + 
     Log[Q2]*(-1/2*(eps*Q2*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*omega*s - 
           2*Q2*s + 2*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
         (omega*Pi*(omega - Q2)*(omega + s)*SUNN) - 
       (eps*Q2*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*omega*s - 2*Q2*s + 2*s^2)*
         (-1 + SUNN)*(1 + SUNN)*Log[omega])/(2*omega*Pi*(omega - Q2)*
         (omega + s)*SUNN) - (eps*Q2*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 
          2*omega*s - 2*Q2*s + 2*s^2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (4*omega*Pi*(omega - Q2)*(omega + s)*SUNN) + 
       (eps*Q2*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*omega*s - 2*Q2*s + 2*s^2)*
         (-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/(4*omega*Pi*(omega - Q2)*
         (omega + s)*SUNN) + (Q2*(-1 + SUNN)*(1 + SUNN)*
         (-2*omega^2 + 3*eps*omega^2 + 4*eps*EulerGamma*omega^2 - 
          (4*I)*eps*omega^2*Pi + 4*omega*Q2 - 4*eps*omega*Q2 - 
          8*eps*EulerGamma*omega*Q2 + (8*I)*eps*omega*Pi*Q2 - 4*Q2^2 + 
          4*eps*Q2^2 + 8*eps*EulerGamma*Q2^2 - (8*I)*eps*Pi*Q2^2 - 
          4*omega*s + 4*eps*omega*s + 8*eps*EulerGamma*omega*s - 
          (8*I)*eps*omega*Pi*s + 4*Q2*s - 8*eps*EulerGamma*Q2*s + 
          (8*I)*eps*Pi*Q2*s - 4*s^2 + 4*eps*s^2 + 8*eps*EulerGamma*s^2 - 
          (8*I)*eps*Pi*s^2 + 2*eps*omega^2*PolyGamma[0, 1/2] - 
          4*eps*omega*Q2*PolyGamma[0, 1/2] + 4*eps*Q2^2*PolyGamma[0, 1/2] + 
          4*eps*omega*s*PolyGamma[0, 1/2] - 4*eps*Q2*s*PolyGamma[0, 1/2] + 
          4*eps*s^2*PolyGamma[0, 1/2]))/(8*omega*Pi*(omega - Q2)*(omega + s)*
         SUNN)) - (eps*Q2*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*omega*s - 
        2*Q2*s + 2*s^2)*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, -(Q2/(omega - Q2))])/(2*omega*Pi*(omega - Q2)*(omega + s)*
       SUNN)}, {1, -1, 
    -1/8*((omega - 2*Q2)*(-omega - eps*omega + eps*EulerGamma*omega + 2*Q2 + 
         2*eps*Q2 - 2*eps*EulerGamma*Q2 + 2*s + 4*eps*s - 2*eps*EulerGamma*s)*
        (-1 + SUNN)*(1 + SUNN))/(Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega - 2*Q2)*(omega - 2*Q2 - 2*s)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (4*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega - 2*Q2)*(omega - 2*Q2 - 2*s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (4*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega - 2*Q2)*(omega - 2*Q2 - 2*s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (8*Pi*(omega - Q2)*(omega + s)*SUNN)}, 
   {1, -1, -1/18*((-6 - 13*eps + 6*eps*EulerGamma)*(omega - s)*s*(-1 + SUNN)*
        (1 + SUNN))/(Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (2*eps*(omega - s)*s*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (2*eps*(omega - s)*s*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega - s)*s*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (3*Pi*(omega - Q2)*(omega + s)*SUNN)}, 
   {1, -1, -1/8*((-omega^2 - eps*omega^2 + eps*EulerGamma*omega^2 + 
         2*omega*Q2 + 2*eps*omega*Q2 - 2*eps*EulerGamma*omega*Q2 + 
         8*omega*s + 16*eps*omega*s - 8*eps*EulerGamma*omega*s - 8*Q2*s - 
         16*eps*Q2*s + 8*eps*EulerGamma*Q2*s - 4*s^2 - 8*eps*s^2 + 
         4*eps*EulerGamma*s^2)*(-1 + SUNN)*(1 + SUNN))/
       (Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega^2 - 2*omega*Q2 - 8*omega*s + 8*Q2*s + 4*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[2])/(4*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega^2 - 2*omega*Q2 - 8*omega*s + 8*Q2*s + 4*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[mu])/(4*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega^2 - 2*omega*Q2 - 8*omega*s + 8*Q2*s + 4*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[Pi])/(8*Pi*(omega - Q2)*(omega + s)*SUNN)}, 
   {1, -1, ((-4*omega^2 - 3*eps*omega^2 + 4*eps*EulerGamma*omega^2 + 
        10*omega*Q2 + 10*eps*omega*Q2 - 10*eps*EulerGamma*omega*Q2 - 8*Q2^2 - 
        8*eps*Q2^2 + 8*eps*EulerGamma*Q2^2 + 4*omega*s + 12*eps*omega*s - 
        4*eps*EulerGamma*omega*s - 8*Q2*s - 16*eps*Q2*s + 
        8*eps*EulerGamma*Q2*s - 4*s^2 - 4*eps*s^2 + 4*eps*EulerGamma*s^2)*
       (-1 + SUNN)*(1 + SUNN))/(8*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(2*omega^2 - 5*omega*Q2 + 4*Q2^2 - 2*omega*s + 4*Q2*s + 2*s^2)*
       (-1 + SUNN)*(1 + SUNN)*Log[2])/(2*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(2*omega^2 - 5*omega*Q2 + 4*Q2^2 - 2*omega*s + 4*Q2*s + 2*s^2)*
       (-1 + SUNN)*(1 + SUNN)*Log[mu])/(2*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(2*omega^2 - 5*omega*Q2 + 4*Q2^2 - 2*omega*s + 4*Q2*s + 2*s^2)*
       (-1 + SUNN)*(1 + SUNN)*Log[Pi])/(4*Pi*(omega - Q2)*(omega + s)*SUNN)}, 
   {1, -1, -1/18*((-33*omega^3 - 67*eps*omega^3 + 33*eps*EulerGamma*omega^3 + 
         6*eps*omega^3*Pi^2 + 45*omega^2*Q2 + 90*eps*omega^2*Q2 - 
         45*eps*EulerGamma*omega^2*Q2 - 18*eps*omega^2*Pi^2*Q2 - 
         18*omega*Q2^2 - 36*eps*omega*Q2^2 + 18*eps*EulerGamma*omega*Q2^2 + 
         18*eps*omega*Pi^2*Q2^2 - 6*eps*Pi^2*Q2^3)*s^2*(-1 + SUNN)*
        (1 + SUNN))/(omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(11*omega^2 - 15*omega*Q2 + 6*Q2^2)*s^2*(-1 + SUNN)*(1 + SUNN)*
       Log[2])/(3*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(11*omega^2 - 15*omega*Q2 + 6*Q2^2)*s^2*(-1 + SUNN)*(1 + SUNN)*
       Log[mu])/(3*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(11*omega^2 - 15*omega*Q2 + 6*Q2^2)*s^2*(-1 + SUNN)*(1 + SUNN)*
       Log[Pi])/(6*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*Log[Q2]^2)/
      (2*omega^3*Pi*(omega + s)*SUNN) + (3*eps*(omega - Q2)^2*s^2*(-1 + SUNN)*
       (1 + SUNN)*Log[-omega + Q2]^2)/(2*omega^3*Pi*(omega + s)*SUNN) + 
     Log[omega]*((2*eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*Log[Q2])/
        (omega^3*Pi*(omega + s)*SUNN) - (2*eps*(omega - Q2)^2*s^2*(-1 + SUNN)*
         (1 + SUNN)*Log[-omega + Q2])/(omega^3*Pi*(omega + s)*SUNN)) + 
     Log[Q2]*((2*eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
        (omega^3*Pi*(omega + s)*SUNN) + (eps*(omega - Q2)^2*s^2*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(omega^3*Pi*(omega + s)*SUNN) - 
       (eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/
        (omega^3*Pi*(omega + s)*SUNN) + ((omega - Q2)^2*s^2*(-1 + SUNN)*
         (1 + SUNN)*(1 - 2*eps*EulerGamma + (2*I)*eps*Pi - 
          eps*PolyGamma[0, 1/2]))/(omega^3*Pi*(omega + s)*SUNN)) + 
     Log[-omega + Q2]*((-2*eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*
         Log[mu])/(omega^3*Pi*(omega + s)*SUNN) - 
       (eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (omega^3*Pi*(omega + s)*SUNN) + ((omega - Q2)^2*s^2*(-1 + SUNN)*
         (1 + SUNN)*(-1 + 2*eps*EulerGamma - (2*I)*eps*Pi + 
          eps*PolyGamma[0, 1/2]))/(omega^3*Pi*(omega + s)*SUNN)) + 
     (2*eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, -(Q2/(omega - Q2))])/(omega^3*Pi*(omega + s)*SUNN)}, 
   {1, -1, -1/12*((-9*omega^2 - 18*eps*omega^2 + 9*eps*EulerGamma*omega^2 + 
         2*eps*omega^2*Pi^2 + 6*omega*Q2 + 12*eps*omega*Q2 - 
         6*eps*EulerGamma*omega*Q2 - 4*eps*omega*Pi^2*Q2 + 2*eps*Pi^2*Q2^2)*s*
        (omega^2 - 2*omega*Q2 - 4*omega*s + 2*Q2*s)*(-1 + SUNN)*(1 + SUNN))/
       (omega^3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(3*omega - 2*Q2)*s*(omega^2 - 2*omega*Q2 - 4*omega*s + 2*Q2*s)*
       (-1 + SUNN)*(1 + SUNN)*Log[2])/(2*omega^2*Pi*(omega - Q2)*(omega + s)*
       SUNN) + (eps*(3*omega - 2*Q2)*s*(omega^2 - 2*omega*Q2 - 4*omega*s + 
        2*Q2*s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(2*omega^2*Pi*(omega - Q2)*
       (omega + s)*SUNN) + (eps*(3*omega - 2*Q2)*s*(omega^2 - 2*omega*Q2 - 
        4*omega*s + 2*Q2*s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(omega - Q2)*s*(omega^2 - 2*omega*Q2 - 4*omega*s + 2*Q2*s)*
       (-1 + SUNN)*(1 + SUNN)*Log[Q2]^2)/(4*omega^3*Pi*(omega + s)*SUNN) + 
     (3*eps*(omega - Q2)*s*(omega^2 - 2*omega*Q2 - 4*omega*s + 2*Q2*s)*
       (-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2]^2)/(4*omega^3*Pi*(omega + s)*
       SUNN) + Log[Q2]*((eps*(omega - Q2)*s*(omega^2 - 2*omega*Q2 - 
          4*omega*s + 2*Q2*s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
        (omega^3*Pi*(omega + s)*SUNN) + (eps*(omega - Q2)*s*
         (omega^2 - 2*omega*Q2 - 4*omega*s + 2*Q2*s)*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(omega^3*Pi*(omega + s)*SUNN) + 
       (eps*(omega - Q2)*s*(omega^2 - 2*omega*Q2 - 4*omega*s + 2*Q2*s)*
         (-1 + SUNN)*(1 + SUNN)*Log[Pi])/(2*omega^3*Pi*(omega + s)*SUNN) - 
       (eps*(omega - Q2)*s*(omega^2 - 2*omega*Q2 - 4*omega*s + 2*Q2*s)*
         (-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/(2*omega^3*Pi*(omega + s)*
         SUNN) - ((omega - Q2)*s*(omega^2 - 2*omega*Q2 - 4*omega*s + 2*Q2*s)*
         (-1 + SUNN)*(1 + SUNN)*(-1 + 2*eps*EulerGamma - (2*I)*eps*Pi + 
          eps*PolyGamma[0, 1/2]))/(2*omega^3*Pi*(omega + s)*SUNN)) + 
     Log[-omega + Q2]*(-((eps*(omega - Q2)*s*(omega^2 - 2*omega*Q2 - 
           4*omega*s + 2*Q2*s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
         (omega^3*Pi*(omega + s)*SUNN)) - 
       (eps*(omega - Q2)*s*(omega^2 - 2*omega*Q2 - 4*omega*s + 2*Q2*s)*
         (-1 + SUNN)*(1 + SUNN)*Log[omega])/(omega^3*Pi*(omega + s)*SUNN) - 
       (eps*(omega - Q2)*s*(omega^2 - 2*omega*Q2 - 4*omega*s + 2*Q2*s)*
         (-1 + SUNN)*(1 + SUNN)*Log[Pi])/(2*omega^3*Pi*(omega + s)*SUNN) + 
       ((omega - Q2)*s*(omega^2 - 2*omega*Q2 - 4*omega*s + 2*Q2*s)*
         (-1 + SUNN)*(1 + SUNN)*(-1 + 2*eps*EulerGamma - (2*I)*eps*Pi + 
          eps*PolyGamma[0, 1/2]))/(2*omega^3*Pi*(omega + s)*SUNN)) + 
     (eps*(omega - Q2)*s*(omega^2 - 2*omega*Q2 - 4*omega*s + 2*Q2*s)*
       (-1 + SUNN)*(1 + SUNN)*PolyLog[2, -(Q2/(omega - Q2))])/
      (omega^3*Pi*(omega + s)*SUNN)}, 
   {1, -1, -1/24*((-6*omega^4 - 3*eps*omega^4 + 6*eps*EulerGamma*omega^4 + 
         2*eps*omega^4*Pi^2 + 12*omega^3*Q2 + 12*eps*omega^3*Q2 - 
         12*eps*EulerGamma*omega^3*Q2 - 6*eps*omega^3*Pi^2*Q2 - 
         12*omega^2*Q2^2 - 12*eps*omega^2*Q2^2 + 12*eps*EulerGamma*omega^2*
          Q2^2 + 8*eps*omega^2*Pi^2*Q2^2 - 4*eps*omega*Pi^2*Q2^3 + 
         12*omega^3*s + 36*eps*omega^3*s - 12*eps*EulerGamma*omega^3*s - 
         4*eps*omega^3*Pi^2*s - 48*omega^2*Q2*s - 96*eps*omega^2*Q2*s + 
         48*eps*EulerGamma*omega^2*Q2*s + 20*eps*omega^2*Pi^2*Q2*s + 
         24*omega*Q2^2*s + 48*eps*omega*Q2^2*s - 24*eps*EulerGamma*omega*Q2^2*
          s - 24*eps*omega*Pi^2*Q2^2*s + 8*eps*Pi^2*Q2^3*s - 36*omega^2*s^2 - 
         60*eps*omega^2*s^2 + 36*eps*EulerGamma*omega^2*s^2 + 
         12*eps*omega^2*Pi^2*s^2 + 24*omega*Q2*s^2 + 48*eps*omega*Q2*s^2 - 
         24*eps*EulerGamma*omega*Q2*s^2 - 20*eps*omega*Pi^2*Q2*s^2 + 
         8*eps*Pi^2*Q2^2*s^2)*(-1 + SUNN)*(1 + SUNN))/
       (omega^2*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 - 2*omega^2*s + 
        8*omega*Q2*s - 4*Q2^2*s + 6*omega*s^2 - 4*Q2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[2])/(2*omega*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 - 2*omega^2*s + 
        8*omega*Q2*s - 4*Q2^2*s + 6*omega*s^2 - 4*Q2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[mu])/(2*omega*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 - 2*omega^2*s + 
        8*omega*Q2*s - 4*Q2^2*s + 6*omega*s^2 - 4*Q2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[Pi])/(4*omega*Pi*(omega - Q2)*(omega + s)*SUNN) - 
     (eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 - 2*omega^2*s + 
        8*omega*Q2*s - 4*Q2^2*s + 6*omega*s^2 - 4*Q2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[Q2]^2)/(8*omega^2*Pi*(omega + s)*SUNN) + 
     (3*eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 - 2*omega^2*s + 
        8*omega*Q2*s - 4*Q2^2*s + 6*omega*s^2 - 4*Q2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[-omega + Q2]^2)/(8*omega^2*Pi*(omega + s)*SUNN) + 
     Log[-omega + Q2]*(-1/2*(eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 - 
           2*omega^2*s + 8*omega*Q2*s - 4*Q2^2*s + 6*omega*s^2 - 4*Q2*s^2)*
          (-1 + SUNN)*(1 + SUNN)*Log[mu])/(omega^2*Pi*(omega + s)*SUNN) - 
       (eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 - 2*omega^2*s + 
          8*omega*Q2*s - 4*Q2^2*s + 6*omega*s^2 - 4*Q2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[omega])/(2*omega^2*Pi*(omega + s)*SUNN) - 
       (eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 - 2*omega^2*s + 
          8*omega*Q2*s - 4*Q2^2*s + 6*omega*s^2 - 4*Q2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(4*omega^2*Pi*(omega + s)*SUNN) + 
       ((-1 + SUNN)*(1 + SUNN)*(-2*omega^3 + 3*eps*omega^3 + 
          4*eps*EulerGamma*omega^3 - (4*I)*eps*omega^3*Pi + 4*omega^2*Q2 - 
          4*eps*omega^2*Q2 - 8*eps*EulerGamma*omega^2*Q2 + 
          (8*I)*eps*omega^2*Pi*Q2 - 4*omega*Q2^2 + 4*eps*omega*Q2^2 + 
          8*eps*EulerGamma*omega*Q2^2 - (8*I)*eps*omega*Pi*Q2^2 + 
          4*omega^2*s + 4*eps*omega^2*s - 8*eps*EulerGamma*omega^2*s + 
          (8*I)*eps*omega^2*Pi*s - 16*omega*Q2*s + 32*eps*EulerGamma*omega*Q2*
           s - (32*I)*eps*omega*Pi*Q2*s + 8*Q2^2*s - 16*eps*EulerGamma*Q2^2*
           s + (16*I)*eps*Pi*Q2^2*s - 12*omega*s^2 + 4*eps*omega*s^2 + 
          24*eps*EulerGamma*omega*s^2 - (24*I)*eps*omega*Pi*s^2 + 8*Q2*s^2 - 
          16*eps*EulerGamma*Q2*s^2 + (16*I)*eps*Pi*Q2*s^2 + 
          2*eps*omega^3*PolyGamma[0, 1/2] - 4*eps*omega^2*Q2*
           PolyGamma[0, 1/2] + 4*eps*omega*Q2^2*PolyGamma[0, 1/2] - 
          4*eps*omega^2*s*PolyGamma[0, 1/2] + 16*eps*omega*Q2*s*
           PolyGamma[0, 1/2] - 8*eps*Q2^2*s*PolyGamma[0, 1/2] + 
          12*eps*omega*s^2*PolyGamma[0, 1/2] - 8*eps*Q2*s^2*
           PolyGamma[0, 1/2]))/(8*omega^2*Pi*(omega + s)*SUNN)) + 
     Log[Q2]*((eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 - 2*omega^2*s + 
          8*omega*Q2*s - 4*Q2^2*s + 6*omega*s^2 - 4*Q2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[mu])/(2*omega^2*Pi*(omega + s)*SUNN) + 
       (eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 - 2*omega^2*s + 
          8*omega*Q2*s - 4*Q2^2*s + 6*omega*s^2 - 4*Q2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[omega])/(2*omega^2*Pi*(omega + s)*SUNN) + 
       (eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 - 2*omega^2*s + 
          8*omega*Q2*s - 4*Q2^2*s + 6*omega*s^2 - 4*Q2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(4*omega^2*Pi*(omega + s)*SUNN) - 
       (eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 - 2*omega^2*s + 
          8*omega*Q2*s - 4*Q2^2*s + 6*omega*s^2 - 4*Q2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[-omega + Q2])/(4*omega^2*Pi*(omega + s)*SUNN) + 
       ((-1 + SUNN)*(1 + SUNN)*(2*omega^3 - 3*eps*omega^3 - 
          4*eps*EulerGamma*omega^3 + (4*I)*eps*omega^3*Pi - 4*omega^2*Q2 + 
          4*eps*omega^2*Q2 + 8*eps*EulerGamma*omega^2*Q2 - 
          (8*I)*eps*omega^2*Pi*Q2 + 4*omega*Q2^2 - 4*eps*omega*Q2^2 - 
          8*eps*EulerGamma*omega*Q2^2 + (8*I)*eps*omega*Pi*Q2^2 - 
          4*omega^2*s - 4*eps*omega^2*s + 8*eps*EulerGamma*omega^2*s - 
          (8*I)*eps*omega^2*Pi*s + 16*omega*Q2*s - 32*eps*EulerGamma*omega*Q2*
           s + (32*I)*eps*omega*Pi*Q2*s - 8*Q2^2*s + 16*eps*EulerGamma*Q2^2*
           s - (16*I)*eps*Pi*Q2^2*s + 12*omega*s^2 - 4*eps*omega*s^2 - 
          24*eps*EulerGamma*omega*s^2 + (24*I)*eps*omega*Pi*s^2 - 8*Q2*s^2 + 
          16*eps*EulerGamma*Q2*s^2 - (16*I)*eps*Pi*Q2*s^2 - 
          2*eps*omega^3*PolyGamma[0, 1/2] + 4*eps*omega^2*Q2*
           PolyGamma[0, 1/2] - 4*eps*omega*Q2^2*PolyGamma[0, 1/2] + 
          4*eps*omega^2*s*PolyGamma[0, 1/2] - 16*eps*omega*Q2*s*
           PolyGamma[0, 1/2] + 8*eps*Q2^2*s*PolyGamma[0, 1/2] - 
          12*eps*omega*s^2*PolyGamma[0, 1/2] + 8*eps*Q2*s^2*
           PolyGamma[0, 1/2]))/(8*omega^2*Pi*(omega + s)*SUNN)) + 
     (eps*(omega^3 - 2*omega^2*Q2 + 2*omega*Q2^2 - 2*omega^2*s + 
        8*omega*Q2*s - 4*Q2^2*s + 6*omega*s^2 - 4*Q2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*PolyLog[2, -(Q2/(omega - Q2))])/(2*omega^2*Pi*(omega + s)*
       SUNN)}, {1, -1, (eps*Pi*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*Q2*s + 
        2*s^2)*(-1 + SUNN)*(1 + SUNN))/(12*omega*(omega + s)*SUNN) + 
     (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*Q2*s + 2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[Q2]^2)/(8*omega*Pi*(omega + s)*SUNN) - 
     (3*eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*Q2*s + 2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[-omega + Q2]^2)/(8*omega*Pi*(omega + s)*SUNN) + 
     Log[-omega + Q2]*((eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*Q2*s + 2*s^2)*
         (-1 + SUNN)*(1 + SUNN)*Log[mu])/(2*omega*Pi*(omega + s)*SUNN) + 
       (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*Q2*s + 2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[omega])/(2*omega*Pi*(omega + s)*SUNN) + 
       (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*Q2*s + 2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(4*omega*Pi*(omega + s)*SUNN) + 
       ((-1 + SUNN)*(1 + SUNN)*(2*omega^2 - 3*eps*omega^2 - 
          4*eps*EulerGamma*omega^2 + (4*I)*eps*omega^2*Pi - 4*omega*Q2 + 
          4*eps*omega*Q2 + 8*eps*EulerGamma*omega*Q2 - (8*I)*eps*omega*Pi*
           Q2 + 4*Q2^2 - 4*eps*Q2^2 - 8*eps*EulerGamma*Q2^2 + 
          (8*I)*eps*Pi*Q2^2 - 4*eps*omega*s + 4*Q2*s - 8*eps*EulerGamma*Q2*
           s + (8*I)*eps*Pi*Q2*s + 4*s^2 - 4*eps*s^2 - 8*eps*EulerGamma*s^2 + 
          (8*I)*eps*Pi*s^2 - 2*eps*omega^2*PolyGamma[0, 1/2] + 
          4*eps*omega*Q2*PolyGamma[0, 1/2] - 4*eps*Q2^2*PolyGamma[0, 1/2] - 
          4*eps*Q2*s*PolyGamma[0, 1/2] - 4*eps*s^2*PolyGamma[0, 1/2]))/
        (8*omega*Pi*(omega + s)*SUNN)) + 
     Log[Q2]*(-1/2*(eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*Q2*s + 2*s^2)*
          (-1 + SUNN)*(1 + SUNN)*Log[mu])/(omega*Pi*(omega + s)*SUNN) - 
       (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*Q2*s + 2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[omega])/(2*omega*Pi*(omega + s)*SUNN) - 
       (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*Q2*s + 2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(4*omega*Pi*(omega + s)*SUNN) + 
       (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*Q2*s + 2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[-omega + Q2])/(4*omega*Pi*(omega + s)*SUNN) + 
       ((-1 + SUNN)*(1 + SUNN)*(-2*omega^2 + 3*eps*omega^2 + 
          4*eps*EulerGamma*omega^2 - (4*I)*eps*omega^2*Pi + 4*omega*Q2 - 
          4*eps*omega*Q2 - 8*eps*EulerGamma*omega*Q2 + (8*I)*eps*omega*Pi*
           Q2 - 4*Q2^2 + 4*eps*Q2^2 + 8*eps*EulerGamma*Q2^2 - 
          (8*I)*eps*Pi*Q2^2 + 4*eps*omega*s - 4*Q2*s + 8*eps*EulerGamma*Q2*
           s - (8*I)*eps*Pi*Q2*s - 4*s^2 + 4*eps*s^2 + 8*eps*EulerGamma*s^2 - 
          (8*I)*eps*Pi*s^2 + 2*eps*omega^2*PolyGamma[0, 1/2] - 
          4*eps*omega*Q2*PolyGamma[0, 1/2] + 4*eps*Q2^2*PolyGamma[0, 1/2] + 
          4*eps*Q2*s*PolyGamma[0, 1/2] + 4*eps*s^2*PolyGamma[0, 1/2]))/
        (8*omega*Pi*(omega + s)*SUNN)) - 
     (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*Q2*s + 2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*PolyLog[2, -(Q2/(omega - Q2))])/(2*omega*Pi*(omega + s)*
       SUNN)}, {1, -1, 
    ((-9*omega^2 - 9*eps*omega^2 + 9*eps*EulerGamma*omega^2 + 
        2*eps*omega^2*Pi^2 + 6*omega*Q2 + 6*eps*omega*Q2 - 
        6*eps*EulerGamma*omega*Q2 - 4*eps*omega*Pi^2*Q2 + 2*eps*Pi^2*Q2^2)*
       s^2*(-1 + SUNN)*(1 + SUNN))/(12*omega^3*Pi*(omega + s)*SUNN^2) - 
     (eps*(3*omega - 2*Q2)*s^2*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (2*omega^2*Pi*(omega + s)*SUNN^2) - 
     (eps*(3*omega - 2*Q2)*s^2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (2*omega^2*Pi*(omega + s)*SUNN^2) - 
     (eps*(3*omega - 2*Q2)*s^2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*omega^2*Pi*(omega + s)*SUNN^2) + 
     (eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*Log[Q2]^2)/
      (4*omega^3*Pi*(omega + s)*SUNN^2) - 
     (3*eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2]^2)/
      (4*omega^3*Pi*(omega + s)*SUNN^2) + Log[-omega + Q2]*
      ((eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
        (omega^3*Pi*(omega + s)*SUNN^2) + (eps*(omega - Q2)^2*s^2*(-1 + SUNN)*
         (1 + SUNN)*Log[omega])/(omega^3*Pi*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (2*omega^3*Pi*(omega + s)*SUNN^2) + ((omega - Q2)^2*s^2*(-1 + SUNN)*
         (1 + SUNN)*(1 - eps - 2*eps*EulerGamma + (2*I)*eps*Pi - 
          eps*PolyGamma[0, 1/2]))/(2*omega^3*Pi*(omega + s)*SUNN^2)) + 
     Log[Q2]*(-((eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
         (omega^3*Pi*(omega + s)*SUNN^2)) - 
       (eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*Log[omega])/
        (omega^3*Pi*(omega + s)*SUNN^2) - (eps*(omega - Q2)^2*s^2*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(2*omega^3*Pi*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/
        (2*omega^3*Pi*(omega + s)*SUNN^2) + ((omega - Q2)^2*s^2*(-1 + SUNN)*
         (1 + SUNN)*(-1 + eps + 2*eps*EulerGamma - (2*I)*eps*Pi + 
          eps*PolyGamma[0, 1/2]))/(2*omega^3*Pi*(omega + s)*SUNN^2)) - 
     (eps*(omega - Q2)^2*s^2*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, -(Q2/(omega - Q2))])/(omega^3*Pi*(omega + s)*SUNN^2)}, 
   {1, -1, ((-1 - eps + eps*EulerGamma)*s*(-1 + SUNN)*(1 + SUNN))/
      (2*Pi*(omega + s)*SUNN^2) - (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (Pi*(omega + s)*SUNN^2) - (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (Pi*(omega + s)*SUNN^2) - (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (2*Pi*(omega + s)*SUNN^2)}, 
   {1, -1, -1/6*(s*(6*omega^2 + 9*eps*omega^2 - 6*eps*EulerGamma*omega^2 - 
         2*eps*omega^2*Pi^2 - 9*omega*Q2 - 12*eps*omega*Q2 + 
         9*eps*EulerGamma*omega*Q2 + 5*eps*omega*Pi^2*Q2 - 3*eps*Pi^2*Q2^2 - 
         3*omega*s - 3*eps*omega*s + 3*eps*EulerGamma*omega*s + 
         eps*omega*Pi^2*s - eps*Pi^2*Q2*s)*(-1 + SUNN)*(1 + SUNN))/
       (omega^2*Pi*(omega + s)*SUNN^2) + 
     (eps*s*(-2*omega + 3*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (omega*Pi*(omega + s)*SUNN^2) + (eps*s*(-2*omega + 3*Q2 + s)*
       (-1 + SUNN)*(1 + SUNN)*Log[mu])/(omega*Pi*(omega + s)*SUNN^2) + 
     (eps*s*(-2*omega + 3*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (2*omega*Pi*(omega + s)*SUNN^2) - 
     (eps*(omega - Q2)*s*(-2*omega + 3*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
       Log[Q2]^2)/(4*omega^2*Pi*(omega + s)*SUNN^2) + 
     (3*eps*(omega - Q2)*s*(-2*omega + 3*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
       Log[-omega + Q2]^2)/(4*omega^2*Pi*(omega + s)*SUNN^2) + 
     Log[Q2]*((eps*(omega - Q2)*s*(-2*omega + 3*Q2 + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[mu])/(omega^2*Pi*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)*s*(-2*omega + 3*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(omega^2*Pi*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)*s*(-2*omega + 3*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
         Log[Pi])/(2*omega^2*Pi*(omega + s)*SUNN^2) - 
       (eps*(omega - Q2)*s*(-2*omega + 3*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
         Log[-omega + Q2])/(2*omega^2*Pi*(omega + s)*SUNN^2) + 
       ((omega - Q2)*s*(-1 + SUNN)*(1 + SUNN)*(-2*omega + eps*omega + 
          4*eps*EulerGamma*omega - (4*I)*eps*omega*Pi + 3*Q2 - 2*eps*Q2 - 
          6*eps*EulerGamma*Q2 + (6*I)*eps*Pi*Q2 + s - eps*s - 
          2*eps*EulerGamma*s + (2*I)*eps*Pi*s + 2*eps*omega*
           PolyGamma[0, 1/2] - 3*eps*Q2*PolyGamma[0, 1/2] - 
          eps*s*PolyGamma[0, 1/2]))/(2*omega^2*Pi*(omega + s)*SUNN^2)) + 
     Log[-omega + Q2]*(-((eps*(omega - Q2)*s*(-2*omega + 3*Q2 + s)*
          (-1 + SUNN)*(1 + SUNN)*Log[mu])/(omega^2*Pi*(omega + s)*SUNN^2)) - 
       (eps*(omega - Q2)*s*(-2*omega + 3*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(omega^2*Pi*(omega + s)*SUNN^2) - 
       (eps*(omega - Q2)*s*(-2*omega + 3*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
         Log[Pi])/(2*omega^2*Pi*(omega + s)*SUNN^2) + 
       ((omega - Q2)*s*(-1 + SUNN)*(1 + SUNN)*(2*omega - eps*omega - 
          4*eps*EulerGamma*omega + (4*I)*eps*omega*Pi - 3*Q2 + 2*eps*Q2 + 
          6*eps*EulerGamma*Q2 - (6*I)*eps*Pi*Q2 - s + eps*s + 
          2*eps*EulerGamma*s - (2*I)*eps*Pi*s - 2*eps*omega*
           PolyGamma[0, 1/2] + 3*eps*Q2*PolyGamma[0, 1/2] + 
          eps*s*PolyGamma[0, 1/2]))/(2*omega^2*Pi*(omega + s)*SUNN^2)) + 
     (eps*(omega - Q2)*s*(-2*omega + 3*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, -(Q2/(omega - Q2))])/(omega^2*Pi*(omega + s)*SUNN^2)}, 
   {1, -1, -1/4*((-1 - eps + eps*EulerGamma)*(omega - 2*Q2)*(-1 + SUNN)*
        (1 + SUNN))/(Pi*(omega + s)*SUNN^2) + 
     (eps*(omega - 2*Q2)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (2*Pi*(omega + s)*SUNN^2) + (eps*(omega - 2*Q2)*(-1 + SUNN)*(1 + SUNN)*
       Log[mu])/(2*Pi*(omega + s)*SUNN^2) + 
     (eps*(omega - 2*Q2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*Pi*(omega + s)*SUNN^2)}, 
   {1, -1, ((-6*omega - 9*eps*omega + 6*eps*EulerGamma*omega + 8*Q2 + 
        10*eps*Q2 - 8*eps*EulerGamma*Q2 + 2*s + 2*eps*s - 2*eps*EulerGamma*s)*
       (-1 + SUNN)*(1 + SUNN))/(4*Pi*(omega + s)*SUNN^2) - 
     (eps*(3*omega - 4*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (Pi*(omega + s)*SUNN^2) - (eps*(3*omega - 4*Q2 - s)*(-1 + SUNN)*
       (1 + SUNN)*Log[mu])/(Pi*(omega + s)*SUNN^2) - 
     (eps*(3*omega - 4*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (2*Pi*(omega + s)*SUNN^2)}, 
   {1, -1, (eps*Pi*(omega - Q2)*(omega - 3*Q2 - 2*s)*(-1 + SUNN)*(1 + SUNN))/
      (6*omega*(omega + s)*SUNN^2) + (eps*(omega - Q2)*(omega - 3*Q2 - 2*s)*
       (-1 + SUNN)*(1 + SUNN)*Log[Q2]^2)/(4*omega*Pi*(omega + s)*SUNN^2) - 
     (3*eps*(omega - Q2)*(omega - 3*Q2 - 2*s)*(-1 + SUNN)*(1 + SUNN)*
       Log[-omega + Q2]^2)/(4*omega*Pi*(omega + s)*SUNN^2) + 
     Log[-omega + Q2]*((eps*(omega - Q2)*(omega - 3*Q2 - 2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[mu])/(omega*Pi*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)*(omega - 3*Q2 - 2*s)*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(omega*Pi*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)*(omega - 3*Q2 - 2*s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (2*omega*Pi*(omega + s)*SUNN^2) + ((-1 + SUNN)*(1 + SUNN)*
         (2*omega^2 - eps*omega^2 - 4*eps*EulerGamma*omega^2 + 
          (4*I)*eps*omega^2*Pi - 8*omega*Q2 + 4*eps*omega*Q2 + 
          16*eps*EulerGamma*omega*Q2 - (16*I)*eps*omega*Pi*Q2 + 6*Q2^2 - 
          4*eps*Q2^2 - 12*eps*EulerGamma*Q2^2 + (12*I)*eps*Pi*Q2^2 - 
          4*omega*s + 3*eps*omega*s + 8*eps*EulerGamma*omega*s - 
          (8*I)*eps*omega*Pi*s + 4*Q2*s - 2*eps*Q2*s - 8*eps*EulerGamma*Q2*
           s + (8*I)*eps*Pi*Q2*s - 2*eps*omega^2*PolyGamma[0, 1/2] + 
          8*eps*omega*Q2*PolyGamma[0, 1/2] - 6*eps*Q2^2*PolyGamma[0, 1/2] + 
          4*eps*omega*s*PolyGamma[0, 1/2] - 4*eps*Q2*s*PolyGamma[0, 1/2]))/
        (4*omega*Pi*(omega + s)*SUNN^2)) + 
     Log[Q2]*(-((eps*(omega - Q2)*(omega - 3*Q2 - 2*s)*(-1 + SUNN)*(1 + SUNN)*
          Log[mu])/(omega*Pi*(omega + s)*SUNN^2)) - 
       (eps*(omega - Q2)*(omega - 3*Q2 - 2*s)*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(omega*Pi*(omega + s)*SUNN^2) - 
       (eps*(omega - Q2)*(omega - 3*Q2 - 2*s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (2*omega*Pi*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)*(omega - 3*Q2 - 2*s)*(-1 + SUNN)*(1 + SUNN)*
         Log[-omega + Q2])/(2*omega*Pi*(omega + s)*SUNN^2) + 
       ((-1 + SUNN)*(1 + SUNN)*(-2*omega^2 + eps*omega^2 + 
          4*eps*EulerGamma*omega^2 - (4*I)*eps*omega^2*Pi + 8*omega*Q2 - 
          4*eps*omega*Q2 - 16*eps*EulerGamma*omega*Q2 + (16*I)*eps*omega*Pi*
           Q2 - 6*Q2^2 + 4*eps*Q2^2 + 12*eps*EulerGamma*Q2^2 - 
          (12*I)*eps*Pi*Q2^2 + 4*omega*s - 3*eps*omega*s - 
          8*eps*EulerGamma*omega*s + (8*I)*eps*omega*Pi*s - 4*Q2*s + 
          2*eps*Q2*s + 8*eps*EulerGamma*Q2*s - (8*I)*eps*Pi*Q2*s + 
          2*eps*omega^2*PolyGamma[0, 1/2] - 8*eps*omega*Q2*
           PolyGamma[0, 1/2] + 6*eps*Q2^2*PolyGamma[0, 1/2] - 
          4*eps*omega*s*PolyGamma[0, 1/2] + 4*eps*Q2*s*PolyGamma[0, 1/2]))/
        (4*omega*Pi*(omega + s)*SUNN^2)) - 
     (eps*(omega - Q2)*(omega - 3*Q2 - 2*s)*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, -(Q2/(omega - Q2))])/(omega*Pi*(omega + s)*SUNN^2)}, 
   {1, -1, ((-4*omega^2 - 4*eps^2*omega^2 + 4*eps*EulerGamma*omega^2 - 
        2*eps^2*EulerGamma^2*omega^2 + eps^2*omega^2*Pi^2 + 8*omega*Q2 - 
        4*eps*omega*Q2 + 4*eps^2*omega*Q2 - 8*eps*EulerGamma*omega*Q2 + 
        4*eps^2*EulerGamma*omega*Q2 + 4*eps^2*EulerGamma^2*omega*Q2 - 
        2*eps^2*omega*Pi^2*Q2 - 4*Q2^2 + 4*eps*Q2^2 + 4*eps*EulerGamma*Q2^2 - 
        4*eps^2*EulerGamma*Q2^2 - 2*eps^2*EulerGamma^2*Q2^2 + 
        eps^2*Pi^2*Q2^2 + 2*eps*omega*s + 4*eps^2*omega*s - 
        2*eps^2*EulerGamma*omega*s - 2*eps*Q2*s - 2*eps^2*Q2*s + 
        2*eps^2*EulerGamma*Q2*s)*(-1 + SUNN)*(1 + SUNN))/
      (8*eps*Pi*s*(omega + s)*SUNN^2) - (eps*(omega - Q2)^2*(-1 + SUNN)*
       (1 + SUNN)*Log[2]^2)/(Pi*s*(omega + s)*SUNN^2) - 
     (eps*(omega - Q2)^2*(-1 + SUNN)*(1 + SUNN)*Log[mu]^2)/
      (Pi*s*(omega + s)*SUNN^2) + 
     ((omega - Q2)*(-2*omega + 2*eps*EulerGamma*omega + 2*Q2 - 2*eps*Q2 - 
        2*eps*EulerGamma*Q2 + eps*s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*Pi*s*(omega + s)*SUNN^2) - (eps*(omega - Q2)^2*(-1 + SUNN)*
       (1 + SUNN)*Log[Pi]^2)/(4*Pi*s*(omega + s)*SUNN^2) + 
     Log[mu]*(((omega - Q2)*(-2*omega + 2*eps*EulerGamma*omega + 2*Q2 - 
          2*eps*Q2 - 2*eps*EulerGamma*Q2 + eps*s)*(-1 + SUNN)*(1 + SUNN))/
        (2*Pi*s*(omega + s)*SUNN^2) - (eps*(omega - Q2)^2*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(Pi*s*(omega + s)*SUNN^2)) + 
     Log[2]*(((omega - Q2)*(-2*omega + 2*eps*EulerGamma*omega + 2*Q2 - 
          2*eps*Q2 - 2*eps*EulerGamma*Q2 + eps*s)*(-1 + SUNN)*(1 + SUNN))/
        (2*Pi*s*(omega + s)*SUNN^2) - (2*eps*(omega - Q2)^2*(-1 + SUNN)*
         (1 + SUNN)*Log[mu])/(Pi*s*(omega + s)*SUNN^2) - 
       (eps*(omega - Q2)^2*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (Pi*s*(omega + s)*SUNN^2))}, 
   {1, -1, -1/8*((-4*omega^2 + 4*eps*omega^2 + 4*eps*EulerGamma*omega^2 - 
         4*eps^2*EulerGamma*omega^2 - 2*eps^2*EulerGamma^2*omega^2 + 
         eps^2*omega^2*Pi^2 + 12*omega*Q2 - 12*eps*omega*Q2 - 
         12*eps*EulerGamma*omega*Q2 + 12*eps^2*EulerGamma*omega*Q2 + 
         6*eps^2*EulerGamma^2*omega*Q2 - 3*eps^2*omega*Pi^2*Q2 - 8*Q2^2 + 
         8*eps*Q2^2 + 8*eps*EulerGamma*Q2^2 - 8*eps^2*EulerGamma*Q2^2 - 
         4*eps^2*EulerGamma^2*Q2^2 + 2*eps^2*Pi^2*Q2^2 + 4*omega*s + 
         4*eps^2*omega*s - 4*eps*EulerGamma*omega*s + 2*eps^2*EulerGamma^2*
          omega*s - eps^2*omega*Pi^2*s - 4*Q2*s - 2*eps*Q2*s - 2*eps^2*Q2*s + 
         4*eps*EulerGamma*Q2*s + 2*eps^2*EulerGamma*Q2*s - 
         2*eps^2*EulerGamma^2*Q2*s + eps^2*Pi^2*Q2*s + 2*eps*s^2 - 
         4*eps^2*s^2 - 2*eps^2*EulerGamma*s^2)*(-1 + SUNN)*(1 + SUNN))/
       (eps*Pi*s*(omega + s)*SUNN^2) + (eps*(omega - Q2)*(omega - 2*Q2 - s)*
       (-1 + SUNN)*(1 + SUNN)*Log[2]^2)/(Pi*s*(omega + s)*SUNN^2) + 
     (eps*(omega - Q2)*(omega - 2*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*Log[mu]^2)/
      (Pi*s*(omega + s)*SUNN^2) - 
     ((-2*omega^2 + 2*eps*omega^2 + 2*eps*EulerGamma*omega^2 + 6*omega*Q2 - 
        6*eps*omega*Q2 - 6*eps*EulerGamma*omega*Q2 - 4*Q2^2 + 4*eps*Q2^2 + 
        4*eps*EulerGamma*Q2^2 + 2*omega*s - 2*eps*EulerGamma*omega*s - 
        2*Q2*s - eps*Q2*s + 2*eps*EulerGamma*Q2*s + eps*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[Pi])/(4*Pi*s*(omega + s)*SUNN^2) + 
     (eps*(omega - Q2)*(omega - 2*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi]^2)/
      (4*Pi*s*(omega + s)*SUNN^2) + 
     Log[mu]*(-1/2*((-2*omega^2 + 2*eps*omega^2 + 2*eps*EulerGamma*omega^2 + 
           6*omega*Q2 - 6*eps*omega*Q2 - 6*eps*EulerGamma*omega*Q2 - 4*Q2^2 + 
           4*eps*Q2^2 + 4*eps*EulerGamma*Q2^2 + 2*omega*s - 
           2*eps*EulerGamma*omega*s - 2*Q2*s - eps*Q2*s + 2*eps*EulerGamma*Q2*
            s + eps*s^2)*(-1 + SUNN)*(1 + SUNN))/(Pi*s*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)*(omega - 2*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (Pi*s*(omega + s)*SUNN^2)) + 
     Log[2]*(-1/2*((-2*omega^2 + 2*eps*omega^2 + 2*eps*EulerGamma*omega^2 + 
           6*omega*Q2 - 6*eps*omega*Q2 - 6*eps*EulerGamma*omega*Q2 - 4*Q2^2 + 
           4*eps*Q2^2 + 4*eps*EulerGamma*Q2^2 + 2*omega*s - 
           2*eps*EulerGamma*omega*s - 2*Q2*s - eps*Q2*s + 2*eps*EulerGamma*Q2*
            s + eps*s^2)*(-1 + SUNN)*(1 + SUNN))/(Pi*s*(omega + s)*SUNN^2) + 
       (2*eps*(omega - Q2)*(omega - 2*Q2 - s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
        (Pi*s*(omega + s)*SUNN^2) + (eps*(omega - Q2)*(omega - 2*Q2 - s)*
         (-1 + SUNN)*(1 + SUNN)*Log[Pi])/(Pi*s*(omega + s)*SUNN^2))}, 
   {1, -1, -1/24*((-12*omega*Q2 + 12*eps*omega*Q2 + 12*eps*EulerGamma*omega*
          Q2 - 12*eps^2*EulerGamma*omega*Q2 - 6*eps^2*EulerGamma^2*omega*Q2 + 
         eps^2*omega*Pi^2*Q2 + 12*Q2^2 - 12*eps*Q2^2 - 12*eps*EulerGamma*
          Q2^2 + 12*eps^2*EulerGamma*Q2^2 + 6*eps^2*EulerGamma^2*Q2^2 - 
         eps^2*Pi^2*Q2^2 - 12*omega*s + 6*eps*omega*s - 6*eps^2*omega*s + 
         12*eps*EulerGamma*omega*s - 6*eps^2*EulerGamma*omega*s - 
         6*eps^2*EulerGamma^2*omega*s + eps^2*omega*Pi^2*s + 12*Q2*s - 
         12*eps*EulerGamma*Q2*s + 6*eps^2*EulerGamma^2*Q2*s - 
         eps^2*Pi^2*Q2*s - 6*eps*s^2 + 12*eps^2*s^2 + 6*eps^2*EulerGamma*s^2)*
        (-1 + SUNN)*(1 + SUNN))/(eps*Pi*s*(omega + s)*SUNN^2) + 
     (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[2]^2)/
      (Pi*s*(omega + s)*SUNN^2) + (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*
       (1 + SUNN)*Log[mu]^2)/(Pi*s*(omega + s)*SUNN^2) + 
     (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi]^2)/
      (4*Pi*s*(omega + s)*SUNN^2) + 
     (-1/4*((-2*omega*Q2 + 2*eps*omega*Q2 + 2*eps*EulerGamma*omega*Q2 + 
           2*Q2^2 - 2*eps*Q2^2 - 2*eps*EulerGamma*Q2^2 - 2*omega*s + 
           eps*omega*s + 2*eps*EulerGamma*omega*s + 2*Q2*s - 
           2*eps*EulerGamma*Q2*s - eps*s^2)*(-1 + SUNN)*(1 + SUNN))/
         (Pi*s*(omega + s)*SUNN^2) + (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[omega])/(2*Pi*s*(omega + s)*SUNN^2))*Log[Q2] - 
     (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Q2]^2)/
      (4*Pi*s*(omega + s)*SUNN^2) + 
     (((-2*omega*Q2 + 2*eps*omega*Q2 + 2*eps*EulerGamma*omega*Q2 + 2*Q2^2 - 
          2*eps*Q2^2 - 2*eps*EulerGamma*Q2^2 - 2*omega*s + eps*omega*s + 
          2*eps*EulerGamma*omega*s + 2*Q2*s - 2*eps*EulerGamma*Q2*s - 
          eps*s^2)*(-1 + SUNN)*(1 + SUNN))/(4*Pi*s*(omega + s)*SUNN^2) - 
       (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[omega])/
        (2*Pi*s*(omega + s)*SUNN^2))*Log[-omega + Q2] + 
     (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2]^2)/
      (4*Pi*s*(omega + s)*SUNN^2) + 
     Log[mu]*(-1/2*((-2*omega*Q2 + 2*eps*omega*Q2 + 2*eps*EulerGamma*omega*
            Q2 + 2*Q2^2 - 2*eps*Q2^2 - 2*eps*EulerGamma*Q2^2 - 2*omega*s + 
           eps*omega*s + 2*eps*EulerGamma*omega*s + 2*Q2*s - 
           2*eps*EulerGamma*Q2*s - eps*s^2)*(-1 + SUNN)*(1 + SUNN))/
         (Pi*s*(omega + s)*SUNN^2) + (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(Pi*s*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Q2])/
        (Pi*s*(omega + s)*SUNN^2) - (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[-omega + Q2])/(Pi*s*(omega + s)*SUNN^2)) + 
     Log[2]*(-1/2*((-2*omega*Q2 + 2*eps*omega*Q2 + 2*eps*EulerGamma*omega*
            Q2 + 2*Q2^2 - 2*eps*Q2^2 - 2*eps*EulerGamma*Q2^2 - 2*omega*s + 
           eps*omega*s + 2*eps*EulerGamma*omega*s + 2*Q2*s - 
           2*eps*EulerGamma*Q2*s - eps*s^2)*(-1 + SUNN)*(1 + SUNN))/
         (Pi*s*(omega + s)*SUNN^2) + (2*eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[mu])/(Pi*s*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (Pi*s*(omega + s)*SUNN^2) + (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[Q2])/(Pi*s*(omega + s)*SUNN^2) - 
       (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/
        (Pi*s*(omega + s)*SUNN^2)) + 
     Log[Pi]*(-1/4*((-2*omega*Q2 + 2*eps*omega*Q2 + 2*eps*EulerGamma*omega*
            Q2 + 2*Q2^2 - 2*eps*Q2^2 - 2*eps*EulerGamma*Q2^2 - 2*omega*s + 
           eps*omega*s + 2*eps*EulerGamma*omega*s + 2*Q2*s - 
           2*eps*EulerGamma*Q2*s - eps*s^2)*(-1 + SUNN)*(1 + SUNN))/
         (Pi*s*(omega + s)*SUNN^2) + (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[Q2])/(2*Pi*s*(omega + s)*SUNN^2) - 
       (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/
        (2*Pi*s*(omega + s)*SUNN^2)) - (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*
       (1 + SUNN)*PolyLog[2, 1 - omega/Q2])/(2*Pi*s*(omega + s)*SUNN^2) + 
     (eps*(omega - Q2)*(Q2 + s)*(-1 + SUNN)*(1 + SUNN)*PolyLog[2, omega/Q2])/
      (2*Pi*s*(omega + s)*SUNN^2)}, 
   {1, -1, -1/18*((-6*omega - 13*eps*omega + 6*eps*EulerGamma*omega + 9*Q2 + 
         18*eps*Q2 - 9*eps*EulerGamma*Q2)*s*(-1 + SUNN)*(1 + SUNN))/
       (Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(2*omega - 3*Q2)*s*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(2*omega - 3*Q2)*s*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(2*omega - 3*Q2)*s*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (6*Pi*(omega - Q2)*(omega + s)*SUNN)}, 
   {1, -1, -1/18*((-3*omega - 5*eps*omega + 3*eps*EulerGamma*omega + 9*Q2 + 
         18*eps*Q2 - 9*eps*EulerGamma*Q2)*s*(-1 + SUNN)*(1 + SUNN))/
       (Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega - 3*Q2)*s*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega - 3*Q2)*s*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
      (3*Pi*(omega - Q2)*(omega + s)*SUNN) + 
     (eps*(omega - 3*Q2)*s*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (6*Pi*(omega - Q2)*(omega + s)*SUNN)}, 
   {1, -1, ((-4*omega - 4*eps^2*omega + 4*eps*EulerGamma*omega - 
        2*eps^2*EulerGamma^2*omega + eps^2*omega*Pi^2 + 4*Q2 - 4*eps*Q2 - 
        4*eps*EulerGamma*Q2 + 4*eps^2*EulerGamma*Q2 + 2*eps^2*EulerGamma^2*
         Q2 - eps^2*Pi^2*Q2)*(-1 + SUNN)*(1 + SUNN))/
      (16*eps*Pi*(omega + s)*SUNN^2) - (eps*(omega - Q2)*(-1 + SUNN)*
       (1 + SUNN)*Log[2]^2)/(2*Pi*(omega + s)*SUNN^2) - 
     (eps*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*Log[mu]^2)/
      (2*Pi*(omega + s)*SUNN^2) + ((-omega + eps*EulerGamma*omega + Q2 - 
        eps*Q2 - eps*EulerGamma*Q2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*Pi*(omega + s)*SUNN^2) - (eps*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*
       Log[Pi]^2)/(8*Pi*(omega + s)*SUNN^2) + 
     Log[mu]*(((-omega + eps*EulerGamma*omega + Q2 - eps*Q2 - 
          eps*EulerGamma*Q2)*(-1 + SUNN)*(1 + SUNN))/(2*Pi*(omega + s)*
         SUNN^2) - (eps*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (2*Pi*(omega + s)*SUNN^2)) + 
     Log[2]*(((-omega + eps*EulerGamma*omega + Q2 - eps*Q2 - 
          eps*EulerGamma*Q2)*(-1 + SUNN)*(1 + SUNN))/(2*Pi*(omega + s)*
         SUNN^2) - (eps*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
        (Pi*(omega + s)*SUNN^2) - (eps*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*
         Log[Pi])/(2*Pi*(omega + s)*SUNN^2))}, 
   {1, -1, -1/4*((-1 - eps + eps*EulerGamma)*(-1 + SUNN)*(1 + SUNN))/
       (Pi*SUNN^2) + (eps*(-1 + SUNN)*(1 + SUNN)*Log[2])/(2*Pi*SUNN^2) + 
     (eps*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(2*Pi*SUNN^2) + 
     (eps*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(4*Pi*SUNN^2)}, 
   {1, -1, ((-1 - eps + eps*EulerGamma)*(omega - 2*Q2)*(-1 + SUNN)*
       (1 + SUNN))/(4*Pi*(omega + s)*SUNN^2) - 
     (eps*(omega - 2*Q2)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (2*Pi*(omega + s)*SUNN^2) - (eps*(omega - 2*Q2)*(-1 + SUNN)*(1 + SUNN)*
       Log[mu])/(2*Pi*(omega + s)*SUNN^2) - 
     (eps*(omega - 2*Q2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*Pi*(omega + s)*SUNN^2)}, 
   {1, -1, -1/16*((-4*omega + 8*eps^2*omega + 4*eps*EulerGamma*omega - 
         2*eps^2*EulerGamma^2*omega + eps^2*omega*Pi^2 + 4*Q2 - 4*eps*Q2 - 
         4*eps*EulerGamma*Q2 + 4*eps^2*EulerGamma*Q2 + 2*eps^2*EulerGamma^2*
          Q2 - eps^2*Pi^2*Q2 - 4*s + 4*eps*s + 4*eps^2*s + 
         4*eps*EulerGamma*s - 4*eps^2*EulerGamma*s - 2*eps^2*EulerGamma^2*s + 
         eps^2*Pi^2*s)*(-1 + SUNN)*(1 + SUNN))/(eps*Pi*(omega + s)*SUNN^2) + 
     (eps*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[2]^2)/
      (2*Pi*(omega + s)*SUNN^2) + (eps*(omega - Q2 + s)*(-1 + SUNN)*
       (1 + SUNN)*Log[mu]^2)/(2*Pi*(omega + s)*SUNN^2) - 
     ((-omega + eps*EulerGamma*omega + Q2 - eps*Q2 - eps*EulerGamma*Q2 - s + 
        eps*s + eps*EulerGamma*s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*Pi*(omega + s)*SUNN^2) + (eps*(omega - Q2 + s)*(-1 + SUNN)*
       (1 + SUNN)*Log[Pi]^2)/(8*Pi*(omega + s)*SUNN^2) + 
     Log[mu]*(-1/2*((-omega + eps*EulerGamma*omega + Q2 - eps*Q2 - 
           eps*EulerGamma*Q2 - s + eps*s + eps*EulerGamma*s)*(-1 + SUNN)*
          (1 + SUNN))/(Pi*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (2*Pi*(omega + s)*SUNN^2)) + 
     Log[2]*(-1/2*((-omega + eps*EulerGamma*omega + Q2 - eps*Q2 - 
           eps*EulerGamma*Q2 - s + eps*s + eps*EulerGamma*s)*(-1 + SUNN)*
          (1 + SUNN))/(Pi*(omega + s)*SUNN^2) + 
       (eps*(omega - Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[mu])/
        (Pi*(omega + s)*SUNN^2) + (eps*(omega - Q2 + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(2*Pi*(omega + s)*SUNN^2))}, 
   {1, -1, ((-9*omega^2 - 9*eps*omega^2 + 9*eps*EulerGamma*omega^2 + 
        2*eps*omega^2*Pi^2 + 6*omega*Q2 + 6*eps*omega*Q2 - 
        6*eps*EulerGamma*omega*Q2 - 4*eps*omega*Pi^2*Q2 + 2*eps*Pi^2*Q2^2)*
       (omega + s)*(-1 + SUNN)*(1 + SUNN))/(12*omega^3*Pi*SUNN^2) - 
     (eps*(3*omega - 2*Q2)*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[2])/
      (2*omega^2*Pi*SUNN^2) - (eps*(3*omega - 2*Q2)*(omega + s)*(-1 + SUNN)*
       (1 + SUNN)*Log[mu])/(2*omega^2*Pi*SUNN^2) - 
     (eps*(3*omega - 2*Q2)*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (4*omega^2*Pi*SUNN^2) + (eps*(omega - Q2)^2*(omega + s)*(-1 + SUNN)*
       (1 + SUNN)*Log[Q2]^2)/(4*omega^3*Pi*SUNN^2) - 
     (3*eps*(omega - Q2)^2*(omega + s)*(-1 + SUNN)*(1 + SUNN)*
       Log[-omega + Q2]^2)/(4*omega^3*Pi*SUNN^2) + 
     Log[-omega + Q2]*((eps*(omega - Q2)^2*(omega + s)*(-1 + SUNN)*(1 + SUNN)*
         Log[mu])/(omega^3*Pi*SUNN^2) + (eps*(omega - Q2)^2*(omega + s)*
         (-1 + SUNN)*(1 + SUNN)*Log[omega])/(omega^3*Pi*SUNN^2) + 
       (eps*(omega - Q2)^2*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (2*omega^3*Pi*SUNN^2) + ((omega - Q2)^2*(omega + s)*(-1 + SUNN)*
         (1 + SUNN)*(1 - eps - 2*eps*EulerGamma + (2*I)*eps*Pi - 
          eps*PolyGamma[0, 1/2]))/(2*omega^3*Pi*SUNN^2)) + 
     Log[Q2]*(-((eps*(omega - Q2)^2*(omega + s)*(-1 + SUNN)*(1 + SUNN)*
          Log[mu])/(omega^3*Pi*SUNN^2)) - (eps*(omega - Q2)^2*(omega + s)*
         (-1 + SUNN)*(1 + SUNN)*Log[omega])/(omega^3*Pi*SUNN^2) - 
       (eps*(omega - Q2)^2*(omega + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (2*omega^3*Pi*SUNN^2) + (eps*(omega - Q2)^2*(omega + s)*(-1 + SUNN)*
         (1 + SUNN)*Log[-omega + Q2])/(2*omega^3*Pi*SUNN^2) + 
       ((omega - Q2)^2*(omega + s)*(-1 + SUNN)*(1 + SUNN)*
         (-1 + eps + 2*eps*EulerGamma - (2*I)*eps*Pi + 
          eps*PolyGamma[0, 1/2]))/(2*omega^3*Pi*SUNN^2)) - 
     (eps*(omega - Q2)^2*(omega + s)*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, -(Q2/(omega - Q2))])/(omega^3*Pi*SUNN^2)}, 
   {1, -1, -1/6*((-6*omega^2 - 9*eps*omega^2 + 6*eps*EulerGamma*omega^2 + 
         2*eps*omega^2*Pi^2 + 6*omega*Q2 + 9*eps*omega*Q2 - 
         6*eps*EulerGamma*omega*Q2 - 4*eps*omega*Pi^2*Q2 + 2*eps*Pi^2*Q2^2 - 
         3*omega*s - 3*eps*omega*s + 3*eps*EulerGamma*omega*s + 
         eps*omega*Pi^2*s - eps*Pi^2*Q2*s)*(-1 + SUNN)*(1 + SUNN))/
       (omega^2*Pi*SUNN^2) + (eps*(2*omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
       Log[2])/(omega*Pi*SUNN^2) + (eps*(2*omega - 2*Q2 + s)*(-1 + SUNN)*
       (1 + SUNN)*Log[mu])/(omega*Pi*SUNN^2) + 
     (eps*(2*omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
      (2*omega*Pi*SUNN^2) - (eps*(omega - Q2)*(2*omega - 2*Q2 + s)*
       (-1 + SUNN)*(1 + SUNN)*Log[Q2]^2)/(4*omega^2*Pi*SUNN^2) + 
     (3*eps*(omega - Q2)*(2*omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
       Log[-omega + Q2]^2)/(4*omega^2*Pi*SUNN^2) + 
     Log[Q2]*((eps*(omega - Q2)*(2*omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
         Log[mu])/(omega^2*Pi*SUNN^2) + 
       (eps*(omega - Q2)*(2*omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(omega^2*Pi*SUNN^2) + 
       (eps*(omega - Q2)*(2*omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (2*omega^2*Pi*SUNN^2) - (eps*(omega - Q2)*(2*omega - 2*Q2 + s)*
         (-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/(2*omega^2*Pi*SUNN^2) + 
       ((omega - Q2)*(-1 + SUNN)*(1 + SUNN)*(2*omega - eps*omega - 
          4*eps*EulerGamma*omega + (4*I)*eps*omega*Pi - 2*Q2 + eps*Q2 + 
          4*eps*EulerGamma*Q2 - (4*I)*eps*Pi*Q2 + s - eps*s - 
          2*eps*EulerGamma*s + (2*I)*eps*Pi*s - 2*eps*omega*
           PolyGamma[0, 1/2] + 2*eps*Q2*PolyGamma[0, 1/2] - 
          eps*s*PolyGamma[0, 1/2]))/(2*omega^2*Pi*SUNN^2)) + 
     Log[-omega + Q2]*(-((eps*(omega - Q2)*(2*omega - 2*Q2 + s)*(-1 + SUNN)*
          (1 + SUNN)*Log[mu])/(omega^2*Pi*SUNN^2)) - 
       (eps*(omega - Q2)*(2*omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
         Log[omega])/(omega^2*Pi*SUNN^2) - 
       (eps*(omega - Q2)*(2*omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/
        (2*omega^2*Pi*SUNN^2) + ((omega - Q2)*(-1 + SUNN)*(1 + SUNN)*
         (-2*omega + eps*omega + 4*eps*EulerGamma*omega - 
          (4*I)*eps*omega*Pi + 2*Q2 - eps*Q2 - 4*eps*EulerGamma*Q2 + 
          (4*I)*eps*Pi*Q2 - s + eps*s + 2*eps*EulerGamma*s - (2*I)*eps*Pi*s + 
          2*eps*omega*PolyGamma[0, 1/2] - 2*eps*Q2*PolyGamma[0, 1/2] + 
          eps*s*PolyGamma[0, 1/2]))/(2*omega^2*Pi*SUNN^2)) + 
     (eps*(omega - Q2)*(2*omega - 2*Q2 + s)*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, -(Q2/(omega - Q2))])/(omega^2*Pi*SUNN^2)}, 
   {1, -1, (eps*Pi*(2*omega^2 - 4*omega*Q2 + 2*Q2^2 + omega*s - 2*Q2*s)*
       (-1 + SUNN)*(1 + SUNN))/(12*omega*(omega + s)*SUNN^2) + 
     (eps*(2*omega^2 - 4*omega*Q2 + 2*Q2^2 + omega*s - 2*Q2*s)*(-1 + SUNN)*
       (1 + SUNN)*Log[Q2]^2)/(8*omega*Pi*(omega + s)*SUNN^2) - 
     (3*eps*(2*omega^2 - 4*omega*Q2 + 2*Q2^2 + omega*s - 2*Q2*s)*(-1 + SUNN)*
       (1 + SUNN)*Log[-omega + Q2]^2)/(8*omega*Pi*(omega + s)*SUNN^2) + 
     Log[Q2]*(-1/2*(eps*(2*omega^2 - 4*omega*Q2 + 2*Q2^2 + omega*s - 2*Q2*s)*
          (-1 + SUNN)*(1 + SUNN)*Log[mu])/(omega*Pi*(omega + s)*SUNN^2) - 
       (eps*(2*omega^2 - 4*omega*Q2 + 2*Q2^2 + omega*s - 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[omega])/(2*omega*Pi*(omega + s)*SUNN^2) - 
       (eps*(2*omega^2 - 4*omega*Q2 + 2*Q2^2 + omega*s - 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(4*omega*Pi*(omega + s)*SUNN^2) + 
       (eps*(2*omega^2 - 4*omega*Q2 + 2*Q2^2 + omega*s - 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[-omega + Q2])/(4*omega*Pi*(omega + s)*SUNN^2) + 
       ((-1 + SUNN)*(1 + SUNN)*(-2*omega^2 + eps*omega^2 + 
          4*eps*EulerGamma*omega^2 - (4*I)*eps*omega^2*Pi + 4*omega*Q2 - 
          2*eps*omega*Q2 - 8*eps*EulerGamma*omega*Q2 + (8*I)*eps*omega*Pi*
           Q2 - 2*Q2^2 + 2*eps*Q2^2 + 4*eps*EulerGamma*Q2^2 - 
          (4*I)*eps*Pi*Q2^2 - omega*s - eps*omega*s + 2*eps*EulerGamma*omega*
           s - (2*I)*eps*omega*Pi*s + 2*Q2*s - 4*eps*EulerGamma*Q2*s + 
          (4*I)*eps*Pi*Q2*s + 2*eps*omega^2*PolyGamma[0, 1/2] - 
          4*eps*omega*Q2*PolyGamma[0, 1/2] + 2*eps*Q2^2*PolyGamma[0, 1/2] + 
          eps*omega*s*PolyGamma[0, 1/2] - 2*eps*Q2*s*PolyGamma[0, 1/2]))/
        (4*omega*Pi*(omega + s)*SUNN^2)) + Log[-omega + Q2]*
      ((eps*(2*omega^2 - 4*omega*Q2 + 2*Q2^2 + omega*s - 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[mu])/(2*omega*Pi*(omega + s)*SUNN^2) + 
       (eps*(2*omega^2 - 4*omega*Q2 + 2*Q2^2 + omega*s - 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[omega])/(2*omega*Pi*(omega + s)*SUNN^2) + 
       (eps*(2*omega^2 - 4*omega*Q2 + 2*Q2^2 + omega*s - 2*Q2*s)*(-1 + SUNN)*
         (1 + SUNN)*Log[Pi])/(4*omega*Pi*(omega + s)*SUNN^2) + 
       ((-1 + SUNN)*(1 + SUNN)*(2*omega^2 - eps*omega^2 - 
          4*eps*EulerGamma*omega^2 + (4*I)*eps*omega^2*Pi - 4*omega*Q2 + 
          2*eps*omega*Q2 + 8*eps*EulerGamma*omega*Q2 - (8*I)*eps*omega*Pi*
           Q2 + 2*Q2^2 - 2*eps*Q2^2 - 4*eps*EulerGamma*Q2^2 + 
          (4*I)*eps*Pi*Q2^2 + omega*s + eps*omega*s - 2*eps*EulerGamma*omega*
           s + (2*I)*eps*omega*Pi*s - 2*Q2*s + 4*eps*EulerGamma*Q2*s - 
          (4*I)*eps*Pi*Q2*s - 2*eps*omega^2*PolyGamma[0, 1/2] + 
          4*eps*omega*Q2*PolyGamma[0, 1/2] - 2*eps*Q2^2*PolyGamma[0, 1/2] - 
          eps*omega*s*PolyGamma[0, 1/2] + 2*eps*Q2*s*PolyGamma[0, 1/2]))/
        (4*omega*Pi*(omega + s)*SUNN^2)) - 
     (eps*(2*omega^2 - 4*omega*Q2 + 2*Q2^2 + omega*s - 2*Q2*s)*(-1 + SUNN)*
       (1 + SUNN)*PolyLog[2, -(Q2/(omega - Q2))])/(2*omega*Pi*(omega + s)*
       SUNN^2)}, {1, -1, 
    ((-12*eps*omega + 24*eps^2*omega + 12*eps^2*EulerGamma*omega - 12*s + 
        12*eps*s + 12*eps^2*s + 12*eps*EulerGamma*s - 12*eps^2*EulerGamma*s - 
        6*eps^2*EulerGamma^2*s + eps^2*Pi^2*s)*(-1 + SUNN)*(1 + SUNN))/
      (48*eps*Pi*(omega + s)*SUNN^2) - (eps*s*(-1 + SUNN)*(1 + SUNN)*
       Log[2]^2)/(2*Pi*(omega + s)*SUNN^2) - 
     (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[mu]^2)/(2*Pi*(omega + s)*SUNN^2) - 
     (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[Pi]^2)/(8*Pi*(omega + s)*SUNN^2) + 
     (-1/4*((eps*omega + s - eps*s - eps*EulerGamma*s)*(-1 + SUNN)*
          (1 + SUNN))/(Pi*(omega + s)*SUNN^2) - 
       (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[omega])/(4*Pi*(omega + s)*SUNN^2))*
      Log[Q2] + (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[Q2]^2)/
      (8*Pi*(omega + s)*SUNN^2) + 
     (((eps*omega + s - eps*s - eps*EulerGamma*s)*(-1 + SUNN)*(1 + SUNN))/
        (4*Pi*(omega + s)*SUNN^2) + (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[omega])/
        (4*Pi*(omega + s)*SUNN^2))*Log[-omega + Q2] - 
     (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2]^2)/
      (8*Pi*(omega + s)*SUNN^2) + 
     Log[Pi]*(-1/4*((eps*omega + s - eps*s - eps*EulerGamma*s)*(-1 + SUNN)*
          (1 + SUNN))/(Pi*(omega + s)*SUNN^2) - 
       (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[Q2])/(4*Pi*(omega + s)*SUNN^2) + 
       (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/
        (4*Pi*(omega + s)*SUNN^2)) + 
     Log[mu]*(-1/2*((eps*omega + s - eps*s - eps*EulerGamma*s)*(-1 + SUNN)*
          (1 + SUNN))/(Pi*(omega + s)*SUNN^2) - 
       (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(2*Pi*(omega + s)*SUNN^2) - 
       (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[Q2])/(2*Pi*(omega + s)*SUNN^2) + 
       (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/
        (2*Pi*(omega + s)*SUNN^2)) + 
     Log[2]*(-1/2*((eps*omega + s - eps*s - eps*EulerGamma*s)*(-1 + SUNN)*
          (1 + SUNN))/(Pi*(omega + s)*SUNN^2) - 
       (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[mu])/(Pi*(omega + s)*SUNN^2) - 
       (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(2*Pi*(omega + s)*SUNN^2) - 
       (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[Q2])/(2*Pi*(omega + s)*SUNN^2) + 
       (eps*s*(-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/
        (2*Pi*(omega + s)*SUNN^2)) + (eps*s*(-1 + SUNN)*(1 + SUNN)*
       PolyLog[2, 1 - omega/Q2])/(4*Pi*(omega + s)*SUNN^2) - 
     (eps*s*(-1 + SUNN)*(1 + SUNN)*PolyLog[2, omega/Q2])/
      (4*Pi*(omega + s)*SUNN^2)}}, "CombinedRows" -> 
  {{1, -1, -1/72*((-1 + SUNN)*(1 + SUNN)*(27*eps*omega^2*Pi^2 - 
         54*eps*omega*Pi^2*Q2 + 36*eps*Pi^2*Q2^2 + 18*eps*omega*Pi^2*s + 
         18*eps*Pi^2*s^2 + 12*omega^2*SUNN - 4*eps*omega^2*SUNN - 
         12*eps*EulerGamma*omega^2*SUNN - 24*omega*Q2*SUNN - 
         16*eps*omega*Q2*SUNN + 24*eps*EulerGamma*omega*Q2*SUNN + 
         24*Q2^2*SUNN + 16*eps*Q2^2*SUNN - 24*eps*EulerGamma*Q2^2*SUNN + 
         24*omega*s*SUNN + 16*eps*omega*s*SUNN - 24*eps*EulerGamma*omega*s*
          SUNN + 24*s^2*SUNN + 16*eps*s^2*SUNN - 24*eps*EulerGamma*s^2*SUNN))/
       (Pi*s*(omega + s)*SUNN^2) - 
     (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*omega*s + 2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[mu])/(3*Pi*s*(omega + s)*SUNN) - 
     (eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*omega*s + 2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[Pi])/(6*Pi*s*(omega + s)*SUNN) + 
     (eps*(3*omega^2 - 6*omega*Q2 + 4*Q2^2 + 2*omega*s + 2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[-omega + Q2]^2)/(4*Pi*s*(omega + s)*SUNN^2) + 
     Log[omega]*((eps*(3*omega^2 - 6*omega*Q2 + 4*Q2^2 + 2*omega*s + 2*s^2)*
         (-1 + SUNN)*(1 + SUNN)*Log[Q2])/(4*Pi*s*(omega + s)*SUNN^2) - 
       (eps*(3*omega^2 - 6*omega*Q2 + 4*Q2^2 + 2*omega*s + 2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[-omega + Q2])/(4*Pi*s*(omega + s)*SUNN^2)) + 
     Log[2]*(-1/3*(eps*(omega^2 - 2*omega*Q2 + 2*Q2^2 + 2*omega*s + 2*s^2)*
          (-1 + SUNN)*(1 + SUNN))/(Pi*s*(omega + s)*SUNN) - 
       (eps*(3*omega^2 - 6*omega*Q2 + 4*Q2^2 + 2*omega*s + 2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[Q2])/(2*Pi*s*(omega + s)*SUNN^2) + 
       (eps*(3*omega^2 - 6*omega*Q2 + 4*Q2^2 + 2*omega*s + 2*s^2)*(-1 + SUNN)*
         (1 + SUNN)*Log[-omega + Q2])/(2*Pi*s*(omega + s)*SUNN^2)) + 
     Log[Q2]*(-1/4*(eps*(3*omega^2 - 6*omega*Q2 + 4*Q2^2 + 2*omega*s + 2*s^2)*
          (-1 + SUNN)*(1 + SUNN)*Log[-omega + Q2])/(Pi*s*(omega + s)*
          SUNN^2) + ((I/4)*eps*(3*omega^2 - 6*omega*Q2 + 4*Q2^2 + 2*omega*s + 
          2*s^2)*(-1 + SUNN)*(1 + SUNN)*(I*EulerGamma + 2*Pi + 
          I*PolyGamma[0, 1/2]))/(Pi*s*(omega + s)*SUNN^2)) + 
     (eps*(3*omega^2 - 6*omega*Q2 + 4*Q2^2 + 2*omega*s + 2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*Log[-omega + Q2]*(EulerGamma - (2*I)*Pi + 
        PolyGamma[0, 1/2]))/(4*Pi*s*(omega + s)*SUNN^2) + 
     (eps*(3*omega^2 - 6*omega*Q2 + 4*Q2^2 + 2*omega*s + 2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*PolyLog[2, 1 - omega/Q2])/(4*Pi*s*(omega + s)*SUNN^2) - 
     (eps*(3*omega^2 - 6*omega*Q2 + 4*Q2^2 + 2*omega*s + 2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*PolyLog[2, omega/Q2])/(4*Pi*s*(omega + s)*SUNN^2) + 
     (eps*(3*omega^2 - 6*omega*Q2 + 4*Q2^2 + 2*omega*s + 2*s^2)*(-1 + SUNN)*
       (1 + SUNN)*PolyLog[2, -(Q2/(omega - Q2))])/(2*Pi*s*(omega + s)*
       SUNN^2)}, {1, -2, 0}}, "InputHash" -> 95028121739659674104084594710444\
241326553837740121012036747231098505525294343|>
