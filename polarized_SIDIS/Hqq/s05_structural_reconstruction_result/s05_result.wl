<|"Schema" -> "polarized-sidis-structural-reconstruction-comparison-v1", 
 "Channel" -> "Hqq", "Sector" -> "RealSame", 
 "SourceHash" -> 
  835846937214868120807976542555199561866408608273656349095928570382653415320\
4, "EquationResultHash" -> 
  427683930042502346637425688707703189214468588468584256955605098448942453126\
98, "EquationReceiptHash" -> 
  911234184548850389741962555235572138037886821936428656910743073053262339135\
30, "InputHash" -> 
  315012474449943383053468159617723567817911263888718273682862838592173171310\
83, "InputHashes" -> <|"common/s01_inputs.json" -> 
    3378658934672342604816691367456786922901008087585899078694965090418331283\
2649, "common/s05_inputs.json" -> 
    3797134255418813929956331378084920634454097797613422384007667122397384344\
0599, "Hqq/s01_result/reference/s01_result/s01_inputs/s01_result.wl" -> 
    6236141875823703353348083198367717562914953472407878739034866251836609931\
642, "Hqq/s05_result/reference/unpolarized_real.wl" -> 
    5812860551919100352381614728787514864834239621704825622279095491286087465\
9042, "common/s02_result/s02_result.wl" -> 
    8763488122700630353093597572583533003994794907904231568983159969497876529\
341, "common/s04_result/s04_result.wl" -> 
    6832582559442704311260834015700865252638007872011695004391325773511943728\
3507, "Hqq/s01_result/reference/s01_result/s01_inputs/s02_result.wl" -> 
    2352413981838082869261067007057566448305224908459749074055286439628427439\
8|>, "EquationInputHashes" -> <|"cache/s05/Hqq/45a512ffc5e2f23ed6a8fe86d45eb6\
079e7e75874064fec6fe14095ec120734b/RealSame_assembled_Photon_1_3.wl" -> 
    7267286558105990177844009671417202687813291468548652205894991838598878455\
2483, "cache/s05/Hqq/45a512ffc5e2f23ed6a8fe86d45eb6079e7e75874064fec6fe14095e\
c120734b/RealSame_assembled_Photon_3_1.wl" -> 
    1983982627332196210979216770948962893584156469367591816502663723073118878\
560, "cache/s05/Hqq/45a512ffc5e2f23ed6a8fe86d45eb6079e7e75874064fec6fe14095ec\
120734b/RealSame_assembled_Photon_2_3.wl" -> 
    9002154237881767602080868435470681116281152623628063152365297572426011278\
3155, "cache/s05/Hqq/45a512ffc5e2f23ed6a8fe86d45eb6079e7e75874064fec6fe14095e\
c120734b/RealSame_assembled_Photon_3_2.wl" -> 
    4205207370021846550964617650739588215230967199505262899159489327179213971\
657, "cache/s05/Hqq/45a512ffc5e2f23ed6a8fe86d45eb6079e7e75874064fec6fe14095ec\
120734b/RealSame_spin_reconstruction_8.wl" -> 
    3557511894159053371989180009948390758718617631917152126845511012229015886\
0535|>, "IncomingVariables" -> {1, xIn, yIn, hIn}, 
 "OutgoingVariables" -> {1, xOut, yOut, hOut}, 
 "Measurements" -> {<|"Accepted" -> True, 
    "Checks" -> <|"DistinctSpinVariables" -> True, 
      "SpinIndependentCoefficients" -> True, "ExactExpressionRestoration" -> 
       True, "PolynomialSpinDependence" -> True, 
      "ExactAbstractReconstruction" -> True, "ExactExistingResponse" -> 
       True|>, "InputBytes" -> 63599912, "AbstractBytes" -> 108456, 
    "CoefficientCount" -> 237, "Seconds" -> 1.972943`6.746659531792736, 
    "KernelMemoryBytes" -> 412186176, "PeakKernelMemoryBytes" -> 1084669560, 
    "Component" -> 8, "Binding" -> 504346269498985926488277083544968840551186\
35012497564101744963153202579374755|>, <|"Accepted" -> True, 
    "Checks" -> <|"DistinctSpinVariables" -> True, 
      "SpinIndependentCoefficients" -> True, "ExactExpressionRestoration" -> 
       True, "PolynomialSpinDependence" -> True, 
      "ExactAbstractReconstruction" -> True, "ExactExistingResponse" -> 
       True|>, "InputBytes" -> 98648792, "AbstractBytes" -> 101128, 
    "CoefficientCount" -> 232, "Seconds" -> 3.00028`6.928706780475805, 
    "KernelMemoryBytes" -> 474801304, "PeakKernelMemoryBytes" -> 1536062552, 
    "Component" -> 9, "Binding" -> 350343560942176275717010683396973834955878\
12313202946828298282740227642031194|>}, "NegativeControl" -> 
  <|"Accepted" -> False, "Checks" -> <|"DistinctSpinVariables" -> True, 
     "SpinIndependentCoefficients" -> True, "ExactExpressionRestoration" -> 
      True, "PolynomialSpinDependence" -> True, 
     "ExactAbstractReconstruction" -> True, "ExactExistingResponse" -> 
      False|>, "InputBytes" -> 63599912, "AbstractBytes" -> 108456, 
   "CoefficientCount" -> 237, "Seconds" -> 1.93784`6.738862909664968, 
   "KernelMemoryBytes" -> 475010608, "PeakKernelMemoryBytes" -> 1536062552|>, 
 "CandidateDefinitions" -> 
  {HoldPattern[structuralSpinReconstruction[expression_, response_, 
      incoming_, outgoing_]] :> Module[{variables, pattern, 
      replacements = {}, atom, shrink, opaque, extracted, reconstructed, 
      restored, evidence, started = AbsoluteTime[]}, 
     variables = DeleteCases[Join[incoming, outgoing], 1]; 
      pattern = Alternatives @@ variables; atom[value_] := 
       atom[value] = Module[{symbol = Unique["sidisSpinCoefficient"]}, 
         AppendTo[replacements, symbol -> value]; symbol]; 
      shrink[value_] := If[FreeQ[value, pattern], If[AtomQ[value], value, 
         atom[value]], shrink /@ value]; opaque = shrink[expression]; 
      evidence = Association["DistinctSpinVariables" -> 
         DuplicateFreeQ[variables], "SpinIndependentCoefficients" -> 
         FreeQ[Last /@ replacements, pattern], 
        "ExactExpressionRestoration" -> (opaque /. replacements) === 
          expression, "PolynomialSpinDependence" -> PolynomialQ[opaque, 
          variables]]; extracted = First[compactSpinResponse[{opaque}, 
         incoming, outgoing]]; reconstructed = 
       Sum[incoming[[i]]*outgoing[[j]]*extracted[[j,i]], 
        {i, Length[incoming]}, {j, Length[outgoing]}]; 
      restored = extracted /. replacements; AssociateTo[evidence, 
       {"ExactAbstractReconstruction" -> Expand[opaque - reconstructed] === 
          0, "ExactExistingResponse" -> restored === response}]; 
      Association["Accepted" -> And @@ Values[evidence], 
       "Checks" -> evidence, "InputBytes" -> ByteCount[expression], 
       "AbstractBytes" -> ByteCount[opaque], "CoefficientCount" -> 
        Length[replacements], "Seconds" -> AbsoluteTime[] - started, 
       "KernelMemoryBytes" -> MemoryInUse[], "PeakKernelMemoryBytes" -> 
        MaxMemoryUsed[]]]}, "ExtractionDefinitions" -> 
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
       {expression, photon}]]}, "NativeVersions" -> 
  {"13.1.0 for Linux x86 (64-bit) (June 16, 2022)", "10.2.1"}, 
 "Checks" -> <|"compute allocation" -> True, "isolated runtime" -> True, 
   "complete comparison source syntax" -> True, 
   "pinned actual equation packet" -> True, 
   "pinned accepted equation receipt" -> True, "equation reader accepted" -> 
    True, 
   "reader artifact Hqq/s05_reconstruction_equation_result/s05_checks.json" \
-> True, 
   "reader artifact Hqq/s05_reconstruction_equation_result/s05_input_08.wl" \
-> True, 
   "reader artifact Hqq/s05_reconstruction_equation_result/s05_input_09.wl" \
-> True, 
   "reader artifact Hqq/s05_reconstruction_equation_result/s05_result.wl" -> 
    True, "actual channel and equation schema" -> True, 
   "equation reader source identity" -> True, 
   "unchanged production source" -> True, 
   "physical input common/s01_inputs.json" -> True, 
   "physical input common/s05_inputs.json" -> True, 
   "physical input \
Hqq/s01_result/reference/s01_result/s01_inputs/s01_result.wl" -> True, 
   "physical input Hqq/s05_result/reference/unpolarized_real.wl" -> True, 
   "physical input common/s02_result/s02_result.wl" -> True, 
   "physical input common/s04_result/s04_result.wl" -> True, 
   "physical input \
Hqq/s01_result/reference/s01_result/s01_inputs/s02_result.wl" -> True, 
   "saved equation input \
cache/s05/Hqq/45a512ffc5e2f23ed6a8fe86d45eb6079e7e75874064fec6fe14095ec120734\
b/RealSame_assembled_Photon_1_3.wl" -> True, "saved equation input \
cache/s05/Hqq/45a512ffc5e2f23ed6a8fe86d45eb6079e7e75874064fec6fe14095ec120734\
b/RealSame_assembled_Photon_3_1.wl" -> True, "saved equation input \
cache/s05/Hqq/45a512ffc5e2f23ed6a8fe86d45eb6079e7e75874064fec6fe14095ec120734\
b/RealSame_assembled_Photon_2_3.wl" -> True, "saved equation input \
cache/s05/Hqq/45a512ffc5e2f23ed6a8fe86d45eb6079e7e75874064fec6fe14095ec120734\
b/RealSame_assembled_Photon_3_2.wl" -> True, "saved equation input \
cache/s05/Hqq/45a512ffc5e2f23ed6a8fe86d45eb6079e7e75874064fec6fe14095ec120734\
b/RealSame_spin_reconstruction_8.wl" -> True, 
   "unchanged native extraction installed" -> True, 
   "exact task binding 8" -> True, "distinct spin polynomial variables" -> 
    True, "polynomial photon spin dependence" -> True, 
   "complete check inventory 8" -> True, "8 DistinctSpinVariables" -> True, 
   "8 SpinIndependentCoefficients" -> True, "8 ExactExpressionRestoration" -> 
    True, "8 PolynomialSpinDependence" -> True, 
   "8 ExactAbstractReconstruction" -> True, "8 ExactExistingResponse" -> 
    True, "complete reconstruction accepted 8" -> True, 
   "own accepted reconstruction comparison" -> True, 
   "exact task binding 9" -> True, "complete check inventory 9" -> True, 
   "9 DistinctSpinVariables" -> True, "9 SpinIndependentCoefficients" -> 
    True, "9 ExactExpressionRestoration" -> True, 
   "9 PolynomialSpinDependence" -> True, "9 ExactAbstractReconstruction" -> 
    True, "9 ExactExistingResponse" -> True, 
   "complete reconstruction accepted 9" -> True, 
   "nonzero saved response control" -> True, "changed response rejected" -> 
    True|>, "Accepted" -> True, "FiniteNLOFHatsComputed" -> False|>
