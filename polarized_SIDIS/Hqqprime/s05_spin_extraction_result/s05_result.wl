<|"Schema" -> "polarized-sidis-spin-extraction-validation-v1", 
 "Channel" -> "Hqqprime", "SourceHash" -> 32939925596217754064759322751463035\
134590559922597046616927551685888239680627, "ProductionSourceHash" -> 1115976\
42649877335146354643631523227333482362657993886757367239273649122262323, 
 "ConfigHash" -> 403328312109285443964985882566191409058856095105376254469420\
12901554942212396, "BaselineMatrixInputHashes" -> 
  <|"cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694bb\
5c26caa9b01/Real_assembled_Photon_1_1.wl" -> 
    7780417443185816196981449804444881228260836260258311992892187672929700757\
1555, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_assembled_Photon_1_2.wl" -> 
    3385551332827345497209423513050621574983980172495980088836883857793129596\
6141, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_assembled_Photon_1_3.wl" -> 
    5056212034718249442101742453058971754178259751078922453370317287054681254\
1585, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_assembled_Photon_2_1.wl" -> 
    9368804108950808201194884855524256937931701166750312383987043028749608366\
4673, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_assembled_Photon_2_2.wl" -> 
    6730326189802837215771197783615191944774793935199486716006007047927587839\
9063, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_assembled_Photon_2_3.wl" -> 
    2121137756181346906096640150649600077622409707908246425978986746345262288\
0060, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_assembled_Photon_3_1.wl" -> 
    4599520316129990867024359953414438691065898814322948747478362545023472223\
2689, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_assembled_Photon_3_2.wl" -> 
    7541771386190414836692838859287775755632713218055233826136982900190306445\
5809, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_assembled_Photon_3_3.wl" -> 
    5876856359172194011579648148486575528049110710872995075380077969869728773\
6008, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_assembled_Scalar_PgD.wl" -> 
    2842183367555241368934769987049154485844652490644786769419076965790679565\
450, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694b\
b5c26caa9b01/Real_assembled_Scalar_PhotonWard.wl" -> 
    7974394653909946629780756922645904137615713306822087000845541223459139504\
2515|>, "InputHash" -> 
  111722680686345950169839872510092929494466004364341338891904187652862269591\
05, "InputHashes" -> <|"common/s01_inputs.json" -> 
    3378658934672342604816691367456786922901008087585899078694965090418331283\
2649, "common/s05_inputs.json" -> 
    3797134255418813929956331378084920634454097797613422384007667122397384344\
0599, 
   "Hqqprime/s01_result/reference/s01_result/s01_inputs/s01_result/real.wl" \
-> 10281130361652107366161974898972575133148884409053839536699212581808056934\
0538, "Hqqprime/s05_result/reference/unpolarized_real.wl" -> 1061907921731208\
99946596928980445166031572022398381196894898970724742772014671, 
   "common/s02_result/s02_result.wl" -> 8763488122700630353093597572583533003\
994794907904231568983159969497876529341, "common/s04_result/s04_result.wl" -> 
    6832582559442704311260834015700865252638007872011695004391325773511943728\
3507, "Hqq/s01_result/reference/s01_result/s01_inputs/s02_result.wl" -> 
    2352413981838082869261067007057566448305224908459749074055286439628427439\
8, "Hqqprime/s01_result/reference/s01_result/s01_inputs/s02_result/kinematics\
.wl" -> 
    3910948699502764643576996617625642435666580644068497881761353830701470396\
4345|>, "BasisInputHash" -> 
  876348812270063035309359757258353300399479490790423156898315996949787652934\
1, "ExtractionDefinitions" -> 
  {HoldPattern[compactSpinResponse[photon_, incoming_, outgoing_]] :> 
    Module[{variables, incomingComponents, incomingZero, outgoingZero}, 
     variables = DeleteCases[Join[incoming, outgoing], 1]; 
      gate["distinct spin polynomial variables", DuplicateFreeQ[variables]]; 
      incomingZero = Thread[DeleteCases[incoming, 1] -> 0]; 
      outgoingZero = Thread[DeleteCases[outgoing, 1] -> 0]; 
      Table[gate["polynomial photon spin dependence", PolynomialQ[expression, 
          variables]]; incomingComponents = Table[If[incoming[[i]] === 1, 
           expression /. incomingZero, D[expression, incoming[[i]]] /. 
            incomingZero], {i, Length[incoming]}]; 
        Table[If[outgoing[[j]] === 1, incomingComponents[[i]] /. 
           outgoingZero, D[incomingComponents[[i]], outgoing[[j]]] /. 
           outgoingZero], {j, Length[outgoing]}, {i, Length[incoming]}], 
       {expression, photon}]]}, "Evidence" -> 
  <|"ExtractionSeconds" -> 26.925165, "MatrixBytes" -> 227384352, 
   "CandidateResponseBytes" -> 154970224, "ComponentCount" -> 144, 
   "ComparisonIndex" -> {2, 4, 4}, "LegacyComponentBytes" -> 250530072, 
   "CompactComponentBytes" -> 23858272, "LegacyComponentSeconds" -> 
    12.763018, "CompleteMatrixReconstructionPassed" -> True|>, 
 "PriorExtractionDiagnostic" -> <|"ResponseBytes" -> 80253720, 
   "ExtractionSeconds" -> 7.170361, "ExpansionIdenticallyZero" -> False, 
   "RationallyIdenticallyZero" -> True, "ExpandedResidualBytes" -> 
    156887744|>, "LinearSumDefinitions" -> 
  {HoldPattern[linearComponentSum[task_]] :> 
    If[StringContainsQ[task["Key"], "Ward"], algebraicReduce[
      Total[task["Values"]]], Total[task["Values"]]]}, 
 "LinearSumEvidence" -> <|"Component" -> "Photon_1_1", 
   "LinearSeconds" -> 0.000085, "InputBytes" -> 1597544, 
   "LinearBytes" -> 1597160, "AcceptedBytes" -> 7372768, 
   "ExactComparisonPassed" -> True|>, "PairFixtureHashes" -> 
  <|"cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694bb\
5c26caa9b01/Real_1_1.wl" -> 
    5630774222347747367502835338516398131767716970816665547114207531920618617\
8084, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_1_2.wl" -> 
    9563180290030864610227612457187842258799552740332039572327403974061048917\
5092, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_1_3.wl" -> 
    2797410048068878281495507473155726227951502886028896192344420909426247334\
2960, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_1_4.wl" -> 
    4706431790686874338908668039504051784624076246012054093791900121483962385\
3035, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_2_2.wl" -> 10449942165966970154321159302480357051919809170\
4262999862074258291515964398277, "cache/s05/Hqqprime/18b347965f823f882898b5ab\
686a0df9e4da4713068f82b6694bb5c26caa9b01/Real_2_3.wl" -> 
    9583002518051781324197845726560483953814132390723566031152974998111387785\
7299, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_2_4.wl" -> 
    8095323004187083227876793881572689374730612685009021591688251480153855132\
1959, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_3_3.wl" -> 
    5934650800128805776369033191774197711724421774588699465811189096245954832\
1834, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_3_4.wl" -> 
    4563093020465450685261201431285028046941601954645414412628663770889424499\
8135, "cache/s05/Hqqprime/18b347965f823f882898b5ab686a0df9e4da4713068f82b6694\
bb5c26caa9b01/Real_4_4.wl" -> 
    4244448343435069056866628421897459560370227820626924690878357972614949758\
5191|>, "Checks" -> <|"compute allocation" -> True, 
   "isolated runtime" -> True, "native package already initialized" -> True, 
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
   "incoming photon-basis projection" -> True, 
   "accepted compact calculation source" -> True, 
   "single reviewed real photon interface change" -> True, 
   "unchanged complete scalar and frame routines" -> True, 
   "unchanged complete pair contractions" -> True, 
   "pinned input \
Hqqprime/s01_result/reference/s01_result/s01_inputs/s02_result/kinematics.wl" \
-> True, 
   "pinned input \
Hqq/s01_result/reference/s01_result/s01_inputs/s02_result.wl" -> True, 
   "reviewed previous source \
s05_real_spin_response_before_compact_products.wls" -> True, 
   "reviewed previous source \
s05_real_spin_response_before_coupling_inventory.wls" -> True, 
   "reviewed previous source \
s05_real_spin_response_before_worker_initialization.wls" -> True, 
   "reviewed previous source \
s05_real_spin_response_before_coefficient_reduction.wls" -> True, 
   "reviewed previous source s05_real_spin_response_before_projection.wls" -> 
    True, "compact real comparison exists" -> True, 
   "compact real comparison accepted" -> True, 
   "pinned pre-interface real source" -> True, 
   "accepted real coordinate and photon interfaces" -> True, 
   "real interface comparison shares physical inputs" -> True, 
   "executed coordinate conversion code" -> True, 
   "unique reference coordinate conversion" -> True, 
   "all reference scalar products reconstruct" -> True, 
   "complete validation source syntax" -> True, 
   "bound archived production generation" -> True, 
   "matrix fixture contract" -> True, 
   "pinned matrix fixture Real_assembled_Photon_1_1.wl" -> True, 
   "accepted matrix fixture Real_assembled_Photon_1_1.wl" -> True, 
   "pinned matrix fixture Real_assembled_Photon_1_2.wl" -> True, 
   "accepted matrix fixture Real_assembled_Photon_1_2.wl" -> True, 
   "pinned matrix fixture Real_assembled_Photon_1_3.wl" -> True, 
   "accepted matrix fixture Real_assembled_Photon_1_3.wl" -> True, 
   "pinned matrix fixture Real_assembled_Photon_2_1.wl" -> True, 
   "accepted matrix fixture Real_assembled_Photon_2_1.wl" -> True, 
   "pinned matrix fixture Real_assembled_Photon_2_2.wl" -> True, 
   "accepted matrix fixture Real_assembled_Photon_2_2.wl" -> True, 
   "pinned matrix fixture Real_assembled_Photon_2_3.wl" -> True, 
   "accepted matrix fixture Real_assembled_Photon_2_3.wl" -> True, 
   "pinned matrix fixture Real_assembled_Photon_3_1.wl" -> True, 
   "accepted matrix fixture Real_assembled_Photon_3_1.wl" -> True, 
   "pinned matrix fixture Real_assembled_Photon_3_2.wl" -> True, 
   "accepted matrix fixture Real_assembled_Photon_3_2.wl" -> True, 
   "pinned matrix fixture Real_assembled_Photon_3_3.wl" -> True, 
   "accepted matrix fixture Real_assembled_Photon_3_3.wl" -> True, 
   "pinned matrix fixture Real_assembled_Scalar_PgD.wl" -> True, 
   "accepted matrix fixture Real_assembled_Scalar_PgD.wl" -> True, 
   "pinned matrix fixture Real_assembled_Scalar_PhotonWard.wl" -> True, 
   "accepted matrix fixture Real_assembled_Scalar_PhotonWard.wl" -> True, 
   "distinct saved matrix entries" -> True, "complete saved photon matrix" -> 
    True, "fixture native quark species" -> True, 
   "fixture photon Ward identity" -> True, "fixture photon Hermiticity" -> 
    True, "single fixture sector" -> True, "pinned pair fixture {1, 1}" -> 
    True, "accepted pair fixture {1, 1}" -> True, 
   "pinned pair fixture {1, 2}" -> True, "accepted pair fixture {1, 2}" -> 
    True, "pinned pair fixture {1, 3}" -> True, 
   "accepted pair fixture {1, 3}" -> True, "pinned pair fixture {1, 4}" -> 
    True, "accepted pair fixture {1, 4}" -> True, 
   "pinned pair fixture {2, 2}" -> True, "accepted pair fixture {2, 2}" -> 
    True, "pinned pair fixture {2, 3}" -> True, 
   "accepted pair fixture {2, 3}" -> True, "pinned pair fixture {2, 4}" -> 
    True, "accepted pair fixture {2, 4}" -> True, 
   "pinned pair fixture {3, 3}" -> True, "accepted pair fixture {3, 3}" -> 
    True, "pinned pair fixture {3, 4}" -> True, 
   "accepted pair fixture {3, 4}" -> True, "pinned pair fixture {4, 4}" -> 
    True, "accepted pair fixture {4, 4}" -> True, 
   "inherited sum input construction syntax" -> True, 
   "Real common pair projection inventory" -> True, 
   "polynomial dependence on resolved spin" -> True, 
   "exact spin polynomial decomposition" -> True, 
   "linear sum accepted checkpoint reconstruction" -> True, 
   "linear assembly Ward Scalar_PhotonWard" -> True, 
   "distinct spin polynomial variables" -> True, 
   "unit component spin monomial" -> True, "distinct component monomials" -> 
    True, "polynomial photon spin dependence" -> True, 
   "all spin monomials represented" -> True, 
   "complete response dimensions" -> True, "exact spin polynomial 1" -> True, 
   "exact spin polynomial 2" -> True, "exact spin polynomial 3" -> True, 
   "exact spin polynomial 4" -> True, "exact spin polynomial 5" -> True, 
   "exact spin polynomial 6" -> True, "exact spin polynomial 7" -> True, 
   "exact spin polynomial 8" -> True, "exact spin polynomial 9" -> True, 
   "exact saved matrix {1, 1}" -> True, "exact saved matrix {1, 2}" -> True, 
   "exact saved matrix {1, 3}" -> True, "exact saved matrix {2, 1}" -> True, 
   "exact saved matrix {2, 2}" -> True, "exact saved matrix {2, 3}" -> True, 
   "exact saved matrix {3, 1}" -> True, "exact saved matrix {3, 2}" -> True, 
   "exact saved matrix {3, 3}" -> True, "complete original reference Pg" -> 
    True, "complete original reference Ppp" -> True, 
   "saved extraction definition syntax" -> True, 
   "nonzero polarized comparison exists" -> True, 
   "exact legacy polarized component" -> True, 
   "smaller measured polarized component" -> True|>, 
 "FiniteNLOFHatsComputed" -> False, "PeakKernelMemoryBytes" -> 1406213912|>
