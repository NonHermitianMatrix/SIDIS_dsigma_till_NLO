<|"Schema" -> "polarized-sidis-complete-photon-projection-v1", 
 "Channel" -> "Hqq", "InputHash" -> 70494534012770262048733901266323001845349\
566713282102087519793010348146218749, "InputHashes" -> 
  <|"common/s01_inputs.json" -> 337865893467234260481669136745678692290100808\
75858990786949650904183312832649, "common/s07_inputs.json" -> 
    7475455627839468165669571799838712124208139851840690037624940670158096906\
3830, "Hqq/s01_result/reference/s01_result/s01_inputs/s01_result.wl" -> 
    6236141875823703353348083198367717562914953472407878739034866251836609931\
642, "Hqq/s07_result/reference/unpolarized_virtual.wl" -> 
    4512531563674559489043926648517787861801724524777561287962795925390039048\
680, "common/s07_result/reference/s05_virtual_families.wl" -> 
    8852387741413436851155353096043578091290443756263991046079560017089187693\
6418, "common/s02_result/s02_result.wl" -> 
    8763488122700630353093597572583533003994794907904231568983159969497876529\
341, "common/s04_result/s04_result.wl" -> 
    6832582559442704311260834015700865252638007872011695004391325773511943728\
3507, "Hqq/s03_result/s03_result.wl" -> 
    6959953954755774504871929066409388529754356210072566845157272681927554195\
7068|>, "ProductionSourceHash" -> 
  539707540901890545641310857254532550630586116286721312543964745569597789928\
69, "SourceHash" -> 
  793325979648162829466554676860804492715971715306206752218160330097030728779\
68, "DiagnosticHash" -> 
  577317559045541888650616747966407596771750275150492922447630794338055209349\
53, "ProjectionDefinitions" -> 
  {HoldPattern[completePhotonProject[tensor_, leftAxis_, rightAxis_]] :> 
    (tensor /. {LorentzIndex[mu, D] -> Momentum[leftAxis], 
      LorentzIndex[nu, D] -> Momentum[rightAxis], LorentzIndex[mu] -> 
       Momentum[leftAxis], LorentzIndex[nu] -> Momentum[rightAxis], 
      LorentzIndex[mu, D - 4] -> Momentum[leftAxis, D - 4], 
      LorentzIndex[nu, D - 4] -> Momentum[rightAxis, D - 4]})}, 
 "FailingTask" -> {5, 1, 1}, "CorrectedProjection" -> 
  (I*(-1 + SUNN)*(1 + SUNN)*(-32*loopK*loopP^2*Q^4 + 32*loopP^3*Q^4 - 
      16*loopK*loopP*loopQ*Q^4 + 48*loopP^2*loopQ*Q^4 + 
      16*loopP*loopQ^2*Q^4 + 2*loopK*loopSquare*Q^6 - 
      2*loopP*loopSquare*Q^6 - 2*loopQ*loopSquare*Q^6 - 
      32*loopK*loopP^2*Q^2*s - 32*loopK*loopP*loopQ*Q^2*s + 
      48*loopP^2*loopQ*Q^2*s + 32*loopP*loopQ^2*Q^2*s + 
      6*loopK*loopSquare*Q^4*s - 4*loopP*loopSquare*Q^4*s - 
      6*loopQ*loopSquare*Q^4*s - 16*loopK*loopP*loopQ*s^2 + 
      16*loopP*loopQ^2*s^2 + 6*loopK*loopSquare*Q^2*s^2 - 
      2*loopP*loopSquare*Q^2*s^2 - 6*loopQ*loopSquare*Q^2*s^2 + 
      2*loopK*loopSquare*s^3 - 2*loopQ*loopSquare*s^3 - 
      64*loopK*loopP^2*Q^2*t + 32*loopP^3*Q^2*t - 32*loopK*loopP*loopQ*Q^2*
       t + 48*loopP^2*loopQ*Q^2*t + 16*loopP*loopQ^2*Q^2*t + 
      32*loopK*loopP*Q^4*t - 8*D*loopK*loopP*Q^4*t - 32*loopP^2*Q^4*t + 
      8*D*loopP^2*Q^4*t + 12*loopK*loopQ*Q^4*t - 4*D*loopK*loopQ*Q^4*t - 
      44*loopP*loopQ*Q^4*t + 12*D*loopP*loopQ*Q^4*t - 12*loopQ^2*Q^4*t + 
      4*D*loopQ^2*Q^4*t + 4*loopK*loopSquare*Q^4*t + 
      18*loopP*loopSquare*Q^4*t - 4*D*loopP*loopSquare*Q^4*t + 
      6*loopQ*loopSquare*Q^4*t - 2*D*loopQ*loopSquare*Q^4*t - 2*loopK*Q^6*t + 
      2*loopP*Q^6*t + 2*loopQ*Q^6*t - 32*loopK*loopP*loopQ*s*t + 
      16*loopP^2*loopQ*s*t + 16*loopP*loopQ^2*s*t + 32*loopK*loopP*Q^2*s*t - 
      8*D*loopK*loopP*Q^2*s*t - 48*loopP^2*Q^2*s*t + 8*D*loopP^2*Q^2*s*t + 
      24*loopK*loopQ*Q^2*s*t - 8*D*loopK*loopQ*Q^2*s*t - 
      60*loopP*loopQ*Q^2*s*t + 16*D*loopP*loopQ*Q^2*s*t - 
      24*loopQ^2*Q^2*s*t + 8*D*loopQ^2*Q^2*s*t + 8*loopK*loopSquare*Q^2*s*t + 
      12*loopP*loopSquare*Q^2*s*t - 4*D*loopP*loopSquare*Q^2*s*t + 
      12*loopQ*loopSquare*Q^2*s*t - 4*D*loopQ*loopSquare*Q^2*s*t - 
      4*loopK*Q^4*s*t + 10*loopP*Q^4*s*t - 2*D*loopP*Q^4*s*t + 
      4*loopQ*Q^4*s*t + 4*loopSquare*Q^4*s*t - D*loopSquare*Q^4*s*t + 
      12*loopK*loopQ*s^2*t - 4*D*loopK*loopQ*s^2*t - 16*loopP*loopQ*s^2*t + 
      4*D*loopP*loopQ*s^2*t - 12*loopQ^2*s^2*t + 4*D*loopQ^2*s^2*t + 
      4*loopK*loopSquare*s^2*t - 6*loopP*loopSquare*s^2*t + 
      6*loopQ*loopSquare*s^2*t - 2*D*loopQ*loopSquare*s^2*t - 
      2*loopK*Q^2*s^2*t + 8*loopP*Q^2*s^2*t - 2*D*loopP*Q^2*s^2*t + 
      2*loopQ*Q^2*s^2*t + 8*loopSquare*Q^2*s^2*t - 2*D*loopSquare*Q^2*s^2*t + 
      4*loopSquare*s^3*t - D*loopSquare*s^3*t + 16*loopK*loopP*Q^2*t^2 - 
      8*D*loopK*loopP*Q^2*t^2 - 32*loopP^2*Q^2*t^2 + 8*D*loopP^2*Q^2*t^2 + 
      8*loopK*loopQ*Q^2*t^2 - 4*D*loopK*loopQ*Q^2*t^2 - 
      44*loopP*loopQ*Q^2*t^2 + 12*D*loopP*loopQ*Q^2*t^2 - 
      12*loopQ^2*Q^2*t^2 + 4*D*loopQ^2*Q^2*t^2 + 20*loopP*loopSquare*Q^2*
       t^2 - 4*D*loopP*loopSquare*Q^2*t^2 + 8*loopQ*loopSquare*Q^2*t^2 - 
      2*D*loopQ*loopSquare*Q^2*t^2 + 6*loopP*Q^4*t^2 - 2*D*loopP*Q^4*t^2 + 
      6*loopQ*Q^4*t^2 - 2*D*loopQ*Q^4*t^2 - 2*loopSquare*Q^4*t^2 + 
      D*loopSquare*Q^4*t^2 + 8*loopK*loopQ*s*t^2 - 4*D*loopK*loopQ*s*t^2 - 
      12*loopP*loopQ*s*t^2 + 4*D*loopP*loopQ*s*t^2 - 12*loopQ^2*s*t^2 + 
      4*D*loopQ^2*s*t^2 - 4*loopP*loopSquare*s*t^2 + 
      8*loopQ*loopSquare*s*t^2 - 2*D*loopQ*loopSquare*s*t^2 + 
      10*loopP*Q^2*s*t^2 - 4*D*loopP*Q^2*s*t^2 + 6*loopQ*Q^2*s*t^2 - 
      2*D*loopQ*Q^2*s*t^2 + 4*loopSquare*Q^2*s*t^2 - D*loopSquare*Q^2*s*t^2 + 
      6*loopSquare*s^2*t^2 - 2*D*loopSquare*s^2*t^2 + 4*loopP*Q^2*t^3 - 
      2*D*loopP*Q^2*t^3 + 4*loopQ*Q^2*t^3 - 2*D*loopQ*Q^2*t^3 - 
      2*loopSquare*Q^2*t^3 + D*loopSquare*Q^2*t^3 + 2*loopSquare*s*t^3 - 
      D*loopSquare*s*t^3))/(loopSquare*(2*loopK - 2*loopP - 2*loopQ + 
      loopSquare)*(-2*loopQ + loopSquare - Q^2)*(Q^2 + s)^2*SUNN*t*
     (Q^2 + s + t)) + (I*hIn*hOut*(-1 + SUNN)*(1 + SUNN)*
     (-128*loopK^2*loopP*Q^6 + 32*D*loopK^2*loopP*Q^6 + 
      256*loopK*loopP^2*Q^6 - 64*D*loopK*loopP^2*Q^6 - 128*loopP^3*Q^6 + 
      32*D*loopP^3*Q^6 - 64*loopK^2*loopQ*Q^6 + 16*D*loopK^2*loopQ*Q^6 + 
      384*loopK*loopP*loopQ*Q^6 - 96*D*loopK*loopP*loopQ*Q^6 - 
      320*loopP^2*loopQ*Q^6 + 80*D*loopP^2*loopQ*Q^6 + 
      128*loopK*loopQ^2*Q^6 - 32*D*loopK*loopQ^2*Q^6 - 
      256*loopP*loopQ^2*Q^6 + 64*D*loopP*loopQ^2*Q^6 - 64*loopQ^3*Q^6 + 
      16*D*loopQ^3*Q^6 - 256*loopK^2*loopP*Q^4*s + 64*D*loopK^2*loopP*Q^4*s + 
      352*loopK*loopP^2*Q^4*s - 96*D*loopK*loopP^2*Q^4*s - 96*loopP^3*Q^4*s + 
      32*D*loopP^3*Q^4*s - 192*loopK^2*loopQ*Q^4*s + 
      48*D*loopK^2*loopQ*Q^4*s + 816*loopK*loopP*loopQ*Q^4*s - 
      208*D*loopK*loopP*loopQ*Q^4*s - 464*loopP^2*loopQ*Q^4*s + 
      128*D*loopP^2*loopQ*Q^4*s + 384*loopK*loopQ^2*Q^4*s - 
      96*D*loopK*loopQ^2*Q^4*s - 560*loopP*loopQ^2*Q^4*s + 
      144*D*loopP*loopQ^2*Q^4*s - 192*loopQ^3*Q^4*s + 48*D*loopQ^3*Q^4*s - 
      6*loopK*loopSquare*Q^6*s + 2*D*loopK*loopSquare*Q^6*s + 
      6*loopP*loopSquare*Q^6*s - 2*D*loopP*loopSquare*Q^6*s + 
      6*loopQ*loopSquare*Q^6*s - 2*D*loopQ*loopSquare*Q^6*s - 
      128*loopK^2*loopP*Q^2*s^2 + 32*D*loopK^2*loopP*Q^2*s^2 + 
      96*loopK*loopP^2*Q^2*s^2 - 32*D*loopK*loopP^2*Q^2*s^2 - 
      192*loopK^2*loopQ*Q^2*s^2 + 48*D*loopK^2*loopQ*Q^2*s^2 + 
      480*loopK*loopP*loopQ*Q^2*s^2 - 128*D*loopK*loopP*loopQ*Q^2*s^2 - 
      144*loopP^2*loopQ*Q^2*s^2 + 48*D*loopP^2*loopQ*Q^2*s^2 + 
      384*loopK*loopQ^2*Q^2*s^2 - 96*D*loopK*loopQ^2*Q^2*s^2 - 
      352*loopP*loopQ^2*Q^2*s^2 + 96*D*loopP*loopQ^2*Q^2*s^2 - 
      192*loopQ^3*Q^2*s^2 + 48*D*loopQ^3*Q^2*s^2 - 18*loopK*loopSquare*Q^4*
       s^2 + 6*D*loopK*loopSquare*Q^4*s^2 + 12*loopP*loopSquare*Q^4*s^2 - 
      4*D*loopP*loopSquare*Q^4*s^2 + 18*loopQ*loopSquare*Q^4*s^2 - 
      6*D*loopQ*loopSquare*Q^4*s^2 - 64*loopK^2*loopQ*s^3 + 
      16*D*loopK^2*loopQ*s^3 + 48*loopK*loopP*loopQ*s^3 - 
      16*D*loopK*loopP*loopQ*s^3 + 128*loopK*loopQ^2*s^3 - 
      32*D*loopK*loopQ^2*s^3 - 48*loopP*loopQ^2*s^3 + 
      16*D*loopP*loopQ^2*s^3 - 64*loopQ^3*s^3 + 16*D*loopQ^3*s^3 - 
      18*loopK*loopSquare*Q^2*s^3 + 6*D*loopK*loopSquare*Q^2*s^3 + 
      6*loopP*loopSquare*Q^2*s^3 - 2*D*loopP*loopSquare*Q^2*s^3 + 
      18*loopQ*loopSquare*Q^2*s^3 - 6*D*loopQ*loopSquare*Q^2*s^3 - 
      6*loopK*loopSquare*s^4 + 2*D*loopK*loopSquare*s^4 + 
      6*loopQ*loopSquare*s^4 - 2*D*loopQ*loopSquare*s^4 + 
      256*loopK*loopP^2*Q^4*t - 64*D*loopK*loopP^2*Q^4*t - 
      256*loopP^3*Q^4*t + 64*D*loopP^3*Q^4*t + 384*loopK*loopP*loopQ*Q^4*t - 
      96*D*loopK*loopP*loopQ*Q^4*t - 640*loopP^2*loopQ*Q^4*t + 
      160*D*loopP^2*loopQ*Q^4*t + 128*loopK*loopQ^2*Q^4*t - 
      32*D*loopK*loopQ^2*Q^4*t - 512*loopP*loopQ^2*Q^4*t + 
      128*D*loopP*loopQ^2*Q^4*t - 128*loopQ^3*Q^4*t + 32*D*loopQ^3*Q^4*t - 
      64*loopK*loopP^2*Q^2*s*t - 96*loopP^3*Q^2*s*t + 32*D*loopP^3*Q^2*s*t + 
      352*loopK*loopP*loopQ*Q^2*s*t - 96*D*loopK*loopP*loopQ*Q^2*s*t - 
      528*loopP^2*loopQ*Q^2*s*t + 144*D*loopP^2*loopQ*Q^2*s*t + 
      256*loopK*loopQ^2*Q^2*s*t - 64*D*loopK*loopQ^2*Q^2*s*t - 
      688*loopP*loopQ^2*Q^2*s*t + 176*D*loopP*loopQ^2*Q^2*s*t - 
      256*loopQ^3*Q^2*s*t + 64*D*loopQ^3*Q^2*s*t + 96*loopK*loopP*Q^4*s*t - 
      56*D*loopK*loopP*Q^4*s*t + 8*D^2*loopK*loopP*Q^4*s*t - 
      96*loopP^2*Q^4*s*t + 56*D*loopP^2*Q^4*s*t - 8*D^2*loopP^2*Q^4*s*t + 
      60*loopK*loopQ*Q^4*s*t - 32*D*loopK*loopQ*Q^4*s*t + 
      4*D^2*loopK*loopQ*Q^4*s*t - 156*loopP*loopQ*Q^4*s*t + 
      88*D*loopP*loopQ*Q^4*s*t - 12*D^2*loopP*loopQ*Q^4*s*t - 
      60*loopQ^2*Q^4*s*t + 32*D*loopQ^2*Q^4*s*t - 4*D^2*loopQ^2*Q^4*s*t - 
      12*loopK*loopSquare*Q^4*s*t + 4*D*loopK*loopSquare*Q^4*s*t + 
      170*loopP*loopSquare*Q^4*s*t - 58*D*loopP*loopSquare*Q^4*s*t + 
      4*D^2*loopP*loopSquare*Q^4*s*t + 94*loopQ*loopSquare*Q^4*s*t - 
      32*D*loopQ*loopSquare*Q^4*s*t + 2*D^2*loopQ*loopSquare*Q^4*s*t + 
      6*loopK*Q^6*s*t - 2*D*loopK*Q^6*s*t - 6*loopP*Q^6*s*t + 
      2*D*loopP*Q^6*s*t - 6*loopQ*Q^6*s*t + 2*D*loopQ*Q^6*s*t - 
      32*loopK*loopP*loopQ*s^2*t - 48*loopP^2*loopQ*s^2*t + 
      16*D*loopP^2*loopQ*s^2*t + 128*loopK*loopQ^2*s^2*t - 
      32*D*loopK*loopQ^2*s^2*t - 176*loopP*loopQ^2*s^2*t + 
      48*D*loopP*loopQ^2*s^2*t - 128*loopQ^3*s^2*t + 32*D*loopQ^3*s^2*t + 
      96*loopK*loopP*Q^2*s^2*t - 56*D*loopK*loopP*Q^2*s^2*t + 
      8*D^2*loopK*loopP*Q^2*s^2*t - 48*loopP^2*Q^2*s^2*t + 
      40*D*loopP^2*Q^2*s^2*t - 8*D^2*loopP^2*Q^2*s^2*t + 
      120*loopK*loopQ*Q^2*s^2*t - 64*D*loopK*loopQ*Q^2*s^2*t + 
      8*D^2*loopK*loopQ*Q^2*s^2*t - 204*loopP*loopQ*Q^2*s^2*t + 
      116*D*loopP*loopQ*Q^2*s^2*t - 16*D^2*loopP*loopQ*Q^2*s^2*t - 
      120*loopQ^2*Q^2*s^2*t + 64*D*loopQ^2*Q^2*s^2*t - 
      8*D^2*loopQ^2*Q^2*s^2*t - 24*loopK*loopSquare*Q^2*s^2*t + 
      8*D*loopK*loopSquare*Q^2*s^2*t + 188*loopP*loopSquare*Q^2*s^2*t - 
      64*D*loopP*loopSquare*Q^2*s^2*t + 4*D^2*loopP*loopSquare*Q^2*s^2*t + 
      188*loopQ*loopSquare*Q^2*s^2*t - 64*D*loopQ*loopSquare*Q^2*s^2*t + 
      4*D^2*loopQ*loopSquare*Q^2*s^2*t + 12*loopK*Q^4*s^2*t - 
      4*D*loopK*Q^4*s^2*t + 18*loopP*Q^4*s^2*t - 12*D*loopP*Q^4*s^2*t + 
      2*D^2*loopP*Q^4*s^2*t - 12*loopQ*Q^4*s^2*t + 4*D*loopQ*Q^4*s^2*t + 
      12*loopSquare*Q^4*s^2*t - 7*D*loopSquare*Q^4*s^2*t + 
      D^2*loopSquare*Q^4*s^2*t + 60*loopK*loopQ*s^3*t - 
      32*D*loopK*loopQ*s^3*t + 4*D^2*loopK*loopQ*s^3*t - 
      48*loopP*loopQ*s^3*t + 28*D*loopP*loopQ*s^3*t - 
      4*D^2*loopP*loopQ*s^3*t - 60*loopQ^2*s^3*t + 32*D*loopQ^2*s^3*t - 
      4*D^2*loopQ^2*s^3*t - 12*loopK*loopSquare*s^3*t + 
      4*D*loopK*loopSquare*s^3*t + 18*loopP*loopSquare*s^3*t - 
      6*D*loopP*loopSquare*s^3*t + 94*loopQ*loopSquare*s^3*t - 
      32*D*loopQ*loopSquare*s^3*t + 2*D^2*loopQ*loopSquare*s^3*t + 
      6*loopK*Q^2*s^3*t - 2*D*loopK*Q^2*s^3*t + 24*loopP*Q^2*s^3*t - 
      14*D*loopP*Q^2*s^3*t + 2*D^2*loopP*Q^2*s^3*t - 6*loopQ*Q^2*s^3*t + 
      2*D*loopQ*Q^2*s^3*t + 24*loopSquare*Q^2*s^3*t - 
      14*D*loopSquare*Q^2*s^3*t + 2*D^2*loopSquare*Q^2*s^3*t + 
      12*loopSquare*s^4*t - 7*D*loopSquare*s^4*t + D^2*loopSquare*s^4*t - 
      128*loopP^3*Q^2*t^2 + 32*D*loopP^3*Q^2*t^2 - 320*loopP^2*loopQ*Q^2*
       t^2 + 80*D*loopP^2*loopQ*Q^2*t^2 - 256*loopP*loopQ^2*Q^2*t^2 + 
      64*D*loopP*loopQ^2*Q^2*t^2 - 64*loopQ^3*Q^2*t^2 + 
      16*D*loopQ^3*Q^2*t^2 - 64*loopP^2*loopQ*s*t^2 + 
      16*D*loopP^2*loopQ*s*t^2 - 128*loopP*loopQ^2*s*t^2 + 
      32*D*loopP*loopQ^2*s*t^2 - 64*loopQ^3*s*t^2 + 16*D*loopQ^3*s*t^2 + 
      144*loopK*loopP*Q^2*s*t^2 - 72*D*loopK*loopP*Q^2*s*t^2 + 
      8*D^2*loopK*loopP*Q^2*s*t^2 - 96*loopP^2*Q^2*s*t^2 + 
      56*D*loopP^2*Q^2*s*t^2 - 8*D^2*loopP^2*Q^2*s*t^2 + 
      72*loopK*loopQ*Q^2*s*t^2 - 36*D*loopK*loopQ*Q^2*s*t^2 + 
      4*D^2*loopK*loopQ*Q^2*s*t^2 - 156*loopP*loopQ*Q^2*s*t^2 + 
      88*D*loopP*loopQ*Q^2*s*t^2 - 12*D^2*loopP*loopQ*Q^2*s*t^2 - 
      60*loopQ^2*Q^2*s*t^2 + 32*D*loopQ^2*Q^2*s*t^2 - 
      4*D^2*loopQ^2*Q^2*s*t^2 + 164*loopP*loopSquare*Q^2*s*t^2 - 
      56*D*loopP*loopSquare*Q^2*s*t^2 + 4*D^2*loopP*loopSquare*Q^2*s*t^2 + 
      88*loopQ*loopSquare*Q^2*s*t^2 - 30*D*loopQ*loopSquare*Q^2*s*t^2 + 
      2*D^2*loopQ*loopSquare*Q^2*s*t^2 + 30*loopP*Q^4*s*t^2 - 
      16*D*loopP*Q^4*s*t^2 + 2*D^2*loopP*Q^4*s*t^2 + 30*loopQ*Q^4*s*t^2 - 
      16*D*loopQ*Q^4*s*t^2 + 2*D^2*loopQ*Q^4*s*t^2 - 
      18*loopSquare*Q^4*s*t^2 + 9*D*loopSquare*Q^4*s*t^2 - 
      D^2*loopSquare*Q^4*s*t^2 + 72*loopK*loopQ*s^2*t^2 - 
      36*D*loopK*loopQ*s^2*t^2 + 4*D^2*loopK*loopQ*s^2*t^2 - 
      60*loopP*loopQ*s^2*t^2 + 32*D*loopP*loopQ*s^2*t^2 - 
      4*D^2*loopP*loopQ*s^2*t^2 - 60*loopQ^2*s^2*t^2 + 32*D*loopQ^2*s^2*t^2 - 
      4*D^2*loopQ^2*s^2*t^2 + 12*loopP*loopSquare*s^2*t^2 - 
      4*D*loopP*loopSquare*s^2*t^2 + 88*loopQ*loopSquare*s^2*t^2 - 
      30*D*loopQ*loopSquare*s^2*t^2 + 2*D^2*loopQ*loopSquare*s^2*t^2 + 
      66*loopP*Q^2*s^2*t^2 - 34*D*loopP*Q^2*s^2*t^2 + 
      4*D^2*loopP*Q^2*s^2*t^2 + 30*loopQ*Q^2*s^2*t^2 - 
      16*D*loopQ*Q^2*s^2*t^2 + 2*D^2*loopQ*Q^2*s^2*t^2 + 
      12*loopSquare*Q^2*s^2*t^2 - 7*D*loopSquare*Q^2*s^2*t^2 + 
      D^2*loopSquare*Q^2*s^2*t^2 + 30*loopSquare*s^3*t^2 - 
      16*D*loopSquare*s^3*t^2 + 2*D^2*loopSquare*s^3*t^2 + 
      36*loopP*Q^2*s*t^3 - 18*D*loopP*Q^2*s*t^3 + 2*D^2*loopP*Q^2*s*t^3 + 
      36*loopQ*Q^2*s*t^3 - 18*D*loopQ*Q^2*s*t^3 + 2*D^2*loopQ*Q^2*s*t^3 - 
      18*loopSquare*Q^2*s*t^3 + 9*D*loopSquare*Q^2*s*t^3 - 
      D^2*loopSquare*Q^2*s*t^3 + 18*loopSquare*s^2*t^3 - 
      9*D*loopSquare*s^2*t^3 + D^2*loopSquare*s^2*t^3))/
    ((-3 + D)*loopSquare*(2*loopK - 2*loopP - 2*loopQ + loopSquare)*
     (-2*loopQ + loopSquare - Q^2)*s*(Q^2 + s)^2*SUNN*t*(Q^2 + s + t)) - 
   (I*(-1 + SUNN)*(1 + SUNN)*(-32*loopK^2*loopP*Q^6 + 64*loopK*loopP^2*Q^6 - 
      32*loopP^3*Q^6 - 16*loopK^2*loopQ*Q^6 + 96*loopK*loopP*loopQ*Q^6 - 
      80*loopP^2*loopQ*Q^6 + 32*loopK*loopQ^2*Q^6 - 64*loopP*loopQ^2*Q^6 - 
      16*loopQ^3*Q^6 - 64*loopK^2*loopP*Q^4*s - 32*loopK*loopP^2*Q^4*s + 
      32*D*loopK*loopP^2*Q^4*s + 96*loopP^3*Q^4*s - 32*D*loopP^3*Q^4*s - 
      48*loopK^2*loopQ*Q^4*s + 144*loopK*loopP*loopQ*Q^4*s + 
      16*D*loopK*loopP*loopQ*Q^4*s + 64*loopP^2*loopQ*Q^4*s - 
      48*D*loopP^2*loopQ*Q^4*s + 96*loopK*loopQ^2*Q^4*s - 
      80*loopP*loopQ^2*Q^4*s - 16*D*loopP*loopQ^2*Q^4*s - 48*loopQ^3*Q^4*s + 
      6*loopK*loopSquare*Q^6*s - 2*D*loopK*loopSquare*Q^6*s - 
      6*loopP*loopSquare*Q^6*s + 2*D*loopP*loopSquare*Q^6*s - 
      6*loopQ*loopSquare*Q^6*s + 2*D*loopQ*loopSquare*Q^6*s - 
      32*loopK^2*loopP*Q^2*s^2 - 96*loopK*loopP^2*Q^2*s^2 + 
      32*D*loopK*loopP^2*Q^2*s^2 - 48*loopK^2*loopQ*Q^2*s^2 + 
      32*D*loopK*loopP*loopQ*Q^2*s^2 + 144*loopP^2*loopQ*Q^2*s^2 - 
      48*D*loopP^2*loopQ*Q^2*s^2 + 96*loopK*loopQ^2*Q^2*s^2 + 
      32*loopP*loopQ^2*Q^2*s^2 - 32*D*loopP*loopQ^2*Q^2*s^2 - 
      48*loopQ^3*Q^2*s^2 + 18*loopK*loopSquare*Q^4*s^2 - 
      6*D*loopK*loopSquare*Q^4*s^2 - 12*loopP*loopSquare*Q^4*s^2 + 
      4*D*loopP*loopSquare*Q^4*s^2 - 18*loopQ*loopSquare*Q^4*s^2 + 
      6*D*loopQ*loopSquare*Q^4*s^2 - 16*loopK^2*loopQ*s^3 - 
      48*loopK*loopP*loopQ*s^3 + 16*D*loopK*loopP*loopQ*s^3 + 
      32*loopK*loopQ^2*s^3 + 48*loopP*loopQ^2*s^3 - 16*D*loopP*loopQ^2*s^3 - 
      16*loopQ^3*s^3 + 18*loopK*loopSquare*Q^2*s^3 - 6*D*loopK*loopSquare*Q^2*
       s^3 - 6*loopP*loopSquare*Q^2*s^3 + 2*D*loopP*loopSquare*Q^2*s^3 - 
      18*loopQ*loopSquare*Q^2*s^3 + 6*D*loopQ*loopSquare*Q^2*s^3 + 
      6*loopK*loopSquare*s^4 - 2*D*loopK*loopSquare*s^4 - 
      6*loopQ*loopSquare*s^4 + 2*D*loopQ*loopSquare*s^4 + 
      64*loopK*loopP^2*Q^4*t - 64*loopP^3*Q^4*t + 96*loopK*loopP*loopQ*Q^4*
       t - 160*loopP^2*loopQ*Q^4*t + 32*loopK*loopQ^2*Q^4*t - 
      128*loopP*loopQ^2*Q^4*t - 32*loopQ^3*Q^4*t - 256*loopK*loopP^2*Q^2*s*
       t + 64*D*loopK*loopP^2*Q^2*s*t + 96*loopP^3*Q^2*s*t - 
      32*D*loopP^3*Q^2*s*t - 32*loopK*loopP*loopQ*Q^2*s*t + 
      32*D*loopK*loopP*loopQ*Q^2*s*t + 48*loopP^2*loopQ*Q^2*s*t - 
      48*D*loopP^2*loopQ*Q^2*s*t + 64*loopK*loopQ^2*Q^2*s*t - 
      112*loopP*loopQ^2*Q^2*s*t - 16*D*loopP*loopQ^2*Q^2*s*t - 
      64*loopQ^3*Q^2*s*t + 144*loopK*loopP*Q^4*s*t - 
      72*D*loopK*loopP*Q^4*s*t + 8*D^2*loopK*loopP*Q^4*s*t - 
      144*loopP^2*Q^4*s*t + 72*D*loopP^2*Q^4*s*t - 8*D^2*loopP^2*Q^4*s*t + 
      60*loopK*loopQ*Q^4*s*t - 32*D*loopK*loopQ*Q^4*s*t + 
      4*D^2*loopK*loopQ*Q^4*s*t - 204*loopP*loopQ*Q^4*s*t + 
      104*D*loopP*loopQ*Q^4*s*t - 12*D^2*loopP*loopQ*Q^4*s*t - 
      60*loopQ^2*Q^4*s*t + 32*D*loopQ^2*Q^4*s*t - 4*D^2*loopQ^2*Q^4*s*t + 
      12*loopK*loopSquare*Q^4*s*t - 4*D*loopK*loopSquare*Q^4*s*t + 
      110*loopP*loopSquare*Q^4*s*t - 38*D*loopP*loopSquare*Q^4*s*t + 
      4*D^2*loopP*loopSquare*Q^4*s*t + 46*loopQ*loopSquare*Q^4*s*t - 
      16*D*loopQ*loopSquare*Q^4*s*t + 2*D^2*loopQ*loopSquare*Q^4*s*t - 
      6*loopK*Q^6*s*t + 2*D*loopK*Q^6*s*t + 6*loopP*Q^6*s*t - 
      2*D*loopP*Q^6*s*t + 6*loopQ*Q^6*s*t - 2*D*loopQ*Q^6*s*t - 
      128*loopK*loopP*loopQ*s^2*t + 32*D*loopK*loopP*loopQ*s^2*t + 
      48*loopP^2*loopQ*s^2*t - 16*D*loopP^2*loopQ*s^2*t + 
      32*loopK*loopQ^2*s^2*t + 16*loopP*loopQ^2*s^2*t - 
      16*D*loopP*loopQ^2*s^2*t - 32*loopQ^3*s^2*t + 144*loopK*loopP*Q^2*s^2*
       t - 72*D*loopK*loopP*Q^2*s^2*t + 8*D^2*loopK*loopP*Q^2*s^2*t - 
      192*loopP^2*Q^2*s^2*t + 88*D*loopP^2*Q^2*s^2*t - 
      8*D^2*loopP^2*Q^2*s^2*t + 120*loopK*loopQ*Q^2*s^2*t - 
      64*D*loopK*loopQ*Q^2*s^2*t + 8*D^2*loopK*loopQ*Q^2*s^2*t - 
      276*loopP*loopQ*Q^2*s^2*t + 140*D*loopP*loopQ*Q^2*s^2*t - 
      16*D^2*loopP*loopQ*Q^2*s^2*t - 120*loopQ^2*Q^2*s^2*t + 
      64*D*loopQ^2*Q^2*s^2*t - 8*D^2*loopQ^2*Q^2*s^2*t + 
      24*loopK*loopSquare*Q^2*s^2*t - 8*D*loopK*loopSquare*Q^2*s^2*t + 
      92*loopP*loopSquare*Q^2*s^2*t - 32*D*loopP*loopSquare*Q^2*s^2*t + 
      4*D^2*loopP*loopSquare*Q^2*s^2*t + 92*loopQ*loopSquare*Q^2*s^2*t - 
      32*D*loopQ*loopSquare*Q^2*s^2*t + 4*D^2*loopQ*loopSquare*Q^2*s^2*t - 
      12*loopK*Q^4*s^2*t + 4*D*loopK*Q^4*s^2*t + 42*loopP*Q^4*s^2*t - 
      20*D*loopP*Q^4*s^2*t + 2*D^2*loopP*Q^4*s^2*t + 12*loopQ*Q^4*s^2*t - 
      4*D*loopQ*Q^4*s^2*t + 18*loopSquare*Q^4*s^2*t - 
      9*D*loopSquare*Q^4*s^2*t + D^2*loopSquare*Q^4*s^2*t + 
      60*loopK*loopQ*s^3*t - 32*D*loopK*loopQ*s^3*t + 
      4*D^2*loopK*loopQ*s^3*t - 72*loopP*loopQ*s^3*t + 
      36*D*loopP*loopQ*s^3*t - 4*D^2*loopP*loopQ*s^3*t - 60*loopQ^2*s^3*t + 
      32*D*loopQ^2*s^3*t - 4*D^2*loopQ^2*s^3*t + 12*loopK*loopSquare*s^3*t - 
      4*D*loopK*loopSquare*s^3*t - 18*loopP*loopSquare*s^3*t + 
      6*D*loopP*loopSquare*s^3*t + 46*loopQ*loopSquare*s^3*t - 
      16*D*loopQ*loopSquare*s^3*t + 2*D^2*loopQ*loopSquare*s^3*t - 
      6*loopK*Q^2*s^3*t + 2*D*loopK*Q^2*s^3*t + 36*loopP*Q^2*s^3*t - 
      18*D*loopP*Q^2*s^3*t + 2*D^2*loopP*Q^2*s^3*t + 6*loopQ*Q^2*s^3*t - 
      2*D*loopQ*Q^2*s^3*t + 36*loopSquare*Q^2*s^3*t - 
      18*D*loopSquare*Q^2*s^3*t + 2*D^2*loopSquare*Q^2*s^3*t + 
      18*loopSquare*s^4*t - 9*D*loopSquare*s^4*t + D^2*loopSquare*s^4*t - 
      32*loopP^3*Q^2*t^2 - 80*loopP^2*loopQ*Q^2*t^2 - 
      64*loopP*loopQ^2*Q^2*t^2 - 16*loopQ^3*Q^2*t^2 - 
      16*loopP^2*loopQ*s*t^2 - 32*loopP*loopQ^2*s*t^2 - 16*loopQ^3*s*t^2 + 
      96*loopK*loopP*Q^2*s*t^2 - 56*D*loopK*loopP*Q^2*s*t^2 + 
      8*D^2*loopK*loopP*Q^2*s*t^2 - 144*loopP^2*Q^2*s*t^2 + 
      72*D*loopP^2*Q^2*s*t^2 - 8*D^2*loopP^2*Q^2*s*t^2 + 
      48*loopK*loopQ*Q^2*s*t^2 - 28*D*loopK*loopQ*Q^2*s*t^2 + 
      4*D^2*loopK*loopQ*Q^2*s*t^2 - 204*loopP*loopQ*Q^2*s*t^2 + 
      104*D*loopP*loopQ*Q^2*s*t^2 - 12*D^2*loopP*loopQ*Q^2*s*t^2 - 
      60*loopQ^2*Q^2*s*t^2 + 32*D*loopQ^2*Q^2*s*t^2 - 
      4*D^2*loopQ^2*Q^2*s*t^2 + 116*loopP*loopSquare*Q^2*s*t^2 - 
      40*D*loopP*loopSquare*Q^2*s*t^2 + 4*D^2*loopP*loopSquare*Q^2*s*t^2 + 
      52*loopQ*loopSquare*Q^2*s*t^2 - 18*D*loopQ*loopSquare*Q^2*s*t^2 + 
      2*D^2*loopQ*loopSquare*Q^2*s*t^2 + 30*loopP*Q^4*s*t^2 - 
      16*D*loopP*Q^4*s*t^2 + 2*D^2*loopP*Q^4*s*t^2 + 30*loopQ*Q^4*s*t^2 - 
      16*D*loopQ*Q^4*s*t^2 + 2*D^2*loopQ*Q^4*s*t^2 - 
      12*loopSquare*Q^4*s*t^2 + 7*D*loopSquare*Q^4*s*t^2 - 
      D^2*loopSquare*Q^4*s*t^2 + 48*loopK*loopQ*s^2*t^2 - 
      28*D*loopK*loopQ*s^2*t^2 + 4*D^2*loopK*loopQ*s^2*t^2 - 
      60*loopP*loopQ*s^2*t^2 + 32*D*loopP*loopQ*s^2*t^2 - 
      4*D^2*loopP*loopQ*s^2*t^2 - 60*loopQ^2*s^2*t^2 + 32*D*loopQ^2*s^2*t^2 - 
      4*D^2*loopQ^2*s^2*t^2 - 12*loopP*loopSquare*s^2*t^2 + 
      4*D*loopP*loopSquare*s^2*t^2 + 52*loopQ*loopSquare*s^2*t^2 - 
      18*D*loopQ*loopSquare*s^2*t^2 + 2*D^2*loopQ*loopSquare*s^2*t^2 + 
      54*loopP*Q^2*s^2*t^2 - 30*D*loopP*Q^2*s^2*t^2 + 
      4*D^2*loopP*Q^2*s^2*t^2 + 30*loopQ*Q^2*s^2*t^2 - 
      16*D*loopQ*Q^2*s^2*t^2 + 2*D^2*loopQ*Q^2*s^2*t^2 + 
      18*loopSquare*Q^2*s^2*t^2 - 9*D*loopSquare*Q^2*s^2*t^2 + 
      D^2*loopSquare*Q^2*s^2*t^2 + 30*loopSquare*s^3*t^2 - 
      16*D*loopSquare*s^3*t^2 + 2*D^2*loopSquare*s^3*t^2 + 
      24*loopP*Q^2*s*t^3 - 14*D*loopP*Q^2*s*t^3 + 2*D^2*loopP*Q^2*s*t^3 + 
      24*loopQ*Q^2*s*t^3 - 14*D*loopQ*Q^2*s*t^3 + 2*D^2*loopQ*Q^2*s*t^3 - 
      12*loopSquare*Q^2*s*t^3 + 7*D*loopSquare*Q^2*s*t^3 - 
      D^2*loopSquare*Q^2*s*t^3 + 12*loopSquare*s^2*t^3 - 
      7*D*loopSquare*s^2*t^3 + D^2*loopSquare*s^2*t^3)*xIn*xOut)/
    ((-3 + D)*loopSquare*(2*loopK - 2*loopP - 2*loopQ + loopSquare)*
     (-2*loopQ + loopSquare - Q^2)*s*(Q^2 + s)^2*SUNN*t*(Q^2 + s + t)) + 
   (I*(-1 + SUNN)*(1 + SUNN)*(32*loopK^2*loopP*Q^6 - 64*loopK*loopP^2*Q^6 + 
      32*loopP^3*Q^6 + 16*loopK^2*loopQ*Q^6 - 96*loopK*loopP*loopQ*Q^6 + 
      80*loopP^2*loopQ*Q^6 - 32*loopK*loopQ^2*Q^6 + 64*loopP*loopQ^2*Q^6 + 
      16*loopQ^3*Q^6 + 64*loopK^2*loopP*Q^4*s - 96*loopK*loopP^2*Q^4*s + 
      32*loopP^3*Q^4*s + 48*loopK^2*loopQ*Q^4*s - 208*loopK*loopP*loopQ*Q^4*
       s + 128*loopP^2*loopQ*Q^4*s - 96*loopK*loopQ^2*Q^4*s + 
      144*loopP*loopQ^2*Q^4*s + 48*loopQ^3*Q^4*s + 2*loopK*loopSquare*Q^6*s - 
      2*loopP*loopSquare*Q^6*s - 2*loopQ*loopSquare*Q^6*s + 
      32*loopK^2*loopP*Q^2*s^2 - 32*loopK*loopP^2*Q^2*s^2 + 
      48*loopK^2*loopQ*Q^2*s^2 - 128*loopK*loopP*loopQ*Q^2*s^2 + 
      48*loopP^2*loopQ*Q^2*s^2 - 96*loopK*loopQ^2*Q^2*s^2 + 
      96*loopP*loopQ^2*Q^2*s^2 + 48*loopQ^3*Q^2*s^2 + 
      6*loopK*loopSquare*Q^4*s^2 - 4*loopP*loopSquare*Q^4*s^2 - 
      6*loopQ*loopSquare*Q^4*s^2 + 16*loopK^2*loopQ*s^3 - 
      16*loopK*loopP*loopQ*s^3 - 32*loopK*loopQ^2*s^3 + 
      16*loopP*loopQ^2*s^3 + 16*loopQ^3*s^3 + 6*loopK*loopSquare*Q^2*s^3 - 
      2*loopP*loopSquare*Q^2*s^3 - 6*loopQ*loopSquare*Q^2*s^3 + 
      2*loopK*loopSquare*s^4 - 2*loopQ*loopSquare*s^4 - 
      64*loopK*loopP^2*Q^4*t + 64*loopP^3*Q^4*t - 96*loopK*loopP*loopQ*Q^4*
       t + 160*loopP^2*loopQ*Q^4*t - 32*loopK*loopQ^2*Q^4*t + 
      128*loopP*loopQ^2*Q^4*t + 32*loopQ^3*Q^4*t + 32*loopP^3*Q^2*s*t - 
      96*loopK*loopP*loopQ*Q^2*s*t + 144*loopP^2*loopQ*Q^2*s*t - 
      64*loopK*loopQ^2*Q^2*s*t + 176*loopP*loopQ^2*Q^2*s*t + 
      64*loopQ^3*Q^2*s*t - 16*loopK*loopP*Q^4*s*t + 8*D*loopK*loopP*Q^4*s*t + 
      16*loopP^2*Q^4*s*t - 8*D*loopP^2*Q^4*s*t - 12*loopK*loopQ*Q^4*s*t + 
      4*D*loopK*loopQ*Q^4*s*t + 28*loopP*loopQ*Q^4*s*t - 
      12*D*loopP*loopQ*Q^4*s*t + 12*loopQ^2*Q^4*s*t - 4*D*loopQ^2*Q^4*s*t + 
      4*loopK*loopSquare*Q^4*s*t - 38*loopP*loopSquare*Q^4*s*t + 
      4*D*loopP*loopSquare*Q^4*s*t - 22*loopQ*loopSquare*Q^4*s*t + 
      2*D*loopQ*loopSquare*Q^4*s*t - 2*loopK*Q^6*s*t + 2*loopP*Q^6*s*t + 
      2*loopQ*Q^6*s*t + 16*loopP^2*loopQ*s^2*t - 32*loopK*loopQ^2*s^2*t + 
      48*loopP*loopQ^2*s^2*t + 32*loopQ^3*s^2*t - 16*loopK*loopP*Q^2*s^2*t + 
      8*D*loopK*loopP*Q^2*s^2*t - 8*D*loopP^2*Q^2*s^2*t - 
      24*loopK*loopQ*Q^2*s^2*t + 8*D*loopK*loopQ*Q^2*s^2*t + 
      36*loopP*loopQ*Q^2*s^2*t - 16*D*loopP*loopQ*Q^2*s^2*t + 
      24*loopQ^2*Q^2*s^2*t - 8*D*loopQ^2*Q^2*s^2*t + 
      8*loopK*loopSquare*Q^2*s^2*t - 44*loopP*loopSquare*Q^2*s^2*t + 
      4*D*loopP*loopSquare*Q^2*s^2*t - 44*loopQ*loopSquare*Q^2*s^2*t + 
      4*D*loopQ*loopSquare*Q^2*s^2*t - 4*loopK*Q^4*s^2*t - 
      2*loopP*Q^4*s^2*t + 2*D*loopP*Q^4*s^2*t + 4*loopQ*Q^4*s^2*t - 
      2*loopSquare*Q^4*s^2*t + D*loopSquare*Q^4*s^2*t - 
      12*loopK*loopQ*s^3*t + 4*D*loopK*loopQ*s^3*t + 8*loopP*loopQ*s^3*t - 
      4*D*loopP*loopQ*s^3*t + 12*loopQ^2*s^3*t - 4*D*loopQ^2*s^3*t + 
      4*loopK*loopSquare*s^3*t - 6*loopP*loopSquare*s^3*t - 
      22*loopQ*loopSquare*s^3*t + 2*D*loopQ*loopSquare*s^3*t - 
      2*loopK*Q^2*s^3*t - 4*loopP*Q^2*s^3*t + 2*D*loopP*Q^2*s^3*t + 
      2*loopQ*Q^2*s^3*t - 4*loopSquare*Q^2*s^3*t + 2*D*loopSquare*Q^2*s^3*t - 
      2*loopSquare*s^4*t + D*loopSquare*s^4*t + 32*loopP^3*Q^2*t^2 + 
      80*loopP^2*loopQ*Q^2*t^2 + 64*loopP*loopQ^2*Q^2*t^2 + 
      16*loopQ^3*Q^2*t^2 + 16*loopP^2*loopQ*s*t^2 + 32*loopP*loopQ^2*s*t^2 + 
      16*loopQ^3*s*t^2 - 32*loopK*loopP*Q^2*s*t^2 + 8*D*loopK*loopP*Q^2*s*
       t^2 + 16*loopP^2*Q^2*s*t^2 - 8*D*loopP^2*Q^2*s*t^2 - 
      16*loopK*loopQ*Q^2*s*t^2 + 4*D*loopK*loopQ*Q^2*s*t^2 + 
      28*loopP*loopQ*Q^2*s*t^2 - 12*D*loopP*loopQ*Q^2*s*t^2 + 
      12*loopQ^2*Q^2*s*t^2 - 4*D*loopQ^2*Q^2*s*t^2 - 
      36*loopP*loopSquare*Q^2*s*t^2 + 4*D*loopP*loopSquare*Q^2*s*t^2 - 
      20*loopQ*loopSquare*Q^2*s*t^2 + 2*D*loopQ*loopSquare*Q^2*s*t^2 - 
      6*loopP*Q^4*s*t^2 + 2*D*loopP*Q^4*s*t^2 - 6*loopQ*Q^4*s*t^2 + 
      2*D*loopQ*Q^4*s*t^2 + 4*loopSquare*Q^4*s*t^2 - D*loopSquare*Q^4*s*t^2 - 
      16*loopK*loopQ*s^2*t^2 + 4*D*loopK*loopQ*s^2*t^2 + 
      12*loopP*loopQ*s^2*t^2 - 4*D*loopP*loopQ*s^2*t^2 + 12*loopQ^2*s^2*t^2 - 
      4*D*loopQ^2*s^2*t^2 - 4*loopP*loopSquare*s^2*t^2 - 
      20*loopQ*loopSquare*s^2*t^2 + 2*D*loopQ*loopSquare*s^2*t^2 - 
      14*loopP*Q^2*s^2*t^2 + 4*D*loopP*Q^2*s^2*t^2 - 6*loopQ*Q^2*s^2*t^2 + 
      2*D*loopQ*Q^2*s^2*t^2 - 2*loopSquare*Q^2*s^2*t^2 + 
      D*loopSquare*Q^2*s^2*t^2 - 6*loopSquare*s^3*t^2 + 
      2*D*loopSquare*s^3*t^2 - 8*loopP*Q^2*s*t^3 + 2*D*loopP*Q^2*s*t^3 - 
      8*loopQ*Q^2*s*t^3 + 2*D*loopQ*Q^2*s*t^3 + 4*loopSquare*Q^2*s*t^3 - 
      D*loopSquare*Q^2*s*t^3 - 4*loopSquare*s^2*t^3 + D*loopSquare*s^2*t^3)*
     yIn*yOut)/(loopSquare*(2*loopK - 2*loopP - 2*loopQ + loopSquare)*
     (-2*loopQ + loopSquare - Q^2)*s*(Q^2 + s)^2*SUNN*t*(Q^2 + s + t)), 
 "Checks" -> <|"compute allocation" -> True, "isolated runtime" -> True, 
   "complete source syntax" -> True, "supported virtual channel" -> True, 
   "pinned amplitude" -> True, "pinned virtual reference" -> True, 
   "pinned original virtual source" -> True, 
   "accepted original virtual map" -> True, 
   "accepted spin and angular inputs" -> True, 
   "accepted dimensional Born input" -> True, 
   "Born frame restored exactly" -> True, "algebraic Born frame" -> True, 
   "unconditional exact algebra" -> True, "transverse rational function" -> 
    True, "rationalized transverse denominator" -> True, 
   "polynomial division reconstruction" -> True, 
   "complete rational reconstruction on shell" -> True, 
   "denominator Bezout reconstruction" -> True, 
   "invertible transverse denominator" -> True, 
   "loop physical projections" -> True, "linear evanescent norm equation" -> 
    True, "loop dimensional norm reconstructs" -> True, 
   "general loop radius reconstructs" -> True, 
   "compact dimensional scalar identity" -> True, 
   "inherited massless specialization" -> True, 
   "complete inherited virtual inventory" -> True, 
   "uniform native spinor dimension" -> True, "one inherited Born gluon" -> 
    True, "all compact scalar products restored" -> True, 
   "fully scalar virtual contraction" -> True, 
   "denominators independent of normal angle" -> True, 
   "polynomial angular numerator" -> True, 
   "angular numerator reconstruction" -> True, "evaluated angular moment" -> 
    True, "inherited initial average" -> True, 
   "inherited charge normalization" -> True, 
   "native physical photon projection interface" -> True, 
   "accepted compact calculation source" -> True, 
   "single reviewed gluon-completion change" -> True, 
   "unchanged other spin-contraction definitions" -> True, 
   "unchanged complete virtual diagram algebra" -> True, 
   "reviewed original virtual source" -> True, 
   "compact virtual comparison exists" -> True, 
   "compact virtual comparison accepted" -> True, 
   "native virtual spin closure" -> True, 
   "polynomial dependence on resolved spin" -> True, 
   "exact spin polynomial decomposition" -> True, 
   "virtual photon reconstruction" -> True, "virtual spin reconstruction" -> 
    True, "entire inherited Born spin response" -> True, 
   "comparison source syntax" -> True, "actual failing interface binding" -> 
    True, "native photon interface {4, 4, eL, eL}" -> True, 
   "native photon interface {4, 4, eL, eX}" -> True, 
   "native photon interface {4, 4, eL, eY}" -> True, 
   "native photon interface {4, 4, eL, p}" -> True, 
   "native photon interface {4, 4, eL, q}" -> True, 
   "native photon interface {4, 4, eX, eL}" -> True, 
   "native photon interface {4, 4, eX, eX}" -> True, 
   "native photon interface {4, 4, eX, eY}" -> True, 
   "native photon interface {4, 4, eX, p}" -> True, 
   "native photon interface {4, 4, eX, q}" -> True, 
   "native photon interface {4, 4, eY, eL}" -> True, 
   "native photon interface {4, 4, eY, eX}" -> True, 
   "native photon interface {4, 4, eY, eY}" -> True, 
   "native photon interface {4, 4, eY, p}" -> True, 
   "native photon interface {4, 4, eY, q}" -> True, 
   "native photon interface {4, 4, p, eL}" -> True, 
   "native photon interface {4, 4, p, eX}" -> True, 
   "native photon interface {4, 4, p, eY}" -> True, 
   "native photon interface {4, 4, p, p}" -> True, 
   "native photon interface {4, 4, p, q}" -> True, 
   "native photon interface {4, 4, q, eL}" -> True, 
   "native photon interface {4, 4, q, eX}" -> True, 
   "native photon interface {4, 4, q, eY}" -> True, 
   "native photon interface {4, 4, q, p}" -> True, 
   "native photon interface {4, 4, q, q}" -> True, 
   "native photon interface {4, D, eL, eL}" -> True, 
   "native photon interface {4, D, eL, eX}" -> True, 
   "native photon interface {4, D, eL, eY}" -> True, 
   "native photon interface {4, D, eL, p}" -> True, 
   "native photon interface {4, D, eL, q}" -> True, 
   "native photon interface {4, D, eX, eL}" -> True, 
   "native photon interface {4, D, eX, eX}" -> True, 
   "native photon interface {4, D, eX, eY}" -> True, 
   "native photon interface {4, D, eX, p}" -> True, 
   "native photon interface {4, D, eX, q}" -> True, 
   "native photon interface {4, D, eY, eL}" -> True, 
   "native photon interface {4, D, eY, eX}" -> True, 
   "native photon interface {4, D, eY, eY}" -> True, 
   "native photon interface {4, D, eY, p}" -> True, 
   "native photon interface {4, D, eY, q}" -> True, 
   "native photon interface {4, D, p, eL}" -> True, 
   "native photon interface {4, D, p, eX}" -> True, 
   "native photon interface {4, D, p, eY}" -> True, 
   "native photon interface {4, D, p, p}" -> True, 
   "native photon interface {4, D, p, q}" -> True, 
   "native photon interface {4, D, q, eL}" -> True, 
   "native photon interface {4, D, q, eX}" -> True, 
   "native photon interface {4, D, q, eY}" -> True, 
   "native photon interface {4, D, q, p}" -> True, 
   "native photon interface {4, D, q, q}" -> True, 
   "native photon interface {4, -4 + D, eL, eL}" -> True, 
   "native photon interface {4, -4 + D, eL, eX}" -> True, 
   "native photon interface {4, -4 + D, eL, eY}" -> True, 
   "native photon interface {4, -4 + D, eL, p}" -> True, 
   "native photon interface {4, -4 + D, eL, q}" -> True, 
   "native photon interface {4, -4 + D, eX, eL}" -> True, 
   "native photon interface {4, -4 + D, eX, eX}" -> True, 
   "native photon interface {4, -4 + D, eX, eY}" -> True, 
   "native photon interface {4, -4 + D, eX, p}" -> True, 
   "native photon interface {4, -4 + D, eX, q}" -> True, 
   "native photon interface {4, -4 + D, eY, eL}" -> True, 
   "native photon interface {4, -4 + D, eY, eX}" -> True, 
   "native photon interface {4, -4 + D, eY, eY}" -> True, 
   "native photon interface {4, -4 + D, eY, p}" -> True, 
   "native photon interface {4, -4 + D, eY, q}" -> True, 
   "native photon interface {4, -4 + D, p, eL}" -> True, 
   "native photon interface {4, -4 + D, p, eX}" -> True, 
   "native photon interface {4, -4 + D, p, eY}" -> True, 
   "native photon interface {4, -4 + D, p, p}" -> True, 
   "native photon interface {4, -4 + D, p, q}" -> True, 
   "native photon interface {4, -4 + D, q, eL}" -> True, 
   "native photon interface {4, -4 + D, q, eX}" -> True, 
   "native photon interface {4, -4 + D, q, eY}" -> True, 
   "native photon interface {4, -4 + D, q, p}" -> True, 
   "native photon interface {4, -4 + D, q, q}" -> True, 
   "native photon interface {D, 4, eL, eL}" -> True, 
   "native photon interface {D, 4, eL, eX}" -> True, 
   "native photon interface {D, 4, eL, eY}" -> True, 
   "native photon interface {D, 4, eL, p}" -> True, 
   "native photon interface {D, 4, eL, q}" -> True, 
   "native photon interface {D, 4, eX, eL}" -> True, 
   "native photon interface {D, 4, eX, eX}" -> True, 
   "native photon interface {D, 4, eX, eY}" -> True, 
   "native photon interface {D, 4, eX, p}" -> True, 
   "native photon interface {D, 4, eX, q}" -> True, 
   "native photon interface {D, 4, eY, eL}" -> True, 
   "native photon interface {D, 4, eY, eX}" -> True, 
   "native photon interface {D, 4, eY, eY}" -> True, 
   "native photon interface {D, 4, eY, p}" -> True, 
   "native photon interface {D, 4, eY, q}" -> True, 
   "native photon interface {D, 4, p, eL}" -> True, 
   "native photon interface {D, 4, p, eX}" -> True, 
   "native photon interface {D, 4, p, eY}" -> True, 
   "native photon interface {D, 4, p, p}" -> True, 
   "native photon interface {D, 4, p, q}" -> True, 
   "native photon interface {D, 4, q, eL}" -> True, 
   "native photon interface {D, 4, q, eX}" -> True, 
   "native photon interface {D, 4, q, eY}" -> True, 
   "native photon interface {D, 4, q, p}" -> True, 
   "native photon interface {D, 4, q, q}" -> True, 
   "native photon interface {D, D, eL, eL}" -> True, 
   "native photon interface {D, D, eL, eX}" -> True, 
   "native photon interface {D, D, eL, eY}" -> True, 
   "native photon interface {D, D, eL, p}" -> True, 
   "native photon interface {D, D, eL, q}" -> True, 
   "native photon interface {D, D, eX, eL}" -> True, 
   "native photon interface {D, D, eX, eX}" -> True, 
   "native photon interface {D, D, eX, eY}" -> True, 
   "native photon interface {D, D, eX, p}" -> True, 
   "native photon interface {D, D, eX, q}" -> True, 
   "native photon interface {D, D, eY, eL}" -> True, 
   "native photon interface {D, D, eY, eX}" -> True, 
   "native photon interface {D, D, eY, eY}" -> True, 
   "native photon interface {D, D, eY, p}" -> True, 
   "native photon interface {D, D, eY, q}" -> True, 
   "native photon interface {D, D, p, eL}" -> True, 
   "native photon interface {D, D, p, eX}" -> True, 
   "native photon interface {D, D, p, eY}" -> True, 
   "native photon interface {D, D, p, p}" -> True, 
   "native photon interface {D, D, p, q}" -> True, 
   "native photon interface {D, D, q, eL}" -> True, 
   "native photon interface {D, D, q, eX}" -> True, 
   "native photon interface {D, D, q, eY}" -> True, 
   "native photon interface {D, D, q, p}" -> True, 
   "native photon interface {D, D, q, q}" -> True, 
   "native photon interface {D, -4 + D, eL, eL}" -> True, 
   "native photon interface {D, -4 + D, eL, eX}" -> True, 
   "native photon interface {D, -4 + D, eL, eY}" -> True, 
   "native photon interface {D, -4 + D, eL, p}" -> True, 
   "native photon interface {D, -4 + D, eL, q}" -> True, 
   "native photon interface {D, -4 + D, eX, eL}" -> True, 
   "native photon interface {D, -4 + D, eX, eX}" -> True, 
   "native photon interface {D, -4 + D, eX, eY}" -> True, 
   "native photon interface {D, -4 + D, eX, p}" -> True, 
   "native photon interface {D, -4 + D, eX, q}" -> True, 
   "native photon interface {D, -4 + D, eY, eL}" -> True, 
   "native photon interface {D, -4 + D, eY, eX}" -> True, 
   "native photon interface {D, -4 + D, eY, eY}" -> True, 
   "native photon interface {D, -4 + D, eY, p}" -> True, 
   "native photon interface {D, -4 + D, eY, q}" -> True, 
   "native photon interface {D, -4 + D, p, eL}" -> True, 
   "native photon interface {D, -4 + D, p, eX}" -> True, 
   "native photon interface {D, -4 + D, p, eY}" -> True, 
   "native photon interface {D, -4 + D, p, p}" -> True, 
   "native photon interface {D, -4 + D, p, q}" -> True, 
   "native photon interface {D, -4 + D, q, eL}" -> True, 
   "native photon interface {D, -4 + D, q, eX}" -> True, 
   "native photon interface {D, -4 + D, q, eY}" -> True, 
   "native photon interface {D, -4 + D, q, p}" -> True, 
   "native photon interface {D, -4 + D, q, q}" -> True, 
   "native photon interface {-4 + D, 4, eL, eL}" -> True, 
   "native photon interface {-4 + D, 4, eL, eX}" -> True, 
   "native photon interface {-4 + D, 4, eL, eY}" -> True, 
   "native photon interface {-4 + D, 4, eL, p}" -> True, 
   "native photon interface {-4 + D, 4, eL, q}" -> True, 
   "native photon interface {-4 + D, 4, eX, eL}" -> True, 
   "native photon interface {-4 + D, 4, eX, eX}" -> True, 
   "native photon interface {-4 + D, 4, eX, eY}" -> True, 
   "native photon interface {-4 + D, 4, eX, p}" -> True, 
   "native photon interface {-4 + D, 4, eX, q}" -> True, 
   "native photon interface {-4 + D, 4, eY, eL}" -> True, 
   "native photon interface {-4 + D, 4, eY, eX}" -> True, 
   "native photon interface {-4 + D, 4, eY, eY}" -> True, 
   "native photon interface {-4 + D, 4, eY, p}" -> True, 
   "native photon interface {-4 + D, 4, eY, q}" -> True, 
   "native photon interface {-4 + D, 4, p, eL}" -> True, 
   "native photon interface {-4 + D, 4, p, eX}" -> True, 
   "native photon interface {-4 + D, 4, p, eY}" -> True, 
   "native photon interface {-4 + D, 4, p, p}" -> True, 
   "native photon interface {-4 + D, 4, p, q}" -> True, 
   "native photon interface {-4 + D, 4, q, eL}" -> True, 
   "native photon interface {-4 + D, 4, q, eX}" -> True, 
   "native photon interface {-4 + D, 4, q, eY}" -> True, 
   "native photon interface {-4 + D, 4, q, p}" -> True, 
   "native photon interface {-4 + D, 4, q, q}" -> True, 
   "native photon interface {-4 + D, D, eL, eL}" -> True, 
   "native photon interface {-4 + D, D, eL, eX}" -> True, 
   "native photon interface {-4 + D, D, eL, eY}" -> True, 
   "native photon interface {-4 + D, D, eL, p}" -> True, 
   "native photon interface {-4 + D, D, eL, q}" -> True, 
   "native photon interface {-4 + D, D, eX, eL}" -> True, 
   "native photon interface {-4 + D, D, eX, eX}" -> True, 
   "native photon interface {-4 + D, D, eX, eY}" -> True, 
   "native photon interface {-4 + D, D, eX, p}" -> True, 
   "native photon interface {-4 + D, D, eX, q}" -> True, 
   "native photon interface {-4 + D, D, eY, eL}" -> True, 
   "native photon interface {-4 + D, D, eY, eX}" -> True, 
   "native photon interface {-4 + D, D, eY, eY}" -> True, 
   "native photon interface {-4 + D, D, eY, p}" -> True, 
   "native photon interface {-4 + D, D, eY, q}" -> True, 
   "native photon interface {-4 + D, D, p, eL}" -> True, 
   "native photon interface {-4 + D, D, p, eX}" -> True, 
   "native photon interface {-4 + D, D, p, eY}" -> True, 
   "native photon interface {-4 + D, D, p, p}" -> True, 
   "native photon interface {-4 + D, D, p, q}" -> True, 
   "native photon interface {-4 + D, D, q, eL}" -> True, 
   "native photon interface {-4 + D, D, q, eX}" -> True, 
   "native photon interface {-4 + D, D, q, eY}" -> True, 
   "native photon interface {-4 + D, D, q, p}" -> True, 
   "native photon interface {-4 + D, D, q, q}" -> True, 
   "native photon interface {-4 + D, -4 + D, eL, eL}" -> True, 
   "native photon interface {-4 + D, -4 + D, eL, eX}" -> True, 
   "native photon interface {-4 + D, -4 + D, eL, eY}" -> True, 
   "native photon interface {-4 + D, -4 + D, eL, p}" -> True, 
   "native photon interface {-4 + D, -4 + D, eL, q}" -> True, 
   "native photon interface {-4 + D, -4 + D, eX, eL}" -> True, 
   "native photon interface {-4 + D, -4 + D, eX, eX}" -> True, 
   "native photon interface {-4 + D, -4 + D, eX, eY}" -> True, 
   "native photon interface {-4 + D, -4 + D, eX, p}" -> True, 
   "native photon interface {-4 + D, -4 + D, eX, q}" -> True, 
   "native photon interface {-4 + D, -4 + D, eY, eL}" -> True, 
   "native photon interface {-4 + D, -4 + D, eY, eX}" -> True, 
   "native photon interface {-4 + D, -4 + D, eY, eY}" -> True, 
   "native photon interface {-4 + D, -4 + D, eY, p}" -> True, 
   "native photon interface {-4 + D, -4 + D, eY, q}" -> True, 
   "native photon interface {-4 + D, -4 + D, p, eL}" -> True, 
   "native photon interface {-4 + D, -4 + D, p, eX}" -> True, 
   "native photon interface {-4 + D, -4 + D, p, eY}" -> True, 
   "native photon interface {-4 + D, -4 + D, p, p}" -> True, 
   "native photon interface {-4 + D, -4 + D, p, q}" -> True, 
   "native photon interface {-4 + D, -4 + D, q, eL}" -> True, 
   "native photon interface {-4 + D, -4 + D, q, eX}" -> True, 
   "native photon interface {-4 + D, -4 + D, q, eY}" -> True, 
   "native photon interface {-4 + D, -4 + D, q, p}" -> True, 
   "native photon interface {-4 + D, -4 + D, q, q}" -> True, 
   "accepted virtual projection unchanged {eL, eL}" -> True, 
   "accepted virtual projection unchanged {eL, eX}" -> True, 
   "accepted virtual projection unchanged {eL, eY}" -> True, 
   "accepted virtual projection unchanged {eL, p}" -> True, 
   "accepted virtual projection unchanged {eL, q}" -> True, 
   "accepted virtual projection unchanged {eX, eL}" -> True, 
   "accepted virtual projection unchanged {eX, eX}" -> True, 
   "accepted virtual projection unchanged {eX, eY}" -> True, 
   "accepted virtual projection unchanged {eX, p}" -> True, 
   "accepted virtual projection unchanged {eX, q}" -> True, 
   "accepted virtual projection unchanged {eY, eL}" -> True, 
   "accepted virtual projection unchanged {eY, eX}" -> True, 
   "accepted virtual projection unchanged {eY, eY}" -> True, 
   "accepted virtual projection unchanged {eY, p}" -> True, 
   "accepted virtual projection unchanged {eY, q}" -> True, 
   "accepted virtual projection unchanged {p, eL}" -> True, 
   "accepted virtual projection unchanged {p, eX}" -> True, 
   "accepted virtual projection unchanged {p, eY}" -> True, 
   "accepted virtual projection unchanged {p, p}" -> True, 
   "accepted virtual projection unchanged {p, q}" -> True, 
   "accepted virtual projection unchanged {q, eL}" -> True, 
   "accepted virtual projection unchanged {q, eX}" -> True, 
   "accepted virtual projection unchanged {q, eY}" -> True, 
   "accepted virtual projection unchanged {q, p}" -> True, 
   "accepted virtual projection unchanged {q, q}" -> True, 
   "failing diagram explicit contraction {eL, eL}" -> True, 
   "failing diagram explicit contraction {eL, eX}" -> True, 
   "failing diagram explicit contraction {eL, eY}" -> True, 
   "failing diagram explicit contraction {eL, p}" -> True, 
   "failing diagram explicit contraction {eL, q}" -> True, 
   "failing diagram explicit contraction {eX, eL}" -> True, 
   "failing diagram explicit contraction {eX, eX}" -> True, 
   "failing diagram explicit contraction {eX, eY}" -> True, 
   "failing diagram explicit contraction {eX, p}" -> True, 
   "failing diagram explicit contraction {eX, q}" -> True, 
   "failing diagram explicit contraction {eY, eL}" -> True, 
   "failing diagram explicit contraction {eY, eX}" -> True, 
   "failing diagram explicit contraction {eY, eY}" -> True, 
   "failing diagram explicit contraction {eY, p}" -> True, 
   "failing diagram explicit contraction {eY, q}" -> True, 
   "failing diagram explicit contraction {p, eL}" -> True, 
   "failing diagram explicit contraction {p, eX}" -> True, 
   "failing diagram explicit contraction {p, eY}" -> True, 
   "failing diagram explicit contraction {p, p}" -> True, 
   "failing diagram explicit contraction {p, q}" -> True, 
   "failing diagram explicit contraction {q, eL}" -> True, 
   "failing diagram explicit contraction {q, eX}" -> True, 
   "failing diagram explicit contraction {q, eY}" -> True, 
   "failing diagram explicit contraction {q, p}" -> True, 
   "failing diagram explicit contraction {q, q}" -> True, 
   "failing projection now fully scalar" -> True|>, 
 "FiniteNLOFHatsComputed" -> False|>
