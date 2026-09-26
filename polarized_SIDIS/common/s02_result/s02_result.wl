<|"Schema" -> "polarized-sidis-spin-basis-v1", 
 "Scope" -> <|"jet_matching" -> "deferred", "measurement" -> 
    "reference-large-transverse-momentum-SIDIS", "numerics" -> "deferred", 
   "order" -> 
    "through alpha_s^2, reference nonzero-transverse-momentum counting", 
   "spin" -> "all-incoming-and-tagged-outgoing-components", 
   "working_gamma5_prescription" -> 
    "BMHV; finite scheme conversions require separate checks"|>, 
 "SpinLabels" -> {"U", "X", "Y", "H"}, "PauliMatrices" -> 
  {{{1, 0}, {0, 1}}, {{0, 1}, {1, 0}}, {{0, -I}, {I, 0}}, {{1, 0}, {0, -1}}}, 
 "PauliGram" -> {{2, 0, 0, 0}, {0, 2, 0, 0}, {0, 0, 2, 0}, {0, 0, 0, 2}}, 
 "IncomingDensityNormalization" -> 2, "OutgoingAnalyzerNormalization" -> 1, 
 "DensityMatrix" -> {{(1 + pz)/2, (px - I*py)/2}, 
   {(px + I*py)/2, (1 - pz)/2}}, "DensityEigenvalues" -> 
  {(1 - Sqrt[px^2 + py^2 + pz^2])/2, (1 + Sqrt[px^2 + py^2 + pz^2])/2}, 
 "QuarkDiracCoefficients" -> {{1, 0, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}, 
   {0, 1, 0, 0}}, "AntiquarkDiracCoefficients" -> 
  {{1, 0, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}, {0, -1, 0, 0}}, 
 "QuarkSpinNumerators" -> {GS[spinMomentum], GA[5] . GS[spinX] . 
    GS[spinMomentum], GA[5] . GS[spinY] . GS[spinMomentum], 
   GA[5] . GS[spinMomentum]}, "AntiquarkSpinNumerators" -> 
  {GS[spinMomentum], GA[5] . GS[spinX] . GS[spinMomentum], 
   GA[5] . GS[spinY] . GS[spinMomentum], -GA[5] . GS[spinMomentum]}, 
 "DiracBasis" -> {GS[spinMomentum], GA[5] . GS[spinMomentum], 
   GA[5] . GS[spinX] . GS[spinMomentum], GA[5] . GS[spinY] . 
    GS[spinMomentum]}, "GluonHelicityVectorsCanonical" -> 
  {{0, 0}, {1/Sqrt[2], 1/Sqrt[2]}, {I/Sqrt[2], (-I)/Sqrt[2]}, {0, 0}}, 
 "GluonStokesTensorsCanonical" -> {{{0, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, 
    {0, 0, 0, 0}}, {{0, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, -1, 0}, {0, 0, 0, 0}}, 
   {{0, 0, 0, 0}, {0, 0, 1, 0}, {0, 1, 0, 0}, {0, 0, 0, 0}}, 
   {{0, 0, 0, 0}, {0, 0, -I, 0}, {0, I, 0, 0}, {0, 0, 0, 0}}}, 
 "PhotonLabels" -> {"LL", "XX", "YY", "ReLX", "ReLY", "ReXY", "ImLX", "ImLY", 
   "ImXY"}, "PhotonBasis" -> {{{1, 0, 0}, {0, 0, 0}, {0, 0, 0}}, {{0, 0, 0}, 
   {0, 1, 0}, {0, 0, 0}}, {{0, 0, 0}, {0, 0, 0}, {0, 0, 1}}, {{0, 1, 0}, {1, 
   0, 0}, {0, 0, 0}}, {{0, 0, 1}, {0, 0, 0}, {1, 0, 0}}, {{0, 0, 0}, {0, 0, 
   1}, {0, 1, 0}}, {{0, -I, 0}, {I, 0, 0}, {0, 0, 0}}, 
   {{0, 0, -I}, {0, 0, 0}, {I, 0, 0}}, {{0, 0, 0}, {0, 0, -I}, {0, I, 0}}}, 
 "PhotonDual" -> {{{1, 0, 0}, {0, 0, 0}, {0, 0, 0}}, {{0, 0, 0}, {0, 1, 0}, 
   {0, 0, 0}}, {{0, 0, 0}, {0, 0, 0}, {0, 0, 1}}, 
   {{0, 1/2, 0}, {1/2, 0, 0}, {0, 0, 0}}, {{0, 0, 1/2}, {0, 0, 0}, 
    {1/2, 0, 0}}, {{0, 0, 0}, {0, 0, 1/2}, {0, 1/2, 0}}, 
   {{0, -1/2*I, 0}, {I/2, 0, 0}, {0, 0, 0}}, {{0, 0, -1/2*I}, {0, 0, 0}, 
    {I/2, 0, 0}}, {{0, 0, 0}, {0, 0, -1/2*I}, {0, I/2, 0}}}, 
 "PhotonMetric" -> {{1, 0, 0}, {0, -1, 0}, {0, 0, -1}}, 
 "SpinResponseIndexOrder" -> {"outgoing", "incoming"}, 
 "GluonLabels" -> <|"X" -> "linear Stokes 1", "Y" -> "linear Stokes 2", 
   "H" -> "helicity"|>, "AmplitudeInventory" -> 
  <|"Hqq" -> <|"InputSHA256" -> 
      "0dc987fe060db67a8fa060945380760b0ceb788843882e760c0a79959852297a", 
     "Sectors" -> <|"Born" -> <|"DiagramCount" -> 2, "SpinorMomenta" -> 
          {Momentum[k1, D], Momentum[p, D]}, "PolarizationMomenta" -> 
          {k2, q}|>, "RealQGG" -> <|"DiagramCount" -> 8, 
         "SpinorMomenta" -> {Momentum[k1, D], Momentum[p, D]}, 
         "PolarizationMomenta" -> {k2, k3, q}|>, "RealSame" -> 
        <|"DiagramCount" -> 8, "SpinorMomenta" -> {Momentum[k1, D], 
           -Momentum[k3, D], Momentum[k2, D], Momentum[p, D]}, 
         "PolarizationMomenta" -> {q}|>, "RealDistinct" -> 
        <|"DiagramCount" -> 4, "SpinorMomenta" -> {Momentum[k1, D], 
           Momentum[p, D], Momentum[k2, D], -Momentum[k3, D]}, 
         "PolarizationMomenta" -> {q}|>, "Virtual" -> <|"DiagramCount" -> 15, 
         "SpinorMomenta" -> {Momentum[k1, D], Momentum[p, D]}, 
         "PolarizationMomenta" -> {k2, q}|>|>|>, 
   "Hqg" -> <|"InputSHA256" -> 
      "8403c287ed130c5db601069eb71ad2d6a7b2b851662dea716441c472bc10eba9", 
     "Sectors" -> <|"Born" -> <|"DiagramCount" -> 2, "SpinorMomenta" -> 
          {Momentum[k2, D], Momentum[p, D]}, "PolarizationMomenta" -> 
          {k1, q}|>, "Real" -> <|"DiagramCount" -> 8, "SpinorMomenta" -> 
          {Momentum[k2, D], Momentum[p, D]}, "PolarizationMomenta" -> 
          {k1, k3, q}|>, "Virtual" -> <|"DiagramCount" -> 15, 
         "SpinorMomenta" -> {Momentum[k2, D], Momentum[p, D]}, 
         "PolarizationMomenta" -> {k1, q}|>|>|>, 
   "Hgq" -> <|"InputSHA256" -> 
      "90ea5cf71f391c94994c583fc730d56dc8796838c9fd5ae22c9363a3abcee8eb", 
     "Sectors" -> <|"Born" -> <|"DiagramCount" -> 2, "SpinorMomenta" -> 
          {Momentum[k1, D], -Momentum[k2, D]}, "PolarizationMomenta" -> 
          {q, p}|>, "Real" -> <|"DiagramCount" -> 8, "SpinorMomenta" -> 
          {Momentum[k1, D], -Momentum[k2, D]}, "PolarizationMomenta" -> 
          {q, k3, p}|>, "Virtual" -> <|"DiagramCount" -> 15, 
         "SpinorMomenta" -> {Momentum[k1, D], -Momentum[k2, D]}, 
         "PolarizationMomenta" -> {q, p}|>|>|>, 
   "Hgg" -> <|"InputSHA256" -> 
      "87f8e6569853ab998c595f1a329a0d9c05390eb624cea2fd91ac2b7881703953", 
     "Sectors" -> <|"amplitudes" -> <|"DiagramCount" -> 8, 
         "SpinorMomenta" -> {Momentum[k2, D], -Momentum[k3, D]}, 
         "PolarizationMomenta" -> {q, p, k1}|>|>|>, 
   "Hqqbar" -> <|"InputSHA256" -> 
      "393e8503576b3fdd557c40f0fe6cfab9dd31d956100f8091dd615d904ab70c8a", 
     "Sectors" -> <|"amplitudes" -> <|"DiagramCount" -> 8, 
         "SpinorMomenta" -> {Momentum[k2, D], -Momentum[k1, D], 
           Momentum[k3, D], Momentum[p, D]}, "PolarizationMomenta" -> 
          {q}|>|>|>, "Hqqprime" -> 
    <|"InputSHA256" -> 
      "e34d22bd588e253ff7bd84975579bb6160cba57027dea3fe0ddeede715e8327a", 
     "Sectors" -> <|"amplitudes" -> <|"DiagramCount" -> 4, 
         "SpinorMomenta" -> {Momentum[k1, D], -Momentum[k3, D], 
           Momentum[k2, D], Momentum[p, D]}, "PolarizationMomenta" -> 
          {q}|>|>|>|>, "Checks" -> <|"compute allocation" -> True, 
   "isolated Wolfram user base" -> True, "BMHV active" -> True, 
   "S01 accepted" -> True, "configuration identity" -> True, 
   "Hqq amplitude identity" -> True, "Hqq amplitude association" -> True, 
   "Hqq open external states" -> True, "Hqg amplitude identity" -> True, 
   "Hqg amplitude association" -> True, "Hqg open external states" -> True, 
   "Hgq amplitude identity" -> True, "Hgq amplitude association" -> True, 
   "Hgq open external states" -> True, "Hgg amplitude identity" -> True, 
   "Hgg amplitude association" -> True, "Hgg open external states" -> True, 
   "Hqqbar amplitude identity" -> True, "Hqqbar amplitude association" -> 
    True, "Hqqbar open external states" -> True, 
   "Hqqprime amplitude identity" -> True, "Hqqprime amplitude association" -> 
    True, "Hqqprime open external states" -> True, 
   "complete Pauli basis" -> True, "density trace" -> True, 
   "density Hermiticity" -> True, "pure state idempotence" -> True, 
   "complete incoming outgoing response" -> True, "Clifford algebra" -> True, 
   "gamma5 squared" -> True, "quark Dirac equation" -> True, 
   "antiquark Dirac equation" -> True, "quark normalization" -> True, 
   "antiquark normalization" -> True, "independent massless Dirac basis" -> 
    True, "quark projector reconstruction" -> True, 
   "antiquark projector reconstruction" -> True, 
   "gluon physical normalization" -> True, "gluon transverse states" -> True, 
   "gluon completeness" -> True, "photon matrix reconstruction" -> True, 
   "native spin-sum replacement interface" -> True|>, 
 "Gamma5Scheme" -> "BMHV", "LeviCivitaSign" -> -1, 
 "FeynCalcVersion" -> "10.2.1", "WolframVersion" -> 
  "13.1.0 for Linux x86 (64-bit) (June 16, 2022)", 
 "SourceHash" -> 431316430081936545932065259691725048860271857854586493182242\
31011252837402443, "InputManifestHash" -> 
  337865893467234260481669136745678692290100808758589907869496509041833128326\
49, "FiniteFHatsComputed" -> False, "Boundary" -> "Canonical physical spin \
bases only; contractions, evanescent terms, subtraction and finite scheme \
conversion remain separate gates."|>
