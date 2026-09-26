<|"Schema" -> "polarized-sidis-virtual-gauge-completion-v1", 
 "Channel" -> "Hgq", "ReferenceDifferences" -> <|"Pg" -> 0, "Ppp" -> 0|>, 
 "ResolvedDifferences" -> 
  <|"Pg" -> (I*(4*loopK*loopP*Q^4 - 2*D*loopK*loopP*Q^4 - 4*loopP^2*Q^4 + 
       2*D*loopP^2*Q^4 - 4*loopP*loopQ*Q^4 + 2*D*loopP*loopQ*Q^4 - 
       8*loopK*loopP*Q^2*s + 4*D*loopK*loopP*Q^2*s + 4*loopP^2*Q^2*s - 
       2*D*loopP^2*Q^2*s + 8*loopP*loopQ*Q^2*s - 4*D*loopP*loopQ*Q^2*s + 
       4*loopK*loopP*s^2 - 2*D*loopK*loopP*s^2 - 4*loopP*loopQ*s^2 + 
       2*D*loopP*loopQ*s^2 - 4*loopK*loopP*Q^2*t + 2*D*loopP^2*Q^2*t + 
       2*D*loopP*loopQ*Q^2*t - 4*loopK*loopP*s*t + 12*loopP^2*s*t - 
       2*D*loopP^2*s*t + 8*loopP*loopQ*s*t - 2*D*loopP*loopQ*s*t + 
       2*loopSquare*Q^2*s*t - D*loopSquare*Q^2*s*t - 2*loopSquare*s^2*t + 
       D*loopSquare*s^2*t + 4*loopP^2*t^2 + 4*loopP*loopQ*t^2))/
     ((2*loopP - loopSquare)*(-2*loopK + 2*loopP + 2*loopQ - loopSquare)*
      loopSquare*(Q^2 + s)*SUNN*t*(Q^2 + s + t)), 
   "Ppp" -> ((2*I)*s*(-4*loopK*loopP + 4*loopP^2 + 4*loopP*loopQ + 
       loopSquare*t))/((2*loopP - loopSquare)*(-2*loopK + 2*loopP + 2*loopQ - 
       loopSquare)*loopSquare*(Q^2 + s)*SUNN)|>, 
 "BornDifferences" -> <|"Pg" -> 0, "Ppp" -> 0|>, 
 "ExtendedBornResidual" -> {{{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}, {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}, {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}, {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}, {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}, {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}, {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}, {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}, {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}}, "CandidateDensity" -> 
  (1 + xIn)*FV[eX, rho]*FV[eX, sigma] + (I*hIn + yIn)*FV[eX, sigma]*
    FV[eY, rho] + ((-I)*hIn + yIn)*FV[eX, rho]*FV[eY, sigma] + 
   (1 - xIn)*FV[eY, rho]*FV[eY, sigma] - 
   (2*eIn*(((Q^2 + s + t)*Pair[LorentzIndex[rho], Momentum[eX]]*
        Pair[LorentzIndex[sigma], Momentum[eX]])/2 + 
      ((Q^2 + s + t)*Pair[LorentzIndex[rho], Momentum[eY]]*
        Pair[LorentzIndex[sigma], Momentum[eY]])/2 - 
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
  <|"Amplitudes" -> 655471340322074087856599014813249585032429371163428251817\
30381327027082815723, "Reference" -> 
    9062876149983414340255853214814472033956278405533456939566915626825214599\
4082, "Born" -> 
    3937218957859342209249692428721431450797304271755081438031415128820836556\
0183, "Basis" -> 
    8763488122700630353093597572583533003994794907904231568983159969497876529\
341, "Angular" -> 
    6832582559442704311260834015700865252638007872011695004391325773511943728\
3507|>, "FiniteNLOFHatsComputed" -> False|>
