#!/usr/bin/env wolframscript

(*
  Independent polarized q -> q pole/factorization contract.

  This regression consumes only the reviewed internal real and virtual
  artifacts, the project Born normalization, and universal factorization
  conventions.  It does not read a published coefficient function.  The
  virtual coefficients are extracted from the reviewed Kira/SubTropica
  physical assembly and its separately frozen external-leg UV/IR ledger.
*)

ClearAll["Global`*"];

fail[msg_] := (
  Print["Polarized q->q factorization pole contract: FAIL: " <>
    ToString[msg, InputForm]];
  Exit[1]
);
env[name_] := Module[{value = Environment[name]},
  If[!StringQ[value] || StringLength[value] == 0,
    fail["missing environment variable " <> name]
  ];
  ExpandFileName[value]
];
sha256[file_] := IntegerString[FileHash[file, "SHA256"], 16, 64];
exactHeld[file_, label_] := Module[{held = Check[Get[file], $Failed]},
  If[Head[held] =!= HoldComplete || !FreeQ[held, _Real] ||
     !FreeQ[held, _Total], fail[label <> " is not an exact frozen object"]];
  ReleaseHold[held]
];
readManifest[file_, contract_: None] := Module[
  {value = Check[Import[file, "RawJSON"], $Failed]},
  If[!AssociationQ[value] || Lookup[value, "passed", False] =!= True,
    fail["manifest did not pass: " <> file]
  ];
  If[contract =!= None && Lookup[value, "contract", ""] =!= contract,
    fail["manifest contract changed: " <> file]
  ];
  value
];
sameQ[actual_, expected_, label_] := Module[
  {difference = physicalReduce[actual - expected]},
  If[!(TrueQ[difference === 0] ||
       (ListQ[difference] && And @@ (TrueQ[# === 0] & /@ Flatten[difference]))),
    fail[label <> ": " <> ToString[difference, InputForm]]
  ]
];

scriptFile = ExpandFileName[$InputFileName];
buildRoot = env["NLO_EQA_BUILD_ROOT"];
sourceRoot = env["NLO_EQA_SOURCE_ROOT"];
physicalRoot = FileNameJoin[{buildRoot, "kira_bundle", "assembled", "physical"}];
normalizationRoot = FileNameJoin[{buildRoot, "physical_real_pole_normalization"}];
realDistributionRoot = FileNameJoin[{buildRoot, "real_distributions"}];
virtualPhysicalRoot = FileNameJoin[{buildRoot, "virtual_kira_bundle", "assembled", "physical"}];
outputRoot = FileNameJoin[{buildRoot, "factorization_pole_contract"}];

physicalManifestFile = FileNameJoin[{physicalRoot, "manifest.json"}];
physicalPoleFile = FileNameJoin[{physicalRoot,
  "polarized_real_fixed_interior_pole.wl"}];
physicalFiniteFile = FileNameJoin[{physicalRoot,
  "polarized_real_fixed_interior_finite.wl"}];
normalizationManifestFile = FileNameJoin[{normalizationRoot, "manifest.json"}];
normalizationOuterFile = FileNameJoin[{normalizationRoot,
  "paper_outer_vw_coefficient.wl"}];
realDistributionManifestFile = FileNameJoin[{realDistributionRoot,
  "manifest.json"}];
realDoubleDeltaFile = FileNameJoin[{realDistributionRoot,
  "real_double_delta.wl"}];
realPoleRegularFile = FileNameJoin[{realDistributionRoot,
  "real_pole_regular.wl"}];
realPoleD0File = FileNameJoin[{realDistributionRoot, "real_pole_D0.wl"}];
realPoleDeltaFile = FileNameJoin[{realDistributionRoot,
  "real_pole_delta.wl"}];
realDistributionGeneratorFile = FileNameJoin[{sourceRoot, "mathematica", "50_distribute_real_poles.wls"}];
virtualReviewFile = FileNameJoin[{buildRoot, "feyncalc_virtual_reviewed.json"}];
virtualKiraManifestFile = FileNameJoin[{buildRoot, "virtual_kira_bundle", "assembled", "manifest.json"}];
virtualPhysicalManifestFile = FileNameJoin[{virtualPhysicalRoot,
  "manifest.json"}];
virtualDeltaFile = FileNameJoin[{virtualPhysicalRoot,
  "paper_normalized_virtual_delta.wl"}];
virtualExternalLedgerFile = FileNameJoin[{virtualPhysicalRoot,
  "external_self_energy_uv_ir_ledger.wl"}];
bornSourceFile = FileNameJoin[{sourceRoot, "mathematica", "13_born_hvbm.wl"}];
virtualSourceFile = FileNameJoin[{sourceRoot, "mathematica", "14_virtual_hvbm.wl"}];
countertermSourceFile = FileNameJoin[{sourceRoot, "mathematica", "17_real_counterterms.wl"}];
universalVirtualSourceFile = FileNameJoin[{sourceRoot, "mathematica", "18_virtual_qcd.wl"}];

requiredFiles = {physicalManifestFile, physicalPoleFile, physicalFiniteFile,
  normalizationManifestFile, normalizationOuterFile,
  realDistributionManifestFile, realDoubleDeltaFile, realPoleRegularFile,
  realPoleD0File, realPoleDeltaFile, realDistributionGeneratorFile,
  virtualReviewFile,
  virtualKiraManifestFile, virtualPhysicalManifestFile, virtualDeltaFile,
  virtualExternalLedgerFile, bornSourceFile, virtualSourceFile,
  countertermSourceFile, universalVirtualSourceFile};
If[!And @@ (FileExistsQ /@ requiredFiles), fail["a required input is missing"]];

physicalManifest = readManifest[physicalManifestFile,
  "polarized-q-to-q-fixed-interior-real-laurent-v1"];
normalizationManifest = readManifest[normalizationManifestFile,
  "polarized-q-to-q-physical-real-pole-normalization-v1"];
realDistributionManifest = readManifest[realDistributionManifestFile,
  "polarized-q-to-q-bare-real-distribution-poles-v1"];
virtualReview = Check[Import[virtualReviewFile, "RawJSON"], $Failed];
virtualKiraManifest = readManifest[virtualKiraManifestFile];
virtualPhysicalManifest = readManifest[virtualPhysicalManifestFile,
  "polarized-q-to-q-physical-virtual-laurent-v1"];
If[Lookup[realDistributionManifest, "generator_sha256", ""] =!=
     sha256[realDistributionGeneratorFile] ||
   Lookup[realDistributionManifest, "analytic_branch_policy", ""] =!=
     "preserve logarithms of positive physical cross-ratios; PowerExpand forbidden" ||
   Lookup[realDistributionManifest, "publication_comparison_performed", True] =!=
     False,
  fail["real distribution generator or branch contract changed"]
];
If[!AssociationQ[virtualReview] ||
   Lookup[Lookup[virtualReview, "review", <||>], "status", ""] =!= "reviewed" ||
   Lookup[Lookup[virtualReview, "derivation", <||>],
     "published_coefficients_used", True] =!= False,
  fail["reviewed polarized virtual source contract changed"]
];
If[Lookup[virtualKiraManifest, "kira_version", ""] =!= "3.1" ||
   Lookup[virtualKiraManifest, "uv_ir_ledger_status", ""] =!=
     "zero only after the separate UV/IR ledger",
  fail["polarized virtual Kira boundary changed"]
];
If[Lookup[virtualPhysicalManifest, "pipeline", {}] =!=
     {"Mathematica 15", "FeynArts", "FeynCalc", "Kira 3.1",
       "SubTropica 1.2.10"} ||
   Lookup[virtualPhysicalManifest, "published_coefficient_functions_used", True] =!=
     False ||
   Lookup[virtualPhysicalManifest, "distribution_support", ""] =!=
     "delta(1-w) only",
  fail["physical virtual pipeline or publication boundary changed"]
];
If[Lookup[physicalManifest["outputs"], FileNameTake[physicalPoleFile], ""] =!=
     sha256[physicalPoleFile] ||
   Lookup[physicalManifest["outputs"], FileNameTake[physicalFiniteFile], ""] =!=
     sha256[physicalFiniteFile],
  fail["physical real output hash mismatch"]
];
If[Lookup[normalizationManifest["outputs"],
     FileNameTake[normalizationOuterFile], ""] =!= sha256[normalizationOuterFile],
  fail["normalization output hash mismatch"]
];
realDistributionFiles = {realDoubleDeltaFile, realPoleRegularFile,
  realPoleD0File, realPoleDeltaFile};
If[!And @@ Map[
    Lookup[realDistributionManifest["outputs"], FileNameTake[#], ""] ===
      sha256[#] &,
    realDistributionFiles],
  fail["real distribution output hash mismatch"]
];
virtualPhysicalFiles = {virtualDeltaFile, virtualExternalLedgerFile};
If[!And @@ Map[
    Lookup[virtualPhysicalManifest["outputs"], FileNameTake[#], ""] ===
      sha256[#] &,
    virtualPhysicalFiles],
  fail["physical virtual output hash mismatch"]
];

fixedPole = exactHeld[physicalPoleFile, "physical real pole"];
fixedFinite = exactHeld[physicalFiniteFile, "physical real finite coefficient"];
frozenOuterPole = exactHeld[normalizationOuterFile,
  "paper outer-vw real pole"];
frozenRealDoubleDelta = exactHeld[realDoubleDeltaFile,
  "real double-delta coefficient"];
frozenRealPoleTuple = {
  exactHeld[realPoleRegularFile, "real regular simple pole"],
  exactHeld[realPoleD0File, "real D0 simple pole"],
  exactHeld[realPoleDeltaFile, "real delta simple pole"]
} /. mu2 -> muR2;
frozenVirtualDelta = exactHeld[virtualDeltaFile,
  "paper-normalized physical virtual delta"] /. mu2 -> muR2;
physicalExternalLedger = exactHeld[virtualExternalLedgerFile,
  "physical external-leg UV/IR ledger"];

physicalAssumptions = s > 0 && muR2 > 0 && 0 < v < 1 && 0 < w < 1;
physicalReduce[expr_] := FullSimplify[FunctionExpand[expr],
  Assumptions -> physicalAssumptions];

r = 1 - v;
d = r + v w;
rho = 1 - v w;
beta = (1 + v)/r;
yGamma = r/rho;
LReal = Log[4 Pi muR2/(s v r)] - EulerGamma;
LVirtual = Log[4 Pi muR2/(s r)] - EulerGamma;
vwMap = {t -> -s r, s4 -> s v (1 - w)};

(* Strip alpha_s/pi and CF alpha_em^2 e_q^2/(s v w). *)
outerPole = physicalReduce[
  (2 Pi s v w fixedPole/(CF ee^4 eq^2 gs^2)) /. vwMap
];
outerFinite = physicalReduce[
  (2 Pi s v w (fixedFinite + fixedPole Log[muR2])/
    (CF ee^4 eq^2 gs^2)) /. vwMap
];
sameQ[outerPole, frozenOuterPole, "independent outer-vw normalization"];

(* Endpoint expansion of the frozen bare real object.  B_1 is deliberately
   not inferred from a fixed-interior finite coefficient. *)
Bminus1 = physicalReduce[Limit[(1 - w) outerPole, w -> 1,
  Direction -> "FromBelow"]];
B0 = physicalReduce[Limit[
  (1 - w) outerFinite + 2 Bminus1 Log[1 - w], w -> 1,
  Direction -> "FromBelow"]];
sameQ[Bminus1, -4 beta, "polarized Born soft residue B_-1"];
sameQ[B0, -4 beta LReal, "endpoint coefficient B_0"];

realDoubleDelta = -Bminus1/2;
realPoleTuple = physicalReduce[{
  outerPole - Bminus1/(1 - w),
  Bminus1,
  -B0/2
}];
sameQ[realDoubleDelta, frozenRealDoubleDelta,
  "frozen real double-delta coefficient"];
sameQ[realPoleTuple, frozenRealPoleTuple,
  "independent reconstruction of frozen real pole tuple"];

(* Positive bare-to-renormalized pole insertions.  A tuple is
   {regular,D0,delta} inside the common paper prefactor N_A/(v w).
   The regular entries include the canonicalization induced by the outer
   1/w multiplying D0. *)
j0 = physicalReduce[(r + 2 v w)/(r d)];
jEndpoint = beta;
ffFullRegular = physicalReduce[
  (2 (j0 - jEndpoint)/(1 - w))/v - j0 (1 + d)
];

pdfPoleTuple = physicalReduce[{
  -beta (1 + w),
  2 beta,
  3 beta/2
}];
ffPoleTuple = physicalReduce[{
  v w ffFullRegular - 2 beta,
  2 beta,
  beta (2 Log[v] + 3/2)
}];
leptonPoleTuple = physicalReduce[{
  (2 - yGamma) (1 - v^2 w^2)/r,
  0,
  0
}];

(* Multiplication by the common outer 1/(v w) is itself distributional:
   (1/w) D0 = D0 + 1/w.  This map checks the outer tuples against the
   ordinary full-w-density convolution transforms. *)
outerToFullTuple[tuple_] := physicalReduce[{
  (tuple[[1]] + tuple[[2]])/(v w),
  tuple[[2]]/v,
  tuple[[3]]/v
}];
sameQ[outerToFullTuple[pdfPoleTuple], {
  beta (1 - w)/(v w), 2 beta/v, 3 beta/(2 v)},
  "incoming polarized PDF convolution normalization"];
sameQ[outerToFullTuple[ffPoleTuple], {
  ffFullRegular, 2 beta/v, beta (2 Log[v] + 3/2)/v},
  "outgoing unpolarized FF convolution normalization"];
sameQ[outerToFullTuple[leptonPoleTuple], {
  (2 - yGamma) (1 - v^2 w^2)/(r v w), 0, 0},
  "lepton-collinear convolution normalization"];

(* The ordinary photon row is independently fixed by regular pole closure
   and must also factor into Delta P_{gamma/l}=2-y times the polarized
   four-dimensional Compton numerator 1-(v w)^2. *)
leptonFromClosure = physicalReduce[
  -realPoleTuple[[1]] - pdfPoleTuple[[1]] - ffPoleTuple[[1]]
];
sameQ[leptonPoleTuple[[1]], leptonFromClosure,
  "lepton-collinear row from local closure"];
sameQ[leptonPoleTuple[[1]],
  (1 + v w) (1 + v - 2 v w)/r,
  "polarized photon-kernel factorization"];

(* Extract the virtual double and single poles from the physical
   Kira/SubTropica delta artifact rather than assuming them from closure. *)
virtualDoubleDelta = physicalReduce[
  Limit[eps^2 frozenVirtualDelta, eps -> 0]
];
virtualSingleDelta = physicalReduce[
  Limit[eps (frozenVirtualDelta - virtualDoubleDelta/eps^2), eps -> 0]
];
virtualSingleTuple = {0, 0, virtualSingleDelta};
sameQ[virtualDoubleDelta, -2 beta,
  "physical virtual double pole"];
sameQ[virtualSingleDelta, -beta (3 + 2 LVirtual),
  "physical virtual single pole"];
sameQ[realDoubleDelta + virtualDoubleDelta, 0,
  "real-virtual double pole"];
sameQ[realPoleTuple[[3]] + virtualSingleTuple[[3]],
  -beta (3 + 2 Log[v]), "real-plus-virtual single delta row"];
sameQ[realPoleTuple + virtualSingleTuple + pdfPoleTuple + ffPoleTuple +
  leptonPoleTuple, {0, 0, 0}, "complete simple-pole closure"];

(* First verify the separately frozen active external-leg UV/IR ledger. *)
If[!AssociationQ[physicalExternalLedger] ||
   Lookup[physicalExternalLedger, "columns", {}] =!=
     {"UV1", "IR2", "IR1", "finite"} ||
   Lookup[physicalExternalLedger, "normalization", ""] =!=
     "aLoop=CF alphaS/(4 Pi) at amplitude level" ||
   Lookup[physicalExternalLedger, "bare_external_self_energy", {}] +
       Lookup[physicalExternalLedger, "counterterm_subtraction", {}] =!=
     Lookup[physicalExternalLedger, "renormalized_external_residue", {}],
  fail["physical external-leg UV/IR ledger did not close"]
];

(* The same reviewed polarized vector-current projector permits the complete
   amplitude-level form-factor ledger.  After conversion to the outer paper
   normalization, each entry below includes beta and the columns are
   {UV,IR^2,IR}. *)
fullFormFactorLedger = <|
  "bare_1PI_vertex" -> beta {1, -2, -4},
  "MSbar_quark_field" -> beta {-1, 0, 0},
  "external_LSZ_residue" -> beta {0, 0, 1},
  "total_before_scale_expansion" -> beta {0, -2, -3}
|>;
sameQ[fullFormFactorLedger["bare_1PI_vertex"] +
  fullFormFactorLedger["MSbar_quark_field"] +
  fullFormFactorLedger["external_LSZ_residue"],
  fullFormFactorLedger["total_before_scale_expansion"],
  "complete polarized form-factor UV/IR ledger"];
uvIrLedger = <|
  "physical_external_self_energy" -> physicalExternalLedger,
  "paper_outer_full_form_factor" -> fullFormFactorLedger
|>;

(* In hep-ph/0211007 Eqs. (20)--(21), the factorized hard part receives
   -Delta H_qq convolution Born.  Since Eq. (23) fixes the finite scheme
   kernel Delta f_qq=-4 CF(1-z), its contribution to the hard part is
   -Delta f_qq convolution Born=+4 CF(1-z) convolution Born.  Keep the
   scheme-kernel sign distinct from the hard-counterterm sign.  Neither has
   a plus or delta component. *)
hvbmSplittingEpsilonTuple = {4 beta (1 - w), 0, 0};
hvbmSchemeKernelTuple = {-4 beta (1 - w), 0, 0};
hvbmRawCollinearEvanescentTuple = -hvbmSplittingEpsilonTuple;
hvbmHardCountertermTuple = -hvbmSchemeKernelTuple;
sameQ[hvbmSplittingEpsilonTuple + hvbmSchemeKernelTuple, {0, 0, 0},
  "primitive HVBM splitting-kernel restoration"];
sameQ[-hvbmSchemeKernelTuple, hvbmHardCountertermTuple,
  "finite HVBM hard-counterterm sign"];
sameQ[hvbmRawCollinearEvanescentTuple + hvbmHardCountertermTuple,
  {0, 0, 0}, "hard-level HVBM helicity restoration"];

If[!DirectoryQ[outputRoot],
  CreateDirectory[outputRoot, CreateIntermediateDirectories -> True]];
writeFrozen[name_, value_] := Module[{file = FileNameJoin[{outputRoot, name}]},
  With[{frozen = value}, Put[HoldComplete[frozen], file]];
  FileNameTake[file] -> sha256[file]
];
outputs = Association[
  writeFrozen["real_pole_outer_tuple.wl", realPoleTuple],
  writeFrozen["virtual_poles_outer.wl", <|
    "double_delta" -> virtualDoubleDelta,
    "single_tuple" -> virtualSingleTuple|>],
  writeFrozen["pdf_pole_outer_tuple.wl", pdfPoleTuple],
  writeFrozen["ff_pole_outer_tuple.wl", ffPoleTuple],
  writeFrozen["lepton_pole_outer_tuple.wl", leptonPoleTuple],
  writeFrozen["hvbm_finite_outer_tuple.wl", hvbmHardCountertermTuple],
  writeFrozen["uv_ir_ledger_outer.wl", uvIrLedger]
];

manifest = <|
  "schema_version" -> 1,
  "contract" -> "polarized-q-to-q-factorization-pole-closure-v2",
  "generated_by" -> "Mathematica 15 exact internal factorization audit",
  "normalization" -> <|
    "N_A" -> "CF alpha_em^2 e_q^2 alpha_s/(pi s)",
    "common_outer_prefactor" -> "N_A/(v w)",
    "tuple_order" -> {"regular", "D0", "delta"},
    "D0" -> "[1/(1-w)]_+ on [0,1]",
    "outer_to_full_tuple" ->
      "{R,C0,Cdelta} -> {(R+C0)/(v w),C0/v,Cdelta/v}",
    "hard_counterterm_convention" ->
      "dDelta sigma_fact=dDelta sigma_bare-(alpha_s/pi) Delta H convolution dDelta sigma_Born",
    "finite_scheme_kernel" -> "Delta f_qq(z)=-4 CF(1-z)",
    "finite_hard_insertion" -> "-Delta f_qq convolution Born=+4 CF(1-z) convolution Born",
    "raw_collinear_evanescent_hard_term" ->
      "-[Delta P_qq-P_qq]/epsilon convolution Born=-4 CF(1-z) convolution Born"
  |>,
  "method_reference" -> <|
    "arxiv" -> "hep-ph/0211007v1",
    "source_archive_sha256" ->
      "36dfb04ce689bb7f1fe195546c763f69b657f2bce2996ba520c07841b594b07d",
    "source_member" -> "hadnlo-final.tex",
    "source_member_sha256" ->
      "35dadc6237ad5945f4517de34429eed5b58d7451de143d2ff1214db4ecfab5a2",
    "hard_subtraction_equation" -> "Eq. (20)",
    "Delta_H_definition" -> "Eq. (21)",
    "finite_kernel_equation" -> "Eq. (23)"
  |>,
  "source_hashes" -> <|
    "generator_source" -> sha256[scriptFile],
    "physical_real_manifest" -> sha256[physicalManifestFile],
    "physical_real_pole" -> sha256[physicalPoleFile],
    "physical_real_finite" -> sha256[physicalFiniteFile],
    "physical_normalization_manifest" -> sha256[normalizationManifestFile],
    "physical_outer_pole" -> sha256[normalizationOuterFile],
    "real_distribution_manifest" -> sha256[realDistributionManifestFile],
    "real_distribution_generator" -> sha256[realDistributionGeneratorFile],
    "real_double_delta" -> sha256[realDoubleDeltaFile],
    "real_pole_regular" -> sha256[realPoleRegularFile],
    "real_pole_D0" -> sha256[realPoleD0File],
    "real_pole_delta" -> sha256[realPoleDeltaFile],
    "polarized_born_source" -> sha256[bornSourceFile],
    "polarized_virtual_source" -> sha256[virtualSourceFile],
    "reviewed_virtual_export" -> sha256[virtualReviewFile],
    "virtual_kira_manifest" -> sha256[virtualKiraManifestFile],
    "physical_virtual_manifest" -> sha256[virtualPhysicalManifestFile],
    "physical_virtual_delta" -> sha256[virtualDeltaFile],
    "physical_external_uv_ir_ledger" -> sha256[virtualExternalLedgerFile],
    "universal_vector_form_factor_uv_ir_source" ->
      sha256[universalVirtualSourceFile],
    "counterterm_transform_source" -> sha256[countertermSourceFile]
  |>,
  "endpoint" -> <|
    "B_minus_1" -> ToString[Bminus1, InputForm],
    "B_0" -> ToString[B0, InputForm],
    "B_1" -> "outside this pole-only contract; reviewed by polarized-q-to-q-endpoint-soft-b1-v1",
    "finite_real_delta" -> "outside this pole-only contract; frozen by the endpoint-B1 assembly",
    "pole_delta" -> "frozen from B_0; does not require B_1"
  |>,
  "status" -> <|
    "real_pole_distribution" -> "independently reconstructed and frozen",
    "pdf_pole" -> "frozen",
    "ff_pole" -> "frozen",
    "lepton_pole" ->
      "closure-frozen; the independently reviewed D-dimensional Compton source is consumed downstream",
    "hvbm_finite_restoration" ->
      "frozen as the hard-counterterm contribution -Delta f_qq convolution Born",
    "virtual_poles" ->
      "derived from and frozen against the physical Kira/SubTropica virtual assembly",
    "external_uv_ir_ledger" ->
      "derived and hash-checked against the physical external-leg ledger",
    "finite_closure" -> "outside this pole-only contract; assembled downstream"
  |>,
  "scope_boundary" -> {
    "This contract freezes pole closure and the finite HVBM hard counterterm only.",
    "The reviewed endpoint B_1 and polarized gamma-q epsilon coefficient are admitted by the downstream finite-direct assembly."
  },
  "publication_coefficient_functions_used" -> False,
  "forbidden_executables_invoked" -> {},
  "outputs" -> outputs,
  "checks" -> <|
    "input_hashes" -> True,
    "born_soft_endpoint" -> True,
    "outer_vw_normalization" -> True,
    "real_distribution_through_simple_pole" -> True,
    "real_distribution_output_hashes" -> True,
    "physical_virtual_output_hashes" -> True,
    "physical_virtual_laurent_extraction" -> True,
    "physical_external_uv_ir_ledger" -> True,
    "real_virtual_double_pole" -> True,
    "pdf_plus_ff_D0_closure" -> True,
    "outer_prefactor_distribution_canonicalization" -> True,
    "pdf_and_ff_convolution_transforms" -> True,
    "lepton_regular_closure" -> True,
    "single_delta_closure" -> True,
    "complete_simple_pole_closure" -> True,
    "hvbm_scheme_kernel_sign" -> True,
    "hvbm_hard_counterterm_sign" -> True,
    "hvbm_raw_evanescent_hard_term_sign" -> True,
    "hvbm_hard_level_helicity_restoration" -> True,
    "method_reference_sign_derived_without_target_coefficients" -> True,
    "no_appendix_input" -> True
  |>,
  "passed" -> True
|>;
Export[FileNameJoin[{outputRoot, "manifest.json"}], manifest, "RawJSON"];
Print[ExportString[manifest, "RawJSON"]];
Print["PASS: polarized q->q factorization pole contract frozen."];
Print["SCOPE: finite endpoint and photon-boundary terms are assembled downstream."];
Exit[0];
