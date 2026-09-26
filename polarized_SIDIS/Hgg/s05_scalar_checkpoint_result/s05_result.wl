<|"Schema" -> "polarized-sidis-scalar-checkpoint-validation-v1", 
 "Channel" -> "Hgg", "SourceHash" -> 2849942845089539808020046475211385074313\
9739706342241568660165972438869667359, "ProductionSourceHash" -> 
  167330064401774571057951554968804562943993944535984440499493472952883430923\
25, "InputHash" -> 
  303263232144041314914229306499074331287238411852647614830016373252382444820\
47, "InputHashes" -> <|"common/s01_inputs.json" -> 
    3378658934672342604816691367456786922901008087585899078694965090418331283\
2649, "common/s05_inputs.json" -> 
    3797134255418813929956331378084920634454097797613422384007667122397384344\
0599, "Hgg/s01_result/reference/s01_result/s01_inputs/s01_result/real.wl" -> 
    6150200236706306525219014304602206430582714067240872969186088451921022761\
1987, "Hgg/s05_result/reference/unpolarized_real.wl" -> 
    6505819662584053622487387000729173584644957638212579661282545061843475358\
2311, "common/s02_result/s02_result.wl" -> 
    8763488122700630353093597572583533003994794907904231568983159969497876529\
341, "common/s04_result/s04_result.wl" -> 
    6832582559442704311260834015700865252638007872011695004391325773511943728\
3507, "Hqq/s01_result/reference/s01_result/s01_inputs/s02_result.wl" -> 
    2352413981838082869261067007057566448305224908459749074055286439628427439\
8, 
   "Hgg/s01_result/reference/s01_result/s01_inputs/s02_result/kinematics.wl" \
-> 
    3910948699502764643576996617625642435666580644068497881761353830701470396\
4345|>, "NativeVersions" -> {"13.1.0 for Linux x86 (64-bit) (June 16, 2022)", 
   "10.2.1"}, "ControlHash" -> 1036354000690098817223469036086512484554666673\
6276861361641750471603929422491, "ControlPair" -> {1, 1}, 
 "OriginalRestorationDefinitions" -> 
  {HoldPattern[restoredScalarComponent[component_]] :> 
    Module[{restored}, restored = profiledNative[
        "restore defining scalar products", component /. epsilonRule /. 
         scalarRestore]; profiledNative[
       "on-shell reduction of restored coefficient", 
       algebraicReduce[restored]]]}, "ReductionDefinitions" -> 
  {{HoldPattern[algebraicReduce[values_List]] :> algebraicReduce /@ values, 
    HoldPattern[algebraicReduce[value_]] :> spinMap[algebraicReduceOne, 
      value]}, {HoldPattern[algebraicReduceOne[value_]] :> 
     Module[{rational, num, den, inverse, gcd, bezout, work, division, 
       answer, proof}, gate["unconditional exact algebra", 
        FreeQ[value, _ConditionalExpression | _Piecewise | _Real | $Aborted | 
          $Failed]]; rational = Together[value]; num = Numerator[rational]; 
       den = Denominator[rational]; gate["transverse rational function", 
        PolynomialQ[num, transverseK] && PolynomialQ[den, transverseK]]; 
       If[FreeQ[den, transverseK], inverse = 1/den, 
        {gcd, bezout} = PolynomialExtendedGCD[den, transverseConstraint, 
           transverseK]; gate["denominator Bezout reconstruction", 
          zero[gcd - bezout . {den, transverseConstraint}]]; 
         gate["invertible transverse denominator", FreeQ[gcd, transverseK] && 
           gcd =!= 0]; inverse = First[bezout]/gcd]; 
       work = Together[num*inverse]; 
       gate["rationalized transverse denominator", FreeQ[Denominator[work], 
         transverseK]]; division = PolynomialReduce[Numerator[work], 
         {transverseConstraint}, {transverseK}]; 
       gate["polynomial division reconstruction", 
        zero[Numerator[work] - First[First[division]]*transverseConstraint - 
          Last[division]]]; answer = Factor[Last[division]/
          Denominator[work]]; proof = Last[PolynomialReduce[
          Numerator[Together[rational - answer]], {transverseConstraint}, 
          {transverseK}]]; gate["complete rational reconstruction on shell", 
        zero[proof]]; answer]}, {HoldPattern[angularAverage[values_List]] :> 
     angularAverage /@ values, HoldPattern[angularAverage[value_]] :> 
     spinMap[angularAverageOne, value]}, 
   {HoldPattern[angularAverageOne[value_]] :> 
     Module[{rational, num, den, rows, reconstructed}, 
      rational = Together[algebraicReduce[value]]; num = Numerator[rational]; 
       den = Denominator[rational]; 
       gate["denominators independent of normal angle", 
        FreeQ[den, normalDot]]; gate["polynomial angular numerator", 
        PolynomialQ[num, normalDot]]; rows = CoefficientRules[num, 
         {normalDot}]; reconstructed = 
        Total[(Last[#1]*normalDot^First[First[#1]] & ) /@ rows]; 
       gate["angular numerator reconstruction", zero[num - reconstructed]]; 
       algebraicReduce[Total[(Last[#1]*normalMoment[First[First[#1]]] & ) /@ 
           rows]/den]]}}, "CheckpointDefinitions" -> 
  {HoldPattern[checkpointedScalarComponent[component_]] :> 
    Module[{restored, argumentHash, path, saved, answer, seconds, record, 
      serialized, temporary}, restored = component /. epsilonRule /. 
        scalarRestore; argumentHash = 
       Hash[{inputHash, coefficientAlgorithmHash, restored}, "SHA256"]; 
      path = FileNameJoin[{coefficientDirectory, StringJoin[
          IntegerString[argumentHash, 16, 64], ".wl"]}]; 
      saved = If[FileExistsQ[path], Get[path], Association[]]; 
      If[Lookup[saved, "InputHash", None] === inputHash && 
        Lookup[saved, "ArgumentHash", None] === argumentHash && 
        KeyExistsQ[saved, "Value"], coefficientCacheHits++; 
        Print["REUSED_SCALAR_COEFFICIENT ", IntegerString[argumentHash, 16, 
          64]]; Return[saved["Value"]]]; {seconds, answer} = 
       AbsoluteTiming[algebraicReduce[restored]]; 
      record = Association["InputHash" -> inputHash, "ArgumentHash" -> 
         argumentHash, "Value" -> answer]; serialized = 
       StringJoin["Uncompress[", ToString[Compress[record], InputForm], 
        "]\n"]; gate["scalar coefficient below file bound", 
       StringLength[serialized] < 128*1024^2]; 
      temporary = StringJoin[path, ".", ToString[$ProcessID], ".tmp"]; 
      Export[temporary, serialized, "Text"]; 
      gate["scalar coefficient exact saved value", Get[temporary] === 
        record]; RenameFile[temporary, path, OverwriteTarget -> True]; 
      coefficientCacheWrites++; Print["SAVED_SCALAR_COEFFICIENT ", 
       IntegerString[argumentHash, 16, 64], " seconds ", seconds, " bytes ", 
       FileByteCount[path]]; answer]}, "InstalledDefinitions" -> 
  {HoldPattern[restoredScalarComponent[component_]] :> 
    Module[{restored, argumentHash, path, saved, answer, seconds, record, 
      serialized, temporary}, restored = component /. epsilonRule /. 
        scalarRestore; argumentHash = 
       Hash[{inputHash, coefficientAlgorithmHash, restored}, "SHA256"]; 
      path = FileNameJoin[{coefficientDirectory, StringJoin[
          IntegerString[argumentHash, 16, 64], ".wl"]}]; 
      saved = If[FileExistsQ[path], Get[path], Association[]]; 
      If[Lookup[saved, "InputHash", None] === inputHash && 
        Lookup[saved, "ArgumentHash", None] === argumentHash && 
        KeyExistsQ[saved, "Value"], coefficientCacheHits++; 
        Print["REUSED_SCALAR_COEFFICIENT ", IntegerString[argumentHash, 16, 
          64]]; Return[saved["Value"]]]; {seconds, answer} = 
       AbsoluteTiming[algebraicReduce[restored]]; 
      record = Association["InputHash" -> inputHash, "ArgumentHash" -> 
         argumentHash, "Value" -> answer]; serialized = 
       StringJoin["Uncompress[", ToString[Compress[record], InputForm], 
        "]\n"]; gate["scalar coefficient below file bound", 
       StringLength[serialized] < 128*1024^2]; 
      temporary = StringJoin[path, ".", ToString[$ProcessID], ".tmp"]; 
      Export[temporary, serialized, "Text"]; 
      gate["scalar coefficient exact saved value", Get[temporary] === 
        record]; RenameFile[temporary, path, OverwriteTarget -> True]; 
      coefficientCacheWrites++; Print["SAVED_SCALAR_COEFFICIENT ", 
       IntegerString[argumentHash, 16, 64], " seconds ", seconds, " bytes ", 
       FileByteCount[path]]; answer]}, "AlgorithmHash" -> 5159107239559402540\
2246928792973997828828419548499539032492466607909882260697, 
 "TraceSeconds" -> 47.792556, "FirstSeconds" -> 226.5001, 
 "ReloadSeconds" -> 35.657461, "CacheHits" -> 36, "CacheWrites" -> 14, 
 "Checks" -> <|"compute allocation" -> True, "isolated runtime" -> True, 
   "complete source syntax" -> True, "integer real operation time limit" -> 
    True, "bounded real operation time limit" -> True, 
   "bounded real operation memory limit" -> True, "known channel" -> True, 
   "pinned input \
Hgg/s01_result/reference/s01_result/s01_inputs/s01_result/real.wl" -> True, 
   "pinned input Hgg/s05_result/reference/unpolarized_real.wl" -> True, 
   "accepted spin basis" -> True, "accepted angular moments" -> True, 
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
   "single accepted pair-completion interface" -> True, 
   "unchanged complete pair contractions" -> True, 
   "pinned input \
Hgg/s01_result/reference/s01_result/s01_inputs/s02_result/kinematics.wl" -> 
    True, "pinned input \
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
   "accepted spin extraction and linear sum comparison" -> True, 
   "spin extraction comparison source binding" -> True, 
   "spin extraction comparison shares physical inputs" -> True, 
   "executed compact extraction definition" -> True, 
   "executed linear assembly definition" -> True, 
   "pinned accepted reconstruction dispatch source" -> True, 
   "unchanged exact spin reconstruction and checkpoint contract" -> True, 
   "accepted complete spin dispatch comparison" -> True, 
   "accepted complete scalar-restoration comparison" -> True, 
   "scalar-restoration comparison shares physical conventions" -> True, 
   "unchanged scalar-restoration starting definitions" -> True, 
   "exact accepted scalar-restoration definitions installed" -> True, 
   "pinned complete pair-assembly proof" -> True, 
   "pinned pair-assembly baseline" -> True, 
   "accepted complete pair-assembly comparison" -> True, 
   "pair-assembly comparison shares physical conventions" -> True, 
   "exact accepted pair-assembly definitions installed" -> True, 
   "complete scalar checkpoint comparison syntax" -> True, 
   "own scalar checkpoint comparison channel" -> True, 
   "single comparison sector" -> True, 
   "unchanged complete pair initialization syntax" -> True, 
   "Real generated process fields" -> True, 
   "Real generated momentum-field correspondence" -> True, 
   "Real unique coupling degree" -> True, 
   "Real tree coupling reconstruction" -> True, 
   "Real uniform native spinor dimension" -> True, 
   "all compact scalar products restored" -> True, 
   "fully scalar real contraction" -> True, 
   "denominators independent of normal angle" -> True, 
   "polynomial angular numerator" -> True, 
   "angular numerator reconstruction" -> True, "evaluated angular moment" -> 
    True, "native physical photon projection interface" -> True, 
   "control pair is diagonal" -> True, "pinned accepted own control pair" -> 
    True, "complete own control input binding" -> True, 
   "unchanged complete scalar reduction equations" -> True, 
   "real spin closures" -> True, 
   "scalar spin variables have declared axes" -> True, 
   "distinct spin polynomial variables" -> True, 
   "polynomial photon spin dependence" -> True, 
   "complete scalar spin coefficient inventory" -> True, 
   "exact derivative scalar spin decomposition" -> True, 
   "scalar coefficient below file bound" -> True, 
   "scalar coefficient exact saved value" -> True, 
   "complete own accepted projection reproduced" -> True, 
   "complete cached projection exactly unchanged" -> True, 
   "saved coefficients actually reused" -> True, 
   "all scalar equations retained" -> True|>, "FiniteNLOFHatsComputed" -> 
  False|>
