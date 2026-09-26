<|"Schema" -> "polarized-sidis-uv-branch-comparison-v1", "Channel" -> "Hqg", 
 "Key" -> {"ExtendedResponse", {4, 4, 4}}, "OriginalResidual" -> 
  (Q*(1 - 4*SUNN^2 + 3*SUNN^4)*(Q^2*(s - t) + s*(s + t))*
    (-(s*Sqrt[-(s*t*(Q^2 + s + t))]) + Sqrt[-(s^3*t*(Q^2 + s + t))]))/
   (8*Pi^2*s*(Q^2 + s)^3*SUNN^2*(Q^2 + s + t)), 
 "RefinedOriginalResidual" -> 0, "InitialSumResidual" -> 
  (Q*(1 - 4*SUNN^2 + 3*SUNN^4)*(Q^2*(s - t) + s*(s + t))*
    (-(s*Sqrt[-(s*t*(Q^2 + s + t))]) + Sqrt[-(s^3*t*(Q^2 + s + t))]))/
   (8*Pi^2*s*(Q^2 + s)^3*SUNN^2*(Q^2 + s + t)), "RefinedSumResidual" -> 0, 
 "Definitions" -> {HoldPattern[refineUVResidual[value_]] :> 
    FullSimplify[Refine[Factor[Together[value]], physical], physical, 
     TimeConstraint -> 120]}, "PhysicalConditions" -> 
  Q > 0 && s > 0 && t < 0 && Q^2 + s + t > 0 && mu > 0 && SUNN > 1, 
 "ElapsedSeconds" -> 0.182809, "SourceHash" -> 385760866157090592164744099623\
31103901921043558519651830612589356931150591114, 
 "BaselineSourceHash" -> 3108992765719479523115117449601263984380963951453727\
8610773721318798832867721, "InspectionHash" -> 
  659322577736830784489538935129543383098782785150096892975166295263422075240\
05, "InputHashes" -> <|"common/s13_inputs.json" -> 
    3192054374103587898701046516075056880897076221675809072372014701569094271\
7928, "common/s06_result/s06_result.wl" -> 
    1629893493036707090606236278450981817622056446909249767204950169338278543\
2993, "common/s07_inputs.json" -> 
    7475455627839468165669571799838712124208139851840690037624940670158096906\
3830, "Hqg/s07_result/reference/unpolarized_virtual.wl" -> 
    3161343664648254953248038480823319051621003733910858107697110609956227461\
2207, "common/s06_result/reference/sources/s14_uv_residues.wl" -> 10019526590\
2543766866281603105383417972009523408684637318047840923974715340525, 
   "common/s13_result/reference/Hqq_virtual.wl" -> 75098305796972905830581012\
192375202678202716929028161122057863935457691189529, 
   "common/s13_result/reference/s19_masters.wl" -> 99546644709971512685378018\
097073341455411265743879441474867971232303512995393, 
   "common/s13_result/reference/s14_master_values.wl" -> 31631692853062481042\
91206313973572526029133602211831839957471171315494560363, 
   "common/s13_result/reference/s14_reduction.wl" -> 103455007794664424338470\
840029770610501249251774449281789103230689103073715852, 
   "common/s13_result/reference/s19_assemble_virtual.wl" -> 10896278166591304\
7106377405721414951605651829272962170432160691405977789261788, 
   "common/s06_result/reference/s02_result.wl" -> 877026587748340277492278858\
81478611024439966740386429429497480747151794336781, 
   "common/s06_result/reference/s12_result.wl" -> 356541931541112354090177888\
0411668102929752606631738644441449540611230929486, 
   "common/s06_result/reference/s14_result.wl" -> 324747108823299180725341817\
59114340411806190315091829833210262535831731018400, 
   "Hqg/s07_result/s07_result.wl" -> 8218792505566711989741744495082758487754\
3509387452884001816975182436171133068, 
   "Hqg/s09_reduction_result/s09_result.wl" -> 352035548487440788248781520368\
70093778629025592506541184226390100109797847259, 
   "Hqg/s03_result/s03_result.wl" -> 1087885345897816454531165300091680687258\
22073151764294101398130228693883946394, "common/s02_result/s02_result.wl" -> 
    8763488122700630353093597572583533003994794907904231568983159969497876529\
341|>, "NativeVersions" -> {"13.1.0 for Linux x86 (64-bit) (June 16, 2022)", 
   "10.2.1"}, "Checks" -> <|"compute allocation" -> True, 
   "complete source syntax" -> True, "pinned production source" -> True, 
   "pinned actual failed equation" -> True, "accepted inspection" -> True, 
   "unique inherited physical assumptions" -> True, 
   "original residual is zero on physical domain" -> True, 
   "actual Hermitian and counterterm sum vanishes" -> True|>, 
 "Accepted" -> True, "FiniteNLOFHatsComputed" -> False|>
