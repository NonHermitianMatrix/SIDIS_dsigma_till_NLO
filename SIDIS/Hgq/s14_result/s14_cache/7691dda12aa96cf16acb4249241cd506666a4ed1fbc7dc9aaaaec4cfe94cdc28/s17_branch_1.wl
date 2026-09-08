<|"Delta" -> -1/6*(Pi*s*(12 + 21*eps + 42*eps^2 - 12*eps*EulerGamma - 
       21*eps^2*EulerGamma + 6*eps^2*EulerGamma^2 - 3*eps^2*Pi^2 - 
       24*SUNN^2 - 33*eps*SUNN^2 - 54*eps^2*SUNN^2 + 24*eps*EulerGamma*
        SUNN^2 + 33*eps^2*EulerGamma*SUNN^2 - 12*eps^2*EulerGamma^2*SUNN^2 + 
       4*eps^2*Pi^2*SUNN^2))/(eps^2*SUNN) + (Pi*s*(-1 + 5*SUNN^2)*Log[B]^2)/
    SUNN + (Pi*s*(-1 + 2*SUNN^2)*Log[Pi]^2)/SUNN + 
   Log[Q2/(omega + Q2)]*((Pi*s*(omega - eps*EulerGamma*omega - eps*Q2 - s - 
        eps*s + eps*EulerGamma*s - 2*omega*SUNN^2 - 2*eps*omega*SUNN^2 + 
        2*eps*EulerGamma*omega*SUNN^2 + 2*s*SUNN^2 + 2*eps*s*SUNN^2 - 
        2*eps*EulerGamma*s*SUNN^2 + eps*omega*ArcTanh[omega/(omega + 2*Q2)] - 
        eps*s*ArcTanh[omega/(omega + 2*Q2)]))/(2*eps*(omega - s)*SUNN) + 
     (Pi*s*SUNN*Log[Q2/(Pi^2*(omega + Q2))])/2 - 
     (Pi*s*(-1 + 2*SUNN^2)*Log[(omega + Q2)/Q2])/(4*SUNN)) + 
   (Pi*s*(omega - eps*EulerGamma*omega - eps*Q2 - s - eps*s + 
      eps*EulerGamma*s - 2*omega*SUNN^2 - 2*eps*omega*SUNN^2 + 
      2*eps*EulerGamma*omega*SUNN^2 + 2*s*SUNN^2 + 2*eps*s*SUNN^2 - 
      2*eps*EulerGamma*s*SUNN^2)*Log[(Pi*(omega + Q2))/Q2])/
    (2*eps*(omega - s)*SUNN) + (2*(-1 - eps + eps*EulerGamma)*Pi*s*SUNN*
     Log[-((omega + Q2)/(omega*s - s^2))])/eps + 
   Pi*s*SUNN*Log[-((omega + Q2)/(omega*s - s^2))]^2 + 
   Log[Pi]*((Pi*s*(3*omega + 7*eps*omega - 3*eps*EulerGamma*omega + eps*Q2 - 
        3*s - 6*eps*s + 3*eps*EulerGamma*s - 6*omega*SUNN^2 - 
        9*eps*omega*SUNN^2 + 6*eps*EulerGamma*omega*SUNN^2 + 6*s*SUNN^2 + 
        9*eps*s*SUNN^2 - 6*eps*EulerGamma*s*SUNN^2))/
      (2*eps*(omega - s)*SUNN) + Pi*s*SUNN*Log[Q2/(omega + Q2)] + 
     2*Pi*s*SUNN*Log[-((omega + Q2)/(omega*s - s^2))]) + 
   Log[B]*((Pi*s*(4 + 7*eps - 4*eps*EulerGamma - 12*SUNN^2 - 15*eps*SUNN^2 + 
        12*eps*EulerGamma*SUNN^2))/(2*eps*SUNN) + 
     (Pi*s*(-3 + 10*SUNN^2)*Log[Pi])/(2*SUNN) + 
     (Pi*s*(-1 + 2*SUNN^2)*Log[Q2/(omega + Q2)])/(2*SUNN) + 
     (Pi*s*(-1 + 2*SUNN^2)*Log[(Pi*(omega + Q2))/Q2])/(2*SUNN) + 
     4*Pi*s*SUNN*Log[-((omega + Q2)/(omega*s - s^2))]) + 
   (Pi*s*(-1 + 2*SUNN^2)*PolyLog[2, -(omega/Q2)])/SUNN + 
   (Pi*s*(-1 + 2*SUNN^2)*PolyLog[2, omega/(omega + Q2)])/SUNN, 
 "L0" -> (Pi*s*(4 + 7*eps - 4*eps*EulerGamma - 12*SUNN^2 - 15*eps*SUNN^2 + 
      12*eps*EulerGamma*SUNN^2))/(2*eps*SUNN) + 
   (2*Pi*s*(-1 + 5*SUNN^2)*Log[B])/SUNN + (Pi*s*(-3 + 10*SUNN^2)*Log[Pi])/
    (2*SUNN) + (Pi*s*(-1 + 2*SUNN^2)*Log[Q2/(omega + Q2)])/(2*SUNN) + 
   (Pi*s*(-1 + 2*SUNN^2)*Log[(Pi*(omega + Q2))/Q2])/(2*SUNN) + 
   4*Pi*s*SUNN*Log[-((omega + Q2)/(omega*s - s^2))], 
 "L1" -> (-2*Pi*s)/SUNN + 10*Pi*s*SUNN, 
 "Regular" -> -1/2*(Pi*(Q2*(omega - s) - 2*Q2*w - s*w)*
      (-omega + s + Q2*SUNN^2 + (omega - s)*SUNN^2 + s*SUNN^2 + w - 
       SUNN^2*w))/(eps*(omega - s)*(Q2 + s)*SUNN*(omega - s - w)) - 
   (Pi*SUNN*(4*(omega - s)^2*s + Q2*(omega - s)*w - 5*(omega - s)*s*w + 
      2*s*w^2))/(eps*(omega - s)*(omega - s - w)*w) + 
   (Pi*(Q2*(omega - s)*s + (omega - s)*s^2 - Q2*(omega - s)*w - Q2*s*w - 
      2*(omega - s)*s*w - s^2*w + Q2*(omega - s)*SUNN^2*w + 
      2*(omega - s)*s*SUNN^2*w + s*w^2 - s*SUNN^2*w^2))/
    (2*eps*(omega - s)*(Q2 + s)*SUNN*w) - 
   (Pi*(Q2^2*s + Q2*(omega - s)*s + 2*Q2*s^2 + (omega - s)*s^2 + s^3 - 
      Q2*(omega - s)*w - 2*Q2*s*w - 2*(omega - s)*s*w - 2*s^2*w + 
      Q2*(omega - s)*SUNN^2*w + Q2*s*SUNN^2*w + 2*(omega - s)*s*SUNN^2*w + 
      s^2*SUNN^2*w + s*w^2 - s*SUNN^2*w^2))/(2*(omega - s)*(Q2 + s)*SUNN*w) + 
   (Pi*(Q2*(omega - s)^2*s + (omega - s)^2*s^2 - Q2*(omega - s)^2*w + 
      Q2^2*(omega - s)*SUNN^2*w + Q2*(omega - s)^2*SUNN^2*w + 
      Q2*(omega - s)*s*SUNN^2*w + Q2*(omega - s)*w^2 - Q2*s*w^2 - 
      (omega - s)*s*w^2 - s^2*w^2 - Q2*(omega - s)*SUNN^2*w^2 + 
      Q2*s*SUNN^2*w^2 + (omega - s)*s*SUNN^2*w^2 + s^2*SUNN^2*w^2 + s*w^3 - 
      s*SUNN^2*w^3))/(eps*(omega - s)*(Q2 + s)*SUNN*(omega - s - w)*w) + 
   (Pi*SUNN*(-12*Q2*(omega - s)^4*w - 20*(omega - s)^5*w - 
      4*(omega - s)^4*s*w + 40*Q2*(omega - s)^3*w^2 + 60*(omega - s)^4*w^2 - 
      8*(omega - s)^3*s*w^2 - 68*Q2*(omega - s)^2*w^3 - 
      60*(omega - s)^3*w^3 + 28*(omega - s)^2*s*w^3 + 64*Q2*(omega - s)*w^4 + 
      20*(omega - s)^2*w^4 - 16*(omega - s)*s*w^4 - 24*Q2*w^5))/
    (2*(omega - s)^4*(omega - s - w)*w) + 
   (Pi*SUNN*(-2*(omega - s)^5*s - 5*Q2*(omega - s)^4*w + 4*(omega - s)^5*w + 
      13*(omega - s)^4*s*w + 16*Q2*(omega - s)^3*w^2 - 12*(omega - s)^4*w^2 - 
      24*(omega - s)^3*s*w^2 - 20*Q2*(omega - s)^2*w^3 + 
      12*(omega - s)^3*w^3 + 20*(omega - s)^2*s*w^3 + 16*Q2*(omega - s)*w^4 - 
      4*(omega - s)^2*w^4 - 8*(omega - s)*s*w^4 - 8*Q2*w^5))/
    (2*eps*(omega - s)^4*(omega - s - w)*w) - 
   (Pi*(-16*Q2^2*(omega - s)^10*s^2 - 16*Q2*(omega - s)^11*s^2 - 
      96*Q2^2*(omega - s)^9*s^3 - 112*Q2*(omega - s)^10*s^3 - 
      240*Q2^2*(omega - s)^8*s^4 - 336*Q2*(omega - s)^9*s^4 - 
      320*Q2^2*(omega - s)^7*s^5 - 560*Q2*(omega - s)^8*s^5 - 
      240*Q2^2*(omega - s)^6*s^6 - 560*Q2*(omega - s)^7*s^6 - 
      96*Q2^2*(omega - s)^5*s^7 - 336*Q2*(omega - s)^6*s^7 - 
      16*Q2^2*(omega - s)^4*s^8 - 112*Q2*(omega - s)^5*s^8 - 
      16*Q2*(omega - s)^4*s^9 + 32*Q2^2*(omega - s)^10*s^2*SUNN^2 + 
      32*Q2*(omega - s)^11*s^2*SUNN^2 + 192*Q2^2*(omega - s)^9*s^3*SUNN^2 + 
      224*Q2*(omega - s)^10*s^3*SUNN^2 + 480*Q2^2*(omega - s)^8*s^4*SUNN^2 + 
      672*Q2*(omega - s)^9*s^4*SUNN^2 + 640*Q2^2*(omega - s)^7*s^5*SUNN^2 + 
      1120*Q2*(omega - s)^8*s^5*SUNN^2 + 480*Q2^2*(omega - s)^6*s^6*SUNN^2 + 
      1120*Q2*(omega - s)^7*s^6*SUNN^2 + 192*Q2^2*(omega - s)^5*s^7*SUNN^2 + 
      672*Q2*(omega - s)^6*s^7*SUNN^2 + 32*Q2^2*(omega - s)^4*s^8*SUNN^2 + 
      224*Q2*(omega - s)^5*s^8*SUNN^2 + 32*Q2*(omega - s)^4*s^9*SUNN^2 + 
      16*Q2^3*(omega - s)^9*s*w + 16*Q2^2*(omega - s)^10*s*w - 
      96*Q2^3*(omega - s)^8*s^2*w - 32*Q2^2*(omega - s)^9*s^2*w + 
      64*Q2*(omega - s)^10*s^2*w - 528*Q2^3*(omega - s)^7*s^3*w - 
      336*Q2^2*(omega - s)^8*s^3*w + 432*Q2*(omega - s)^9*s^3*w - 
      832*Q2^3*(omega - s)^6*s^4*w - 640*Q2^2*(omega - s)^7*s^4*w + 
      1248*Q2*(omega - s)^8*s^4*w - 528*Q2^3*(omega - s)^5*s^5*w - 
      400*Q2^2*(omega - s)^6*s^5*w + 2000*Q2*(omega - s)^7*s^5*w - 
      96*Q2^3*(omega - s)^4*s^6*w + 96*Q2^2*(omega - s)^5*s^6*w + 
      1920*Q2*(omega - s)^6*s^6*w + 16*Q2^3*(omega - s)^3*s^7*w + 
      208*Q2^2*(omega - s)^4*s^7*w + 1104*Q2*(omega - s)^5*s^7*w + 
      64*Q2^2*(omega - s)^3*s^8*w + 352*Q2*(omega - s)^4*s^8*w + 
      48*Q2*(omega - s)^3*s^9*w + 16*Q2^3*(omega - s)^9*s*SUNN^2*w + 
      64*Q2^2*(omega - s)^10*s*SUNN^2*w + 48*Q2*(omega - s)^11*s*SUNN^2*w + 
      480*Q2^3*(omega - s)^8*s^2*SUNN^2*w + 816*Q2^2*(omega - s)^9*s^2*SUNN^2*
       w + 336*Q2*(omega - s)^10*s^2*SUNN^2*w + 1776*Q2^3*(omega - s)^7*s^3*
       SUNN^2*w + 3168*Q2^2*(omega - s)^8*s^3*SUNN^2*w + 
      1040*Q2*(omega - s)^9*s^3*SUNN^2*w + 2624*Q2^3*(omega - s)^6*s^4*SUNN^2*
       w + 5840*Q2^2*(omega - s)^7*s^4*SUNN^2*w + 1872*Q2*(omega - s)^8*s^4*
       SUNN^2*w + 1776*Q2^3*(omega - s)^5*s^5*SUNN^2*w + 
      5760*Q2^2*(omega - s)^6*s^5*SUNN^2*w + 2160*Q2*(omega - s)^7*s^5*SUNN^2*
       w + 480*Q2^3*(omega - s)^4*s^6*SUNN^2*w + 3024*Q2^2*(omega - s)^5*s^6*
       SUNN^2*w + 1648*Q2*(omega - s)^6*s^6*SUNN^2*w + 
      16*Q2^3*(omega - s)^3*s^7*SUNN^2*w + 736*Q2^2*(omega - s)^4*s^7*SUNN^2*
       w + 816*Q2*(omega - s)^5*s^7*SUNN^2*w + 48*Q2^2*(omega - s)^3*s^8*
       SUNN^2*w + 240*Q2*(omega - s)^4*s^8*SUNN^2*w + 
      32*Q2*(omega - s)^3*s^9*SUNN^2*w - 16*Q2^3*(omega - s)^9*w^2 - 
      32*Q2^2*(omega - s)^10*w^2 - 16*Q2*(omega - s)^11*w^2 + 
      192*Q2^4*(omega - s)^7*s*w^2 + 96*Q2^3*(omega - s)^8*s*w^2 - 
      288*Q2^2*(omega - s)^9*s*w^2 - 176*Q2*(omega - s)^10*s*w^2 + 
      528*Q2^3*(omega - s)^7*s^2*w^2 - 304*Q2^2*(omega - s)^8*s^2*w^2 - 
      848*Q2*(omega - s)^9*s^2*w^2 - 384*Q2^4*(omega - s)^5*s^3*w^2 + 
      1600*Q2^3*(omega - s)^6*s^3*w^2 + 1472*Q2^2*(omega - s)^7*s^3*w^2 - 
      2304*Q2*(omega - s)^8*s^3*w^2 + 2832*Q2^3*(omega - s)^5*s^4*w^2 + 
      4272*Q2^2*(omega - s)^6*s^4*w^2 - 3856*Q2*(omega - s)^7*s^4*w^2 + 
      192*Q2^4*(omega - s)^3*s^5*w^2 + 2400*Q2^3*(omega - s)^4*s^5*w^2 + 
      4576*Q2^2*(omega - s)^5*s^5*w^2 - 4096*Q2*(omega - s)^6*s^5*w^2 + 
      752*Q2^3*(omega - s)^3*s^6*w^2 + 2224*Q2^2*(omega - s)^4*s^6*w^2 - 
      2736*Q2*(omega - s)^5*s^6*w^2 + 384*Q2^2*(omega - s)^3*s^7*w^2 - 
      1088*Q2*(omega - s)^4*s^7*w^2 - 16*Q2^2*(omega - s)^2*s^8*w^2 - 
      224*Q2*(omega - s)^3*s^8*w^2 - 16*Q2*(omega - s)^2*s^9*w^2 - 
      16*Q2^3*(omega - s)^9*SUNN^2*w^2 - 64*Q2^2*(omega - s)^10*SUNN^2*w^2 - 
      48*Q2*(omega - s)^11*SUNN^2*w^2 + 192*Q2^4*(omega - s)^7*s*SUNN^2*w^2 + 
      704*Q2^3*(omega - s)^8*s*SUNN^2*w^2 - 16*Q2^2*(omega - s)^9*s*SUNN^2*
       w^2 - 592*Q2*(omega - s)^10*s*SUNN^2*w^2 + 2304*Q2^4*(omega - s)^6*s^2*
       SUNN^2*w^2 + 5136*Q2^3*(omega - s)^7*s^2*SUNN^2*w^2 + 
      688*Q2^2*(omega - s)^8*s^2*SUNN^2*w^2 - 2800*Q2*(omega - s)^9*s^2*
       SUNN^2*w^2 + 4224*Q2^4*(omega - s)^5*s^3*SUNN^2*w^2 + 
      11680*Q2^3*(omega - s)^6*s^3*SUNN^2*w^2 + 1840*Q2^2*(omega - s)^7*s^3*
       SUNN^2*w^2 - 7072*Q2*(omega - s)^8*s^3*SUNN^2*w^2 + 
      2304*Q2^4*(omega - s)^4*s^4*SUNN^2*w^2 + 11536*Q2^3*(omega - s)^5*s^4*
       SUNN^2*w^2 + 2416*Q2^2*(omega - s)^6*s^4*SUNN^2*w^2 - 
      10736*Q2*(omega - s)^7*s^4*SUNN^2*w^2 + 192*Q2^4*(omega - s)^3*s^5*
       SUNN^2*w^2 + 4992*Q2^3*(omega - s)^4*s^5*SUNN^2*w^2 + 
      2000*Q2^2*(omega - s)^5*s^5*SUNN^2*w^2 - 10208*Q2*(omega - s)^6*s^5*
       SUNN^2*w^2 + 752*Q2^3*(omega - s)^3*s^6*SUNN^2*w^2 + 
      1040*Q2^2*(omega - s)^4*s^6*SUNN^2*w^2 - 6032*Q2*(omega - s)^5*s^6*
       SUNN^2*w^2 + 32*Q2^3*(omega - s)^2*s^7*SUNN^2*w^2 + 
      272*Q2^2*(omega - s)^3*s^7*SUNN^2*w^2 - 2080*Q2*(omega - s)^4*s^7*
       SUNN^2*w^2 + 16*Q2^2*(omega - s)^2*s^8*SUNN^2*w^2 - 
      352*Q2*(omega - s)^3*s^8*SUNN^2*w^2 - 16*Q2*(omega - s)^2*s^9*SUNN^2*
       w^2 - 192*Q2^4*(omega - s)^7*w^3 - 384*Q2^3*(omega - s)^8*w^3 - 
      128*Q2^2*(omega - s)^9*w^3 + 64*Q2*(omega - s)^10*w^3 + 
      768*Q2^5*(omega - s)^5*s*w^3 - 2672*Q2^3*(omega - s)^7*s*w^3 - 
      1264*Q2^2*(omega - s)^8*s*w^3 + 560*Q2*(omega - s)^9*s*w^3 + 
      512*Q2^5*(omega - s)^4*s^2*w^3 + 2432*Q2^4*(omega - s)^5*s^2*w^3 - 
      3936*Q2^3*(omega - s)^6*s^2*w^3 - 5056*Q2^2*(omega - s)^7*s^2*w^3 + 
      2112*Q2*(omega - s)^8*s^2*w^3 + 768*Q2^5*(omega - s)^3*s^3*w^3 + 
      5120*Q2^4*(omega - s)^4*s^3*w^3 - 528*Q2^3*(omega - s)^5*s^3*w^3 - 
      10192*Q2^2*(omega - s)^6*s^3*w^3 + 4512*Q2*(omega - s)^7*s^3*w^3 + 
      2880*Q2^4*(omega - s)^3*s^4*w^3 + 1856*Q2^3*(omega - s)^4*s^4*w^3 - 
      10976*Q2^2*(omega - s)^5*s^4*w^3 + 6016*Q2*(omega - s)^6*s^4*w^3 + 
      624*Q2^3*(omega - s)^3*s^5*w^3 - 6032*Q2^2*(omega - s)^4*s^5*w^3 + 
      5184*Q2*(omega - s)^5*s^5*w^3 - 96*Q2^3*(omega - s)^2*s^6*w^3 - 
      1280*Q2^2*(omega - s)^3*s^6*w^3 + 2880*Q2*(omega - s)^4*s^6*w^3 + 
      16*Q2^3*(omega - s)*s^7*w^3 + 80*Q2^2*(omega - s)^2*s^7*w^3 + 
      992*Q2*(omega - s)^3*s^7*w^3 + 32*Q2^2*(omega - s)*s^8*w^3 + 
      192*Q2*(omega - s)^2*s^8*w^3 + 16*Q2*(omega - s)*s^9*w^3 - 
      192*Q2^4*(omega - s)^7*SUNN^2*w^3 - 800*Q2^3*(omega - s)^8*SUNN^2*w^3 - 
      448*Q2^2*(omega - s)^9*SUNN^2*w^3 + 192*Q2*(omega - s)^10*SUNN^2*w^3 + 
      768*Q2^5*(omega - s)^5*s*SUNN^2*w^3 + 2688*Q2^4*(omega - s)^6*s*SUNN^2*
       w^3 - 3408*Q2^3*(omega - s)^7*s*SUNN^2*w^3 - 5040*Q2^2*(omega - s)^8*s*
       SUNN^2*w^3 + 1664*Q2*(omega - s)^9*s*SUNN^2*w^3 + 
      3584*Q2^5*(omega - s)^4*s^2*SUNN^2*w^3 + 10880*Q2^4*(omega - s)^5*s^2*
       SUNN^2*w^3 - 7680*Q2^3*(omega - s)^6*s^2*SUNN^2*w^3 - 
      18240*Q2^2*(omega - s)^7*s^2*SUNN^2*w^3 + 6176*Q2*(omega - s)^8*s^2*
       SUNN^2*w^3 + 768*Q2^5*(omega - s)^3*s^3*SUNN^2*w^3 + 
      11264*Q2^4*(omega - s)^4*s^3*SUNN^2*w^3 - 8752*Q2^3*(omega - s)^5*s^3*
       SUNN^2*w^3 - 31376*Q2^2*(omega - s)^6*s^3*SUNN^2*w^3 + 
      12912*Q2*(omega - s)^7*s^3*SUNN^2*w^3 + 3648*Q2^4*(omega - s)^3*s^4*
       SUNN^2*w^3 - 3744*Q2^3*(omega - s)^4*s^4*SUNN^2*w^3 - 
      28128*Q2^2*(omega - s)^5*s^4*SUNN^2*w^3 + 16768*Q2*(omega - s)^6*s^4*
       SUNN^2*w^3 + 384*Q2^4*(omega - s)^2*s^5*SUNN^2*w^3 + 
      336*Q2^3*(omega - s)^3*s^5*SUNN^2*w^3 - 12240*Q2^2*(omega - s)^4*s^5*
       SUNN^2*w^3 + 14032*Q2*(omega - s)^5*s^5*SUNN^2*w^3 + 
      448*Q2^3*(omega - s)^2*s^6*SUNN^2*w^3 - 1408*Q2^2*(omega - s)^3*s^6*
       SUNN^2*w^3 + 7584*Q2*(omega - s)^4*s^6*SUNN^2*w^3 + 
      48*Q2^3*(omega - s)*s^7*SUNN^2*w^3 + 528*Q2^2*(omega - s)^2*s^7*SUNN^2*
       w^3 + 2576*Q2*(omega - s)^3*s^7*SUNN^2*w^3 + 96*Q2^2*(omega - s)*s^8*
       SUNN^2*w^3 + 512*Q2*(omega - s)^2*s^8*SUNN^2*w^3 + 
      48*Q2*(omega - s)*s^9*SUNN^2*w^3 - 768*Q2^5*(omega - s)^5*w^4 - 
      1536*Q2^4*(omega - s)^6*w^4 - 16*Q2^3*(omega - s)^7*w^4 + 
      704*Q2^2*(omega - s)^8*w^4 - 96*Q2*(omega - s)^9*w^4 + 
      1024*Q2^6*(omega - s)^3*s*w^4 - 512*Q2^5*(omega - s)^4*s*w^4 - 
      7488*Q2^4*(omega - s)^5*s*w^4 - 1440*Q2^3*(omega - s)^6*s*w^4 + 
      4736*Q2^2*(omega - s)^7*s*w^4 - 720*Q2*(omega - s)^8*s*w^4 + 
      3328*Q2^5*(omega - s)^3*s^2*w^4 - 6656*Q2^4*(omega - s)^4*s^2*w^4 - 
      6000*Q2^3*(omega - s)^5*s^2*w^4 + 12864*Q2^2*(omega - s)^6*s^2*w^4 - 
      2352*Q2*(omega - s)^7*s^2*w^4 - 1920*Q2^4*(omega - s)^3*s^3*w^4 - 
      6848*Q2^3*(omega - s)^4*s^3*w^4 + 18304*Q2^2*(omega - s)^5*s^3*w^4 - 
      4368*Q2*(omega - s)^6*s^3*w^4 - 1008*Q2^3*(omega - s)^3*s^4*w^4 + 
      14656*Q2^2*(omega - s)^4*s^4*w^4 - 5040*Q2*(omega - s)^5*s^4*w^4 + 
      192*Q2^4*(omega - s)*s^5*w^4 + 1632*Q2^3*(omega - s)^2*s^5*w^4 + 
      6528*Q2^2*(omega - s)^3*s^5*w^4 - 3696*Q2*(omega - s)^4*s^5*w^4 + 
      368*Q2^3*(omega - s)*s^6*w^4 + 1472*Q2^2*(omega - s)^2*s^6*w^4 - 
      1680*Q2*(omega - s)^3*s^6*w^4 + 128*Q2^2*(omega - s)*s^7*w^4 - 
      432*Q2*(omega - s)^2*s^7*w^4 - 48*Q2*(omega - s)*s^8*w^4 - 
      768*Q2^5*(omega - s)^5*SUNN^2*w^4 - 3456*Q2^4*(omega - s)^6*SUNN^2*
       w^4 - 816*Q2^3*(omega - s)^7*SUNN^2*w^4 + 2144*Q2^2*(omega - s)^8*
       SUNN^2*w^4 - 288*Q2*(omega - s)^9*SUNN^2*w^4 + 
      1024*Q2^6*(omega - s)^3*s*SUNN^2*w^4 + 4096*Q2^5*(omega - s)^4*s*SUNN^2*
       w^4 - 14016*Q2^4*(omega - s)^5*s*SUNN^2*w^4 - 11616*Q2^3*(omega - s)^6*
       s*SUNN^2*w^4 + 14208*Q2^2*(omega - s)^7*s*SUNN^2*w^4 - 
      2128*Q2*(omega - s)^8*s*SUNN^2*w^4 + 5376*Q2^5*(omega - s)^3*s^2*SUNN^2*
       w^4 - 19200*Q2^4*(omega - s)^4*s^2*SUNN^2*w^4 - 
      27216*Q2^3*(omega - s)^5*s^2*SUNN^2*w^4 + 37536*Q2^2*(omega - s)^6*s^2*
       SUNN^2*w^4 - 6864*Q2*(omega - s)^7*s^2*SUNN^2*w^4 + 
      1536*Q2^5*(omega - s)^2*s^3*SUNN^2*w^4 - 4480*Q2^4*(omega - s)^3*s^3*
       SUNN^2*w^4 - 19776*Q2^3*(omega - s)^4*s^3*SUNN^2*w^4 + 
      51328*Q2^2*(omega - s)^5*s^3*SUNN^2*w^4 - 12624*Q2*(omega - s)^6*s^3*
       SUNN^2*w^4 + 2688*Q2^4*(omega - s)^2*s^4*SUNN^2*w^4 + 
      816*Q2^3*(omega - s)^3*s^4*SUNN^2*w^4 + 39072*Q2^2*(omega - s)^4*s^4*
       SUNN^2*w^4 - 14480*Q2*(omega - s)^5*s^4*SUNN^2*w^4 + 
      576*Q2^4*(omega - s)*s^5*SUNN^2*w^4 + 5280*Q2^3*(omega - s)^2*s^5*
       SUNN^2*w^4 + 16512*Q2^2*(omega - s)^3*s^5*SUNN^2*w^4 - 
      10608*Q2*(omega - s)^4*s^5*SUNN^2*w^4 + 1104*Q2^3*(omega - s)*s^6*
       SUNN^2*w^4 + 3680*Q2^2*(omega - s)^2*s^6*SUNN^2*w^4 - 
      4848*Q2*(omega - s)^3*s^6*SUNN^2*w^4 + 384*Q2^2*(omega - s)*s^7*SUNN^2*
       w^4 - 1264*Q2*(omega - s)^2*s^7*SUNN^2*w^4 - 144*Q2*(omega - s)*s^8*
       SUNN^2*w^4 - 1024*Q2^6*(omega - s)^3*w^5 - 2048*Q2^5*(omega - s)^4*
       w^5 + 1856*Q2^4*(omega - s)^5*w^5 + 2304*Q2^3*(omega - s)^6*w^5 - 
      1120*Q2^2*(omega - s)^7*w^5 + 64*Q2*(omega - s)^8*w^5 - 
      5376*Q2^5*(omega - s)^3*s*w^5 + 4096*Q2^4*(omega - s)^4*s*w^5 + 
      10752*Q2^3*(omega - s)^5*s*w^5 - 6144*Q2^2*(omega - s)^6*s*w^5 + 
      432*Q2*(omega - s)^7*s*w^5 + 512*Q2^5*(omega - s)^2*s^2*w^5 + 
      2944*Q2^4*(omega - s)^3*s^2*w^5 + 16896*Q2^3*(omega - s)^4*s^2*w^5 - 
      13920*Q2^2*(omega - s)^5*s^2*w^5 + 1248*Q2*(omega - s)^6*s^2*w^5 + 
      768*Q2^5*(omega - s)*s^3*w^5 + 5120*Q2^4*(omega - s)^2*s^3*w^5 + 
      10752*Q2^3*(omega - s)^3*s^3*w^5 - 16640*Q2^2*(omega - s)^4*s^3*w^5 + 
      2000*Q2*(omega - s)^5*s^3*w^5 + 1344*Q2^4*(omega - s)*s^4*w^5 + 
      2304*Q2^3*(omega - s)^2*s^4*w^5 - 11040*Q2^2*(omega - s)^3*s^4*w^5 + 
      1920*Q2*(omega - s)^4*s^4*w^5 - 3840*Q2^2*(omega - s)^2*s^5*w^5 + 
      1104*Q2*(omega - s)^3*s^5*w^5 - 544*Q2^2*(omega - s)*s^6*w^5 + 
      352*Q2*(omega - s)^2*s^6*w^5 + 48*Q2*(omega - s)*s^7*w^5 - 
      1024*Q2^6*(omega - s)^3*SUNN^2*w^5 - 5632*Q2^5*(omega - s)^4*SUNN^2*
       w^5 + 2496*Q2^4*(omega - s)^5*SUNN^2*w^5 + 7296*Q2^3*(omega - s)^6*
       SUNN^2*w^5 - 3360*Q2^2*(omega - s)^7*SUNN^2*w^5 + 
      192*Q2*(omega - s)^8*SUNN^2*w^5 + 2048*Q2^6*(omega - s)^2*s*SUNN^2*
       w^5 - 14080*Q2^5*(omega - s)^3*s*SUNN^2*w^5 - 
      2560*Q2^4*(omega - s)^4*s*SUNN^2*w^5 + 33024*Q2^3*(omega - s)^5*s*
       SUNN^2*w^5 - 18048*Q2^2*(omega - s)^6*s*SUNN^2*w^5 + 
      1296*Q2*(omega - s)^7*s*SUNN^2*w^5 + 4096*Q2^5*(omega - s)^2*s^2*SUNN^2*
       w^5 + 4736*Q2^4*(omega - s)^3*s^2*SUNN^2*w^5 + 
      48384*Q2^3*(omega - s)^4*s^2*SUNN^2*w^5 - 40224*Q2^2*(omega - s)^5*s^2*
       SUNN^2*w^5 + 3744*Q2*(omega - s)^6*s^2*SUNN^2*w^5 + 
      2304*Q2^5*(omega - s)*s^3*SUNN^2*w^5 + 12800*Q2^4*(omega - s)^2*s^3*
       SUNN^2*w^5 + 26880*Q2^3*(omega - s)^3*s^3*SUNN^2*w^5 - 
      47616*Q2^2*(omega - s)^4*s^3*SUNN^2*w^5 + 6000*Q2*(omega - s)^5*s^3*
       SUNN^2*w^5 + 4032*Q2^4*(omega - s)*s^4*SUNN^2*w^5 + 
      4224*Q2^3*(omega - s)^2*s^4*SUNN^2*w^5 - 31584*Q2^2*(omega - s)^3*s^4*
       SUNN^2*w^5 + 5760*Q2*(omega - s)^4*s^4*SUNN^2*w^5 - 
      11136*Q2^2*(omega - s)^2*s^5*SUNN^2*w^5 + 3312*Q2*(omega - s)^3*s^5*
       SUNN^2*w^5 - 1632*Q2^2*(omega - s)*s^6*SUNN^2*w^5 + 
      1056*Q2*(omega - s)^2*s^6*SUNN^2*w^5 + 144*Q2*(omega - s)*s^7*SUNN^2*
       w^5 + 3328*Q2^5*(omega - s)^3*w^6 + 1024*Q2^4*(omega - s)^4*w^6 - 
      4224*Q2^3*(omega - s)^5*w^6 + 768*Q2^2*(omega - s)^6*w^6 - 
      16*Q2*(omega - s)^7*w^6 + 1024*Q2^6*(omega - s)*s*w^6 + 
      3584*Q2^5*(omega - s)^2*s*w^6 + 2048*Q2^4*(omega - s)^3*s*w^6 - 
      14592*Q2^3*(omega - s)^4*s*w^6 + 3648*Q2^2*(omega - s)^5*s*w^6 - 
      96*Q2*(omega - s)^6*s*w^6 + 1280*Q2^5*(omega - s)*s^2*w^6 - 
      3072*Q2^4*(omega - s)^2*s^2*w^6 - 18432*Q2^3*(omega - s)^3*s^2*w^6 + 
      6912*Q2^2*(omega - s)^4*s^2*w^6 - 240*Q2*(omega - s)^5*s^2*w^6 - 
      2048*Q2^4*(omega - s)*s^3*w^6 - 9984*Q2^3*(omega - s)^2*s^3*w^6 + 
      6528*Q2^2*(omega - s)^3*s^3*w^6 - 320*Q2*(omega - s)^4*s^3*w^6 - 
      1920*Q2^3*(omega - s)*s^4*w^6 + 3072*Q2^2*(omega - s)^2*s^4*w^6 - 
      240*Q2*(omega - s)^3*s^4*w^6 + 576*Q2^2*(omega - s)*s^5*w^6 - 
      96*Q2*(omega - s)^2*s^5*w^6 - 16*Q2*(omega - s)*s^6*w^6 - 
      2048*Q2^6*(omega - s)^2*SUNN^2*w^6 + 5888*Q2^5*(omega - s)^3*SUNN^2*
       w^6 + 4608*Q2^4*(omega - s)^4*SUNN^2*w^6 - 12672*Q2^3*(omega - s)^5*
       SUNN^2*w^6 + 2304*Q2^2*(omega - s)^6*SUNN^2*w^6 - 
      48*Q2*(omega - s)^7*SUNN^2*w^6 + 3072*Q2^6*(omega - s)*s*SUNN^2*w^6 + 
      4608*Q2^5*(omega - s)^2*s*SUNN^2*w^6 + 8192*Q2^4*(omega - s)^3*s*SUNN^2*
       w^6 - 42240*Q2^3*(omega - s)^4*s*SUNN^2*w^6 + 10944*Q2^2*(omega - s)^5*
       s*SUNN^2*w^6 - 288*Q2*(omega - s)^6*s*SUNN^2*w^6 + 
      3840*Q2^5*(omega - s)*s^2*SUNN^2*w^6 - 11776*Q2^4*(omega - s)^2*s^2*
       SUNN^2*w^6 - 52224*Q2^3*(omega - s)^3*s^2*SUNN^2*w^6 + 
      20736*Q2^2*(omega - s)^4*s^2*SUNN^2*w^6 - 720*Q2*(omega - s)^5*s^2*
       SUNN^2*w^6 - 6144*Q2^4*(omega - s)*s^3*SUNN^2*w^6 - 
      28416*Q2^3*(omega - s)^2*s^3*SUNN^2*w^6 + 19584*Q2^2*(omega - s)^3*s^3*
       SUNN^2*w^6 - 960*Q2*(omega - s)^4*s^3*SUNN^2*w^6 - 
      5760*Q2^3*(omega - s)*s^4*SUNN^2*w^6 + 9216*Q2^2*(omega - s)^2*s^4*
       SUNN^2*w^6 - 720*Q2*(omega - s)^3*s^4*SUNN^2*w^6 + 
      1728*Q2^2*(omega - s)*s^5*SUNN^2*w^6 - 288*Q2*(omega - s)^2*s^5*SUNN^2*
       w^6 - 48*Q2*(omega - s)*s^6*SUNN^2*w^6 - 1024*Q2^6*(omega - s)*w^7 - 
      4096*Q2^5*(omega - s)^2*w^7 - 4608*Q2^4*(omega - s)^3*w^7 + 
      3072*Q2^3*(omega - s)^4*w^7 - 192*Q2^2*(omega - s)^5*w^7 - 
      4096*Q2^5*(omega - s)*s*w^7 - 6144*Q2^4*(omega - s)^2*s*w^7 + 
      8448*Q2^3*(omega - s)^3*s*w^7 - 768*Q2^2*(omega - s)^4*s*w^7 - 
      1536*Q2^4*(omega - s)*s^2*w^7 + 7680*Q2^3*(omega - s)^2*s^2*w^7 - 
      1152*Q2^2*(omega - s)^3*s^2*w^7 + 2304*Q2^3*(omega - s)*s^3*w^7 - 
      768*Q2^2*(omega - s)^2*s^3*w^7 - 192*Q2^2*(omega - s)*s^4*w^7 - 
      3072*Q2^6*(omega - s)*SUNN^2*w^7 - 10240*Q2^5*(omega - s)^2*SUNN^2*
       w^7 - 13824*Q2^4*(omega - s)^3*SUNN^2*w^7 + 9216*Q2^3*(omega - s)^4*
       SUNN^2*w^7 - 576*Q2^2*(omega - s)^5*SUNN^2*w^7 - 
      12288*Q2^5*(omega - s)*s*SUNN^2*w^7 - 16384*Q2^4*(omega - s)^2*s*SUNN^2*
       w^7 + 25344*Q2^3*(omega - s)^3*s*SUNN^2*w^7 - 
      2304*Q2^2*(omega - s)^4*s*SUNN^2*w^7 - 4608*Q2^4*(omega - s)*s^2*SUNN^2*
       w^7 + 23040*Q2^3*(omega - s)^2*s^2*SUNN^2*w^7 - 
      3456*Q2^2*(omega - s)^3*s^2*SUNN^2*w^7 + 6912*Q2^3*(omega - s)*s^3*
       SUNN^2*w^7 - 2304*Q2^2*(omega - s)^2*s^3*SUNN^2*w^7 - 
      576*Q2^2*(omega - s)*s^4*SUNN^2*w^7 + 2048*Q2^5*(omega - s)*w^8 + 
      4096*Q2^4*(omega - s)^2*w^8 - 768*Q2^3*(omega - s)^3*w^8 + 
      3072*Q2^4*(omega - s)*s*w^8 - 1536*Q2^3*(omega - s)^2*s*w^8 - 
      768*Q2^3*(omega - s)*s^2*w^8 + 6144*Q2^5*(omega - s)*SUNN^2*w^8 + 
      12288*Q2^4*(omega - s)^2*SUNN^2*w^8 - 2304*Q2^3*(omega - s)^3*SUNN^2*
       w^8 + 9216*Q2^4*(omega - s)*s*SUNN^2*w^8 - 4608*Q2^3*(omega - s)^2*s*
       SUNN^2*w^8 - 2304*Q2^3*(omega - s)*s^2*SUNN^2*w^8 - 
      1024*Q2^4*(omega - s)*w^9 - 3072*Q2^4*(omega - s)*SUNN^2*w^9))/
    (32*eps*Q2*(omega - s)^3*SUNN*(omega + Q2 - w)*(omega - s - w)*(s - w)*w*
     ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)^3) - 
   (Pi*(-16*Q2^3*(omega - s)^9*s^2 - 48*Q2^2*(omega - s)^10*s^2 - 
      64*Q2*(omega - s)^11*s^2 - 96*Q2^3*(omega - s)^8*s^3 - 
      320*Q2^2*(omega - s)^9*s^3 - 432*Q2*(omega - s)^10*s^3 - 
      240*Q2^3*(omega - s)^7*s^4 - 912*Q2^2*(omega - s)^8*s^4 - 
      1264*Q2*(omega - s)^9*s^4 - 320*Q2^3*(omega - s)^6*s^5 - 
      1440*Q2^2*(omega - s)^7*s^5 - 2096*Q2*(omega - s)^8*s^5 - 
      240*Q2^3*(omega - s)^5*s^6 - 1360*Q2^2*(omega - s)^6*s^6 - 
      2160*Q2*(omega - s)^7*s^6 - 96*Q2^3*(omega - s)^4*s^7 - 
      768*Q2^2*(omega - s)^5*s^7 - 1424*Q2*(omega - s)^6*s^7 - 
      16*Q2^3*(omega - s)^3*s^8 - 240*Q2^2*(omega - s)^4*s^8 - 
      592*Q2*(omega - s)^5*s^8 - 32*Q2^2*(omega - s)^3*s^9 - 
      144*Q2*(omega - s)^4*s^9 - 16*Q2*(omega - s)^3*s^10 - 
      16*Q2^2*(omega - s)^10*s^2*SUNN^2 - 16*Q2*(omega - s)^11*s^2*SUNN^2 - 
      96*Q2^2*(omega - s)^9*s^3*SUNN^2 - 112*Q2*(omega - s)^10*s^3*SUNN^2 - 
      240*Q2^2*(omega - s)^8*s^4*SUNN^2 - 336*Q2*(omega - s)^9*s^4*SUNN^2 - 
      320*Q2^2*(omega - s)^7*s^5*SUNN^2 - 560*Q2*(omega - s)^8*s^5*SUNN^2 - 
      240*Q2^2*(omega - s)^6*s^6*SUNN^2 - 560*Q2*(omega - s)^7*s^6*SUNN^2 - 
      96*Q2^2*(omega - s)^5*s^7*SUNN^2 - 336*Q2*(omega - s)^6*s^7*SUNN^2 - 
      16*Q2^2*(omega - s)^4*s^8*SUNN^2 - 112*Q2*(omega - s)^5*s^8*SUNN^2 - 
      16*Q2*(omega - s)^4*s^9*SUNN^2 - 72*Q2^3*(omega - s)^9*s*w - 
      64*Q2^2*(omega - s)^10*s*w + 48*Q2*(omega - s)^11*s*w - 
      192*Q2^4*(omega - s)^7*s^2*w - 1056*Q2^3*(omega - s)^8*s^2*w - 
      1312*Q2^2*(omega - s)^9*s^2*w + 320*Q2*(omega - s)^10*s^2*w - 
      768*Q2^4*(omega - s)^6*s^3*w - 3832*Q2^3*(omega - s)^7*s^3*w - 
      5296*Q2^2*(omega - s)^8*s^3*w + 960*Q2*(omega - s)^9*s^3*w - 
      1152*Q2^4*(omega - s)^5*s^4*w - 6288*Q2^3*(omega - s)^6*s^4*w - 
      9600*Q2^2*(omega - s)^7*s^4*w + 1648*Q2*(omega - s)^8*s^4*w - 
      768*Q2^4*(omega - s)^4*s^5*w - 5336*Q2^3*(omega - s)^5*s^5*w - 
      9360*Q2^2*(omega - s)^6*s^5*w + 1736*Q2*(omega - s)^7*s^5*w - 
      192*Q2^4*(omega - s)^3*s^6*w - 2272*Q2^3*(omega - s)^4*s^6*w - 
      5072*Q2^2*(omega - s)^5*s^6*w + 1168*Q2*(omega - s)^6*s^6*w - 
      360*Q2^3*(omega - s)^3*s^7*w - 1376*Q2^2*(omega - s)^4*s^7*w + 
      560*Q2*(omega - s)^5*s^7*w + 16*Q2^3*(omega - s)^2*s^8*w - 
      80*Q2^2*(omega - s)^3*s^8*w + 240*Q2*(omega - s)^4*s^8*w + 
      32*Q2^2*(omega - s)^2*s^9*w + 88*Q2*(omega - s)^3*s^9*w + 
      16*Q2*(omega - s)^2*s^10*w - 136*Q2^3*(omega - s)^9*s*SUNN^2*w - 
      624*Q2^2*(omega - s)^10*s*SUNN^2*w - 480*Q2*(omega - s)^11*s*SUNN^2*w - 
      1008*Q2^3*(omega - s)^8*s^2*SUNN^2*w - 4288*Q2^2*(omega - s)^9*s^2*
       SUNN^2*w - 3568*Q2*(omega - s)^10*s^2*SUNN^2*w - 
      2904*Q2^3*(omega - s)^7*s^3*SUNN^2*w - 12480*Q2^2*(omega - s)^8*s^3*
       SUNN^2*w - 11488*Q2*(omega - s)^9*s^3*SUNN^2*w - 
      4160*Q2^3*(omega - s)^6*s^4*SUNN^2*w - 19776*Q2^2*(omega - s)^7*s^4*
       SUNN^2*w - 20848*Q2*(omega - s)^8*s^4*SUNN^2*w - 
      3096*Q2^3*(omega - s)^5*s^5*SUNN^2*w - 18272*Q2^2*(omega - s)^6*s^5*
       SUNN^2*w - 23240*Q2*(omega - s)^7*s^5*SUNN^2*w - 
      1104*Q2^3*(omega - s)^4*s^6*SUNN^2*w - 9744*Q2^2*(omega - s)^5*s^6*
       SUNN^2*w - 16240*Q2*(omega - s)^6*s^6*SUNN^2*w - 
      136*Q2^3*(omega - s)^3*s^7*SUNN^2*w - 2736*Q2^2*(omega - s)^4*s^7*
       SUNN^2*w - 6928*Q2*(omega - s)^5*s^7*SUNN^2*w - 
      304*Q2^2*(omega - s)^3*s^8*SUNN^2*w - 1648*Q2*(omega - s)^4*s^8*SUNN^2*
       w - 168*Q2*(omega - s)^3*s^9*SUNN^2*w + 56*Q2^3*(omega - s)^9*w^2 + 
      112*Q2^2*(omega - s)^10*w^2 + 48*Q2*(omega - s)^11*w^2 - 
      928*Q2^4*(omega - s)^7*s*w^2 - 448*Q2^3*(omega - s)^8*s*w^2 + 
      1584*Q2^2*(omega - s)^9*s*w^2 + 464*Q2*(omega - s)^10*s*w^2 - 
      768*Q2^5*(omega - s)^5*s^2*w^2 - 6048*Q2^4*(omega - s)^6*s^2*w^2 - 
      6216*Q2^3*(omega - s)^7*s^2*w^2 + 7056*Q2^2*(omega - s)^8*s^2*w^2 + 
      2112*Q2*(omega - s)^9*s^2*w^2 + 16*(omega - s)^10*s^2*w^2 - 
      1536*Q2^5*(omega - s)^4*s^3*w^2 - 10912*Q2^4*(omega - s)^5*s^3*w^2 - 
      15280*Q2^3*(omega - s)^6*s^3*w^2 + 13856*Q2^2*(omega - s)^7*s^3*w^2 + 
      5168*Q2*(omega - s)^8*s^3*w^2 + 96*(omega - s)^9*s^3*w^2 - 
      768*Q2^5*(omega - s)^3*s^4*w^2 - 7584*Q2^4*(omega - s)^4*s^4*w^2 - 
      14328*Q2^3*(omega - s)^5*s^4*w^2 + 14864*Q2^2*(omega - s)^6*s^4*w^2 + 
      7928*Q2*(omega - s)^7*s^4*w^2 + 256*(omega - s)^8*s^4*w^2 - 
      1600*Q2^4*(omega - s)^3*s^5*w^2 - 4960*Q2^3*(omega - s)^4*s^5*w^2 + 
      10192*Q2^2*(omega - s)^5*s^5*w^2 + 8352*Q2*(omega - s)^6*s^5*w^2 + 
      384*(omega - s)^7*s^5*w^2 + 192*Q2^4*(omega - s)^2*s^6*w^2 + 
      232*Q2^3*(omega - s)^3*s^6*w^2 + 4928*Q2^2*(omega - s)^4*s^6*w^2 + 
      5920*Q2*(omega - s)^5*s^6*w^2 + 336*(omega - s)^6*s^6*w^2 + 
      432*Q2^3*(omega - s)^2*s^7*w^2 + 1600*Q2^2*(omega - s)^3*s^7*w^2 + 
      2496*Q2*(omega - s)^4*s^7*w^2 + 160*(omega - s)^5*s^7*w^2 + 
      272*Q2^2*(omega - s)^2*s^8*w^2 + 504*Q2*(omega - s)^3*s^8*w^2 + 
      32*(omega - s)^4*s^8*w^2 + 32*Q2*(omega - s)^2*s^9*w^2 + 
      136*Q2^3*(omega - s)^9*SUNN^2*w^2 + 544*Q2^2*(omega - s)^10*SUNN^2*
       w^2 + 400*Q2*(omega - s)^11*SUNN^2*w^2 - 1632*Q2^4*(omega - s)^7*s*
       SUNN^2*w^2 - 6256*Q2^3*(omega - s)^8*s*SUNN^2*w^2 - 
      288*Q2^2*(omega - s)^9*s*SUNN^2*w^2 + 4800*Q2*(omega - s)^10*s*SUNN^2*
       w^2 - 7584*Q2^4*(omega - s)^6*s^2*SUNN^2*w^2 - 
      30648*Q2^3*(omega - s)^7*s^2*SUNN^2*w^2 - 9504*Q2^2*(omega - s)^8*s^2*
       SUNN^2*w^2 + 22016*Q2*(omega - s)^9*s^2*SUNN^2*w^2 - 
      16*(omega - s)^10*s^2*SUNN^2*w^2 - 12384*Q2^4*(omega - s)^5*s^3*SUNN^2*
       w^2 - 55104*Q2^3*(omega - s)^6*s^3*SUNN^2*w^2 - 
      22384*Q2^2*(omega - s)^7*s^3*SUNN^2*w^2 + 53744*Q2*(omega - s)^8*s^3*
       SUNN^2*w^2 - 128*(omega - s)^9*s^3*SUNN^2*w^2 - 
      8160*Q2^4*(omega - s)^4*s^4*SUNN^2*w^2 - 46408*Q2^3*(omega - s)^5*s^4*
       SUNN^2*w^2 - 20448*Q2^2*(omega - s)^6*s^4*SUNN^2*w^2 + 
      78216*Q2*(omega - s)^7*s^4*SUNN^2*w^2 - 480*(omega - s)^8*s^4*SUNN^2*
       w^2 - 1728*Q2^4*(omega - s)^3*s^5*SUNN^2*w^2 - 
      17328*Q2^3*(omega - s)^4*s^5*SUNN^2*w^2 - 5088*Q2^2*(omega - s)^5*s^5*
       SUNN^2*w^2 + 70656*Q2*(omega - s)^6*s^5*SUNN^2*w^2 - 
      1088*(omega - s)^7*s^5*SUNN^2*w^2 - 1384*Q2^3*(omega - s)^3*s^6*SUNN^2*
       w^2 + 4176*Q2^2*(omega - s)^4*s^6*SUNN^2*w^2 + 
      39584*Q2*(omega - s)^5*s^6*SUNN^2*w^2 - 1616*(omega - s)^6*s^6*SUNN^2*
       w^2 + 384*Q2^3*(omega - s)^2*s^7*SUNN^2*w^2 + 
      3088*Q2^2*(omega - s)^3*s^7*SUNN^2*w^2 + 13152*Q2*(omega - s)^4*s^7*
       SUNN^2*w^2 - 1600*(omega - s)^5*s^7*SUNN^2*w^2 + 
      560*Q2^2*(omega - s)^2*s^8*SUNN^2*w^2 + 2248*Q2*(omega - s)^3*s^8*
       SUNN^2*w^2 - 1024*(omega - s)^4*s^8*SUNN^2*w^2 + 
      112*Q2*(omega - s)^2*s^9*SUNN^2*w^2 - 384*(omega - s)^3*s^9*SUNN^2*
       w^2 - 64*(omega - s)^2*s^10*SUNN^2*w^2 + 736*Q2^4*(omega - s)^7*w^3 + 
      1440*Q2^3*(omega - s)^8*w^3 + 432*Q2^2*(omega - s)^9*w^3 - 
      192*Q2*(omega - s)^10*w^3 - 3776*Q2^5*(omega - s)^5*s*w^3 + 
      288*Q2^4*(omega - s)^6*s*w^3 + 11864*Q2^3*(omega - s)^7*s*w^3 + 
      2688*Q2^2*(omega - s)^8*s*w^3 - 1792*Q2*(omega - s)^9*s*w^3 - 
      16*(omega - s)^10*s*w^3 - 1024*Q2^6*(omega - s)^3*s^2*w^3 - 
      9728*Q2^5*(omega - s)^4*s^2*w^3 - 7808*Q2^4*(omega - s)^5*s^2*w^3 + 
      31936*Q2^3*(omega - s)^6*s^2*w^3 + 8512*Q2^2*(omega - s)^7*s^2*w^3 - 
      6640*Q2*(omega - s)^8*s^2*w^3 - 128*(omega - s)^9*s^2*w^3 - 
      3904*Q2^5*(omega - s)^3*s^3*w^3 - 7008*Q2^4*(omega - s)^4*s^3*w^3 + 
      39512*Q2^3*(omega - s)^5*s^3*w^3 + 18128*Q2^2*(omega - s)^6*s^3*w^3 - 
      13208*Q2*(omega - s)^7*s^3*w^3 - 432*(omega - s)^8*s^3*w^3 + 
      768*Q2^5*(omega - s)^2*s^4*w^3 + 1472*Q2^4*(omega - s)^3*s^4*w^3 + 
      24576*Q2^3*(omega - s)^4*s^4*w^3 + 19328*Q2^2*(omega - s)^5*s^4*w^3 - 
      17776*Q2*(omega - s)^6*s^4*w^3 - 816*(omega - s)^7*s^4*w^3 + 
      2080*Q2^4*(omega - s)^2*s^5*w^3 + 8248*Q2^3*(omega - s)^3*s^5*w^3 + 
      8048*Q2^2*(omega - s)^4*s^5*w^3 - 17512*Q2*(omega - s)^5*s^5*w^3 - 
      928*(omega - s)^6*s^5*w^3 + 1152*Q2^3*(omega - s)^2*s^6*w^3 - 
      256*Q2^2*(omega - s)^3*s^6*w^3 - 11440*Q2*(omega - s)^4*s^6*w^3 - 
      624*(omega - s)^5*s^6*w^3 - 72*Q2^3*(omega - s)*s^7*w^3 - 
      992*Q2^2*(omega - s)^2*s^7*w^3 - 4312*Q2*(omega - s)^3*s^7*w^3 - 
      224*(omega - s)^4*s^7*w^3 - 144*Q2^2*(omega - s)*s^8*w^3 - 
      848*Q2*(omega - s)^2*s^8*w^3 - 32*(omega - s)^3*s^8*w^3 - 
      72*Q2*(omega - s)*s^9*w^3 + 1632*Q2^4*(omega - s)^7*SUNN^2*w^3 + 
      6112*Q2^3*(omega - s)^8*SUNN^2*w^3 + 3040*Q2^2*(omega - s)^9*SUNN^2*
       w^3 - 1600*Q2*(omega - s)^10*SUNN^2*w^3 - 6720*Q2^5*(omega - s)^5*s*
       SUNN^2*w^3 - 18464*Q2^4*(omega - s)^6*s*SUNN^2*w^3 + 
      26248*Q2^3*(omega - s)^7*s*SUNN^2*w^3 + 34432*Q2^2*(omega - s)^8*s*
       SUNN^2*w^3 - 13472*Q2*(omega - s)^9*s*SUNN^2*w^3 + 
      16*(omega - s)^10*s*SUNN^2*w^3 - 15616*Q2^5*(omega - s)^4*s^2*SUNN^2*
       w^3 - 47616*Q2^4*(omega - s)^5*s^2*SUNN^2*w^3 + 
      60928*Q2^3*(omega - s)^6*s^2*SUNN^2*w^3 + 118672*Q2^2*(omega - s)^7*s^2*
       SUNN^2*w^3 - 48208*Q2*(omega - s)^8*s^2*SUNN^2*w^3 + 
      160*(omega - s)^9*s^2*SUNN^2*w^3 - 7104*Q2^5*(omega - s)^3*s^3*SUNN^2*
       w^3 - 26912*Q2^4*(omega - s)^4*s^3*SUNN^2*w^3 + 
      88520*Q2^3*(omega - s)^5*s^3*SUNN^2*w^3 + 186320*Q2^2*(omega - s)^6*s^3*
       SUNN^2*w^3 - 96008*Q2*(omega - s)^7*s^3*SUNN^2*w^3 + 
      720*(omega - s)^8*s^3*SUNN^2*w^3 + 4736*Q2^4*(omega - s)^3*s^4*SUNN^2*
       w^3 + 75136*Q2^3*(omega - s)^4*s^4*SUNN^2*w^3 + 
      147824*Q2^2*(omega - s)^5*s^4*SUNN^2*w^3 - 116592*Q2*(omega - s)^6*s^4*
       SUNN^2*w^3 + 1936*(omega - s)^7*s^4*SUNN^2*w^3 + 
      4704*Q2^4*(omega - s)^2*s^5*SUNN^2*w^3 + 30568*Q2^3*(omega - s)^3*s^5*
       SUNN^2*w^3 + 52176*Q2^2*(omega - s)^4*s^5*SUNN^2*w^3 - 
      90584*Q2*(omega - s)^5*s^5*SUNN^2*w^3 + 3424*(omega - s)^6*s^5*SUNN^2*
       w^3 + 3008*Q2^3*(omega - s)^2*s^6*SUNN^2*w^3 - 
      1424*Q2^2*(omega - s)^3*s^6*SUNN^2*w^3 - 46672*Q2*(omega - s)^4*s^6*
       SUNN^2*w^3 + 4112*(omega - s)^5*s^6*SUNN^2*w^3 - 
      600*Q2^3*(omega - s)*s^7*SUNN^2*w^3 - 5632*Q2^2*(omega - s)^2*s^7*
       SUNN^2*w^3 - 15816*Q2*(omega - s)^3*s^7*SUNN^2*w^3 + 
      3328*(omega - s)^4*s^7*SUNN^2*w^3 - 816*Q2^2*(omega - s)*s^8*SUNN^2*
       w^3 - 2960*Q2*(omega - s)^2*s^8*SUNN^2*w^3 + 1728*(omega - s)^3*s^8*
       SUNN^2*w^3 - 152*Q2*(omega - s)*s^9*SUNN^2*w^3 + 
      512*(omega - s)^2*s^9*SUNN^2*w^3 + 64*(omega - s)*s^10*SUNN^2*w^3 + 
      3008*Q2^5*(omega - s)^5*w^4 + 5376*Q2^4*(omega - s)^6*w^4 - 
      328*Q2^3*(omega - s)^7*w^4 - 2384*Q2^2*(omega - s)^8*w^4 + 
      272*Q2*(omega - s)^9*w^4 - 4864*Q2^6*(omega - s)^3*s*w^4 + 
      3712*Q2^5*(omega - s)^4*s*w^4 + 27712*Q2^4*(omega - s)^5*s*w^4 - 
      1696*Q2^3*(omega - s)^6*s*w^4 - 14224*Q2^2*(omega - s)^7*s*w^4 + 
      2240*Q2*(omega - s)^8*s*w^4 + 32*(omega - s)^9*s*w^4 + 
      1024*Q2^6*(omega - s)^2*s^2*w^4 + 2496*Q2^5*(omega - s)^3*s^2*w^4 + 
      42752*Q2^4*(omega - s)^4*s^2*w^4 + 360*Q2^3*(omega - s)^5*s^2*w^4 - 
      38768*Q2^2*(omega - s)^6*s^2*w^4 + 6616*Q2*(omega - s)^7*s^2*w^4 + 
      192*(omega - s)^8*s^2*w^4 + 4288*Q2^5*(omega - s)^2*s^3*w^4 + 
      18528*Q2^4*(omega - s)^3*s^3*w^4 - 5184*Q2^3*(omega - s)^4*s^3*w^4 - 
      61888*Q2^2*(omega - s)^5*s^3*w^4 + 11472*Q2*(omega - s)^6*s^3*w^4 + 
      512*(omega - s)^7*s^3*w^4 + 640*Q2^4*(omega - s)^2*s^4*w^4 - 
      15464*Q2^3*(omega - s)^3*s^4*w^4 - 54480*Q2^2*(omega - s)^4*s^4*w^4 + 
      15368*Q2*(omega - s)^5*s^4*w^4 + 768*(omega - s)^6*s^4*w^4 - 
      864*Q2^4*(omega - s)*s^5*w^4 - 10016*Q2^3*(omega - s)^2*s^5*w^4 - 
      25392*Q2^2*(omega - s)^3*s^5*w^4 + 14400*Q2*(omega - s)^4*s^5*w^4 + 
      672*(omega - s)^5*s^5*w^4 - 1656*Q2^3*(omega - s)*s^6*w^4 - 
      5872*Q2^2*(omega - s)^2*s^6*w^4 + 7672*Q2*(omega - s)^3*s^6*w^4 + 
      320*(omega - s)^4*s^6*w^4 - 576*Q2^2*(omega - s)*s^7*w^4 + 
      2032*Q2*(omega - s)^2*s^7*w^4 + 64*(omega - s)^3*s^7*w^4 + 
      216*Q2*(omega - s)*s^8*w^4 + 6720*Q2^5*(omega - s)^5*SUNN^2*w^4 + 
      21440*Q2^4*(omega - s)^6*SUNN^2*w^4 - 760*Q2^3*(omega - s)^7*SUNN^2*
       w^4 - 16528*Q2^2*(omega - s)^8*SUNN^2*w^4 + 2416*Q2*(omega - s)^9*
       SUNN^2*w^4 - 9472*Q2^6*(omega - s)^3*s*SUNN^2*w^4 - 
      6016*Q2^5*(omega - s)^4*s*SUNN^2*w^4 + 97216*Q2^4*(omega - s)^5*s*
       SUNN^2*w^4 + 38528*Q2^3*(omega - s)^6*s*SUNN^2*w^4 - 
      105456*Q2^2*(omega - s)^7*s*SUNN^2*w^4 + 17024*Q2*(omega - s)^8*s*
       SUNN^2*w^4 - 32*(omega - s)^9*s*SUNN^2*w^4 + 23616*Q2^5*(omega - s)^3*
       s^2*SUNN^2*w^4 + 143616*Q2^4*(omega - s)^4*s^2*SUNN^2*w^4 + 
      70200*Q2^3*(omega - s)^5*s^2*SUNN^2*w^4 - 257776*Q2^2*(omega - s)^6*s^2*
       SUNN^2*w^4 + 51944*Q2*(omega - s)^7*s^2*SUNN^2*w^4 - 
      256*(omega - s)^8*s^2*SUNN^2*w^4 + 19008*Q2^5*(omega - s)^2*s^3*SUNN^2*
       w^4 + 75552*Q2^4*(omega - s)^3*s^3*SUNN^2*w^4 - 
      2688*Q2^3*(omega - s)^4*s^3*SUNN^2*w^4 - 311616*Q2^2*(omega - s)^5*s^3*
       SUNN^2*w^4 + 89104*Q2*(omega - s)^6*s^3*SUNN^2*w^4 - 
      960*(omega - s)^7*s^3*SUNN^2*w^4 - 4928*Q2^4*(omega - s)^2*s^4*SUNN^2*
       w^4 - 80280*Q2^3*(omega - s)^3*s^4*SUNN^2*w^4 - 
      205904*Q2^2*(omega - s)^4*s^4*SUNN^2*w^4 + 95640*Q2*(omega - s)^5*s^4*
       SUNN^2*w^4 - 2176*(omega - s)^6*s^4*SUNN^2*w^4 - 
      7200*Q2^4*(omega - s)*s^5*SUNN^2*w^4 - 53248*Q2^3*(omega - s)^2*s^5*
       SUNN^2*w^4 - 72528*Q2^2*(omega - s)^3*s^5*SUNN^2*w^4 + 
      70208*Q2*(omega - s)^4*s^5*SUNN^2*w^4 - 3232*(omega - s)^5*s^5*SUNN^2*
       w^4 - 7656*Q2^3*(omega - s)*s^6*SUNN^2*w^4 - 7984*Q2^2*(omega - s)^2*
       s^6*SUNN^2*w^4 + 37000*Q2*(omega - s)^3*s^6*SUNN^2*w^4 - 
      3200*(omega - s)^4*s^6*SUNN^2*w^4 + 256*Q2^3*s^7*SUNN^2*w^4 + 
      2368*Q2^2*(omega - s)*s^7*SUNN^2*w^4 + 12784*Q2*(omega - s)^2*s^7*
       SUNN^2*w^4 - 2048*(omega - s)^3*s^7*SUNN^2*w^4 + 
      384*Q2^2*s^8*SUNN^2*w^4 + 2248*Q2*(omega - s)*s^8*SUNN^2*w^4 - 
      768*(omega - s)^2*s^8*SUNN^2*w^4 + 128*Q2*s^9*SUNN^2*w^4 - 
      128*(omega - s)*s^9*SUNN^2*w^4 + 3840*Q2^6*(omega - s)^3*w^5 + 
      6016*Q2^5*(omega - s)^4*w^5 - 6560*Q2^4*(omega - s)^5*w^5 - 
      6976*Q2^3*(omega - s)^6*w^5 + 3664*Q2^2*(omega - s)^7*w^5 - 
      160*Q2*(omega - s)^8*w^5 + 3328*Q2^6*(omega - s)^2*s*w^5 + 
      16832*Q2^5*(omega - s)^3*s*w^5 - 23424*Q2^4*(omega - s)^4*s*w^5 - 
      33840*Q2^3*(omega - s)^5*s*w^5 + 18080*Q2^2*(omega - s)^6*s*w^5 - 
      1104*Q2*(omega - s)^7*s*w^5 - 16*(omega - s)^8*s*w^5 - 
      3136*Q2^5*(omega - s)^2*s^2*w^5 - 35744*Q2^4*(omega - s)^3*s^2*w^5 - 
      59232*Q2^3*(omega - s)^4*s^2*w^5 + 45584*Q2^2*(omega - s)^5*s^2*w^5 - 
      2224*Q2*(omega - s)^6*s^2*w^5 - 80*(omega - s)^7*s^2*w^5 - 
      3456*Q2^5*(omega - s)*s^3*w^5 - 26720*Q2^4*(omega - s)^2*s^3*w^5 - 
      37680*Q2^3*(omega - s)^3*s^3*w^5 + 64768*Q2^2*(omega - s)^4*s^3*w^5 - 
      3880*Q2*(omega - s)^5*s^3*w^5 - 176*(omega - s)^6*s^3*w^5 - 
      6048*Q2^4*(omega - s)*s^4*w^5 - 6592*Q2^3*(omega - s)^2*s^4*w^5 + 
      47664*Q2^2*(omega - s)^3*s^4*w^5 - 5984*Q2*(omega - s)^4*s^4*w^5 - 
      208*(omega - s)^5*s^4*w^5 + 17280*Q2^2*(omega - s)^2*s^5*w^5 - 
      4880*Q2*(omega - s)^3*s^5*w^5 - 128*(omega - s)^4*s^5*w^5 + 
      2448*Q2^2*(omega - s)*s^6*w^5 - 1712*Q2*(omega - s)^2*s^6*w^5 - 
      32*(omega - s)^3*s^6*w^5 - 216*Q2*(omega - s)*s^7*w^5 + 
      9472*Q2^6*(omega - s)^3*SUNN^2*w^5 + 15488*Q2^5*(omega - s)^4*SUNN^2*
       w^5 - 47968*Q2^4*(omega - s)^5*SUNN^2*w^5 - 47104*Q2^3*(omega - s)^6*
       SUNN^2*w^5 + 26480*Q2^2*(omega - s)^7*SUNN^2*w^5 - 
      1632*Q2*(omega - s)^8*SUNN^2*w^5 + 25344*Q2^6*(omega - s)^2*s*SUNN^2*
       w^5 + 58944*Q2^5*(omega - s)^3*s*SUNN^2*w^5 - 
      106112*Q2^4*(omega - s)^4*s*SUNN^2*w^5 - 191696*Q2^3*(omega - s)^5*s*
       SUNN^2*w^5 + 131328*Q2^2*(omega - s)^6*s*SUNN^2*w^5 - 
      10288*Q2*(omega - s)^7*s*SUNN^2*w^5 + 16*(omega - s)^8*s*SUNN^2*w^5 - 
      38336*Q2^5*(omega - s)^2*s^2*SUNN^2*w^5 - 173024*Q2^4*(omega - s)^3*s^2*
       SUNN^2*w^5 - 219424*Q2^3*(omega - s)^4*s^2*SUNN^2*w^5 + 
      254128*Q2^2*(omega - s)^5*s^2*SUNN^2*w^5 - 28144*Q2*(omega - s)^6*s^2*
       SUNN^2*w^5 + 112*(omega - s)^7*s^2*SUNN^2*w^5 - 
      28800*Q2^5*(omega - s)*s^3*SUNN^2*w^5 - 136864*Q2^4*(omega - s)^2*s^3*
       SUNN^2*w^5 - 60880*Q2^3*(omega - s)^3*s^3*SUNN^2*w^5 + 
      258240*Q2^2*(omega - s)^4*s^3*SUNN^2*w^5 - 43192*Q2*(omega - s)^5*s^3*
       SUNN^2*w^5 + 368*(omega - s)^6*s^3*SUNN^2*w^5 - 
      19680*Q2^4*(omega - s)*s^4*SUNN^2*w^5 + 48256*Q2^3*(omega - s)^2*s^4*
       SUNN^2*w^5 + 164240*Q2^2*(omega - s)^3*s^4*SUNN^2*w^5 - 
      43360*Q2*(omega - s)^4*s^4*SUNN^2*w^5 + 720*(omega - s)^5*s^4*SUNN^2*
       w^5 + 3072*Q2^4*s^5*SUNN^2*w^5 + 32256*Q2^3*(omega - s)*s^5*SUNN^2*
       w^5 + 65440*Q2^2*(omega - s)^2*s^5*SUNN^2*w^5 - 
      31408*Q2*(omega - s)^3*s^5*SUNN^2*w^5 + 896*(omega - s)^4*s^5*SUNN^2*
       w^5 + 4352*Q2^3*s^6*SUNN^2*w^5 + 12848*Q2^2*(omega - s)*s^6*SUNN^2*
       w^5 - 15344*Q2*(omega - s)^2*s^6*SUNN^2*w^5 + 
      704*(omega - s)^3*s^6*SUNN^2*w^5 + 896*Q2^2*s^7*SUNN^2*w^5 - 
      3848*Q2*(omega - s)*s^7*SUNN^2*w^5 + 320*(omega - s)^2*s^7*SUNN^2*w^5 - 
      256*Q2*s^8*SUNN^2*w^5 + 64*(omega - s)*s^8*SUNN^2*w^5 - 
      2304*Q2^6*(omega - s)^2*w^6 - 13120*Q2^5*(omega - s)^3*w^6 - 
      5248*Q2^4*(omega - s)^4*w^6 + 12496*Q2^3*(omega - s)^5*w^6 - 
      2352*Q2^2*(omega - s)^6*w^6 + 32*Q2*(omega - s)^7*w^6 - 
      4608*Q2^6*(omega - s)*s*w^6 - 18304*Q2^5*(omega - s)^2*s*w^6 - 
      1216*Q2^4*(omega - s)^3*s*w^6 + 54304*Q2^3*(omega - s)^4*s*w^6 - 
      9056*Q2^2*(omega - s)^5*s*w^6 + 144*Q2*(omega - s)^6*s*w^6 - 
      5760*Q2^5*(omega - s)*s^2*w^6 + 17792*Q2^4*(omega - s)^2*s^2*w^6 + 
      78032*Q2^3*(omega - s)^3*s^2*w^6 - 23216*Q2^2*(omega - s)^4*s^2*w^6 - 
      24*Q2*(omega - s)^5*s^2*w^6 + 9216*Q2^4*(omega - s)*s^3*w^6 + 
      42624*Q2^3*(omega - s)^2*s^3*w^6 - 27808*Q2^2*(omega - s)^3*s^3*w^6 + 
      400*Q2*(omega - s)^4*s^3*w^6 + 8640*Q2^3*(omega - s)*s^4*w^6 - 
      14464*Q2^2*(omega - s)^2*s^4*w^6 + 944*Q2*(omega - s)^3*s^4*w^6 - 
      2592*Q2^2*(omega - s)*s^5*w^6 + 480*Q2*(omega - s)^2*s^5*w^6 + 
      72*Q2*(omega - s)*s^6*w^6 - 25344*Q2^6*(omega - s)^2*SUNN^2*w^6 - 
      69312*Q2^5*(omega - s)^3*SUNN^2*w^6 + 8320*Q2^4*(omega - s)^4*SUNN^2*
       w^6 + 89392*Q2^3*(omega - s)^5*SUNN^2*w^6 - 18128*Q2^2*(omega - s)^6*
       SUNN^2*w^6 + 416*Q2*(omega - s)^7*SUNN^2*w^6 - 
      38400*Q2^6*(omega - s)*s*SUNN^2*w^6 - 84608*Q2^5*(omega - s)^2*s*SUNN^2*
       w^6 + 41152*Q2^4*(omega - s)^3*s*SUNN^2*w^6 + 
      237280*Q2^3*(omega - s)^4*s*SUNN^2*w^6 - 75680*Q2^2*(omega - s)^5*s*
       SUNN^2*w^6 + 2416*Q2*(omega - s)^6*s*SUNN^2*w^6 + 
      1152*Q2^5*(omega - s)*s^2*SUNN^2*w^6 + 173696*Q2^4*(omega - s)^2*s^2*
       SUNN^2*w^6 + 219696*Q2^3*(omega - s)^3*s^2*SUNN^2*w^6 - 
      120784*Q2^2*(omega - s)^4*s^2*SUNN^2*w^6 + 6072*Q2*(omega - s)^5*s^2*
       SUNN^2*w^6 + 12288*Q2^5*s^3*SUNN^2*w^6 + 105472*Q2^4*(omega - s)*s^3*
       SUNN^2*w^6 + 94336*Q2^3*(omega - s)^2*s^3*SUNN^2*w^6 - 
      114656*Q2^2*(omega - s)^3*s^3*SUNN^2*w^6 + 8432*Q2*(omega - s)^4*s^3*
       SUNN^2*w^6 + 15360*Q2^4*s^4*SUNN^2*w^6 + 6976*Q2^3*(omega - s)*s^4*
       SUNN^2*w^6 - 74240*Q2^2*(omega - s)^2*s^4*SUNN^2*w^6 + 
      8144*Q2*(omega - s)^3*s^4*SUNN^2*w^6 - 1536*Q2^3*s^5*SUNN^2*w^6 - 
      26208*Q2^2*(omega - s)*s^5*SUNN^2*w^6 + 5408*Q2*(omega - s)^2*s^5*
       SUNN^2*w^6 - 2816*Q2^2*s^6*SUNN^2*w^6 + 1752*Q2*(omega - s)*s^6*SUNN^2*
       w^6 + 128*Q2*s^7*SUNN^2*w^6 + 4608*Q2^6*(omega - s)*w^7 + 
      17920*Q2^5*(omega - s)^2*w^7 + 19904*Q2^4*(omega - s)^3*w^7 - 
      8384*Q2^3*(omega - s)^4*w^7 + 528*Q2^2*(omega - s)^5*w^7 + 
      18432*Q2^5*(omega - s)*s*w^7 + 24064*Q2^4*(omega - s)^2*s*w^7 - 
      34624*Q2^3*(omega - s)^3*s*w^7 + 1184*Q2^2*(omega - s)^4*s*w^7 + 
      6912*Q2^4*(omega - s)*s^2*w^7 - 34880*Q2^3*(omega - s)^2*s^2*w^7 + 
      4304*Q2^2*(omega - s)^3*s^2*w^7 - 10368*Q2^3*(omega - s)*s^3*w^7 + 
      3744*Q2^2*(omega - s)^2*s^3*w^7 + 864*Q2^2*(omega - s)*s^4*w^7 + 
      38400*Q2^6*(omega - s)*SUNN^2*w^7 + 103936*Q2^5*(omega - s)^2*SUNN^2*
       w^7 + 57920*Q2^4*(omega - s)^3*SUNN^2*w^7 - 63808*Q2^3*(omega - s)^4*
       SUNN^2*w^7 + 4592*Q2^2*(omega - s)^5*SUNN^2*w^7 + 
      16384*Q2^6*s*SUNN^2*w^7 + 96256*Q2^5*(omega - s)*s*SUNN^2*w^7 + 
      17408*Q2^4*(omega - s)^2*s*SUNN^2*w^7 - 122560*Q2^3*(omega - s)^3*s*
       SUNN^2*w^7 + 16480*Q2^2*(omega - s)^4*s*SUNN^2*w^7 + 
      12288*Q2^5*s^2*SUNN^2*w^7 - 67328*Q2^4*(omega - s)*s^2*SUNN^2*w^7 - 
      114112*Q2^3*(omega - s)^2*s^2*SUNN^2*w^7 + 21680*Q2^2*(omega - s)^3*s^2*
       SUNN^2*w^7 - 22528*Q2^4*s^3*SUNN^2*w^7 - 57728*Q2^3*(omega - s)*s^3*
       SUNN^2*w^7 + 21856*Q2^2*(omega - s)^2*s^3*SUNN^2*w^7 - 
      9216*Q2^3*s^4*SUNN^2*w^7 + 11808*Q2^2*(omega - s)*s^4*SUNN^2*w^7 + 
      1536*Q2^2*s^5*SUNN^2*w^7 - 9216*Q2^5*(omega - s)*w^8 - 
      17664*Q2^4*(omega - s)^2*w^8 + 1792*Q2^3*(omega - s)^3*w^8 - 
      13824*Q2^4*(omega - s)*s*w^8 + 7296*Q2^3*(omega - s)^2*s*w^8 + 
      3456*Q2^3*(omega - s)*s^2*w^8 - 16384*Q2^6*SUNN^2*w^8 - 
      68608*Q2^5*(omega - s)*SUNN^2*w^8 - 54016*Q2^4*(omega - s)^2*SUNN^2*
       w^8 + 16128*Q2^3*(omega - s)^3*SUNN^2*w^8 - 40960*Q2^5*s*SUNN^2*w^8 - 
      25088*Q2^4*(omega - s)*s*SUNN^2*w^8 + 21376*Q2^3*(omega - s)^2*s*SUNN^2*
       w^8 - 4096*Q2^4*s^2*SUNN^2*w^8 + 26752*Q2^3*(omega - s)*s^2*SUNN^2*
       w^8 + 6144*Q2^3*s^3*SUNN^2*w^8 + 4608*Q2^4*(omega - s)*w^9 + 
      16384*Q2^5*SUNN^2*w^9 + 13824*Q2^4*(omega - s)*SUNN^2*w^9 + 
      8192*Q2^4*s*SUNN^2*w^9))/(32*Q2*(omega - s)^3*SUNN*(omega + Q2 - w)*
     (omega - s - w)*(s - w)*w*((omega - s)^2 + 2*(omega - s)*s + s^2 + 
       4*Q2*w)^3) - ((7*Pi*s)/(2*SUNN) - (2*EulerGamma*Pi*s)/SUNN - 
     (7*Pi*s*SUNN)/2 + 2*EulerGamma*Pi*s*SUNN - (3*omega*Pi*s*Log[Pi])/
      (2*(omega - s)*SUNN) + (3*Pi*s^2*Log[Pi])/(2*(omega - s)*SUNN) + 
     (omega*Pi*s*SUNN*Log[Pi])/(omega - s) - (Pi*s^2*SUNN*Log[Pi])/
      (omega - s) - (omega*Pi*s*Log[Q2/(omega + Q2)])/(2*(omega - s)*SUNN) + 
     (Pi*s^2*Log[Q2/(omega + Q2)])/(2*(omega - s)*SUNN) + 
     (omega*Pi*s*SUNN*Log[Q2/(omega + Q2)])/(omega - s) - 
     (Pi*s^2*SUNN*Log[Q2/(omega + Q2)])/(omega - s) - 
     (omega*Pi*s*Log[(Pi*(omega + Q2))/Q2])/(2*(omega - s)*SUNN) + 
     (Pi*s^2*Log[(Pi*(omega + Q2))/Q2])/(2*(omega - s)*SUNN) + 
     (omega*Pi*s*SUNN*Log[(Pi*(omega + Q2))/Q2])/(omega - s) - 
     (Pi*s^2*SUNN*Log[(Pi*(omega + Q2))/Q2])/(omega - s))/w - 
   (-4*Pi*s*SUNN + 4*EulerGamma*Pi*s*SUNN + 4*Pi*s*SUNN*Log[Pi] + 
     4*Pi*s*SUNN*Log[-((omega + Q2)/(omega*s - s^2))])/w + 
   (Pi*(-8*Q2^2*(omega - s)^10*s - 8*Q2*(omega - s)^11*s - 
      56*Q2^2*(omega - s)^9*s^2 - 64*Q2*(omega - s)^10*s^2 - 
      168*Q2^2*(omega - s)^8*s^3 - 224*Q2*(omega - s)^9*s^3 - 
      280*Q2^2*(omega - s)^7*s^4 - 448*Q2*(omega - s)^8*s^4 - 
      280*Q2^2*(omega - s)^6*s^5 - 560*Q2*(omega - s)^7*s^5 - 
      168*Q2^2*(omega - s)^5*s^6 - 448*Q2*(omega - s)^6*s^6 - 
      56*Q2^2*(omega - s)^4*s^7 - 224*Q2*(omega - s)^5*s^7 - 
      8*Q2^2*(omega - s)^3*s^8 - 64*Q2*(omega - s)^4*s^8 - 
      8*Q2*(omega - s)^3*s^9 + 16*Q2^2*(omega - s)^10*s*SUNN^2 + 
      16*Q2*(omega - s)^11*s*SUNN^2 + 112*Q2^2*(omega - s)^9*s^2*SUNN^2 + 
      128*Q2*(omega - s)^10*s^2*SUNN^2 + 336*Q2^2*(omega - s)^8*s^3*SUNN^2 + 
      448*Q2*(omega - s)^9*s^3*SUNN^2 + 560*Q2^2*(omega - s)^7*s^4*SUNN^2 + 
      896*Q2*(omega - s)^8*s^4*SUNN^2 + 560*Q2^2*(omega - s)^6*s^5*SUNN^2 + 
      1120*Q2*(omega - s)^7*s^5*SUNN^2 + 336*Q2^2*(omega - s)^5*s^6*SUNN^2 + 
      896*Q2*(omega - s)^6*s^6*SUNN^2 + 112*Q2^2*(omega - s)^4*s^7*SUNN^2 + 
      448*Q2*(omega - s)^5*s^7*SUNN^2 + 16*Q2^2*(omega - s)^3*s^8*SUNN^2 + 
      128*Q2*(omega - s)^4*s^8*SUNN^2 + 16*Q2*(omega - s)^3*s^9*SUNN^2 - 
      8*Q2^3*(omega - s)^9*w + 8*Q2*(omega - s)^11*w + 
      32*Q2^4*(omega - s)^7*s*w - 88*Q2^3*(omega - s)^8*s*w - 
      40*Q2^2*(omega - s)^9*s*w + 104*Q2*(omega - s)^10*s*w + 
      80*Q2^4*(omega - s)^6*s^2*w - 424*Q2^3*(omega - s)^7*s^2*w - 
      296*Q2^2*(omega - s)^8*s^2*w + 504*Q2*(omega - s)^9*s^2*w + 
      48*Q2^4*(omega - s)^5*s^3*w - 952*Q2^3*(omega - s)^6*s^3*w - 
      840*Q2^2*(omega - s)^7*s^3*w + 1304*Q2*(omega - s)^8*s^3*w - 
      16*Q2^4*(omega - s)^4*s^4*w - 1072*Q2^3*(omega - s)^5*s^4*w - 
      1192*Q2^2*(omega - s)^6*s^4*w + 2048*Q2*(omega - s)^7*s^4*w - 
      16*Q2^4*(omega - s)^3*s^5*w - 592*Q2^3*(omega - s)^4*s^5*w - 
      888*Q2^2*(omega - s)^5*s^5*w + 2048*Q2*(omega - s)^6*s^5*w - 
      128*Q2^3*(omega - s)^3*s^6*w - 312*Q2^2*(omega - s)^4*s^6*w + 
      1304*Q2*(omega - s)^5*s^6*w - 24*Q2^2*(omega - s)^3*s^7*w + 
      504*Q2*(omega - s)^4*s^7*w + 8*Q2^2*(omega - s)^2*s^8*w + 
      104*Q2*(omega - s)^3*s^8*w + 8*Q2*(omega - s)^2*s^9*w + 
      24*Q2^3*(omega - s)^9*SUNN^2*w - 16*Q2^2*(omega - s)^10*SUNN^2*w - 
      40*Q2*(omega - s)^11*SUNN^2*w + 344*Q2^3*(omega - s)^8*s*SUNN^2*w + 
      8*Q2^2*(omega - s)^9*s*SUNN^2*w - 416*Q2*(omega - s)^10*s*SUNN^2*w + 
      48*Q2^4*(omega - s)^6*s^2*SUNN^2*w + 1416*Q2^3*(omega - s)^7*s^2*SUNN^2*
       w + 344*Q2^2*(omega - s)^8*s^2*SUNN^2*w - 1840*Q2*(omega - s)^9*s^2*
       SUNN^2*w + 144*Q2^4*(omega - s)^5*s^3*SUNN^2*w + 
      2664*Q2^3*(omega - s)^6*s^3*SUNN^2*w + 952*Q2^2*(omega - s)^7*s^3*
       SUNN^2*w - 4592*Q2*(omega - s)^8*s^3*SUNN^2*w + 
      144*Q2^4*(omega - s)^4*s^4*SUNN^2*w + 2560*Q2^3*(omega - s)^5*s^4*
       SUNN^2*w + 1032*Q2^2*(omega - s)^6*s^4*SUNN^2*w - 
      7160*Q2*(omega - s)^7*s^4*SUNN^2*w + 48*Q2^4*(omega - s)^3*s^5*SUNN^2*
       w + 1200*Q2^3*(omega - s)^4*s^5*SUNN^2*w + 312*Q2^2*(omega - s)^5*s^5*
       SUNN^2*w - 7240*Q2*(omega - s)^6*s^5*SUNN^2*w + 
      192*Q2^3*(omega - s)^3*s^6*SUNN^2*w - 280*Q2^2*(omega - s)^4*s^6*SUNN^2*
       w - 4736*Q2*(omega - s)^5*s^6*SUNN^2*w - 16*Q2^3*(omega - s)^2*s^7*
       SUNN^2*w - 248*Q2^2*(omega - s)^3*s^7*SUNN^2*w - 
      1920*Q2*(omega - s)^4*s^7*SUNN^2*w - 56*Q2^2*(omega - s)^2*s^8*SUNN^2*
       w - 432*Q2*(omega - s)^3*s^8*SUNN^2*w - 40*Q2*(omega - s)^2*s^9*SUNN^2*
       w + 32*Q2^5*(omega - s)^6*w^2 - 16*Q2^4*(omega - s)^7*w^2 + 
      88*Q2^3*(omega - s)^8*w^2 + 128*Q2^2*(omega - s)^9*w^2 - 
      24*Q2*(omega - s)^10*w^2 + 240*Q2^5*(omega - s)^5*s*w^2 - 
      400*Q2^4*(omega - s)^6*s*w^2 + 168*Q2^3*(omega - s)^7*s*w^2 + 
      1040*Q2^2*(omega - s)^8*s*w^2 - 240*Q2*(omega - s)^9*s*w^2 + 
      176*Q2^5*(omega - s)^4*s^2*w^2 - 1088*Q2^4*(omega - s)^5*s^2*w^2 + 
      568*Q2^3*(omega - s)^6*s^2*w^2 + 3872*Q2^2*(omega - s)^7*s^2*w^2 - 
      904*Q2*(omega - s)^8*s^2*w^2 - 48*Q2^5*(omega - s)^3*s^3*w^2 - 
      1248*Q2^4*(omega - s)^4*s^3*w^2 + 1176*Q2^3*(omega - s)^5*s^3*w^2 + 
      7312*Q2^2*(omega - s)^6*s^3*w^2 - 1880*Q2*(omega - s)^7*s^3*w^2 - 
      16*Q2^5*(omega - s)^2*s^4*w^2 - 608*Q2^4*(omega - s)^3*s^4*w^2 + 
      896*Q2^3*(omega - s)^4*s^4*w^2 + 7216*Q2^2*(omega - s)^5*s^4*w^2 - 
      2480*Q2*(omega - s)^6*s^4*w^2 - 64*Q2^4*(omega - s)^2*s^5*w^2 + 
      224*Q2^3*(omega - s)^3*s^5*w^2 + 3584*Q2^2*(omega - s)^4*s^5*w^2 - 
      2144*Q2*(omega - s)^5*s^5*w^2 + 16*Q2^3*(omega - s)^2*s^6*w^2 + 
      752*Q2^2*(omega - s)^3*s^6*w^2 - 1160*Q2*(omega - s)^4*s^6*w^2 + 
      32*Q2^2*(omega - s)^2*s^7*w^2 - 344*Q2*(omega - s)^3*s^7*w^2 - 
      40*Q2*(omega - s)^2*s^8*w^2 + 272*Q2^4*(omega - s)^7*SUNN^2*w^2 - 
      344*Q2^3*(omega - s)^8*SUNN^2*w^2 - 560*Q2^2*(omega - s)^9*SUNN^2*w^2 + 
      120*Q2*(omega - s)^10*SUNN^2*w^2 + 144*Q2^5*(omega - s)^5*s*SUNN^2*
       w^2 + 2160*Q2^4*(omega - s)^6*s*SUNN^2*w^2 - 1768*Q2^3*(omega - s)^7*s*
       SUNN^2*w^2 - 4368*Q2^2*(omega - s)^8*s*SUNN^2*w^2 + 
      1088*Q2*(omega - s)^9*s*SUNN^2*w^2 + 528*Q2^5*(omega - s)^4*s^2*SUNN^2*
       w^2 + 4672*Q2^4*(omega - s)^5*s^2*SUNN^2*w^2 - 
      4792*Q2^3*(omega - s)^6*s^2*SUNN^2*w^2 - 13984*Q2^2*(omega - s)^7*s^2*
       SUNN^2*w^2 + 4216*Q2*(omega - s)^8*s^2*SUNN^2*w^2 + 
      432*Q2^5*(omega - s)^3*s^3*SUNN^2*w^2 + 4064*Q2^4*(omega - s)^4*s^3*
       SUNN^2*w^2 - 7288*Q2^3*(omega - s)^5*s^3*SUNN^2*w^2 - 
      23360*Q2^2*(omega - s)^6*s^3*SUNN^2*w^2 + 9208*Q2*(omega - s)^7*s^3*
       SUNN^2*w^2 + 48*Q2^5*(omega - s)^2*s^4*SUNN^2*w^2 + 
      1248*Q2^4*(omega - s)^3*s^4*SUNN^2*w^2 - 6048*Q2^3*(omega - s)^4*s^4*
       SUNN^2*w^2 - 21728*Q2^2*(omega - s)^5*s^4*SUNN^2*w^2 + 
      12400*Q2*(omega - s)^6*s^4*SUNN^2*w^2 - 32*Q2^4*(omega - s)^2*s^5*
       SUNN^2*w^2 - 2624*Q2^3*(omega - s)^3*s^5*SUNN^2*w^2 - 
      11104*Q2^2*(omega - s)^4*s^5*SUNN^2*w^2 + 10480*Q2*(omega - s)^5*s^5*
       SUNN^2*w^2 - 496*Q2^3*(omega - s)^2*s^6*SUNN^2*w^2 - 
      2832*Q2^2*(omega - s)^3*s^6*SUNN^2*w^2 + 5368*Q2*(omega - s)^4*s^6*
       SUNN^2*w^2 - 272*Q2^2*(omega - s)^2*s^7*SUNN^2*w^2 + 
      1496*Q2*(omega - s)^3*s^7*SUNN^2*w^2 + 168*Q2*(omega - s)^2*s^8*SUNN^2*
       w^2 + 160*Q2^6*(omega - s)^4*w^3 - 80*Q2^5*(omega - s)^5*w^3 + 
      368*Q2^4*(omega - s)^6*w^3 + 448*Q2^3*(omega - s)^7*w^3 - 
      368*Q2^2*(omega - s)^8*w^3 + 24*Q2*(omega - s)^9*w^3 + 
      256*Q2^6*(omega - s)^3*s*w^3 - 624*Q2^5*(omega - s)^4*s*w^3 + 
      2256*Q2^4*(omega - s)^5*s*w^3 + 3968*Q2^3*(omega - s)^6*s*w^3 - 
      2208*Q2^2*(omega - s)^7*s*w^3 + 216*Q2*(omega - s)^8*s*w^3 - 
      32*Q2^6*(omega - s)^2*s^2*w^3 - 224*Q2^5*(omega - s)^3*s^2*w^3 + 
      4000*Q2^4*(omega - s)^4*s^2*w^3 + 8000*Q2^3*(omega - s)^5*s^2*w^3 - 
      6720*Q2^2*(omega - s)^6*s^2*w^3 + 648*Q2*(omega - s)^7*s^2*w^3 - 
      224*Q2^5*(omega - s)^2*s^3*w^3 + 2464*Q2^4*(omega - s)^3*s^3*w^3 + 
      6752*Q2^3*(omega - s)^4*s^3*w^3 - 10112*Q2^2*(omega - s)^5*s^3*w^3 + 
      1144*Q2*(omega - s)^6*s^3*w^3 + 128*Q2^4*(omega - s)^2*s^4*w^3 + 
      2336*Q2^3*(omega - s)^3*s^4*w^3 - 7376*Q2^2*(omega - s)^4*s^4*w^3 + 
      1408*Q2*(omega - s)^5*s^4*w^3 + 64*Q2^3*(omega - s)^2*s^5*w^3 - 
      2464*Q2^2*(omega - s)^3*s^5*w^3 + 1104*Q2*(omega - s)^4*s^5*w^3 - 
      320*Q2^2*(omega - s)^2*s^6*w^3 + 448*Q2*(omega - s)^3*s^6*w^3 + 
      64*Q2*(omega - s)^2*s^7*w^3 + 96*Q2^6*(omega - s)^4*SUNN^2*w^3 + 
      1168*Q2^5*(omega - s)^5*SUNN^2*w^3 - 2256*Q2^4*(omega - s)^6*SUNN^2*
       w^3 - 2432*Q2^3*(omega - s)^7*SUNN^2*w^3 + 1744*Q2^2*(omega - s)^8*
       SUNN^2*w^3 - 120*Q2*(omega - s)^9*SUNN^2*w^3 + 
      768*Q2^6*(omega - s)^3*s*SUNN^2*w^3 + 3824*Q2^5*(omega - s)^4*s*SUNN^2*
       w^3 - 10480*Q2^4*(omega - s)^5*s*SUNN^2*w^3 - 12992*Q2^3*(omega - s)^6*
       s*SUNN^2*w^3 + 11616*Q2^2*(omega - s)^7*s*SUNN^2*w^3 - 
      1016*Q2*(omega - s)^8*s*SUNN^2*w^3 + 288*Q2^6*(omega - s)^2*s^2*SUNN^2*
       w^3 + 2592*Q2^5*(omega - s)^3*s^2*SUNN^2*w^3 - 
      15296*Q2^4*(omega - s)^4*s^2*SUNN^2*w^3 - 22208*Q2^3*(omega - s)^5*s^2*
       SUNN^2*w^3 + 31840*Q2^2*(omega - s)^6*s^2*SUNN^2*w^3 - 
      3592*Q2*(omega - s)^7*s^2*SUNN^2*w^3 + 224*Q2^5*(omega - s)^2*s^3*
       SUNN^2*w^3 - 9088*Q2^4*(omega - s)^3*s^3*SUNN^2*w^3 - 
      16224*Q2^3*(omega - s)^4*s^3*SUNN^2*w^3 + 44096*Q2^2*(omega - s)^5*s^3*
       SUNN^2*w^3 - 7032*Q2*(omega - s)^6*s^3*SUNN^2*w^3 - 
      1792*Q2^4*(omega - s)^2*s^4*SUNN^2*w^3 - 4832*Q2^3*(omega - s)^3*s^4*
       SUNN^2*w^3 + 32048*Q2^2*(omega - s)^4*s^4*SUNN^2*w^3 - 
      8160*Q2*(omega - s)^5*s^4*SUNN^2*w^3 - 256*Q2^3*(omega - s)^2*s^5*
       SUNN^2*w^3 + 11552*Q2^2*(omega - s)^3*s^5*SUNN^2*w^3 - 
      5488*Q2*(omega - s)^4*s^5*SUNN^2*w^3 + 1632*Q2^2*(omega - s)^2*s^6*
       SUNN^2*w^3 - 1920*Q2*(omega - s)^3*s^6*SUNN^2*w^3 - 
      256*Q2*(omega - s)^2*s^7*SUNN^2*w^3 + 128*Q2^7*(omega - s)^2*w^4 - 
      96*Q2^6*(omega - s)^3*w^4 + 1360*Q2^5*(omega - s)^4*w^4 + 
      1024*Q2^4*(omega - s)^5*w^4 - 1472*Q2^3*(omega - s)^6*w^4 + 
      368*Q2^2*(omega - s)^7*w^4 - 8*Q2*(omega - s)^8*w^4 + 
      128*Q2^6*(omega - s)^2*s*w^4 + 2704*Q2^5*(omega - s)^3*s*w^4 + 
      1568*Q2^4*(omega - s)^4*s*w^4 - 8624*Q2^3*(omega - s)^5*s*w^4 + 
      1760*Q2^2*(omega - s)^6*s*w^4 - 72*Q2*(omega - s)^7*s*w^4 + 
      864*Q2^5*(omega - s)^2*s^2*w^4 + 416*Q2^4*(omega - s)^3*s^2*w^4 - 
      12720*Q2^3*(omega - s)^4*s^2*w^4 + 4848*Q2^2*(omega - s)^5*s^2*w^4 - 
      168*Q2*(omega - s)^6*s^2*w^4 + 64*Q2^4*(omega - s)^2*s^3*w^4 - 
      6832*Q2^3*(omega - s)^3*s^3*w^4 + 5968*Q2^2*(omega - s)^4*s^3*w^4 - 
      280*Q2*(omega - s)^5*s^3*w^4 - 944*Q2^3*(omega - s)^2*s^4*w^4 + 
      3120*Q2^2*(omega - s)^3*s^4*w^4 - 336*Q2*(omega - s)^4*s^4*w^4 + 
      608*Q2^2*(omega - s)^2*s^5*w^4 - 192*Q2*(omega - s)^3*s^5*w^4 - 
      32*Q2*(omega - s)^2*s^6*w^4 + 384*Q2^7*(omega - s)^2*SUNN^2*w^4 + 
      1376*Q2^6*(omega - s)^3*SUNN^2*w^4 - 6352*Q2^5*(omega - s)^4*SUNN^2*
       w^4 - 2432*Q2^4*(omega - s)^5*SUNN^2*w^4 + 8608*Q2^3*(omega - s)^6*
       SUNN^2*w^4 - 1776*Q2^2*(omega - s)^7*SUNN^2*w^4 + 
      40*Q2*(omega - s)^8*SUNN^2*w^4 + 384*Q2^6*(omega - s)^2*s*SUNN^2*w^4 - 
      10256*Q2^5*(omega - s)^3*s*SUNN^2*w^4 + 224*Q2^4*(omega - s)^4*s*SUNN^2*
       w^4 + 37744*Q2^3*(omega - s)^5*s*SUNN^2*w^4 - 10752*Q2^2*(omega - s)^6*
       s*SUNN^2*w^4 + 328*Q2*(omega - s)^7*s*SUNN^2*w^4 - 
      3424*Q2^5*(omega - s)^2*s^2*SUNN^2*w^4 + 3552*Q2^4*(omega - s)^3*s^2*
       SUNN^2*w^4 + 51632*Q2^3*(omega - s)^4*s^2*SUNN^2*w^4 - 
      26096*Q2^2*(omega - s)^5*s^2*SUNN^2*w^4 + 1064*Q2*(omega - s)^6*s^2*
       SUNN^2*w^4 + 1728*Q2^4*(omega - s)^2*s^3*SUNN^2*w^4 + 
      27888*Q2^3*(omega - s)^3*s^3*SUNN^2*w^4 - 29264*Q2^2*(omega - s)^4*s^3*
       SUNN^2*w^4 + 1848*Q2*(omega - s)^5*s^3*SUNN^2*w^4 + 
      5072*Q2^3*(omega - s)^2*s^4*SUNN^2*w^4 - 14896*Q2^2*(omega - s)^3*s^4*
       SUNN^2*w^4 + 1744*Q2*(omega - s)^4*s^4*SUNN^2*w^4 - 
      2752*Q2^2*(omega - s)^2*s^5*SUNN^2*w^4 + 800*Q2*(omega - s)^3*s^5*
       SUNN^2*w^4 + 128*Q2*(omega - s)^2*s^6*SUNN^2*w^4 + 
      384*Q2^6*(omega - s)^2*w^5 - 1728*Q2^5*(omega - s)^3*w^5 - 
      3712*Q2^4*(omega - s)^4*w^5 + 1456*Q2^3*(omega - s)^5*w^5 - 
      128*Q2^2*(omega - s)^6*w^5 - 768*Q2^5*(omega - s)^2*s*w^5 - 
      4640*Q2^4*(omega - s)^3*s*w^5 + 7184*Q2^3*(omega - s)^4*s*w^5 - 
      512*Q2^2*(omega - s)^5*s*w^5 - 992*Q2^4*(omega - s)^2*s^2*w^5 + 
      7456*Q2^3*(omega - s)^3*s^2*w^5 - 1392*Q2^2*(omega - s)^4*s^2*w^5 + 
      2080*Q2^3*(omega - s)^2*s^3*w^5 - 1232*Q2^2*(omega - s)^3*s^3*w^5 - 
      320*Q2^2*(omega - s)^2*s^4*w^5 - 2432*Q2^6*(omega - s)^2*SUNN^2*w^5 + 
      8384*Q2^5*(omega - s)^3*SUNN^2*w^5 + 15488*Q2^4*(omega - s)^4*SUNN^2*
       w^5 - 9072*Q2^3*(omega - s)^5*SUNN^2*w^5 + 608*Q2^2*(omega - s)^6*
       SUNN^2*w^5 + 3840*Q2^5*(omega - s)^2*s*SUNN^2*w^5 + 
      17184*Q2^4*(omega - s)^3*s*SUNN^2*w^5 - 34704*Q2^3*(omega - s)^4*s*
       SUNN^2*w^5 + 3424*Q2^2*(omega - s)^5*s*SUNN^2*w^5 + 
      3808*Q2^4*(omega - s)^2*s^2*SUNN^2*w^5 - 34528*Q2^3*(omega - s)^3*s^2*
       SUNN^2*w^5 + 7248*Q2^2*(omega - s)^4*s^2*SUNN^2*w^5 - 
      10016*Q2^3*(omega - s)^2*s^3*SUNN^2*w^5 + 5744*Q2^2*(omega - s)^3*s^3*
       SUNN^2*w^5 + 1408*Q2^2*(omega - s)^2*s^4*SUNN^2*w^5 + 
      896*Q2^5*(omega - s)^2*w^6 + 3872*Q2^4*(omega - s)^3*w^6 - 
      496*Q2^3*(omega - s)^4*w^6 + 2688*Q2^4*(omega - s)^2*s*w^6 - 
      2288*Q2^3*(omega - s)^3*s*w^6 - 1120*Q2^3*(omega - s)^2*s^2*w^6 - 
      4480*Q2^5*(omega - s)^2*SUNN^2*w^6 - 17952*Q2^4*(omega - s)^3*SUNN^2*
       w^6 + 3184*Q2^3*(omega - s)^4*SUNN^2*w^6 - 12416*Q2^4*(omega - s)^2*s*
       SUNN^2*w^6 + 10608*Q2^3*(omega - s)^3*s*SUNN^2*w^6 + 
      5216*Q2^3*(omega - s)^2*s^2*SUNN^2*w^6 - 1408*Q2^4*(omega - s)^2*w^7 + 
      6528*Q2^4*(omega - s)^2*SUNN^2*w^7)*
     Log[(1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
       (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])])/
    (16*Q2*(omega + 2*Q2)*(omega - s)^3*SUNN*(omega + Q2 - w)*w*
     ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)^3*
     Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
       (omega + 2*Q2)^2]) + (4*Pi*s*SUNN*(w^(-1) - (2*eps*Log[w])/w))/eps - 
   (((2*Pi*s)/SUNN - 2*Pi*s*SUNN)*(w^(-1) - (eps*Log[w])/w))/eps + 
   ((-16*Q2^2*(omega - s)^10*s^2 - 16*Q2*(omega - s)^11*s^2 - 
      96*Q2^2*(omega - s)^9*s^3 - 112*Q2*(omega - s)^10*s^3 - 
      240*Q2^2*(omega - s)^8*s^4 - 336*Q2*(omega - s)^9*s^4 - 
      320*Q2^2*(omega - s)^7*s^5 - 560*Q2*(omega - s)^8*s^5 - 
      240*Q2^2*(omega - s)^6*s^6 - 560*Q2*(omega - s)^7*s^6 - 
      96*Q2^2*(omega - s)^5*s^7 - 336*Q2*(omega - s)^6*s^7 - 
      16*Q2^2*(omega - s)^4*s^8 - 112*Q2*(omega - s)^5*s^8 - 
      16*Q2*(omega - s)^4*s^9 + 32*Q2^2*(omega - s)^10*s^2*SUNN^2 + 
      32*Q2*(omega - s)^11*s^2*SUNN^2 + 192*Q2^2*(omega - s)^9*s^3*SUNN^2 + 
      224*Q2*(omega - s)^10*s^3*SUNN^2 + 480*Q2^2*(omega - s)^8*s^4*SUNN^2 + 
      672*Q2*(omega - s)^9*s^4*SUNN^2 + 640*Q2^2*(omega - s)^7*s^5*SUNN^2 + 
      1120*Q2*(omega - s)^8*s^5*SUNN^2 + 480*Q2^2*(omega - s)^6*s^6*SUNN^2 + 
      1120*Q2*(omega - s)^7*s^6*SUNN^2 + 192*Q2^2*(omega - s)^5*s^7*SUNN^2 + 
      672*Q2*(omega - s)^6*s^7*SUNN^2 + 32*Q2^2*(omega - s)^4*s^8*SUNN^2 + 
      224*Q2*(omega - s)^5*s^8*SUNN^2 + 32*Q2*(omega - s)^4*s^9*SUNN^2 + 
      16*Q2^3*(omega - s)^9*s*w + 16*Q2^2*(omega - s)^10*s*w - 
      96*Q2^3*(omega - s)^8*s^2*w - 32*Q2^2*(omega - s)^9*s^2*w + 
      64*Q2*(omega - s)^10*s^2*w - 528*Q2^3*(omega - s)^7*s^3*w - 
      336*Q2^2*(omega - s)^8*s^3*w + 432*Q2*(omega - s)^9*s^3*w - 
      832*Q2^3*(omega - s)^6*s^4*w - 640*Q2^2*(omega - s)^7*s^4*w + 
      1248*Q2*(omega - s)^8*s^4*w - 528*Q2^3*(omega - s)^5*s^5*w - 
      400*Q2^2*(omega - s)^6*s^5*w + 2000*Q2*(omega - s)^7*s^5*w - 
      96*Q2^3*(omega - s)^4*s^6*w + 96*Q2^2*(omega - s)^5*s^6*w + 
      1920*Q2*(omega - s)^6*s^6*w + 16*Q2^3*(omega - s)^3*s^7*w + 
      208*Q2^2*(omega - s)^4*s^7*w + 1104*Q2*(omega - s)^5*s^7*w + 
      64*Q2^2*(omega - s)^3*s^8*w + 352*Q2*(omega - s)^4*s^8*w + 
      48*Q2*(omega - s)^3*s^9*w + 16*Q2^3*(omega - s)^9*s*SUNN^2*w + 
      64*Q2^2*(omega - s)^10*s*SUNN^2*w + 48*Q2*(omega - s)^11*s*SUNN^2*w + 
      480*Q2^3*(omega - s)^8*s^2*SUNN^2*w + 816*Q2^2*(omega - s)^9*s^2*SUNN^2*
       w + 336*Q2*(omega - s)^10*s^2*SUNN^2*w + 1776*Q2^3*(omega - s)^7*s^3*
       SUNN^2*w + 3168*Q2^2*(omega - s)^8*s^3*SUNN^2*w + 
      1040*Q2*(omega - s)^9*s^3*SUNN^2*w + 2624*Q2^3*(omega - s)^6*s^4*SUNN^2*
       w + 5840*Q2^2*(omega - s)^7*s^4*SUNN^2*w + 1872*Q2*(omega - s)^8*s^4*
       SUNN^2*w + 1776*Q2^3*(omega - s)^5*s^5*SUNN^2*w + 
      5760*Q2^2*(omega - s)^6*s^5*SUNN^2*w + 2160*Q2*(omega - s)^7*s^5*SUNN^2*
       w + 480*Q2^3*(omega - s)^4*s^6*SUNN^2*w + 3024*Q2^2*(omega - s)^5*s^6*
       SUNN^2*w + 1648*Q2*(omega - s)^6*s^6*SUNN^2*w + 
      16*Q2^3*(omega - s)^3*s^7*SUNN^2*w + 736*Q2^2*(omega - s)^4*s^7*SUNN^2*
       w + 816*Q2*(omega - s)^5*s^7*SUNN^2*w + 48*Q2^2*(omega - s)^3*s^8*
       SUNN^2*w + 240*Q2*(omega - s)^4*s^8*SUNN^2*w + 
      32*Q2*(omega - s)^3*s^9*SUNN^2*w - 16*Q2^3*(omega - s)^9*w^2 - 
      32*Q2^2*(omega - s)^10*w^2 - 16*Q2*(omega - s)^11*w^2 + 
      192*Q2^4*(omega - s)^7*s*w^2 + 96*Q2^3*(omega - s)^8*s*w^2 - 
      288*Q2^2*(omega - s)^9*s*w^2 - 176*Q2*(omega - s)^10*s*w^2 + 
      528*Q2^3*(omega - s)^7*s^2*w^2 - 304*Q2^2*(omega - s)^8*s^2*w^2 - 
      848*Q2*(omega - s)^9*s^2*w^2 - 384*Q2^4*(omega - s)^5*s^3*w^2 + 
      1600*Q2^3*(omega - s)^6*s^3*w^2 + 1472*Q2^2*(omega - s)^7*s^3*w^2 - 
      2304*Q2*(omega - s)^8*s^3*w^2 + 2832*Q2^3*(omega - s)^5*s^4*w^2 + 
      4272*Q2^2*(omega - s)^6*s^4*w^2 - 3856*Q2*(omega - s)^7*s^4*w^2 + 
      192*Q2^4*(omega - s)^3*s^5*w^2 + 2400*Q2^3*(omega - s)^4*s^5*w^2 + 
      4576*Q2^2*(omega - s)^5*s^5*w^2 - 4096*Q2*(omega - s)^6*s^5*w^2 + 
      752*Q2^3*(omega - s)^3*s^6*w^2 + 2224*Q2^2*(omega - s)^4*s^6*w^2 - 
      2736*Q2*(omega - s)^5*s^6*w^2 + 384*Q2^2*(omega - s)^3*s^7*w^2 - 
      1088*Q2*(omega - s)^4*s^7*w^2 - 16*Q2^2*(omega - s)^2*s^8*w^2 - 
      224*Q2*(omega - s)^3*s^8*w^2 - 16*Q2*(omega - s)^2*s^9*w^2 - 
      16*Q2^3*(omega - s)^9*SUNN^2*w^2 - 64*Q2^2*(omega - s)^10*SUNN^2*w^2 - 
      48*Q2*(omega - s)^11*SUNN^2*w^2 + 192*Q2^4*(omega - s)^7*s*SUNN^2*w^2 + 
      704*Q2^3*(omega - s)^8*s*SUNN^2*w^2 - 16*Q2^2*(omega - s)^9*s*SUNN^2*
       w^2 - 592*Q2*(omega - s)^10*s*SUNN^2*w^2 + 2304*Q2^4*(omega - s)^6*s^2*
       SUNN^2*w^2 + 5136*Q2^3*(omega - s)^7*s^2*SUNN^2*w^2 + 
      688*Q2^2*(omega - s)^8*s^2*SUNN^2*w^2 - 2800*Q2*(omega - s)^9*s^2*
       SUNN^2*w^2 + 4224*Q2^4*(omega - s)^5*s^3*SUNN^2*w^2 + 
      11680*Q2^3*(omega - s)^6*s^3*SUNN^2*w^2 + 1840*Q2^2*(omega - s)^7*s^3*
       SUNN^2*w^2 - 7072*Q2*(omega - s)^8*s^3*SUNN^2*w^2 + 
      2304*Q2^4*(omega - s)^4*s^4*SUNN^2*w^2 + 11536*Q2^3*(omega - s)^5*s^4*
       SUNN^2*w^2 + 2416*Q2^2*(omega - s)^6*s^4*SUNN^2*w^2 - 
      10736*Q2*(omega - s)^7*s^4*SUNN^2*w^2 + 192*Q2^4*(omega - s)^3*s^5*
       SUNN^2*w^2 + 4992*Q2^3*(omega - s)^4*s^5*SUNN^2*w^2 + 
      2000*Q2^2*(omega - s)^5*s^5*SUNN^2*w^2 - 10208*Q2*(omega - s)^6*s^5*
       SUNN^2*w^2 + 752*Q2^3*(omega - s)^3*s^6*SUNN^2*w^2 + 
      1040*Q2^2*(omega - s)^4*s^6*SUNN^2*w^2 - 6032*Q2*(omega - s)^5*s^6*
       SUNN^2*w^2 + 32*Q2^3*(omega - s)^2*s^7*SUNN^2*w^2 + 
      272*Q2^2*(omega - s)^3*s^7*SUNN^2*w^2 - 2080*Q2*(omega - s)^4*s^7*
       SUNN^2*w^2 + 16*Q2^2*(omega - s)^2*s^8*SUNN^2*w^2 - 
      352*Q2*(omega - s)^3*s^8*SUNN^2*w^2 - 16*Q2*(omega - s)^2*s^9*SUNN^2*
       w^2 - 192*Q2^4*(omega - s)^7*w^3 - 384*Q2^3*(omega - s)^8*w^3 - 
      128*Q2^2*(omega - s)^9*w^3 + 64*Q2*(omega - s)^10*w^3 + 
      768*Q2^5*(omega - s)^5*s*w^3 - 2672*Q2^3*(omega - s)^7*s*w^3 - 
      1264*Q2^2*(omega - s)^8*s*w^3 + 560*Q2*(omega - s)^9*s*w^3 + 
      512*Q2^5*(omega - s)^4*s^2*w^3 + 2432*Q2^4*(omega - s)^5*s^2*w^3 - 
      3936*Q2^3*(omega - s)^6*s^2*w^3 - 5056*Q2^2*(omega - s)^7*s^2*w^3 + 
      2112*Q2*(omega - s)^8*s^2*w^3 + 768*Q2^5*(omega - s)^3*s^3*w^3 + 
      5120*Q2^4*(omega - s)^4*s^3*w^3 - 528*Q2^3*(omega - s)^5*s^3*w^3 - 
      10192*Q2^2*(omega - s)^6*s^3*w^3 + 4512*Q2*(omega - s)^7*s^3*w^3 + 
      2880*Q2^4*(omega - s)^3*s^4*w^3 + 1856*Q2^3*(omega - s)^4*s^4*w^3 - 
      10976*Q2^2*(omega - s)^5*s^4*w^3 + 6016*Q2*(omega - s)^6*s^4*w^3 + 
      624*Q2^3*(omega - s)^3*s^5*w^3 - 6032*Q2^2*(omega - s)^4*s^5*w^3 + 
      5184*Q2*(omega - s)^5*s^5*w^3 - 96*Q2^3*(omega - s)^2*s^6*w^3 - 
      1280*Q2^2*(omega - s)^3*s^6*w^3 + 2880*Q2*(omega - s)^4*s^6*w^3 + 
      16*Q2^3*(omega - s)*s^7*w^3 + 80*Q2^2*(omega - s)^2*s^7*w^3 + 
      992*Q2*(omega - s)^3*s^7*w^3 + 32*Q2^2*(omega - s)*s^8*w^3 + 
      192*Q2*(omega - s)^2*s^8*w^3 + 16*Q2*(omega - s)*s^9*w^3 - 
      192*Q2^4*(omega - s)^7*SUNN^2*w^3 - 800*Q2^3*(omega - s)^8*SUNN^2*w^3 - 
      448*Q2^2*(omega - s)^9*SUNN^2*w^3 + 192*Q2*(omega - s)^10*SUNN^2*w^3 + 
      768*Q2^5*(omega - s)^5*s*SUNN^2*w^3 + 2688*Q2^4*(omega - s)^6*s*SUNN^2*
       w^3 - 3408*Q2^3*(omega - s)^7*s*SUNN^2*w^3 - 5040*Q2^2*(omega - s)^8*s*
       SUNN^2*w^3 + 1664*Q2*(omega - s)^9*s*SUNN^2*w^3 + 
      3584*Q2^5*(omega - s)^4*s^2*SUNN^2*w^3 + 10880*Q2^4*(omega - s)^5*s^2*
       SUNN^2*w^3 - 7680*Q2^3*(omega - s)^6*s^2*SUNN^2*w^3 - 
      18240*Q2^2*(omega - s)^7*s^2*SUNN^2*w^3 + 6176*Q2*(omega - s)^8*s^2*
       SUNN^2*w^3 + 768*Q2^5*(omega - s)^3*s^3*SUNN^2*w^3 + 
      11264*Q2^4*(omega - s)^4*s^3*SUNN^2*w^3 - 8752*Q2^3*(omega - s)^5*s^3*
       SUNN^2*w^3 - 31376*Q2^2*(omega - s)^6*s^3*SUNN^2*w^3 + 
      12912*Q2*(omega - s)^7*s^3*SUNN^2*w^3 + 3648*Q2^4*(omega - s)^3*s^4*
       SUNN^2*w^3 - 3744*Q2^3*(omega - s)^4*s^4*SUNN^2*w^3 - 
      28128*Q2^2*(omega - s)^5*s^4*SUNN^2*w^3 + 16768*Q2*(omega - s)^6*s^4*
       SUNN^2*w^3 + 384*Q2^4*(omega - s)^2*s^5*SUNN^2*w^3 + 
      336*Q2^3*(omega - s)^3*s^5*SUNN^2*w^3 - 12240*Q2^2*(omega - s)^4*s^5*
       SUNN^2*w^3 + 14032*Q2*(omega - s)^5*s^5*SUNN^2*w^3 + 
      448*Q2^3*(omega - s)^2*s^6*SUNN^2*w^3 - 1408*Q2^2*(omega - s)^3*s^6*
       SUNN^2*w^3 + 7584*Q2*(omega - s)^4*s^6*SUNN^2*w^3 + 
      48*Q2^3*(omega - s)*s^7*SUNN^2*w^3 + 528*Q2^2*(omega - s)^2*s^7*SUNN^2*
       w^3 + 2576*Q2*(omega - s)^3*s^7*SUNN^2*w^3 + 96*Q2^2*(omega - s)*s^8*
       SUNN^2*w^3 + 512*Q2*(omega - s)^2*s^8*SUNN^2*w^3 + 
      48*Q2*(omega - s)*s^9*SUNN^2*w^3 - 768*Q2^5*(omega - s)^5*w^4 - 
      1536*Q2^4*(omega - s)^6*w^4 - 16*Q2^3*(omega - s)^7*w^4 + 
      704*Q2^2*(omega - s)^8*w^4 - 96*Q2*(omega - s)^9*w^4 + 
      1024*Q2^6*(omega - s)^3*s*w^4 - 512*Q2^5*(omega - s)^4*s*w^4 - 
      7488*Q2^4*(omega - s)^5*s*w^4 - 1440*Q2^3*(omega - s)^6*s*w^4 + 
      4736*Q2^2*(omega - s)^7*s*w^4 - 720*Q2*(omega - s)^8*s*w^4 + 
      3328*Q2^5*(omega - s)^3*s^2*w^4 - 6656*Q2^4*(omega - s)^4*s^2*w^4 - 
      6000*Q2^3*(omega - s)^5*s^2*w^4 + 12864*Q2^2*(omega - s)^6*s^2*w^4 - 
      2352*Q2*(omega - s)^7*s^2*w^4 - 1920*Q2^4*(omega - s)^3*s^3*w^4 - 
      6848*Q2^3*(omega - s)^4*s^3*w^4 + 18304*Q2^2*(omega - s)^5*s^3*w^4 - 
      4368*Q2*(omega - s)^6*s^3*w^4 - 1008*Q2^3*(omega - s)^3*s^4*w^4 + 
      14656*Q2^2*(omega - s)^4*s^4*w^4 - 5040*Q2*(omega - s)^5*s^4*w^4 + 
      192*Q2^4*(omega - s)*s^5*w^4 + 1632*Q2^3*(omega - s)^2*s^5*w^4 + 
      6528*Q2^2*(omega - s)^3*s^5*w^4 - 3696*Q2*(omega - s)^4*s^5*w^4 + 
      368*Q2^3*(omega - s)*s^6*w^4 + 1472*Q2^2*(omega - s)^2*s^6*w^4 - 
      1680*Q2*(omega - s)^3*s^6*w^4 + 128*Q2^2*(omega - s)*s^7*w^4 - 
      432*Q2*(omega - s)^2*s^7*w^4 - 48*Q2*(omega - s)*s^8*w^4 - 
      768*Q2^5*(omega - s)^5*SUNN^2*w^4 - 3456*Q2^4*(omega - s)^6*SUNN^2*
       w^4 - 816*Q2^3*(omega - s)^7*SUNN^2*w^4 + 2144*Q2^2*(omega - s)^8*
       SUNN^2*w^4 - 288*Q2*(omega - s)^9*SUNN^2*w^4 + 
      1024*Q2^6*(omega - s)^3*s*SUNN^2*w^4 + 4096*Q2^5*(omega - s)^4*s*SUNN^2*
       w^4 - 14016*Q2^4*(omega - s)^5*s*SUNN^2*w^4 - 11616*Q2^3*(omega - s)^6*
       s*SUNN^2*w^4 + 14208*Q2^2*(omega - s)^7*s*SUNN^2*w^4 - 
      2128*Q2*(omega - s)^8*s*SUNN^2*w^4 + 5376*Q2^5*(omega - s)^3*s^2*SUNN^2*
       w^4 - 19200*Q2^4*(omega - s)^4*s^2*SUNN^2*w^4 - 
      27216*Q2^3*(omega - s)^5*s^2*SUNN^2*w^4 + 37536*Q2^2*(omega - s)^6*s^2*
       SUNN^2*w^4 - 6864*Q2*(omega - s)^7*s^2*SUNN^2*w^4 + 
      1536*Q2^5*(omega - s)^2*s^3*SUNN^2*w^4 - 4480*Q2^4*(omega - s)^3*s^3*
       SUNN^2*w^4 - 19776*Q2^3*(omega - s)^4*s^3*SUNN^2*w^4 + 
      51328*Q2^2*(omega - s)^5*s^3*SUNN^2*w^4 - 12624*Q2*(omega - s)^6*s^3*
       SUNN^2*w^4 + 2688*Q2^4*(omega - s)^2*s^4*SUNN^2*w^4 + 
      816*Q2^3*(omega - s)^3*s^4*SUNN^2*w^4 + 39072*Q2^2*(omega - s)^4*s^4*
       SUNN^2*w^4 - 14480*Q2*(omega - s)^5*s^4*SUNN^2*w^4 + 
      576*Q2^4*(omega - s)*s^5*SUNN^2*w^4 + 5280*Q2^3*(omega - s)^2*s^5*
       SUNN^2*w^4 + 16512*Q2^2*(omega - s)^3*s^5*SUNN^2*w^4 - 
      10608*Q2*(omega - s)^4*s^5*SUNN^2*w^4 + 1104*Q2^3*(omega - s)*s^6*
       SUNN^2*w^4 + 3680*Q2^2*(omega - s)^2*s^6*SUNN^2*w^4 - 
      4848*Q2*(omega - s)^3*s^6*SUNN^2*w^4 + 384*Q2^2*(omega - s)*s^7*SUNN^2*
       w^4 - 1264*Q2*(omega - s)^2*s^7*SUNN^2*w^4 - 144*Q2*(omega - s)*s^8*
       SUNN^2*w^4 - 1024*Q2^6*(omega - s)^3*w^5 - 2048*Q2^5*(omega - s)^4*
       w^5 + 1856*Q2^4*(omega - s)^5*w^5 + 2304*Q2^3*(omega - s)^6*w^5 - 
      1120*Q2^2*(omega - s)^7*w^5 + 64*Q2*(omega - s)^8*w^5 - 
      5376*Q2^5*(omega - s)^3*s*w^5 + 4096*Q2^4*(omega - s)^4*s*w^5 + 
      10752*Q2^3*(omega - s)^5*s*w^5 - 6144*Q2^2*(omega - s)^6*s*w^5 + 
      432*Q2*(omega - s)^7*s*w^5 + 512*Q2^5*(omega - s)^2*s^2*w^5 + 
      2944*Q2^4*(omega - s)^3*s^2*w^5 + 16896*Q2^3*(omega - s)^4*s^2*w^5 - 
      13920*Q2^2*(omega - s)^5*s^2*w^5 + 1248*Q2*(omega - s)^6*s^2*w^5 + 
      768*Q2^5*(omega - s)*s^3*w^5 + 5120*Q2^4*(omega - s)^2*s^3*w^5 + 
      10752*Q2^3*(omega - s)^3*s^3*w^5 - 16640*Q2^2*(omega - s)^4*s^3*w^5 + 
      2000*Q2*(omega - s)^5*s^3*w^5 + 1344*Q2^4*(omega - s)*s^4*w^5 + 
      2304*Q2^3*(omega - s)^2*s^4*w^5 - 11040*Q2^2*(omega - s)^3*s^4*w^5 + 
      1920*Q2*(omega - s)^4*s^4*w^5 - 3840*Q2^2*(omega - s)^2*s^5*w^5 + 
      1104*Q2*(omega - s)^3*s^5*w^5 - 544*Q2^2*(omega - s)*s^6*w^5 + 
      352*Q2*(omega - s)^2*s^6*w^5 + 48*Q2*(omega - s)*s^7*w^5 - 
      1024*Q2^6*(omega - s)^3*SUNN^2*w^5 - 5632*Q2^5*(omega - s)^4*SUNN^2*
       w^5 + 2496*Q2^4*(omega - s)^5*SUNN^2*w^5 + 7296*Q2^3*(omega - s)^6*
       SUNN^2*w^5 - 3360*Q2^2*(omega - s)^7*SUNN^2*w^5 + 
      192*Q2*(omega - s)^8*SUNN^2*w^5 + 2048*Q2^6*(omega - s)^2*s*SUNN^2*
       w^5 - 14080*Q2^5*(omega - s)^3*s*SUNN^2*w^5 - 
      2560*Q2^4*(omega - s)^4*s*SUNN^2*w^5 + 33024*Q2^3*(omega - s)^5*s*
       SUNN^2*w^5 - 18048*Q2^2*(omega - s)^6*s*SUNN^2*w^5 + 
      1296*Q2*(omega - s)^7*s*SUNN^2*w^5 + 4096*Q2^5*(omega - s)^2*s^2*SUNN^2*
       w^5 + 4736*Q2^4*(omega - s)^3*s^2*SUNN^2*w^5 + 
      48384*Q2^3*(omega - s)^4*s^2*SUNN^2*w^5 - 40224*Q2^2*(omega - s)^5*s^2*
       SUNN^2*w^5 + 3744*Q2*(omega - s)^6*s^2*SUNN^2*w^5 + 
      2304*Q2^5*(omega - s)*s^3*SUNN^2*w^5 + 12800*Q2^4*(omega - s)^2*s^3*
       SUNN^2*w^5 + 26880*Q2^3*(omega - s)^3*s^3*SUNN^2*w^5 - 
      47616*Q2^2*(omega - s)^4*s^3*SUNN^2*w^5 + 6000*Q2*(omega - s)^5*s^3*
       SUNN^2*w^5 + 4032*Q2^4*(omega - s)*s^4*SUNN^2*w^5 + 
      4224*Q2^3*(omega - s)^2*s^4*SUNN^2*w^5 - 31584*Q2^2*(omega - s)^3*s^4*
       SUNN^2*w^5 + 5760*Q2*(omega - s)^4*s^4*SUNN^2*w^5 - 
      11136*Q2^2*(omega - s)^2*s^5*SUNN^2*w^5 + 3312*Q2*(omega - s)^3*s^5*
       SUNN^2*w^5 - 1632*Q2^2*(omega - s)*s^6*SUNN^2*w^5 + 
      1056*Q2*(omega - s)^2*s^6*SUNN^2*w^5 + 144*Q2*(omega - s)*s^7*SUNN^2*
       w^5 + 3328*Q2^5*(omega - s)^3*w^6 + 1024*Q2^4*(omega - s)^4*w^6 - 
      4224*Q2^3*(omega - s)^5*w^6 + 768*Q2^2*(omega - s)^6*w^6 - 
      16*Q2*(omega - s)^7*w^6 + 1024*Q2^6*(omega - s)*s*w^6 + 
      3584*Q2^5*(omega - s)^2*s*w^6 + 2048*Q2^4*(omega - s)^3*s*w^6 - 
      14592*Q2^3*(omega - s)^4*s*w^6 + 3648*Q2^2*(omega - s)^5*s*w^6 - 
      96*Q2*(omega - s)^6*s*w^6 + 1280*Q2^5*(omega - s)*s^2*w^6 - 
      3072*Q2^4*(omega - s)^2*s^2*w^6 - 18432*Q2^3*(omega - s)^3*s^2*w^6 + 
      6912*Q2^2*(omega - s)^4*s^2*w^6 - 240*Q2*(omega - s)^5*s^2*w^6 - 
      2048*Q2^4*(omega - s)*s^3*w^6 - 9984*Q2^3*(omega - s)^2*s^3*w^6 + 
      6528*Q2^2*(omega - s)^3*s^3*w^6 - 320*Q2*(omega - s)^4*s^3*w^6 - 
      1920*Q2^3*(omega - s)*s^4*w^6 + 3072*Q2^2*(omega - s)^2*s^4*w^6 - 
      240*Q2*(omega - s)^3*s^4*w^6 + 576*Q2^2*(omega - s)*s^5*w^6 - 
      96*Q2*(omega - s)^2*s^5*w^6 - 16*Q2*(omega - s)*s^6*w^6 - 
      2048*Q2^6*(omega - s)^2*SUNN^2*w^6 + 5888*Q2^5*(omega - s)^3*SUNN^2*
       w^6 + 4608*Q2^4*(omega - s)^4*SUNN^2*w^6 - 12672*Q2^3*(omega - s)^5*
       SUNN^2*w^6 + 2304*Q2^2*(omega - s)^6*SUNN^2*w^6 - 
      48*Q2*(omega - s)^7*SUNN^2*w^6 + 3072*Q2^6*(omega - s)*s*SUNN^2*w^6 + 
      4608*Q2^5*(omega - s)^2*s*SUNN^2*w^6 + 8192*Q2^4*(omega - s)^3*s*SUNN^2*
       w^6 - 42240*Q2^3*(omega - s)^4*s*SUNN^2*w^6 + 10944*Q2^2*(omega - s)^5*
       s*SUNN^2*w^6 - 288*Q2*(omega - s)^6*s*SUNN^2*w^6 + 
      3840*Q2^5*(omega - s)*s^2*SUNN^2*w^6 - 11776*Q2^4*(omega - s)^2*s^2*
       SUNN^2*w^6 - 52224*Q2^3*(omega - s)^3*s^2*SUNN^2*w^6 + 
      20736*Q2^2*(omega - s)^4*s^2*SUNN^2*w^6 - 720*Q2*(omega - s)^5*s^2*
       SUNN^2*w^6 - 6144*Q2^4*(omega - s)*s^3*SUNN^2*w^6 - 
      28416*Q2^3*(omega - s)^2*s^3*SUNN^2*w^6 + 19584*Q2^2*(omega - s)^3*s^3*
       SUNN^2*w^6 - 960*Q2*(omega - s)^4*s^3*SUNN^2*w^6 - 
      5760*Q2^3*(omega - s)*s^4*SUNN^2*w^6 + 9216*Q2^2*(omega - s)^2*s^4*
       SUNN^2*w^6 - 720*Q2*(omega - s)^3*s^4*SUNN^2*w^6 + 
      1728*Q2^2*(omega - s)*s^5*SUNN^2*w^6 - 288*Q2*(omega - s)^2*s^5*SUNN^2*
       w^6 - 48*Q2*(omega - s)*s^6*SUNN^2*w^6 - 1024*Q2^6*(omega - s)*w^7 - 
      4096*Q2^5*(omega - s)^2*w^7 - 4608*Q2^4*(omega - s)^3*w^7 + 
      3072*Q2^3*(omega - s)^4*w^7 - 192*Q2^2*(omega - s)^5*w^7 - 
      4096*Q2^5*(omega - s)*s*w^7 - 6144*Q2^4*(omega - s)^2*s*w^7 + 
      8448*Q2^3*(omega - s)^3*s*w^7 - 768*Q2^2*(omega - s)^4*s*w^7 - 
      1536*Q2^4*(omega - s)*s^2*w^7 + 7680*Q2^3*(omega - s)^2*s^2*w^7 - 
      1152*Q2^2*(omega - s)^3*s^2*w^7 + 2304*Q2^3*(omega - s)*s^3*w^7 - 
      768*Q2^2*(omega - s)^2*s^3*w^7 - 192*Q2^2*(omega - s)*s^4*w^7 - 
      3072*Q2^6*(omega - s)*SUNN^2*w^7 - 10240*Q2^5*(omega - s)^2*SUNN^2*
       w^7 - 13824*Q2^4*(omega - s)^3*SUNN^2*w^7 + 9216*Q2^3*(omega - s)^4*
       SUNN^2*w^7 - 576*Q2^2*(omega - s)^5*SUNN^2*w^7 - 
      12288*Q2^5*(omega - s)*s*SUNN^2*w^7 - 16384*Q2^4*(omega - s)^2*s*SUNN^2*
       w^7 + 25344*Q2^3*(omega - s)^3*s*SUNN^2*w^7 - 
      2304*Q2^2*(omega - s)^4*s*SUNN^2*w^7 - 4608*Q2^4*(omega - s)*s^2*SUNN^2*
       w^7 + 23040*Q2^3*(omega - s)^2*s^2*SUNN^2*w^7 - 
      3456*Q2^2*(omega - s)^3*s^2*SUNN^2*w^7 + 6912*Q2^3*(omega - s)*s^3*
       SUNN^2*w^7 - 2304*Q2^2*(omega - s)^2*s^3*SUNN^2*w^7 - 
      576*Q2^2*(omega - s)*s^4*SUNN^2*w^7 + 2048*Q2^5*(omega - s)*w^8 + 
      4096*Q2^4*(omega - s)^2*w^8 - 768*Q2^3*(omega - s)^3*w^8 + 
      3072*Q2^4*(omega - s)*s*w^8 - 1536*Q2^3*(omega - s)^2*s*w^8 - 
      768*Q2^3*(omega - s)*s^2*w^8 + 6144*Q2^5*(omega - s)*SUNN^2*w^8 + 
      12288*Q2^4*(omega - s)^2*SUNN^2*w^8 - 2304*Q2^3*(omega - s)^3*SUNN^2*
       w^8 + 9216*Q2^4*(omega - s)*s*SUNN^2*w^8 - 4608*Q2^3*(omega - s)^2*s*
       SUNN^2*w^8 - 2304*Q2^3*(omega - s)*s^2*SUNN^2*w^8 - 
      1024*Q2^4*(omega - s)*w^9 - 3072*Q2^4*(omega - s)*SUNN^2*w^9)*
     (-1/32*Pi + (-2*Pi + EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w])/32))/
    (Q2*(omega - s)^3*SUNN*(omega + Q2 - w)*(omega - s - w)*(s - w)*w*
     ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)^3) + 
   (SUNN*(4*(omega - s)^2*s + Q2*(omega - s)*w - 5*(omega - s)*s*w + 2*s*w^2)*
     (-Pi + EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
      Pi*Log[((s - w)*(-omega + s + w))/((omega + Q2 - w)*w)]))/
    ((omega - s)*(omega - s - w)*w) + ((omega - s)*s + Q2*w)*
    (Q2*(omega - s)^2*s + (omega - s)^2*s^2 - Q2*(omega - s)^2*w + 
     Q2^2*(omega - s)*SUNN^2*w + Q2*(omega - s)^2*SUNN^2*w + 
     Q2*(omega - s)*s*SUNN^2*w + Q2*(omega - s)*w^2 - Q2*s*w^2 - 
     (omega - s)*s*w^2 - s^2*w^2 - Q2*(omega - s)*SUNN^2*w^2 + 
     Q2*s*SUNN^2*w^2 + (omega - s)*s*SUNN^2*w^2 + s^2*SUNN^2*w^2 + s*w^3 - 
     s*SUNN^2*w^3)*((Pi*(-2*(omega - s) + 2*w))/(2*(omega - s)*(Q2 + s)*SUNN*
       (omega + Q2 - w)*(omega - s - w)*w*((omega - s)*s + Q2*w)) + 
     (2*(Pi/(2*((omega - s)*s + Q2*w)) - (EulerGamma*Pi + Pi*Log[Pi] + 
          Pi*Log[w] - Pi*Log[-(((s - w)*(-omega + s + w))/((omega - s)*s + Q2*
                w))])/(2*((omega - s)*s + Q2*w))))/((omega - s)*(Q2 + s)*SUNN*
       (omega - s - w)*w)) + (SUNN*(omega + Q2 - w)*
     (-2*(omega - s)^5*s - 5*Q2*(omega - s)^4*w + 4*(omega - s)^5*w + 
      13*(omega - s)^4*s*w + 16*Q2*(omega - s)^3*w^2 - 12*(omega - s)^4*w^2 - 
      24*(omega - s)^3*s*w^2 - 20*Q2*(omega - s)^2*w^3 + 
      12*(omega - s)^3*w^3 + 20*(omega - s)^2*s*w^3 + 16*Q2*(omega - s)*w^4 - 
      4*(omega - s)^2*w^4 - 8*(omega - s)*s*w^4 - 8*Q2*w^5)*
     (Pi/(2*(omega - s)*(omega + Q2 - w)) + 
      (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
        Pi*Log[((omega + 2*Q2)^2*(omega - s - w)^2*
            (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
               (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*
                 s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/(4*(omega - s)^2*
            (omega + Q2 - w)^2)])/(2*(omega - s)*(omega + Q2 - w))))/
    ((omega - s)^3*(omega - s - w)*w) + 
   (2*s*(omega + Q2 - w)*(Q2*(omega - s)*s + (omega - s)*s^2 - 
      Q2*(omega - s)*w - Q2*s*w - 2*(omega - s)*s*w - s^2*w + 
      Q2*(omega - s)*SUNN^2*w + 2*(omega - s)*s*SUNN^2*w + s*w^2 - 
      s*SUNN^2*w^2)*(Pi/(4*s*(omega + Q2 - w)) + 
      (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
        Pi*Log[((omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[((omega - s)^2 + 
                2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2])*
            (1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
               (omega + 2*Q2)^2]))/(4*s^2*(omega + Q2 - w)^2)])/
       (4*s*(omega + Q2 - w))))/((omega - s)*(Q2 + s)*SUNN*w) + 
   (Q2*(omega - s) - 2*Q2*w - s*w)^2*(-omega + s + Q2*SUNN^2 + 
     (omega - s)*SUNN^2 + s*SUNN^2 + w - SUNN^2*w)*
    (-1/4*(Pi*(-2*(omega - s) + 2*w))/((omega - s)*(Q2 + s)*SUNN*
        (omega + Q2 - w)*(omega - s - w)*(Q2*(omega - s) - 2*Q2*w - s*w)) + 
     (2*(-1/4*Pi/(Q2*(omega - s) - 2*Q2*w - s*w) - 
        (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
          Pi*Log[((omega + 2*Q2)^2*(omega - s - w)^2*(1 - Sqrt[
                ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                 (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*
                   s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
             (4*(Q2*(omega - s) - 2*Q2*w - s*w)^2)])/
         (4*(Q2*(omega - s) - 2*Q2*w - s*w))))/((omega - s)*(Q2 + s)*SUNN*
       (omega - s - w))), "SoftCoefficients" -> 
  {{1, -1, (Pi*(-4 - 7*eps - 14*eps^2 + 4*eps*EulerGamma + 
        7*eps^2*EulerGamma - 2*eps^2*EulerGamma^2 + eps^2*Pi^2)*s*(-1 + SUNN)*
       (1 + SUNN))/(2*eps*SUNN) - (eps*Pi*s*(-1 + SUNN)*(1 + SUNN)*Log[Pi]^2)/
      SUNN + Log[Pi]*(-1/2*(Pi*s*(3*omega + 7*eps*omega - 3*eps*EulerGamma*
            omega + eps*Q2 - 3*s - 6*eps*s + 3*eps*EulerGamma*s - 
           2*omega*SUNN^2 - 5*eps*omega*SUNN^2 + 2*eps*EulerGamma*omega*
            SUNN^2 + 2*s*SUNN^2 + 5*eps*s*SUNN^2 - 2*eps*EulerGamma*s*
            SUNN^2))/((omega - s)*SUNN) - eps*Pi*s*SUNN*
        Log[Q2/(omega + Q2)]) + Log[Q2/(omega + Q2)]*
      (-1/2*(Pi*s*(omega - eps*EulerGamma*omega - eps*Q2 - s - eps*s + 
           eps*EulerGamma*s - 2*omega*SUNN^2 - 2*eps*omega*SUNN^2 + 
           2*eps*EulerGamma*omega*SUNN^2 + 2*s*SUNN^2 + 2*eps*s*SUNN^2 - 
           2*eps*EulerGamma*s*SUNN^2 + eps*omega*ArcTanh[
             omega/(omega + 2*Q2)] - eps*s*ArcTanh[omega/(omega + 2*Q2)]))/
         ((omega - s)*SUNN) - (eps*Pi*s*SUNN*Log[Q2/(Pi^2*(omega + Q2))])/2 + 
       (eps*Pi*s*(-1 + 2*SUNN^2)*Log[(omega + Q2)/Q2])/(4*SUNN)) - 
     (Pi*s*(omega - eps*EulerGamma*omega - eps*Q2 - s - eps*s + 
        eps*EulerGamma*s - 2*omega*SUNN^2 - 2*eps*omega*SUNN^2 + 
        2*eps*EulerGamma*omega*SUNN^2 + 2*s*SUNN^2 + 2*eps*s*SUNN^2 - 
        2*eps*EulerGamma*s*SUNN^2)*Log[(Pi*(omega + Q2))/Q2])/
      (2*(omega - s)*SUNN) - (eps*Pi*s*(-1 + 2*SUNN^2)*
       PolyLog[2, -(omega/Q2)])/SUNN - (eps*Pi*s*(-1 + 2*SUNN^2)*
       PolyLog[2, omega/(omega + Q2)])/SUNN}, 
   {2, -1, (Pi*(-12 - 12*eps - 12*eps^2 + 12*eps*EulerGamma + 
        12*eps^2*EulerGamma - 6*eps^2*EulerGamma^2 + eps^2*Pi^2)*s*SUNN)/
      (3*eps) - 2*eps*Pi*s*SUNN*Log[Pi]^2 - 4*(-1 - eps + eps*EulerGamma)*Pi*
      s*SUNN*Log[-((omega + Q2)/(omega*s - s^2))] - 
     2*eps*Pi*s*SUNN*Log[-((omega + Q2)/(omega*s - s^2))]^2 + 
     Log[Pi]*(-4*(-1 - eps + eps*EulerGamma)*Pi*s*SUNN - 
       4*eps*Pi*s*SUNN*Log[-((omega + Q2)/(omega*s - s^2))])}}, 
 "Assumptions" -> Q2 > 0 && s > 0 && omega > 0 && B > 0 && 
   -Q2 - s < omega - s < 0 && SUNN > 1 && Nc > 1|>
