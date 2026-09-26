<|"Schema" -> "polarized-sidis-transverse-average-v1", 
 "ExternalMomenta" -> {p, q, k1}, "ExternalGram" -> 
  {{0, (Q2 + s)/2, (Q2 + s - s23 + t)/2}, {(Q2 + s)/2, -Q2, (-Q2 - t)/2}, 
   {(Q2 + s - s23 + t)/2, (-Q2 - t)/2, 0}}, 
 "InvariantMap" -> {pq -> (Q2 + s)/2, pk1 -> (Q2 + s - s23 + t)/2, 
   pk2 -> (s23 - t + u3)/2, qk1 -> (-Q2 - t)/2, qk2 -> (a12 + t - u3)/2, 
   k1k2 -> a12/2}, "ParallelCoefficients" -> 
  {(a12*Q2*s23 + Q2^2*s23 + a12*Q2*t + 2*a12*s*t + Q2*s*t - a12*s23*t + 
     Q2*s23*t + a12*t^2 + s*t^2 - Q2*s*u3 + Q2*s23*u3 - s*t*u3 + s23*t*u3)/
    (2*(Q2^2*s23 + Q2*s*s23 - Q2*s23^2 + Q2*s*t + s^2*t + Q2*s23*t - 
      s*s23*t + s*t^2)), (-(a12*s23) + Q2*s23 + a12*t + s*t - s*u3 + s23*u3)/
    (2*(Q2*s23 + s*t)), (a12*Q2*s23 - Q2^2*s23 + a12*s*s23 - Q2*s*s23 + 
     2*Q2*s23^2 - a12*Q2*t - a12*s*t - Q2*s*t - s^2*t - 2*Q2*s23*t + 
     2*s*s23*t - 2*s*t^2 + Q2*s*u3 + s^2*u3 + Q2*s23*u3 - s*s23*u3 + 
     2*s*t*u3)/(2*(Q2^2*s23 + Q2*s*s23 - Q2*s23^2 + Q2*s*t + s^2*t + 
      Q2*s23*t - s*s23*t + s*t^2))}, "CutEuclideanRadiusSquared" -> 
  (a12^2*s23^2 + 2*a12*Q2*s23^2 + Q2^2*s23^2 - 2*a12^2*s23*t - 
    2*a12*Q2*s23*t + 2*a12*s*s23*t + 2*Q2*s*s23*t + a12^2*t^2 - 2*a12*s*t^2 + 
    s^2*t^2 + 4*a12*Q2*s23*u3 + 2*a12*s*s23*u3 - 2*Q2*s*s23*u3 - 
    2*a12*s23^2*u3 + 2*Q2*s23^2*u3 + 2*a12*s*t*u3 - 2*s^2*t*u3 + 
    2*a12*s23*t*u3 + 2*s*s23*t*u3 + s^2*u3^2 - 2*s*s23*u3^2 + s23^2*u3^2)/
   (4*(Q2 + s - s23 + t)*(Q2*s23 + s*t)), "GeneralEuclideanRadiusSquared" -> 
  -((normalMomentumSquare*Q2^2*s23 + normalMomentumSquare*Q2*s*s23 - 
     normalMomentumSquare*Q2*s23^2 + normalMomentumSquare*Q2*s*t + 
     normalMomentumSquare*s^2*t + normalMomentumSquare*Q2*s23*t - 
     normalMomentumSquare*s*s23*t + normalMomentumSquare*s*t^2 - 
     Q2^2*longitudinalProduct[1]^2 - 2*Q2*t*longitudinalProduct[1]^2 - 
     t^2*longitudinalProduct[1]^2 - 2*Q2^2*longitudinalProduct[1]*
      longitudinalProduct[2] - 2*Q2*s*longitudinalProduct[1]*
      longitudinalProduct[2] + 2*Q2*s23*longitudinalProduct[1]*
      longitudinalProduct[2] - 4*Q2*t*longitudinalProduct[1]*
      longitudinalProduct[2] - 2*s*t*longitudinalProduct[1]*
      longitudinalProduct[2] + 2*s23*t*longitudinalProduct[1]*
      longitudinalProduct[2] - 2*t^2*longitudinalProduct[1]*
      longitudinalProduct[2] - Q2^2*longitudinalProduct[2]^2 - 
     2*Q2*s*longitudinalProduct[2]^2 - s^2*longitudinalProduct[2]^2 + 
     2*Q2*s23*longitudinalProduct[2]^2 + 2*s*s23*longitudinalProduct[2]^2 - 
     s23^2*longitudinalProduct[2]^2 - 2*Q2*t*longitudinalProduct[2]^2 - 
     2*s*t*longitudinalProduct[2]^2 + 2*s23*t*longitudinalProduct[2]^2 - 
     t^2*longitudinalProduct[2]^2 + 2*Q2^2*longitudinalProduct[1]*
      longitudinalProduct[3] + 2*Q2*s*longitudinalProduct[1]*
      longitudinalProduct[3] - 4*Q2*s23*longitudinalProduct[1]*
      longitudinalProduct[3] + 2*Q2*t*longitudinalProduct[1]*
      longitudinalProduct[3] - 2*s*t*longitudinalProduct[1]*
      longitudinalProduct[3] + 2*Q2^2*longitudinalProduct[2]*
      longitudinalProduct[3] + 4*Q2*s*longitudinalProduct[2]*
      longitudinalProduct[3] + 2*s^2*longitudinalProduct[2]*
      longitudinalProduct[3] - 2*Q2*s23*longitudinalProduct[2]*
      longitudinalProduct[3] - 2*s*s23*longitudinalProduct[2]*
      longitudinalProduct[3] + 2*Q2*t*longitudinalProduct[2]*
      longitudinalProduct[3] + 2*s*t*longitudinalProduct[2]*
      longitudinalProduct[3] - Q2^2*longitudinalProduct[3]^2 - 
     2*Q2*s*longitudinalProduct[3]^2 - s^2*longitudinalProduct[3]^2)/
    ((Q2 + s - s23 + t)*(Q2*s23 + s*t))), "PhysicalDimension" -> 4, 
 "PhysicalNormalDimension" -> 1, "EvanescentDimension" -> -4 + dimension, 
 "OrthogonalDimension" -> -3 + dimension, 
 "SphereWeight" -> (1 - uFraction)^(-1 + (-4 + dimension)/2)/Sqrt[uFraction], 
 "SphereNormalization" -> (Sqrt[Pi]*Gamma[-2 + dimension/2])/
   Gamma[(-3 + dimension)/2], "GenericEvenMoment" -> 
  ((-1)^bPower*radiusSquared^(aPower + bPower)*Gamma[1/2 + aPower]*
    Gamma[-2 + bPower + dimension/2]*Gamma[(-3 + dimension)/2])/
   (Sqrt[Pi]*Gamma[-2 + dimension/2]*Gamma[-3/2 + aPower + bPower + 
      dimension/2]), "GaussianMomentRatio" -> 
  (Gamma[1/2 + aPower]*Gamma[-2 + bPower + dimension/2]*
    Gamma[(-3 + dimension)/2])/(Sqrt[Pi]*Gamma[-2 + dimension/2]*
    Gamma[-3/2 + aPower + bPower + dimension/2]), 
 "MomentIndexMeaning" -> {"power of k2 dot physical normal", 
   "power of Minkowski evanescent k2 squared"}, 
 "MomentTable" -> <|{0, 0} -> 1, 
   {0, 1} -> -(((-4 + dimension)*radiusSquared)/(-3 + dimension)), 
   {0, 2} -> ((-4 + dimension)*(-2 + dimension)*radiusSquared^2)/
     ((-3 + dimension)*(-1 + dimension)), 
   {0, 3} -> -(((-4 + dimension)*(-2 + dimension)*dimension*radiusSquared^3)/
      ((-3 + dimension)*(-1 + dimension)*(1 + dimension))), 
   {0, 4} -> ((-4 + dimension)*(-2 + dimension)*dimension*(2 + dimension)*
      radiusSquared^4)/((-3 + dimension)*(-1 + dimension)*(1 + dimension)*
      (3 + dimension)), {0, 5} -> 
    -(((-4 + dimension)*(-2 + dimension)*dimension*(2 + dimension)*
       (4 + dimension)*radiusSquared^5)/((-3 + dimension)*(-1 + dimension)*
       (1 + dimension)*(3 + dimension)*(5 + dimension))), 
   {0, 6} -> ((-4 + dimension)*(-2 + dimension)*dimension*(2 + dimension)*
      (4 + dimension)*(6 + dimension)*radiusSquared^6)/
     ((-3 + dimension)*(-1 + dimension)*(1 + dimension)*(3 + dimension)*
      (5 + dimension)*(7 + dimension)), {1, 0} -> 0, {1, 1} -> 0, 
   {1, 2} -> 0, {1, 3} -> 0, {1, 4} -> 0, {1, 5} -> 0, 
   {2, 0} -> radiusSquared/(-3 + dimension), 
   {2, 1} -> -(((-4 + dimension)*radiusSquared^2)/((-3 + dimension)*
       (-1 + dimension))), {2, 2} -> ((-4 + dimension)*(-2 + dimension)*
      radiusSquared^3)/((-3 + dimension)*(-1 + dimension)*(1 + dimension)), 
   {2, 3} -> -(((-4 + dimension)*(-2 + dimension)*dimension*radiusSquared^4)/
      ((-3 + dimension)*(-1 + dimension)*(1 + dimension)*(3 + dimension))), 
   {2, 4} -> ((-4 + dimension)*(-2 + dimension)*dimension*(2 + dimension)*
      radiusSquared^5)/((-3 + dimension)*(-1 + dimension)*(1 + dimension)*
      (3 + dimension)*(5 + dimension)), 
   {2, 5} -> -(((-4 + dimension)*(-2 + dimension)*dimension*(2 + dimension)*
       (4 + dimension)*radiusSquared^6)/((-3 + dimension)*(-1 + dimension)*
       (1 + dimension)*(3 + dimension)*(5 + dimension)*(7 + dimension))), 
   {3, 0} -> 0, {3, 1} -> 0, {3, 2} -> 0, {3, 3} -> 0, {3, 4} -> 0, 
   {4, 0} -> (3*radiusSquared^2)/((-3 + dimension)*(-1 + dimension)), 
   {4, 1} -> (-3*(-4 + dimension)*radiusSquared^3)/
     ((-3 + dimension)*(-1 + dimension)*(1 + dimension)), 
   {4, 2} -> (3*(-4 + dimension)*(-2 + dimension)*radiusSquared^4)/
     ((-3 + dimension)*(-1 + dimension)*(1 + dimension)*(3 + dimension)), 
   {4, 3} -> (-3*(-4 + dimension)*(-2 + dimension)*dimension*radiusSquared^5)/
     ((-3 + dimension)*(-1 + dimension)*(1 + dimension)*(3 + dimension)*
      (5 + dimension)), {4, 4} -> (3*(-4 + dimension)*(-2 + dimension)*
      dimension*(2 + dimension)*radiusSquared^6)/((-3 + dimension)*
      (-1 + dimension)*(1 + dimension)*(3 + dimension)*(5 + dimension)*
      (7 + dimension)), {5, 0} -> 0, {5, 1} -> 0, {5, 2} -> 0, {5, 3} -> 0, 
   {6, 0} -> (15*radiusSquared^3)/((-3 + dimension)*(-1 + dimension)*
      (1 + dimension)), {6, 1} -> (-15*(-4 + dimension)*radiusSquared^4)/
     ((-3 + dimension)*(-1 + dimension)*(1 + dimension)*(3 + dimension)), 
   {6, 2} -> (15*(-4 + dimension)*(-2 + dimension)*radiusSquared^5)/
     ((-3 + dimension)*(-1 + dimension)*(1 + dimension)*(3 + dimension)*
      (5 + dimension)), {6, 3} -> (-15*(-4 + dimension)*(-2 + dimension)*
      dimension*radiusSquared^6)/((-3 + dimension)*(-1 + dimension)*
      (1 + dimension)*(3 + dimension)*(5 + dimension)*(7 + dimension)), 
   {7, 0} -> 0, {7, 1} -> 0, {7, 2} -> 0, 
   {8, 0} -> (105*radiusSquared^4)/((-3 + dimension)*(-1 + dimension)*
      (1 + dimension)*(3 + dimension)), 
   {8, 1} -> (-105*(-4 + dimension)*radiusSquared^5)/
     ((-3 + dimension)*(-1 + dimension)*(1 + dimension)*(3 + dimension)*
      (5 + dimension)), {8, 2} -> (105*(-4 + dimension)*(-2 + dimension)*
      radiusSquared^6)/((-3 + dimension)*(-1 + dimension)*(1 + dimension)*
      (3 + dimension)*(5 + dimension)*(7 + dimension)), {9, 0} -> 0, 
   {9, 1} -> 0, {10, 0} -> (945*radiusSquared^5)/((-3 + dimension)*
      (-1 + dimension)*(1 + dimension)*(3 + dimension)*(5 + dimension)), 
   {10, 1} -> (-945*(-4 + dimension)*radiusSquared^6)/
     ((-3 + dimension)*(-1 + dimension)*(1 + dimension)*(3 + dimension)*
      (5 + dimension)*(7 + dimension)), {11, 0} -> 0, 
   {12, 0} -> (10395*radiusSquared^6)/((-3 + dimension)*(-1 + dimension)*
      (1 + dimension)*(3 + dimension)*(5 + dimension)*(7 + dimension))|>, 
 "VerificationDepth" -> 6, "Continuation" -> "Derive for dimension > 4, then \
continue the evaluated meromorphic expressions to dimension = 4 - 2 eps.", 
 "ConsumerRequirements" -> {"Denominators and measurement must be independent \
of the residual angular variables.", 
   "The complete numerator must reconstruct before its moments are replaced."\
, 
   "Retain positive-energy cuts and the original phase-space and loop \
measures.", "The physical p,q,k1 Gram matrix must have rank three (nonzero \
transverse momentum)."}, "Checks" -> <|"compute allocation" -> True, 
   "isolated runtime" -> True, "accepted spin basis" -> True, 
   "unique real invariant map" -> True, "invariant reconstruction" -> True, 
   "one physical normal direction" -> True, 
   "parallel projection reconstruction" -> True, 
   "general radius specializes to the cut radius" -> True, 
   "sphere integral evaluated" -> True, "sphere Gaussian agreement" -> True, 
   "odd normal moments vanish" -> True, "unit angular normalization" -> True, 
   "transverse radius reconstruction" -> True, 
   "continued integer moments are rational" -> True|>, 
 "SourceHash" -> 311609161938114856921027365150477359698309899175035861172297\
92287202183292532, "InputHash" -> 
  876348812270063035309359757258353300399479490790423156898315996949787652934\
1, "FiniteFHatsComputed" -> False|>
