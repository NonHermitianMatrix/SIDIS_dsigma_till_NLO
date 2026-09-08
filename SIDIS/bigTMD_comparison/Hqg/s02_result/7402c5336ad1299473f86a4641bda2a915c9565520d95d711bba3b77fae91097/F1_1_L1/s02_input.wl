<|"Definition" -> <|"Channel" -> "Hqg", "Label" -> "F1_1_L1", 
   "Left" -> (alphaS^2*eq^2*((Q^2*(-352*omega + 352*s))/(18*Pi*(Q^2 + s)^2) - 
       (-352*omega^2 - 352*Q^4 - 704*Q^2*s - 352*s^2)/(36*Pi*(omega + Q^2)*
         s)))/Pi^2, "Right" -> 16*alphaS^2*eq^2*Pi^2*
     (-1/288*(-176*Q^6*(omega - s)^5*s^5 - (omega - s)^3*s^2*
          (176*(omega - s)^5*s^3 + 528*(omega - s)^4*s^4 + 
           704*(omega - s)^3*s^5 + 352*(omega - s)^2*s^6) + 
         Q^2*(omega - s)*s*(-176*(omega - s)^6*s^4 - 704*(omega - s)^5*s^5 - 
           704*(omega - s)^4*s^6) + Q^4*(-176*(omega - s)^6*s^5 - 
           528*(omega - s)^5*s^6))/(Pi^5*(omega + Q^2)^2*(omega - s)^5*s^6) - 
      (Q^2*(176*Q^4*(omega - s)^5*s^6 + (omega - s)*s^2*
          (176*(omega - s)^6*s^4 + 352*(omega - s)^5*s^5 + 
           176*(omega - s)^4*s^6) + Q^2*s*(352*(omega - s)^6*s^5 + 
           352*(omega - s)^5*s^6)))/(144*Pi^5*(omega + Q^2)^2*(omega - s)^4*
        s^6*(Q^2 + s)^2)), "Assumptions" -> Q > 0 && mu > 0 && s > 0 && 
     omega - s < 0 && omega + Q^2 > 0 && (omega - s)*s < 0 && B > 0 && 
     omega != 0 && Element[nf, Integers] && nf >= 0 && alphaS > 0 && 
     Element[eq, Reals] && omega > 0, "Kind" -> "L1", 
   "ReferenceFile" -> "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/b\
igTMD_comparison/Hqg/s01_result/reference/F1_1_L1.wl"|>, 
 "Difference" -> 
  (alphaS^2*eq^2*((Q^2*(-352*omega + 352*s))/(18*Pi*(Q^2 + s)^2) - 
      (-352*omega^2 - 352*Q^4 - 704*Q^2*s - 352*s^2)/(36*Pi*(omega + Q^2)*
        s)))/Pi^2 - 16*alphaS^2*eq^2*Pi^2*
    (-1/288*(-176*Q^6*(omega - s)^5*s^5 - (omega - s)^3*s^2*
         (176*(omega - s)^5*s^3 + 528*(omega - s)^4*s^4 + 
          704*(omega - s)^3*s^5 + 352*(omega - s)^2*s^6) + 
        Q^2*(omega - s)*s*(-176*(omega - s)^6*s^4 - 704*(omega - s)^5*s^5 - 
          704*(omega - s)^4*s^6) + Q^4*(-176*(omega - s)^6*s^5 - 
          528*(omega - s)^5*s^6))/(Pi^5*(omega + Q^2)^2*(omega - s)^5*s^6) - 
     (Q^2*(176*Q^4*(omega - s)^5*s^6 + (omega - s)*s^2*
         (176*(omega - s)^6*s^4 + 352*(omega - s)^5*s^5 + 
          176*(omega - s)^4*s^6) + Q^2*s*(352*(omega - s)^6*s^5 + 
          352*(omega - s)^5*s^6)))/(144*Pi^5*(omega + Q^2)^2*(omega - s)^4*
       s^6*(Q^2 + s)^2)), "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0241478167581740653455980820462361778209834\
779541942701155100835310562113679603803852066044796858486060140362363986`89.0\
2665117374534, 0.024147816758174065345598082046236177820983477954194270115510\
0835310562113679603803852066044796858486066102035329913`87.80121577291135}, 
    "Difference" -> 0``89.3932342650805, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0228848707592529043535113425105321965987904\
717717383969684389066345674561583000037649946047582400146130731377611159`89.0\
1474023157975, 0.022884870759252904353511342510532196598790471771738396968438\
9066345674561583000037649946047582400146132788751891657`87.95191850786932}, 
    "Difference" -> 0``89.55632740005456, "Equal" -> True|>}, 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183|>
