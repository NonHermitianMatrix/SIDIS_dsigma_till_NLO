<|"Schema" -> "polarized-sidis-virtual-gauge-completion-v1", 
 "Channel" -> "Hqg", "ReferenceDifferences" -> <|"Pg" -> 0, "Ppp" -> 0|>, 
 "ResolvedDifferences" -> 
  <|"Pg" -> ((-1/2*I)*(-2 + D)*(Q^2 + s)*(-1 + SUNN)*(1 + SUNN)*
      (4*loopK^2*Q^4 - 2*D*loopK^2*Q^4 - 4*loopK*loopP*Q^4 + 
       2*D*loopK*loopP*Q^4 - 4*loopK*loopQ*Q^4 + 2*D*loopK*loopQ*Q^4 - 
       2*D*loopK^2*Q^2*s + 4*loopK*loopP*Q^2*s + 2*D*loopK*loopQ*Q^2*s - 
       4*loopK^2*s^2 + 4*loopK*loopQ*s^2 - 4*loopK^2*Q^2*t + 
       2*D*loopK^2*Q^2*t + 8*loopK*loopP*Q^2*t - 4*D*loopK*loopP*Q^2*t + 
       8*loopK*loopQ*Q^2*t - 4*D*loopK*loopQ*Q^2*t - 12*loopK^2*s*t + 
       2*D*loopK^2*s*t + 4*loopK*loopP*s*t + 8*loopK*loopQ*s*t - 
       2*D*loopK*loopQ*s*t - 2*loopSquare*Q^2*s*t + D*loopSquare*Q^2*s*t - 
       4*loopK*loopP*t^2 + 2*D*loopK*loopP*t^2 - 4*loopK*loopQ*t^2 + 
       2*D*loopK*loopQ*t^2 + 2*loopSquare*s*t^2 - D*loopSquare*s*t^2))/
     (loopSquare*(2*loopK + loopSquare)*(2*loopK - 2*loopP - 2*loopQ + 
       loopSquare)*s*SUNN^2*(Q^2 + s + t)*(Q^4 + Q^2*s + Q^2*t - s*t)), 
   "Ppp" -> 0|>, "BornDifferences" -> <|"Pg" -> 0, "Ppp" -> 0|>, 
 "ExtendedBornResidual" -> {{{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}}, {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}}, {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}}, {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}}, {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}}, {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}}, {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}}, {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}}, {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}}}, "CandidateDensity" -> 
  (1 + xOut)*FV[eOutX, rho]*FV[eOutX, sigma] + 
   ((-I)*hOut + yOut)*FV[eOutX, sigma]*FV[eOutY, rho] + 
   (I*hOut + yOut)*FV[eOutX, rho]*FV[eOutY, sigma] + 
   (1 - xOut)*FV[eOutY, rho]*FV[eOutY, sigma] - 
   (2*eOut*(((Q^2 + s + t)*Pair[LorentzIndex[rho], Momentum[eOutX]]*
        Pair[LorentzIndex[sigma], Momentum[eOutX]])/2 + 
      ((Q^2 + s + t)*Pair[LorentzIndex[rho], Momentum[eOutY]]*
        Pair[LorentzIndex[sigma], Momentum[eOutY]])/2 - 
      Pair[LorentzIndex[rho], Momentum[p]]*Pair[LorentzIndex[sigma], 
        Momentum[k1]] - Pair[LorentzIndex[rho], Momentum[k1]]*
       Pair[LorentzIndex[sigma], Momentum[p]] + 
      ((Q^2 + s + t)*Pair[LorentzIndex[rho, D], LorentzIndex[sigma, D]])/2))/
    (Q^2 + s + t), "Checks" -> <|"compute allocation" -> True, 
   "isolated runtime" -> True, "complete source syntax" -> True, 
   "supported virtual channel" -> True, "pinned amplitude" -> True, 
   "pinned virtual reference" -> True, "pinned original virtual source" -> 
    True, "accepted original virtual map" -> True, 
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
   "complete gauge-check source syntax" -> True, "resolved external gluon" -> 
    True, "native virtual spin closure" -> True, 
   "covariant first diagram reproduces reference" -> True, 
   "full Born tensor independent of compared gauge sums" -> True, 
   "physical spin density unchanged" -> True, 
   "auxiliary component completes reference sum" -> True, 
   "polynomial dependence on resolved spin" -> True, 
   "exact spin polynomial decomposition" -> True, 
   "virtual photon reconstruction" -> True, "virtual spin reconstruction" -> 
    True, "entire extended Born response unchanged" -> True|>, 
 "SourceHash" -> 763865792896907078731002695232061835533245665512100324716156\
97969590870374472, "CalculationSourceHash" -> 
  989613985679858728132829884755287536590702617251322160101824230569328618127\
47, "InputHashes" -> 
  <|"Amplitudes" -> 597119391575364249965637204080445655471003021170190008112\
78616020503015517097, "Reference" -> 
    3161343664648254953248038480823319051621003733910858107697110609956227461\
2207, "Born" -> 1087885345897816454531165300091680687258220731517642941013981\
30228693883946394, "Basis" -> 
    8763488122700630353093597572583533003994794907904231568983159969497876529\
341, "Angular" -> 
    6832582559442704311260834015700865252638007872011695004391325773511943728\
3507|>, "FiniteNLOFHatsComputed" -> False|>
