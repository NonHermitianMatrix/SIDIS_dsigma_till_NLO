<|"Schema" -> "polarized-sidis-real-interface-validation-v1", 
 "Channel" -> "Hqqprime", "SourceHash" -> 81086142038514164600090641607166718\
959469297792738873462529669637716405762393, "ProductionSourceHash" -> 
  955679935385275384017011419623718512432731168686246536365345169614452584810\
28, "InputHash" -> 
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
4345|>, "CoordinateCode" -> "(* Derive the old coordinate conversion from \
every saved scalar product. *)\nIf[core, oldRows = \
reference[\"RealScalarProducts\"],\n  oldRows = \
Flatten[Table[{kinematics[\"momenta\"][[i]], kinematics[\"momenta\"][[j]], \
kinematics[\"gram\"][[i, j]]},\n    {i, Length[kinematics[\"momenta\"]]}, {j, \
i, Length[kinematics[\"momenta\"]]}], 1]];\noldValues = oldRows[[All, \
3]];\noldVariables = DeleteDuplicates[Cases[oldValues, symbol_Symbol /; \
Context[symbol] === \"Global`\", Infinity]];\ntemporary = \
Table[Unique[\"referenceInvariant\"], {Length[oldVariables]}];\ntargetValues \
= dotD[#[[1]], #[[2]]] & /@ oldRows;\nsolutions = Block[{$Assumptions = \
True}, Solve[Thread[(oldValues /. Thread[oldVariables -> temporary]) == \
targetValues], temporary]];\ngate[\"unique reference coordinate conversion\", \
Length[solutions] === 1 && FreeQ[solutions, \
_ConditionalExpression]];\ncoordinateRules = Thread[oldVariables -> \
(temporary /. First[solutions])];\ngate[\"all reference scalar products \
reconstruct\", zeroArray[algebraicReduce[(oldValues /. coordinateRules) - \
targetValues]]];\n", "ReferenceCoordinateRules" -> 
  {Q2 -> Q^2, s -> s, t -> t, w -> s23, a -> -s23 + t - u3, b -> a12}, 
 "CoordinateDiagnosticHash" -> 1087912748110900539235097086710851895920117595\
8084583867668962580593000357993, "ProjectionDefinitions" -> 
  {HoldPattern[completePhotonProject[tensor_, leftAxis_, rightAxis_]] :> 
    (tensor /. {LorentzIndex[mu, D] -> Momentum[leftAxis], 
      LorentzIndex[nu, D] -> Momentum[rightAxis], LorentzIndex[mu] -> 
       Momentum[leftAxis], LorentzIndex[nu] -> Momentum[rightAxis], 
      LorentzIndex[mu, D - 4] -> Momentum[leftAxis, D - 4], 
      LorentzIndex[nu, D - 4] -> Momentum[rightAxis, D - 4]})}, 
 "ProjectionProofHash" -> 862934275189564440892749618590988551784847735203355\
57525005998680110664779103, "BaselinePath" -> "/u/scratch/r/rushil/AI_Assiste\
d_SIDIS/polarized_SIDIS_20260917T063521Z/cache/s05/Hqqprime/18b347965f823f882\
898b5ab686a0df9e4da4713068f82b6694bb5c26caa9b01/Real_1_1.wl", 
 "BaselineHash" -> 5630774222347747367502835338516398131767716970816665547114\
2075319206186178084, "Checks" -> <|"compute allocation" -> True, 
   "isolated runtime" -> True, "complete source syntax" -> True, 
   "known channel" -> True, "pinned input \
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
   "compact real comparison accepted" -> True, "interface source syntax" -> 
    True, "comparison owns saved real pair" -> True, 
   "Real generated process fields" -> True, 
   "Real generated momentum-field correspondence" -> True, 
   "Real inherited spectator weight" -> True, 
   "Real unique coupling degree" -> True, 
   "Real tree coupling reconstruction" -> True, 
   "Real uniform native spinor dimension" -> True, 
   "native physical photon projection interface" -> True, 
   "single coordinate interface change" -> True, 
   "unique reference coordinate conversion" -> True, 
   "all reference scalar products reconstruct" -> True, 
   "coordinate diagnostic source binding" -> True, 
   "same saved coordinate equations" -> True, 
   "coordinate solutions agree on physical domain" -> True, 
   "accepted native projection definition" -> True, 
   "same spin and angular inputs" -> True, 
   "accepted real pair input binding" -> True, "real spin closures" -> True, 
   "real projection unchanged {eL, eL}" -> True, 
   "real projection unchanged {eL, eX}" -> True, 
   "real projection unchanged {eL, eY}" -> True, 
   "real projection unchanged {eL, p}" -> True, 
   "real projection unchanged {eL, q}" -> True, 
   "real projection unchanged {eX, eL}" -> True, 
   "real projection unchanged {eX, eX}" -> True, 
   "real projection unchanged {eX, eY}" -> True, 
   "real projection unchanged {eX, p}" -> True, 
   "real projection unchanged {eX, q}" -> True, 
   "real projection unchanged {eY, eL}" -> True, 
   "real projection unchanged {eY, eX}" -> True, 
   "real projection unchanged {eY, eY}" -> True, 
   "real projection unchanged {eY, p}" -> True, 
   "real projection unchanged {eY, q}" -> True, 
   "real projection unchanged {p, eL}" -> True, 
   "real projection unchanged {p, eX}" -> True, 
   "real projection unchanged {p, eY}" -> True, 
   "real projection unchanged {p, p}" -> True, 
   "real projection unchanged {p, q}" -> True, 
   "real projection unchanged {q, eL}" -> True, 
   "real projection unchanged {q, eX}" -> True, 
   "real projection unchanged {q, eY}" -> True, 
   "real projection unchanged {q, p}" -> True, 
   "real projection unchanged {q, q}" -> True, 
   "polynomial dependence on resolved spin" -> True, 
   "exact spin polynomial decomposition" -> True, 
   "all compact scalar products restored" -> True, 
   "fully scalar real contraction" -> True, 
   "denominators independent of normal angle" -> True, 
   "polynomial angular numerator" -> True, 
   "angular numerator reconstruction" -> True, "evaluated angular moment" -> 
    True, "complete accepted real photon matrix unchanged" -> True|>, 
 "FiniteNLOFHatsComputed" -> False|>
