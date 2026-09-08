<|"Definition" -> <|"Channel" -> "Hgq", "Label" -> "Ppp_1_L0", 
   "Left" -> (alphaS^2*eq^2*(((104*s)/3 + (104*s*(-EulerGamma + Log[4*Pi]))/
          3)/(8*Pi) + (-128*s + 104*EulerGamma*s + 176*s*Log[B] - 
         208*s*Log[mu] + 87*s*Log[Pi] - 208*s*Log[2*Pi] + 
         17*s*Log[Q^2/(omega + Q^2)] + 17*s*Log[(Pi*(omega + Q^2))/Q^2] + 
         72*s*Log[-((omega + Q^2)/(omega*s - s^2))])/(24*Pi)))/Pi^2, 
   "Right" -> 16*alphaS^2*Pi^2*
     ((eq^2*(352*Q^4*(omega - s)^5*s^4 + (omega - s)*s*
          (352*(omega - s)^6*s^3 + 704*(omega - s)^5*s^4 + 
           352*(omega - s)^4*s^5) - Q^2*(-704*(omega - s)^6*s^4 - 
           704*(omega - s)^5*s^5))*Log[B])/(768*Pi^5*(omega + Q^2)^2*
        (omega - s)^3*s^3*(-omega + s)^2) + 
      eq^2*((Q^6*(-48*(omega - s)^9*s^4 - 192*(omega - s)^8*s^5 - 
            288*(omega - s)^7*s^6 - 192*(omega - s)^6*s^7 - 
            48*(omega - s)^5*s^8) - omega*Q^2*(omega - s)*
           (48*(omega - s)^9*s^4 + 240*(omega - s)^8*s^5 + 480*(omega - s)^7*
             s^6 + 480*(omega - s)^6*s^7 + 240*(omega - s)^5*s^8 + 
            48*(omega - s)^4*s^9) + Q^4*(-96*(omega - s)^10*s^4 - 
            480*(omega - s)^9*s^5 - 960*(omega - s)^8*s^6 - 
            960*(omega - s)^7*s^7 - 480*(omega - s)^6*s^8 - 
            96*(omega - s)^5*s^9))/(768*Pi^5*Q^2*(omega + Q^2)^2*
          (omega - s)^3*s^3*(-omega + s)^2*((omega - s)^2 + 2*(omega - s)*s + 
            s^2)^2) + ((-208*Q^4*(omega - s)^5*s^4 - (omega - s)*s*
            (208*(omega - s)^6*s^3 + 416*(omega - s)^5*s^4 + 
             208*(omega - s)^4*s^5) + Q^2*(-416*(omega - s)^6*s^4 - 
             416*(omega - s)^5*s^5))*Log[2])/(384*Pi^5*(omega + Q^2)^2*
          (omega - s)^3*s^3*(-omega + s)^2) + 
        ((-208*Q^4*(omega - s)^5*s^4 - (omega - s)*s*(208*(omega - s)^6*s^3 + 
             416*(omega - s)^5*s^4 + 208*(omega - s)^4*s^5) + 
           Q^2*(-416*(omega - s)^6*s^4 - 416*(omega - s)^5*s^5))*Log[mu])/
         (384*Pi^5*(omega + Q^2)^2*(omega - s)^3*s^3*(-omega + s)^2) + 
        ((-208*Q^4*(omega - s)^5*s^4 - (omega - s)*s*(208*(omega - s)^6*s^3 + 
             416*(omega - s)^5*s^4 + 208*(omega - s)^4*s^5) + 
           Q^2*(-416*(omega - s)^6*s^4 - 416*(omega - s)^5*s^5))*Log[Pi])/
         (768*Pi^5*(omega + Q^2)^2*(omega - s)^3*s^3*(-omega + s)^2) + 
        (13*s*Log[4*Pi])/(48*Pi^5) - (17*s*Log[Q^2/(omega + Q^2)])/
         (384*Pi^5) + ((Q^6*(20*(omega - s)^5 + 80*(omega - s)^4*s + 
             120*(omega - s)^3*s^2 + 80*(omega - s)^2*s^3 + 
             20*(omega - s)*s^4) + omega^2*(27*(omega - s)^6 + 
             74*(omega - s)^5*s + 42*(omega - s)^4*s^2 - 46*(omega - s)^3*
              s^3 - 55*(omega - s)^2*s^4 - 12*(omega - s)*s^5 + 2*s^6) + 
           Q^4*(49*(omega - s)^6 + 200*(omega - s)^5*s + 312*(omega - s)^4*
              s^2 + 228*(omega - s)^3*s^3 + 77*(omega - s)^2*s^4 + 
             12*(omega - s)*s^5 + 2*s^6) + Q^2*(56*(omega - s)^7 + 
             230*(omega - s)^6*s + 328*(omega - s)^5*s^2 + 136*(omega - s)^4*
              s^3 - 96*(omega - s)^3*s^4 - 98*(omega - s)^2*s^5 - 
             16*(omega - s)*s^6 + 4*s^7))*Log[Q^2/(omega + Q^2)])/
         (768*omega^5*Pi^5*(omega + Q^2)*(omega - s)) + 
        ((20*Q^6*(omega - s) + 27*(omega - s)^4 - 14*(omega - s)^3*s - 
           93*(omega - s)^2*s^2 - 50*(omega - s)*s^3 + 2*s^4 + 
           Q^4*(49*(omega - s)^2 + 4*(omega - s)*s + 2*s^2) + 
           Q^2*(56*(omega - s)^3 - 28*(omega - s)^2*s - 66*(omega - s)*s^2 + 
             4*s^3))*Log[(omega + Q^2)/Q^2])/(768*omega*Pi^5*(omega + Q^2)*
          (omega - s)) - (3*(omega - s)*s*
          Log[-((omega + Q^2)/((omega - s)*s))])/(16*Pi^5*(-omega + s)))), 
   "Assumptions" -> Q^2 > 0 && s > 0 && -Q^2 - s < omega - s && 
     omega - s < 0 && mu > 0 && B > 0 && Q > 0 && omega > 0 && 
     Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
     Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
   "Kind" -> "L0"|>, "Difference" -> 
  -16*alphaS^2*Pi^2*((eq^2*(352*Q^4*(omega - s)^5*s^4 + 
        (omega - s)*s*(352*(omega - s)^6*s^3 + 704*(omega - s)^5*s^4 + 
          352*(omega - s)^4*s^5) - Q^2*(-704*(omega - s)^6*s^4 - 
          704*(omega - s)^5*s^5))*Log[B])/(768*Pi^5*(omega + Q^2)^2*
       (omega - s)^3*s^3*(-omega + s)^2) + 
     eq^2*((Q^6*(-48*(omega - s)^9*s^4 - 192*(omega - s)^8*s^5 - 
           288*(omega - s)^7*s^6 - 192*(omega - s)^6*s^7 - 
           48*(omega - s)^5*s^8) - omega*Q^2*(omega - s)*
          (48*(omega - s)^9*s^4 + 240*(omega - s)^8*s^5 + 480*(omega - s)^7*
            s^6 + 480*(omega - s)^6*s^7 + 240*(omega - s)^5*s^8 + 
           48*(omega - s)^4*s^9) + Q^4*(-96*(omega - s)^10*s^4 - 
           480*(omega - s)^9*s^5 - 960*(omega - s)^8*s^6 - 
           960*(omega - s)^7*s^7 - 480*(omega - s)^6*s^8 - 
           96*(omega - s)^5*s^9))/(768*Pi^5*Q^2*(omega + Q^2)^2*(omega - s)^3*
         s^3*(-omega + s)^2*((omega - s)^2 + 2*(omega - s)*s + s^2)^2) + 
       ((-208*Q^4*(omega - s)^5*s^4 - (omega - s)*s*(208*(omega - s)^6*s^3 + 
            416*(omega - s)^5*s^4 + 208*(omega - s)^4*s^5) + 
          Q^2*(-416*(omega - s)^6*s^4 - 416*(omega - s)^5*s^5))*Log[2])/
        (384*Pi^5*(omega + Q^2)^2*(omega - s)^3*s^3*(-omega + s)^2) + 
       ((-208*Q^4*(omega - s)^5*s^4 - (omega - s)*s*(208*(omega - s)^6*s^3 + 
            416*(omega - s)^5*s^4 + 208*(omega - s)^4*s^5) + 
          Q^2*(-416*(omega - s)^6*s^4 - 416*(omega - s)^5*s^5))*Log[mu])/
        (384*Pi^5*(omega + Q^2)^2*(omega - s)^3*s^3*(-omega + s)^2) + 
       ((-208*Q^4*(omega - s)^5*s^4 - (omega - s)*s*(208*(omega - s)^6*s^3 + 
            416*(omega - s)^5*s^4 + 208*(omega - s)^4*s^5) + 
          Q^2*(-416*(omega - s)^6*s^4 - 416*(omega - s)^5*s^5))*Log[Pi])/
        (768*Pi^5*(omega + Q^2)^2*(omega - s)^3*s^3*(-omega + s)^2) + 
       (13*s*Log[4*Pi])/(48*Pi^5) - (17*s*Log[Q^2/(omega + Q^2)])/
        (384*Pi^5) + ((Q^6*(20*(omega - s)^5 + 80*(omega - s)^4*s + 
            120*(omega - s)^3*s^2 + 80*(omega - s)^2*s^3 + 
            20*(omega - s)*s^4) + omega^2*(27*(omega - s)^6 + 
            74*(omega - s)^5*s + 42*(omega - s)^4*s^2 - 46*(omega - s)^3*
             s^3 - 55*(omega - s)^2*s^4 - 12*(omega - s)*s^5 + 2*s^6) + 
          Q^4*(49*(omega - s)^6 + 200*(omega - s)^5*s + 312*(omega - s)^4*
             s^2 + 228*(omega - s)^3*s^3 + 77*(omega - s)^2*s^4 + 
            12*(omega - s)*s^5 + 2*s^6) + Q^2*(56*(omega - s)^7 + 
            230*(omega - s)^6*s + 328*(omega - s)^5*s^2 + 136*(omega - s)^4*
             s^3 - 96*(omega - s)^3*s^4 - 98*(omega - s)^2*s^5 - 
            16*(omega - s)*s^6 + 4*s^7))*Log[Q^2/(omega + Q^2)])/
        (768*omega^5*Pi^5*(omega + Q^2)*(omega - s)) + 
       ((20*Q^6*(omega - s) + 27*(omega - s)^4 - 14*(omega - s)^3*s - 
          93*(omega - s)^2*s^2 - 50*(omega - s)*s^3 + 2*s^4 + 
          Q^4*(49*(omega - s)^2 + 4*(omega - s)*s + 2*s^2) + 
          Q^2*(56*(omega - s)^3 - 28*(omega - s)^2*s - 66*(omega - s)*s^2 + 
            4*s^3))*Log[(omega + Q^2)/Q^2])/(768*omega*Pi^5*(omega + Q^2)*
         (omega - s)) - (3*(omega - s)*s*
         Log[-((omega + Q^2)/((omega - s)*s))])/(16*Pi^5*(-omega + s)))) + 
   (alphaS^2*eq^2*(((104*s)/3 + (104*s*(-EulerGamma + Log[4*Pi]))/3)/(8*Pi) + 
      (-128*s + 104*EulerGamma*s + 176*s*Log[B] - 208*s*Log[mu] + 
        87*s*Log[Pi] - 208*s*Log[2*Pi] + 17*s*Log[Q^2/(omega + Q^2)] + 
        17*s*Log[(Pi*(omega + Q^2))/Q^2] + 
        72*s*Log[-((omega + Q^2)/(omega*s - s^2))])/(24*Pi)))/Pi^2, 
 "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.080897412248932244468563518659324048556948\
8738775618375012420185209810884113454753810869113367563435684930293952453`88.\
95730502923547, -0.0808974122489322444685635186593240485569488738775618375012\
42018520981088411345475381086911336759`83.89956993344896}, 
    "Difference" -> 0``84.99163150154314, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.074506215003916624141391700407712107617824\
2842443772366643856537325580522866966216779341268727749758446363085237239`88.\
93691060731639, -0.0745062150039166241413917004077121076178242842443772366643\
85653732558052286696621677934126872771`83.97954725654077}, 
    "Difference" -> 0``85.1073499642948, "Equal" -> True|>}, 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183|>
