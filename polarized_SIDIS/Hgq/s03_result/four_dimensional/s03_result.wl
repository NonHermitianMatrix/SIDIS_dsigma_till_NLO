<|"Schema" -> "polarized-sidis-born-response-v1", "Channel" -> "Hgq", 
 "PhotonLabels" -> {"LL", "XX", "YY", "ReLX", "ReLY", "ReXY", "ImLX", "ImLY", 
   "ImXY"}, "SpinLabels" -> {"U", "X", "Y", "H"}, 
 "IndexOrder" -> {"photon component", "outgoing spin", "incoming spin"}, 
 "Response" -> {{{(8*Q^2*s)/(Q^2 + s)^2, (8*Q^2*s)/(Q^2 + s)^2, 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}, 
   {{-((Q^8 + 2*Q^6*s + 2*Q^4*s^2 + 2*Q^2*s^3 + s^4 + 2*Q^6*t - 2*Q^4*s*t - 
        2*Q^2*s^2*t + 2*s^3*t + 2*Q^4*t^2 - 4*Q^2*s*t^2 + 2*s^2*t^2)/
       ((Q^2 + s)^2*t*(Q^2 + s + t))), (2*(Q^4 + Q^2*s + Q^2*t - s*t)*
       (Q^2*s + s^2 - Q^2*t + s*t))/((Q^2 + s)^2*t*(Q^2 + s + t)), 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 
     -(((Q^2 - s)*(Q^2 + s + 2*t))/(t*(Q^2 + s + t)))}}, 
   {{-((Q^4 + s^2 + 2*Q^2*t + 2*s*t + 2*t^2)/(t*(Q^2 + s + t))), 
     (2*(Q^2 + t)*(s + t))/(t*(Q^2 + s + t)), 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, -(((Q^2 - s)*(Q^2 + s + 2*t))/
       (t*(Q^2 + s + t)))}}, 
   {{(2*Q*(Q^2 - s)*Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)]*(Q^2 + s + 2*t))/
      ((Q^2 + s)*t*(Q^2 + s + t)), 
     (2*Q*(Q^2 - s)*Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)]*(Q^2 + s + 2*t))/
      ((Q^2 + s)*t*(Q^2 + s + t)), 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, (2*Q*(Q^2 + s)*Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)])/
      (t*(Q^2 + s + t))}}, 
   {{0, 0, (2*Q*Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)]*(Q^2 + s + 2*t))/
      (t*(Q^2 + s + t)), 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}, 
   {{0, 0, (-2*(Q^2 - s))/(Q^2 + s), 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}}, {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, (-2*Q*(Q^2 + s)*Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)])/
      (t*(Q^2 + s + t)), 0}}, 
   {{0, 0, 0, (2*Q*Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)]*(Q^2 + s + 2*t))/
      (t*(Q^2 + s + t))}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {(2*Q*(Q^2 - s)*Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)])/
      (t*(Q^2 + s + t)), (2*Q*(Q^2 - s)*
       Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)])/(t*(Q^2 + s + t)), 0, 0}}, 
   {{0, 0, 0, -(((Q^2 - s)*(Q^4 + 2*Q^2*s + s^2 + 2*Q^2*t + 2*s*t + 2*t^2))/
       ((Q^2 + s)*t*(Q^2 + s + t)))}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {-(((Q^4 + s^2)*(Q^2 + s + 2*t))/((Q^2 + s)*t*(Q^2 + s + t))), 
     (2*Q^2*s*(Q^2 + s + 2*t))/((Q^2 + s)*t*(Q^2 + s + t)), 0, 0}}}, 
 "PhotonMatrix" -> {{(8*Q^2*s*(1 + xIn))/(Q^2 + s)^2, 
    (2*Q*Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)]*(Q^4 + hIn*hOut*Q^4 + 
       2*hIn*hOut*Q^2*s - s^2 + hIn*hOut*s^2 + 2*Q^2*t - 2*s*t + Q^4*xIn - 
       s^2*xIn + 2*Q^2*t*xIn - 2*s*t*xIn + I*hOut*Q^4*yIn + 
       (2*I)*hOut*Q^2*s*yIn + I*hOut*s^2*yIn))/((Q^2 + s)*t*(Q^2 + s + t)), 
    (2*Q*Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)]*((-I)*hIn*Q^2 - 
       I*hOut*Q^2 - I*hIn*s + I*hOut*s - (2*I)*hIn*t - I*hOut*Q^2*xIn + 
       I*hOut*s*xIn + Q^2*yIn + s*yIn + 2*t*yIn))/(t*(Q^2 + s + t))}, 
   {(2*Q*Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)]*(Q^4 + hIn*hOut*Q^4 + 
       2*hIn*hOut*Q^2*s - s^2 + hIn*hOut*s^2 + 2*Q^2*t - 2*s*t + Q^4*xIn - 
       s^2*xIn + 2*Q^2*t*xIn - 2*s*t*xIn - I*hOut*Q^4*yIn - 
       (2*I)*hOut*Q^2*s*yIn - I*hOut*s^2*yIn))/((Q^2 + s)*t*(Q^2 + s + t)), 
    -((Q^8 + hIn*hOut*Q^8 + 2*Q^6*s + 2*hIn*hOut*Q^6*s + 2*Q^4*s^2 + 
       2*Q^2*s^3 - 2*hIn*hOut*Q^2*s^3 + s^4 - hIn*hOut*s^4 + 2*Q^6*t + 
       2*hIn*hOut*Q^6*t - 2*Q^4*s*t + 2*hIn*hOut*Q^4*s*t - 2*Q^2*s^2*t - 
       2*hIn*hOut*Q^2*s^2*t + 2*s^3*t - 2*hIn*hOut*s^3*t + 2*Q^4*t^2 - 
       4*Q^2*s*t^2 + 2*s^2*t^2 - 2*Q^6*s*xIn - 4*Q^4*s^2*xIn - 
       2*Q^2*s^3*xIn + 2*Q^6*t*xIn - 2*Q^4*s*t*xIn - 2*Q^2*s^2*t*xIn + 
       2*s^3*t*xIn + 2*Q^4*t^2*xIn - 4*Q^2*s*t^2*xIn + 2*s^2*t^2*xIn)/
      ((Q^2 + s)^2*t*(Q^2 + s + t))), (I*hIn*Q^6 + I*hOut*Q^6 + I*hIn*Q^4*s + 
      I*hOut*Q^4*s - I*hIn*Q^2*s^2 + I*hOut*Q^2*s^2 - I*hIn*s^3 + 
      I*hOut*s^3 + (2*I)*hIn*Q^4*t + (2*I)*hOut*Q^4*t - (2*I)*hIn*s^2*t + 
      (2*I)*hOut*s^2*t + (2*I)*hIn*Q^2*t^2 - (2*I)*hIn*s*t^2 - 
      (2*I)*hOut*Q^4*s*xIn - (2*I)*hOut*Q^2*s^2*xIn - 
      (4*I)*hOut*Q^2*s*t*xIn - 2*Q^4*t*yIn + 2*s^2*t*yIn - 2*Q^2*t^2*yIn + 
      2*s*t^2*yIn)/((Q^2 + s)*t*(Q^2 + s + t))}, 
   {(2*Q*Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)]*(I*hIn*Q^2 + I*hOut*Q^2 + 
       I*hIn*s - I*hOut*s + (2*I)*hIn*t + I*hOut*Q^2*xIn - I*hOut*s*xIn + 
       Q^2*yIn + s*yIn + 2*t*yIn))/(t*(Q^2 + s + t)), 
    ((-I)*hIn*Q^6 - I*hOut*Q^6 - I*hIn*Q^4*s - I*hOut*Q^4*s + I*hIn*Q^2*s^2 - 
      I*hOut*Q^2*s^2 + I*hIn*s^3 - I*hOut*s^3 - (2*I)*hIn*Q^4*t - 
      (2*I)*hOut*Q^4*t + (2*I)*hIn*s^2*t - (2*I)*hOut*s^2*t - 
      (2*I)*hIn*Q^2*t^2 + (2*I)*hIn*s*t^2 + (2*I)*hOut*Q^4*s*xIn + 
      (2*I)*hOut*Q^2*s^2*xIn + (4*I)*hOut*Q^2*s*t*xIn - 2*Q^4*t*yIn + 
      2*s^2*t*yIn - 2*Q^2*t^2*yIn + 2*s*t^2*yIn)/((Q^2 + s)*t*(Q^2 + s + t)), 
    (-Q^4 - hIn*hOut*Q^4 - s^2 + hIn*hOut*s^2 - 2*Q^2*t - 2*hIn*hOut*Q^2*t - 
      2*s*t + 2*hIn*hOut*s*t - 2*t^2 + 2*Q^2*s*xIn + 2*Q^2*t*xIn + 
      2*s*t*xIn + 2*t^2*xIn)/(t*(Q^2 + s + t))}}, 
 "Frame" -> <|p -> {(Q^2 + s)/(2*Q), 0, 0, (Q^2 + s)/(2*Q)}, 
   q -> {0, 0, 0, -Q}, k1 -> {(Q^4 + Q^2*s + Q^2*t - s*t)/(2*Q*(Q^2 + s)), 
     Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)], 0, -1/2*(Q^2 + t)/Q}, 
   k2 -> {(Q^2 + s)/(2*Q) - (Q^4 + Q^2*s + Q^2*t - s*t)/(2*Q*(Q^2 + s)), 
     -Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)], 0, -Q + (Q^2 + s)/(2*Q) + 
      (Q^2 + t)/(2*Q)}, eL -> {1, 0, 0, 0}, eX -> {0, 1, 0, 0}, 
   eY -> {0, 0, 1, 0}, eZ -> {0, 0, 0, 1}, 
   eOutX -> {0, -(((Q^2 + s)*(Q^2 + t))/(Q^4 + Q^2*s + Q^2*t - s*t)), 0, 
     (-2*Q*(Q^2 + s)*Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)])/
      (Q^4 + Q^2*s + Q^2*t - s*t)}, eOutY -> {0, 0, 1, 0}|>, 
 "AlgebraicResponse" -> {{{(8*Q^2*s)/(Q^2 + s)^2, (8*Q^2*s)/(Q^2 + s)^2, 0, 
     0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}, 
   {{-((Q^8 + 2*Q^6*s + 2*Q^4*s^2 + 2*Q^2*s^3 + s^4 + 2*Q^6*t - 2*Q^4*s*t - 
        2*Q^2*s^2*t + 2*s^3*t + 2*Q^4*t^2 - 4*Q^2*s*t^2 + 2*s^2*t^2)/
       ((Q^2 + s)^2*t*(Q^2 + s + t))), (2*(Q^4 + Q^2*s + Q^2*t - s*t)*
       (Q^2*s + s^2 - Q^2*t + s*t))/((Q^2 + s)^2*t*(Q^2 + s + t)), 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 
     -(((Q^2 - s)*(Q^2 + s + 2*t))/(t*(Q^2 + s + t)))}}, 
   {{-((Q^4 + s^2 + 2*Q^2*t + 2*s*t + 2*t^2)/(t*(Q^2 + s + t))), 
     (2*(Q^2 + t)*(s + t))/(t*(Q^2 + s + t)), 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, -(((Q^2 - s)*(Q^2 + s + 2*t))/
       (t*(Q^2 + s + t)))}}, {{(2*Q*(Q^2 - s)*(Q^2 + s + 2*t)*transverseK)/
      ((Q^2 + s)*t*(Q^2 + s + t)), (2*Q*(Q^2 - s)*(Q^2 + s + 2*t)*
       transverseK)/((Q^2 + s)*t*(Q^2 + s + t)), 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}, {0, 0, 0, (2*Q*(Q^2 + s)*transverseK)/(t*(Q^2 + s + t))}}, 
   {{0, 0, (2*Q*(Q^2 + s + 2*t)*transverseK)/(t*(Q^2 + s + t)), 0}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}, 
   {{0, 0, (-2*(Q^2 - s))/(Q^2 + s), 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, 0, 0}}, {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {0, 0, (-2*Q*(Q^2 + s)*transverseK)/(t*(Q^2 + s + t)), 0}}, 
   {{0, 0, 0, (2*Q*(Q^2 + s + 2*t)*transverseK)/(t*(Q^2 + s + t))}, 
    {0, 0, 0, 0}, {0, 0, 0, 0}, {(2*Q*(Q^2 - s)*transverseK)/
      (t*(Q^2 + s + t)), (2*Q*(Q^2 - s)*transverseK)/(t*(Q^2 + s + t)), 0, 
     0}}, {{0, 0, 0, -(((Q^2 - s)*(Q^4 + 2*Q^2*s + s^2 + 2*Q^2*t + 2*s*t + 
         2*t^2))/((Q^2 + s)*t*(Q^2 + s + t)))}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
    {-(((Q^4 + s^2)*(Q^2 + s + 2*t))/((Q^2 + s)*t*(Q^2 + s + t))), 
     (2*Q^2*s*(Q^2 + s + 2*t))/((Q^2 + s)*t*(Q^2 + s + t)), 0, 0}}}, 
 "TransverseSubstitution" -> transverseK -> 
   Sqrt[-((s*t*(Q^2 + s + t))/(Q^2 + s)^2)], "TransverseConstraint" -> 
  (s*t*(Q^2 + s + t))/(Q^2 + s)^2 + transverseK^2, 
 "FrameSolution" -> {ep -> (Q^2 + s)/(2*Q), kz -> -1/2*(Q^2 + t)/Q, 
   ek -> (Q^4 + Q^2*s + Q^2*t - s*t)/(2*Q*(Q^2 + s)), 
   kxSquared -> -((s*t*(Q^2 + s + t))/(Q^2 + s)^2)}, 
 "PhysicalRegion" -> Q > 0 && s > 0 && t < 0 && Q^2 + s + t > 0 && 
   SUNN > 1 && Element[Q | s | t | SUNN | xIn | yIn | hIn | xOut | yOut | 
     hOut, Reals], "ReferenceBornPg" -> 
  (2*(Q^4 + s^2 + 2*Q^2*t + 2*s*t + 2*t^2))/(t*(Q^2 + s + t)), 
 "ReferenceBornPpp" -> 2*s, "CouplingsRemoved" -> "e_q^2 g_s^2", 
 "PhaseSpaceIncluded" -> False, "Dimension" -> 4, 
 "NLOEpsilonTermsIncluded" -> False, "FiniteNLOFHatsComputed" -> False, 
 "IncomingNormalization" -> 2*(-1 + SUNN^2), "ModelChargeSquared" -> 4/9, 
 "EpsilonOrientation" -> -1, "Checks" -> <|"compute allocation" -> True, 
   "supported Born channel" -> True, "isolated runtime" -> True, 
   "basis schema" -> True, "basis checks" -> True, 
   "amplitude identity" -> True, "reference charge normalization" -> True, 
   "one Born gluon" -> True, "channel spin assignments" -> True, 
   "longitudinal frame is linear" -> True, 
   "longitudinal frame is nonsingular in the physical region" -> True, 
   "longitudinal frame linear reconstruction" -> True, 
   "tagged energy is linear" -> True, 
   "tagged energy is nonsingular in the physical region" -> True, 
   "tagged energy linear reconstruction" -> True, 
   "tagged transverse momentum is linear" -> True, 
   "tagged transverse momentum is nonsingular in the physical region" -> 
    True, "tagged transverse momentum linear reconstruction" -> True, 
   "Born frame reconstructs invariants" -> True, 
   "central tagged direction retained" -> True, 
   "unconditional algebraic input" -> True, 
   "transverse-independent denominator" -> True, 
   "polynomial transverse numerator" -> True, 
   "exact transverse reconstruction" -> True, "outgoing spin axes" -> True, 
   "native epsilon orientation determined" -> True, 
   "epsilon orientation is a sign" -> True, 
   "all fermion completeness factors replaced" -> True, 
   "scalar contraction resolved" -> True, "photon Hermiticity" -> True, 
   "photon Ward identity" -> True, "gluon Ward identity" -> True, 
   "photon reconstruction" -> True, "spin response reconstruction" -> True, 
   "photon frame is nonsingular" -> True, 
   "incoming momentum projection reconstructs" -> True, 
   "reference Born Pg" -> True, "reference Born Ppp" -> True|>, 
 "SourceHash" -> 961286209567605860402009661183406600062651229156773866273827\
87070372026452826, "InputHashes" -> 
  <|"Amplitudes" -> 655471340322074087856599014813249585032429371163428251817\
30381327027082815723, "SpinBasis" -> 
    8763488122700630353093597572583533003994794907904231568983159969497876529\
341, "UnpolarizedReference" -> 
    5873409842065947334309738532900076805647803403507560973683792524799441537\
9418|>, "PeakKernelMemoryBytes" -> 208101008, 
 "WolframVersion" -> "13.1.0 for Linux x86 (64-bit) (June 16, 2022)", 
 "FeynCalcVersion" -> "10.2.1"|>
