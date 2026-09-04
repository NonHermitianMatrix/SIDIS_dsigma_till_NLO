<|"Stage" -> "HqqV2S07InitialPPPProjectorRescalingDiagnostic-v1", 
 "ScopeTag" -> 
  "[Hqq_v2, people or agents working on other channels should ignore]", 
 "Source" -> <|"Path" -> "/u/home/r/rushil/AI_Assisted_SIDIS_Hqq_v2/s07_diagn\
ose_initial_ppp_projector_rescaling.wl", 
   "SHA256" -> 
    "df3703604186740cabc5e4212b4744d5a4a04f9801e2c6763ce4660b685f76e5"|>, 
 "Inputs" -> <|"FactorizationCacheSHA256" -> 
    "4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48", 
   "RawResidualCacheSHA256" -> 
    "afc12bb8e9942d9059c0f1eda9e1e6d73d137e19af5dc0cf26651992edaad569", 
   "RationalFactorResultSHA256" -> 
    "633223d4714264ba56b5c20bac98c28d219386f97eb05f3c9c5399f7efe5ddf9", 
   "ResidualSHA256" -> 
    "abe32a8afa08a3631e3735d9941598c05b170a5bebe5d49e78677026ddb02918"|>, 
 "Derivation" -> <|"XDefinition" -> xHat == Q2/(2*pDotQ), 
   "ParentXDefinition" -> xParent == Q2/(2*parentScale*pDotQ), 
   "MomentumScaleRule" -> {parentScale -> eta}, 
   "ExternalPPP" -> Pair[LorentzIndex[mu, D], Momentum[p, D]]*
     Pair[LorentzIndex[nu, D], Momentum[p, D]], 
   "ParentPPP" -> parentScale^2*Pair[LorentzIndex[mu, D], Momentum[p, D]]*
     Pair[LorentzIndex[nu, D], Momentum[p, D]], 
   "ProjectorScale" -> parentScale^2, "ExternalConversionInEta" -> eta^(-2), 
   "InitialConstraint" -> eta*s23 + t1 - eta*t1, 
   "EtaRootRule" -> {eta -> -(t1/(s23 - t1))}, 
   "RouteScale" -> (s23 - t1)^2/t1^2, "RouteScaleEndpoint" -> 1, 
   "GenericOldOrdinary" -> genericRegularDensity + 
     (-genericEndpointPlusCoefficient + genericSingularDensity)/genericS, 
   "GenericNewOrdinary" -> genericRegularDensity*genericRouteScale + 
     (-genericEndpointPlusCoefficient + genericRouteScale*
        genericSingularDensity)/genericS, "GenericCachedRewrite" -> 
    (genericEndpointPlusCoefficient*(-1 + genericRouteScale))/genericS + 
     genericRouteScale*(genericRegularDensity + 
       (-genericEndpointPlusCoefficient + genericSingularDensity)/
        genericS)|>, "InitialRoutes" -> {"Initial_qq", "Initial_gq"}, 
 "PlusEndpointCoefficients" -> 
  <|"Initial_qq" -> (FAGS^4*(-1 + SUNN^2)^2*(Q2 + sHat + t1)*FCGV["EL"]^2*
      HqqV2Charge["UpType"]^2)/(64*Pi^5*SUNN^2), "Initial_gq" -> 0|>, 
 "CorrectedInitialPPPOrdinaryMinusOne" -> 
  <|"Initial_qq" -> -1/128*(FAGS^4*(-1 + SUNN^2)^2*(-(Q2*s23) + s23^2 - 
        s23*sHat + 2*Q2*t1 - 3*s23*t1 + 2*sHat*t1 + 4*t1^2)*FCGV["EL"]^2*
       HqqV2Charge["UpType"]^2)/(Pi^5*SUNN^2*t1^2), 
   "Initial_gq" -> -1/64*(FAGS^4*(-1 + SUNN^2)*(Q2*s23 + sHat*t1)*
       (2*s23^2 - 2*s23*t1 + t1^2)*FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
      (Pi^5*SUNN*t1^4)|>, "RouteCorrections" -> 
  <|"Initial_qq" -> -1/128*(FAGS^4*(-1 + SUNN^2)^2*(-(Q2*s23^3) + s23^4 - 
        s23^3*sHat + 4*Q2*s23^2*t1 - 5*s23^3*t1 + 4*s23^2*sHat*t1 - 
        6*Q2*s23*t1^2 + 10*s23^2*t1^2 - 6*s23*sHat*t1^2 + 4*Q2*t1^3 - 
        10*s23*t1^3 + 4*sHat*t1^3 + 4*t1^4)*FCGV["EL"]^2*
       HqqV2Charge["UpType"]^2)/(Pi^5*SUNN^2*(s23 - t1)^2*t1^2), 
   "Initial_gq" -> (FAGS^4*(-1 + SUNN^2)*(-s23^2 + 2*s23*t1)*
      (Q2*s23 + sHat*t1)*(2*s23^2 - 2*s23*t1 + t1^2)*FCGV["EL"]^2*
      HqqV2Charge["UpType"]^2)/(64*Pi^5*SUNN*t1^4*(-s23 + t1)^2)|>, 
 "CorrectionSum" -> -1/128*(FAGS^4*(-1 + SUNN^2)*(4*Q2*s23^5*SUNN - 
      12*Q2*s23^4*SUNN*t1 + 4*s23^4*sHat*SUNN*t1 + Q2*s23^3*t1^2 - 
      s23^4*t1^2 + s23^3*sHat*t1^2 + 10*Q2*s23^3*SUNN*t1^2 - 
      12*s23^3*sHat*SUNN*t1^2 - Q2*s23^3*SUNN^2*t1^2 + s23^4*SUNN^2*t1^2 - 
      s23^3*sHat*SUNN^2*t1^2 - 4*Q2*s23^2*t1^3 + 5*s23^3*t1^3 - 
      4*s23^2*sHat*t1^3 - 4*Q2*s23^2*SUNN*t1^3 + 10*s23^2*sHat*SUNN*t1^3 + 
      4*Q2*s23^2*SUNN^2*t1^3 - 5*s23^3*SUNN^2*t1^3 + 
      4*s23^2*sHat*SUNN^2*t1^3 + 6*Q2*s23*t1^4 - 10*s23^2*t1^4 + 
      6*s23*sHat*t1^4 - 4*s23*sHat*SUNN*t1^4 - 6*Q2*s23*SUNN^2*t1^4 + 
      10*s23^2*SUNN^2*t1^4 - 6*s23*sHat*SUNN^2*t1^4 - 4*Q2*t1^5 + 
      10*s23*t1^5 - 4*sHat*t1^5 + 4*Q2*SUNN^2*t1^5 - 10*s23*SUNN^2*t1^5 + 
      4*sHat*SUNN^2*t1^5 - 4*t1^6 + 4*SUNN^2*t1^6)*FCGV["EL"]^2*
     HqqV2Charge["UpType"]^2)/(Pi^5*SUNN^2*t1^4*(-s23 + t1)^2), 
 "CorrectedResidual" -> 0, "Metadata" -> 
  <|"RouteScaleSHA256" -> 
    "caf5ad08b5dabff94dba25d1d95640df0a1897f01eeb89b46d05e00e42a5e08f", 
   "CorrectionSumSHA256" -> 
    "1103e64beb64507af7c8b04cd1dd542eb3a30aad8556444ac3606c824d607757", 
   "CorrectedRouteSumSHA256" -> 
    "02d856efca8694e023105d3e138e4e5f7ecdfe58f413bff13dd9d5a6b7d650eb", 
   "CorrectedResidualSHA256" -> 
    "3d2657e44444e31b63ca19355e31677556fdc59d5e9e9382140fa9953816a7af"|>, 
 "Checks" -> <|"FactorizationCache" -> True, "RawResidualCache" -> True, 
   "RationalFactorResult" -> True, "Associations" -> True, 
   "FactorizationScope" -> True, "RawResidualScope" -> True, 
   "RationalFactorScope" -> True, "StoredChecks" -> True, 
   "ResidualIdentity" -> True, "SymbolicMomentumCoefficientDeclared" -> True, 
   "FeynCalcObjects" -> True, "XDefinitionReconstructs" -> True, 
   "ParentDotReconstructs" -> True, "ProjectorScaleReconstructs" -> True, 
   "ExternalConversionReconstructs" -> True, "ConstraintRoot" -> True, 
   "EndpointUnity" -> True, "ScaleClosed" -> True, "ScaleNontrivial" -> True, 
   "GenericCachedIdentity" -> True, "RouteInventory" -> True, 
   "PlusExtraction" -> True, "CorrectionsClosed" -> True, 
   "CorrectionsNonzero" -> True, "OldRouteSumReconstructsLedger" -> True, 
   "CorrectedRouteSumIsOldPlusCorrection" -> True, "PgUnchanged" -> True, 
   "DeltaUnchanged" -> True, "BoundedPlusUnchanged" -> True, 
   "FinalRoutesUnchanged" -> True, "InitialOtherOrdinaryPowersUnchanged" -> 
    True, "CorrectionCancelsCachedResidual" -> True, 
   "CorrectedResidual" -> True, "ExactClosed" -> True|>, 
 "DownstreamBoundary" -> "regenerate only initial PPP ordinary Laurent fields \
from the accepted factorization cache"|>
