<|"Schema" -> "polarized-sidis-real-coordinate-diagnostic-v1", 
 "Channel" -> "Hqqprime", "OldRows" -> {{p, p, 0}, {p, q, (Q2 + s)/2}, 
   {p, k1, (Q2 + s + t - w)/2}, {p, k2, -1/2*a}, {p, k3, (a - t + w)/2}, 
   {q, q, -Q2}, {q, k1, (-Q2 - t)/2}, {q, k2, (a + b + w)/2}, 
   {q, k3, (-a - b + s + t - w)/2}, {k1, k1, 0}, {k1, k2, b/2}, 
   {k1, k3, (-b + s - w)/2}, {k2, k2, 0}, {k2, k3, w/2}, {k3, k3, 0}}, 
 "OldVariables" -> {Q2, s, t, w, a, b}, "TargetValues" -> 
  {0, (Q^2 + s)/2, (Q^2 + s - s23 + t)/2, (s23 - t + u3)/2, -1/2*u3, -Q^2, 
   (-Q^2 - t)/2, (a12 + t - u3)/2, (-a12 + s + u3)/2, 0, a12/2, 
   (-a12 + s - s23)/2, 0, s23/2, 0}, "TemporaryVariables" -> 
  {referenceInvariant39, referenceInvariant40, referenceInvariant41, 
   referenceInvariant42, referenceInvariant43, referenceInvariant44}, 
 "Solutions" -> {{referenceInvariant39 -> ConditionalExpression[Q^2, 
      s > 0 && s23 < s && Inequality[-Q^2 - s + s23, Less, t, Less, 
        -((Q^2*s23)/s)]], referenceInvariant40 -> ConditionalExpression[s, 
      s > 0 && s23 < s && Inequality[-Q^2 - s + s23, Less, t, Less, 
        -((Q^2*s23)/s)]], referenceInvariant41 -> ConditionalExpression[t, 
      s > 0 && s23 < s && Inequality[-Q^2 - s + s23, Less, t, Less, 
        -((Q^2*s23)/s)]], referenceInvariant42 -> ConditionalExpression[s23, 
      s > 0 && s23 < s && Inequality[-Q^2 - s + s23, Less, t, Less, 
        -((Q^2*s23)/s)]], referenceInvariant43 -> ConditionalExpression[
      -s23 + t - u3, s > 0 && s23 < s && Inequality[-Q^2 - s + s23, Less, t, 
        Less, -((Q^2*s23)/s)]], referenceInvariant44 -> 
     ConditionalExpression[a12, s > 0 && s23 < s && 
       Inequality[-Q^2 - s + s23, Less, t, Less, -((Q^2*s23)/s)]]}}, 
 "SourceHash" -> 345777160329559606328067198073294920785736715190320078138414\
64269207160654665, "ProductionSourceHash" -> 
  955679935385275384017011419623718512432731168686246536365345169614452584810\
28, "Checks" -> <|"compute allocation" -> True, "isolated runtime" -> True, 
   "complete source syntax" -> True, "known channel" -> True, 
   "pinned input \
Hqqprime/s01_result/reference/s01_result/s01_inputs/s01_result/real.wl" -> 
    True, "pinned input Hqqprime/s05_result/reference/unpolarized_real.wl" -> 
    True, "accepted spin basis" -> True, "accepted angular moments" -> True, 
   "real longitudinal frame linear" -> True, 
   "real longitudinal frame nonsingular" -> True, 
   "real longitudinal frame reconstructs" -> True, 
   "real energy linear" -> True, "real energy nonsingular" -> True, 
   "real energy reconstructs" -> True, "real transverse coordinate linear" -> 
    True, "real transverse coordinate nonsingular" -> True, 
   "real transverse coordinate reconstructs" -> True, 
   "real frame invariants" -> True, 
   "positive measured transverse momentum" -> True, 
   "unconditional exact algebra" -> True, "transverse rational function" -> 
    True, "rationalized transverse denominator" -> True, 
   "polynomial division reconstruction" -> True, 
   "complete rational reconstruction on shell" -> True, 
   "measured spin axes" -> True, "denominator Bezout reconstruction" -> True, 
   "invertible transverse denominator" -> True, 
   "unresolved physical projections" -> True, 
   "evanescent on-shell norm linear" -> True, 
   "evanescent on-shell norm nonsingular" -> True, 
   "evanescent on-shell norm reconstructs" -> True, 
   "inherited cut radius" -> True, 
   "one remaining physical normal coordinate" -> True, 
   "positive-energy support independent of normal angle" -> True, 
   "compact real dimensional scalar identities" -> True, 
   "incoming photon-basis projection" -> True, "diagnostic source syntax" -> 
    True|>, "AcceptedRealTensor" -> False|>
