<|"Stage" -> "HqqV2S07DeltaCommonBasis-v1", 
 "ScopeTag" -> 
  "[Hqq_v2, people or agents working on other channels should ignore]", 
 "SourceSHA256" -> 
  "28e1cdb65b47cebd2d4b3b2eb1f25f88aedc8d283fa0c2587ecda8ac119d38c2", 
 "Inputs" -> <|"PoleDiagnosticSHA256" -> 
    "d68a942fc7374c7c1b78d5c6ae633983af2f10bda7e34deddd1c4d6696b03b09", 
   "FactorizationCacheSHA256" -> 
    "4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48", 
   "S04ResultSHA256" -> 
    "8c6a83d9c92cf36f99b46a81a0b42159375a900915aa13ffed030984e557b68c"|>, 
 "DerivedPHTRule" -> PHT2 -> -((sHat*t1*z^2)/(Q2 + sHat + t1)), 
 "MapDerivationChecks" -> <|"UniquePHTRule" -> True, 
   "PHTRuleClosesZetaDefinition" -> True, "InverseRulesComplete" -> True, 
   "InvariantPHTRule" -> True|>, "ComponentLeafCounts" -> 
  <|"Hqq;gg" -> 2448, "Hqq;q_qbar_sameFlavor" -> 27400, 
   "Hqq;qPrime_qbarPrime" -> 564, "Virtual" -> 3464, 
   "Factorization" -> 1559|>, "ComponentSHA256" -> 
  <|"Hqq;gg" -> 
    "61ca75400f652ed8b9596dc6361051d3bc31472529daadd9994b14d2f15d945e", 
   "Hqq;q_qbar_sameFlavor" -> 
    "fdca7c3cdf295a781d1e17f5b7648b62d09e771201f4e34277f3e122225c0657", 
   "Hqq;qPrime_qbarPrime" -> 
    "c6cceac5ae4039e9cfbc622fdf50c689612d5e1379deb463531c4b3f84b8b59a", 
   "Virtual" -> 
    "9ddc2a1c3f5be181062461a27304af62358c51f4c5acc0fc6510d50349b4ec39", 
   "Factorization" -> 
    "8dc5cbe5a023f11812831117ed29d2ec221918856c893ae10257e890f7071f80"|>, 
 "ComponentSumCheck" -> True, "Root" -> Sqrt[(sHat + t1)^2], 
 "WolframLinearBranch" -> sHat + t1, "RootRemainderZero" -> False, 
 "RootRemainderLeafCount" -> 54021, "RootRemainderSHA256" -> 
  "785c2b8a98cd84342d8c5f6c14e600655b290c52f626f60aec4a881a0e7ec1a0", 
 "BranchZeroChecks" -> <|"PositiveLinearBranch" -> False, 
   "NegativeLinearBranch" -> False|>, "SignRegionChecks" -> 
  <|"PositiveRegionExists" -> True, "NegativeRegionExists" -> True|>, 
 "PositiveRegion" -> Q2 > 0 && sHat > 0 && Inequality[-sHat, Less, t1, Less, 
    0], "NegativeRegion" -> Q2 > 0 && sHat > 0 && 
   Inequality[-Q2 - sHat, Less, t1, Less, -sHat], 
 "Checks" -> <|"Identities" -> True, "MapDerivation" -> True, 
   "ComponentSum" -> True, "MappedExpressionsClosed" -> True, 
   "RootReductionClosed" -> True, "SignRegionsComputed" -> True|>|>
