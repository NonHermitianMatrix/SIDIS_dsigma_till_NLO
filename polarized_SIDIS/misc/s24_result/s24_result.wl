<|"Schema" -> "polarized-sidis-exact-function-argument-comparison-v1", 
 "SourceHash" -> 
  498362627956502751372556568927026470710720118892042517311199245664197199860\
2, "CaptureHash" -> 
  933950172180171681789739182933102436531084287881763150069512185130046460461\
70, "Definitions" -> {HoldPattern[localCanonicalScalarArguments[value_]] :> 
    Module[{calls, rules}, calls = DeleteDuplicates[
        Cases[value, _Log | _PolyLog, {0, Infinity}]]; 
      rules = Function[call, Module[{argument = Last[call], canonical}, 
          canonical = Factor[Together[Expand[argument]]]; 
           gate["canonical special-function argument exactly preserved", 
            Factor[Together[Expand[argument - canonical]]] === 0]; 
           call -> ReplacePart[call, -1 -> canonical]]] /@ calls; 
      value /. rules]}, "ArgumentMappings" -> 
  {<|"Original" -> Pi, "Canonical" -> Pi|>, <|"Original" -> s23, 
    "Canonical" -> s23|>, 
   <|"Original" -> -(((s - s23)*(s23 - t))/(Q^2*s23 + s*t)), 
    "Canonical" -> ((-s + s23)*(s23 - t))/(Q^2*s23 + s*t)|>, 
   <|"Original" -> ((-s + s23)*(s23 - t))/(Q^2*s23 + s*t), 
    "Canonical" -> ((-s + s23)*(s23 - t))/(Q^2*s23 + s*t)|>}, 
 "RetainedResidual" -> 0, "CompleteOrdinaryResidual" -> 0, 
 "OrdinaryCaptureHash" -> 235614648337619581020611760626009127024024164615585\
79478390134162690744596507, "Checks" -> 
  <|"actual failed product capture accepted" -> True, 
   "canonical special-function argument exactly preserved" -> True, 
   "actual retained product residual is exactly zero" -> True, 
   "actual complete retained products agree" -> True, 
   "all actual argument mappings reconstruct" -> True, 
   "saved coefficient and master remain unchanged" -> True, 
   "actual complete ordinary capture accepted" -> True, 
   "complete saved ordinary comparison exactly zero" -> True, 
   "complete original and recurrence ordinary agree" -> True, 
   "complete ordinary inputs remain unchanged" -> True|>, 
 "NativeVersion" -> "15.0.0 for Linux x86 (64-bit) (May 31, 2026)", 
 "CoefficientAlgorithmChanged" -> False, "Accepted" -> True|>
