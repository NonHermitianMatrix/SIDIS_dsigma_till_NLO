<|"Schema" -> "polarized-sidis-exact-function-argument-comparison-v1", 
 "SourceHash" -> 476917821418363817677282731173455110745972331867741571352723\
81523978785002781, "CaptureHash" -> 
  933950172180171681789739182933102436531084287881763150069512185130046460461\
70, "Definitions" -> {HoldPattern[localCanonicalScalarArguments[value_]] :> 
    Module[{calls, rules}, calls = DeleteDuplicates[
        Cases[value, _Log | _PolyLog, {0, Infinity}]]; 
      rules = Function[call, Module[{argument = Last[call], canonical}, 
          canonical = Factor[Together[argument]]; 
           gate["canonical special-function argument exactly preserved", 
            Factor[Together[argument - canonical]] === 0]; 
           call -> ReplacePart[call, -1 -> canonical]]] /@ calls; 
      value /. rules]}, "ArgumentMappings" -> 
  {<|"Original" -> Pi, "Canonical" -> Pi|>, <|"Original" -> s23, 
    "Canonical" -> s23|>, 
   <|"Original" -> -(((s - s23)*(s23 - t))/(Q^2*s23 + s*t)), 
    "Canonical" -> -(((s - s23)*(s23 - t))/(Q^2*s23 + s*t))|>, 
   <|"Original" -> ((-s + s23)*(s23 - t))/(Q^2*s23 + s*t), 
    "Canonical" -> -(((s - s23)*(s23 - t))/(Q^2*s23 + s*t))|>}, 
 "RetainedResidual" -> 0, "Checks" -> 
  <|"actual failed product capture accepted" -> True, 
   "canonical special-function argument exactly preserved" -> True, 
   "actual retained product residual is exactly zero" -> True, 
   "actual complete retained products agree" -> True, 
   "all actual argument mappings reconstruct" -> True, 
   "saved coefficient and master remain unchanged" -> True|>, 
 "NativeVersion" -> "15.0.0 for Linux x86 (64-bit) (May 31, 2026)", 
 "CoefficientAlgorithmChanged" -> False, "Accepted" -> True|>
