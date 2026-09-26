<|"Schema" -> "polarized-sidis-quark-gluon-transfer-v1", "Channel" -> "Hqg", 
 "IncomingSpinLabels" -> {"U", "X", "Y", "H"}, 
 "OutgoingSpinLabels" -> {"U", "X", "Y", "H", "E"}, 
 "IndexOrder" -> {"daughter spin", "parent spin"}, 
 "RawDimensionalKernel" -> 
  {{((-1 + SUNN)*(1 + SUNN)*(4 - 4*z - 2*z^2 + D*z^2))/((-2 + D)*SUNN*z), 0, 
    0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
   {0, 0, 0, ((-1 + SUNN)*(1 + SUNN)*(4 - 6*z + D*z))/((-2 + D)*SUNN)}, 
   {((-4 + D)*(-1 + SUNN)*(1 + SUNN)*(4 - 4*z - 2*z^2 + D*z^2))/
     (2*(-2 + D)*SUNN*z), 0, 0, 0}}, "PhysicalKernelD" -> 
  {{((-1 + SUNN)*(1 + SUNN)*(4 - 4*z - 2*z^2 + D*z^2))/((-2 + D)*SUNN*z), 0, 
    0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
   {0, 0, 0, ((-1 + SUNN)*(1 + SUNN)*(4 - 6*z + D*z))/((-2 + D)*SUNN)}}, 
 "LeadingKernel" -> {{((-1 + SUNN)*(1 + SUNN)*(2 - 2*z + z^2))/(SUNN*z), 0, 
    0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
   {0, 0, 0, -(((-1 + SUNN)*(1 + SUNN)*(-2 + z))/SUNN)}}, 
 "CDRKernelD" -> {{((-1 + SUNN)*(1 + SUNN)*(4 - 4*z - 2*z^2 + D*z^2))/
     (2*SUNN*z), 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
   {0, 0, 0, ((-1 + SUNN)*(1 + SUNN)*(4 - 6*z + D*z))/((-2 + D)*SUNN)}}, 
 "CDRRegulatorRemainder" -> {{((-4 + D)*(-1 + SUNN)*(1 + SUNN)*z)/(2*SUNN), 
    0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
   {0, 0, 0, (2*(-4 + D)*(-1 + SUNN)*(1 + SUNN)*(-1 + z))/((-2 + D)*SUNN)}}, 
 "MSOperatorD" -> 
  {{-1/2*((-1 + SUNN)*(1 + SUNN)*(-8 + 8*z + 12*z^2 - 8*D*z^2 + D^2*z^2))/
      ((-2 + D)*SUNN*z), 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
   {0, 0, 0, -(((-1 + SUNN)*(1 + SUNN)*(-2 + z))/SUNN)}}, 
 "KernelDifferenceD" -> 
  {{-1/2*((-4 + D)*(-1 + SUNN)*(1 + SUNN)*(4 - 4*z - 2*z^2 + D*z^2))/
      ((-2 + D)*SUNN*z), 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}, 
 "MSReference" -> "arXiv:0807.4424 Eqs. (36)-(39)", "DimensionLimit" -> 4, 
 "ReferenceNormalizationDerived" -> ((-1 + SUNN)*(1 + SUNN))/(2*SUNN), 
 "AngularConvention" -> "Full D-2 transverse angular average; same accepted \
S10 frame and physical axes", "AngularMoments" -> 
  {HoldPattern[angularMoment[0]] :> 1, HoldPattern[angularMoment[1]] :> 
    2/(-2 + D), HoldPattern[angularMoment[power_]] :> 
    (angularMoment[power] = bounded[FullSimplify[
       Integrate[physicalFraction^power*angularWeight, {physicalFraction, 0, 
          1}, Assumptions -> D > Length[pVector], GenerateConditions -> 
          False]/Integrate[angularWeight, {physicalFraction, 0, 1}, 
         Assumptions -> D > Length[pVector], GenerateConditions -> False], 
       D > Length[pVector]], {"dimensional angular moment", power}])}, 
 "SourceHash" -> 102504515401904208243006474799026883973458223365884437497904\
49220175125017707, "InputHashes" -> 
  <|"common/s10_dimensional_gluon_transfer.wls" -> 77946211909415899233436939\
30612706856586127549709790278276762511883539289469, 
   "common/s10_collinear_spin_kernels.wls" -> 3536186380894419733336749136535\
1906962049549826318247515632432673511387993750, 
   "common/s10_result/s10_result.wl" -> 7220756440186462257402738064268169726\
7486613374919733442182629239536957588478, "common/s10_inputs.json" -> 
    6271120817234291511035379141392711871670417959042724691121568746722995158\
3542, "common/s10_result/reference/s08_result.wl" -> 
    2891219962338194233299642318051421929635514847802365982257890389940606034\
9162, "common/s10_result/reference/s08_collinear_subtraction.wl" -> 
    4862738421715726166094117691986397405303555817597572529763215070937366282\
4029, "common/s02_result/s02_result.wl" -> 
    8763488122700630353093597572583533003994794907904231568983159969497876529\
341, "Hqq/s01_result/reference/s01_result/s01_inputs/s02_result.wl" -> 
    2352413981838082869261067007057566448305224908459749074055286439628427439\
8|>, "NativeSourceHashes" -> <|"SplittingFunction.m" -> 
    9587277801500125214392843647212028557540153118951874782770645888594296936\
6086, "QuarkGluonVertex.m" -> 
    6399551047563112739556214751116672017070086388071477051021450724575328301\
1801, "GluonVertex.m" -> 1082381019335456349642365652129857288522266139613050\
61961131467586773302752414|>, "NativeVersions" -> 
  {"13.1.0 for Linux x86 (64-bit) (June 16, 2022)", "10.2.1"}, 
 "Checks" -> <|"compute allocation" -> True, "isolated runtime" -> True, 
   "complete source syntax" -> True, "pinned reference \
common/s10_result/reference/s08_collinear_subtraction.wl" -> True, 
   "pinned reference common/s10_result/reference/s08_result.wl" -> True, 
   "reference subtraction source identity" -> True, 
   "reference Born identity" -> True, "accepted spin projectors" -> True, 
   "endpoint spin identity" -> True, "reference kernel normalization Pqq" -> 
    True, "reference kernel normalization Pqg" -> True, 
   "reference kernel normalization Pgq" -> True, 
   "reference kernel normalization Pgg" -> True, 
   "native helicity kernels evaluated" -> True, "unique collinear frame" -> 
    True, "collinear frame reconstructs" -> True, 
   "positive parent virtuality" -> True, 
   "unique lightlike parent projection" -> True, 
   "reference lightlike parent" -> True, "daughter transverse axes" -> True, 
   "spin axes approach the inherited collinear axes" -> True, 
   "native QCD vertices evaluated" -> True, 
   "opposite unresolved transverse directions" -> True, 
   "dimensional daughter mass shells" -> True, 
   "dimensional parent virtuality" -> True, "own channel" -> True, 
   "accepted physical splitting calculation" -> True, 
   "unchanged S10 input common/s10_inputs.json" -> True, 
   "unchanged S10 input common/s10_result/reference/s08_result.wl" -> True, 
   "unchanged S10 input \
common/s10_result/reference/s08_collinear_subtraction.wl" -> True, 
   "unchanged S10 input common/s02_result/s02_result.wl" -> True, 
   "unchanged S10 input \
Hqq/s01_result/reference/s01_result/s01_inputs/s02_result.wl" -> True, 
   "unchanged native vertex SplittingFunction.m" -> True, 
   "unchanged native vertex QuarkGluonVertex.m" -> True, 
   "unchanged native vertex GluonVertex.m" -> True, 
   "same accepted native runtime" -> True, 
   "native Gram matrices evaluated" -> True, "p exact projector dual" -> 
    True, "p inherited physical projector normalization" -> True, 
   "p orthogonal dimensional complement" -> True, 
   "k1 exact projector dual" -> True, 
   "k1 inherited physical projector normalization" -> True, 
   "k1 orthogonal dimensional complement" -> True, 
   "normalized full transverse angular measure" -> True, 
   "native second moment agrees with dimensional transverse average" -> True, 
   "complete qg entry syntax" -> True, 
   "complete native quark spin closure" -> True, 
   "exact scalar dimensional qg response" -> True, 
   "complete dimensional qg spin reconstruction" -> True, 
   "inherited qg azimuth-independent denominator" -> True, 
   "polynomial unresolved angular numerator" -> True, 
   "exact unresolved angular reconstruction" -> True, 
   "evaluated dimensional qg collinear response" -> True, 
   "same reference-derived qg normalization" -> True, 
   "all physical qg spin entries reproduce accepted S10" -> True, 
   "extra gluon response has zero physical limit" -> True, 
   "CDR qg physical limit preserves all spin components" -> True, 
   "native qg MS operator reconstruction" -> True, 
   "qg MS change has zero physical limit" -> True, 
   "qg MS change has no soft endpoint" -> True|>, "Accepted" -> True, 
 "ConvolutionPerformed" -> False, "FiniteNLOFHatsComputed" -> False|>
