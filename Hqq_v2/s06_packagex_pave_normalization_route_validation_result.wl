<|"Stage" -> "HqqV2S06PackageXPaVeNormalizationRouteValidation-v1", 
 "ScopeTag" -> 
  "[Hqq_v2, people or agents working on other channels should ignore]", 
 "Source" -> <|"Path" -> "/u/home/r/rushil/AI_Assisted_SIDIS_Hqq_v2/s06_valid\
ate_packagex_pave_normalization_route.wl", 
   "SHA256" -> 
    "1d5e114c9b232b1b0fe29975f6e017b5a52ef122751dafe0d2cc53b80889c17b"|>, 
 "Inputs" -> <|"S03SHA256" -> 
    "b3d483dea534ed26b93e601c28788b6c5797a200bb04e72c913b1c0c6c69ab80", 
   "PreLSZS03SHA256" -> 
    "bb9b4c7571029bf7fd851132b583a3896bea5713543ec1a3774c84b99a03c5b4", 
   "S06V2SHA256" -> 
    "a27caf9b820b3685f59119a3a814a035233f50ba64013f2d47308fcf00cb5979", 
   "S06V3SHA256" -> 
    "f658d67c85bcfb54a6f5787430835222b1df0f92dcd77f62cec2aed8e7a95b09", 
   "OldS07CheckpointSHA256" -> 
    "8118047f56686a4032efcc00944508b09cd230b43379f236951a4b732e0b4a96", 
   "FaultyMeasureProbeSHA256" -> 
    "2e5c0385c3a97736393a91d8df79a2955c67554c81d68a65f1909421e521ab52", 
   "PoleDeltaProbeSHA256" -> 
    "b35ef620d3d80e44d3cdc9df7166c18e2e31417a97467c70ca8ba6a7128b8b02"|>, 
 "Route" -> <|"LoopNormalizationHash" -> 
    "2da4b44ce646692ae2a98ba7937c6036af9d556fd9da33a4d3bdf1eb0df79b1e", 
   "CountertermNormalizationHash" -> 
    "2da4b44ce646692ae2a98ba7937c6036af9d556fd9da33a4d3bdf1eb0df79b1e", 
   "DefaultRouteScale" -> 1, "V2ImplicitPrefactor" -> 1, 
   "V3ImplicitPrefactor" -> (2*Pi)^(4 - D), 
   "Checks" -> <|"S03GeneratedLoopNormalizationMatched" -> True, 
     "S03LoopAndCountertermNormalizationsEqual" -> True, 
     "CorrectedS03RetainsLoopNormalization" -> True, 
     "CorrectedS03RetainsCountertermNormalization" -> True, 
     "DefaultRouteScaleIsUnity" -> True, "V2UsesDefaultRouteScale" -> True, 
     "V3UsesFaultyDerivedConversion" -> True, 
     "V3DoesNotUseDefaultRouteScale" -> True, 
     "FaultyProbeUsedAlreadyReducedMaster" -> True, 
     "FaultyProbeSelectedConvertedPaVe" -> True|>|>, 
 "CheckpointChecks" -> <|"BindsV2" -> True, "EveryPoleLiteralZero" -> True, 
   "StoredPoleGate" -> True|>, "PoleDeltaChecks" -> 
  <|"BindsBothCandidates" -> True, "V3ChangesAtLeastOneMappedPole" -> True, 
   "EveryMappedDifferenceResolved" -> True|>, 
 "Candidates" -> <|"S06-v2-unity" -> <|"RouteAgreement" -> True, 
     "StoredStageChecks" -> True, "ExactS07PoleClosure" -> True, 
     "S07EvidenceBindsCandidate" -> True|>, "S06-v3-converted" -> 
    <|"RouteAgreement" -> False, "StoredStageChecks" -> True, 
     "ExactS07PoleClosure" -> False, "S07EvidenceBindsCandidate" -> True|>|>, 
 "CandidateSelections" -> <|"S06-v2-unity" -> True, 
   "S06-v3-converted" -> False|>, "SelectedCandidate" -> "S06-v2-unity", 
 "Correction" -> <|"Origin" -> "s06_probe_packagex_measure_conversion.wl", 
   "Finding" -> "raw FeynArts prefactor was compared after PaVe normalization \
had already been introduced", "InvalidCandidateSHA256" -> 
    "f658d67c85bcfb54a6f5787430835222b1df0f92dcd77f62cec2aed8e7a95b09", 
   "RestoreCandidateSHA256" -> 
    "a27caf9b820b3685f59119a3a814a035233f50ba64013f2d47308fcf00cb5979", 
   "MasterReevaluationRequired" -> False|>, 
 "Checks" -> <|"AcceptedInputHashes" -> True, "AcceptedInputSchemas" -> True, 
   "EndToEndRoute" -> True, "CheckpointPoleEvidence" -> True, 
   "MappedPoleDeltaEvidence" -> True, "UniqueCandidate" -> True, 
   "UnityCandidateSelected" -> True|>|>
