(* Production-only scalar post-processing for the directly generated lower
   Born subprocess

       q_i(pa)+qbar_i(pb) -> g(pc observed)+g(pd).

   FeynCalc is deliberately not loaded here.  The only inputs are the exact
   FORM scalars.  A separate live FeynCalc script is an oracle after this
   production artifact has been written. *)
ClearAll[fail, pass, readFormScalar, rationalReduce, exactZero,
  hardEpsilonTuple, sha256, promote];
fail[message_, detail_: Null] := (
  Print["FAIL: ", message];
  If[detail =!= Null, Print["DETAIL=", InputForm[detail]]];
  Quit[1]
);
pass[message_] := Print["PASS: " <> message];
sha256[path_] := ToLowerCase @ IntegerString[FileHash[path, "SHA256"], 16, 64];

(* FORM may wrap a product immediately before its `*'.  Converting every
   whitespace run to one ordinary space repairs that continuation without
   concatenating tokens. *)
readFormScalar[path_] := Module[{text, held},
  If[! FileExistsQ[path], fail["missing FORM lower-Born scalar", path]];
  text = StringReplace[Import[path, "Text"],
    {WhitespaceCharacter .. -> " ", "i_" -> "I"}];
  held = Quiet @ Check[
    ToExpression[text, InputForm, HoldComplete], $Failed];
  If[held === $Failed || ! MatchQ[held, HoldComplete[_]],
    fail["cannot parse FORM lower-Born scalar", path]];
  ReleaseHold[held]
];

(* Pairwise rational combination avoids a deep intermediate expression when
   a FORM-expanded axial-gauge result is canonicalized by Mathematica. *)
rationalReduce[expression_] := Module[{terms, batches},
  If[TrueQ[expression === 0], Return[0]];
  terms = If[Head[expression] === Plus, List @@ expression, {expression}];
  While[Length[terms] > 1,
    batches = Partition[terms, UpTo[2]];
    terms = (Cancel[Together[Total[#]]] & /@ batches)
  ];
  Factor[Cancel[Together[First[terms]]]]
];
exactZero[expression_] := rationalReduce[expression];

root = DirectoryName[DirectoryName[$InputFileName]];
formBuild = FileNameJoin[{root, "build", "lower_born_gg"}];
promotionBuild = FileNameJoin[{root, "build", "lower_born"}];
If[! DirectoryQ[promotionBuild],
  CreateDirectory[promotionBuild, CreateIntermediateDirectories -> True]];
path[name_] := FileNameJoin[{formBuild, name}];

uSquare = rationalReduce @ readFormScalar[path["math_BornU.m"]];
pSquare = rationalReduce @ readFormScalar[path["math_BornP.m"]];

gateFiles = <|
  "CDR pair reconstruction" -> "math_PairCheckU.m",
  "CDR pc-reference independence" -> "math_GaugeCheckUC.m",
  "CDR pd-reference independence" -> "math_GaugeCheckUD.m",
  "CDR simultaneous-reference independence" -> "math_GaugeCheckUBoth.m",
  "CDR pc Ward identity" -> "math_WardCheckUC.m",
  "CDR pd Ward identity" -> "math_WardCheckUD.m",
  "BMHV pair reconstruction" -> "math_PairCheckP.m",
  "BMHV pc-reference independence" -> "math_GaugeCheckPC.m",
  "BMHV pd-reference independence" -> "math_GaugeCheckPD.m",
  "BMHV simultaneous-reference independence" -> "math_GaugeCheckPBoth.m",
  "BMHV pc Ward identity" -> "math_WardCheckPC.m",
  "BMHV pd Ward identity" -> "math_WardCheckPD.m"
|>;
KeyValueMap[
  Function[{label, file},
    remainder = exactZero @ readFormScalar[path[file]];
    If[remainder =!= 0, fail[label <> " failed", remainder]];
    pass[label <> " is exact"]], gateFiles];

feynmanU = rationalReduce @
  readFormScalar[path["math_FeynmanDiagnosticU.m"]];
feynmanP = rationalReduce @
  readFormScalar[path["math_FeynmanDiagnosticP.m"]];
If[feynmanU === 0 || feynmanP === 0,
  fail["bare simultaneous covariant final-gluon diagnostic unexpectedly vanished"]];
pass["bare simultaneous covariant final-gluon sum is retained only as a nonzero Slavnov--Taylor diagnostic"];

If[! FreeQ[{uSquare, pSquare},
    _DiracGamma | _DiracTrace | _Spinor | _LorentzIndex | _Pair |
    _Momentum | _SUNTF | _SUNF | _FeynAmpDenominator | _Den | _Line |
    _Pol | _Eps4],
  fail["unevaluated tensor/bridge object survived the FORM lower-Born square"]];
If[! FreeQ[{uSquare, pSquare}, NA | CF | CA | alphaS | ep],
  fail["unresolved colour or conversion symbol in FORM lower-Born square"]];
If[FreeQ[uSquare, D] || FreeQ[pSquare, D],
  fail["a lower-Born square lost its exact D dependence"]];

If[exactZero[uSquare - (uSquare /. {t -> u, u -> t})] =!= 0 ||
   exactZero[pSquare - (pSquare /. {t -> u, u -> t})] =!= 0,
  fail["tagged-gluon lower-Born square is not t/u symmetric"]];
pass["both tagged-gluon squares are exactly t/u symmetric"];
If[exactZero[(pSquare + uSquare) /. D -> 4] =!= 0,
  fail["physical double-longitudinal BMHV square is not minus CDR at D=4"]];
pass["D=4 physical helicity identity Polarized=-Unpolarized is exact"];

(* The tagged-parent convention cancels the identical-particle factor:
   (1/2!) times the two possible tagged gluons is one.  Therefore there is
   no extra half in the hard density. *)
toHard[square_] := rationalReduce[
  square/(16 Pi s) /. {
    gs^4 -> (4 Pi alphaS)^2,
    t -> -s (1-v), u -> -s v, Nc -> CA
  }
];
uHardD = toHard[uSquare];
pHardD = toHard[pSquare];
If[FreeQ[uHardD, D] || FreeQ[pHardD, D],
  fail["lower-Born hard density lost D dependence"]];

hardEpsilonTuple[hard_] := Module[{full, tuple, remainder},
  full = rationalReduce[hard /. D -> 4-2 ep];
  tuple = <|
    0 -> rationalReduce[full /. ep -> 0],
    1 -> rationalReduce[Coefficient[full, ep, 1]]
  |>;
  remainder = rationalReduce[
    Normal[Series[full, {ep, 0, 1}]]-tuple[0]-ep tuple[1]];
  If[remainder =!= 0,
    fail["O(ep) tuple does not reconstruct the exact series through ep^1",
      remainder]];
  <|"exact" -> full, "coefficients" -> tuple|>
];
uEp = hardEpsilonTuple[uHardD];
pEp = hardEpsilonTuple[pHardD];
If[uEp["coefficients"][1] === 0 || pEp["coefficients"][1] === 0,
  fail["required Born O(ep) coefficient vanished"]];
pass["exact D hard densities and both nonzero Born O(ep) coefficients are retained"];

metadataPath = path["metadata.json"];
If[! FileExistsQ[metadataPath], fail["lower-Born translation metadata missing"]];
metadata = Import[metadataPath, "RawJSON"];
expectedIDs = Table[
  "GraphID[Topology == 1, Generic == 1, Classes == 1, Number == " <>
    ToString[index] <> "]", {index, 3}];
If[metadata["schema"] =!= "qqbar_annihilation_lower_born_gg_translation_v1" ||
   metadata["diagram_count"] =!= 3 || metadata["conjugate_count"] =!= 3 ||
   metadata["graph_ids"] =!= expectedIDs ||
   metadata["create_feyn_amp_prefactor"] =!= "1" ||
   metadata["fcfaconvert_contract"] =!= False ||
   metadata["tagged_final_combinatoric_factor"] =!= 1,
  fail["direct lower-Born translation metadata changed", metadata]];
pass["three direct FeynArts graph IDs, unit prefactors, and unit tagged-final factor are frozen"];

formFiles = {
  FileNameJoin[{root, "form", "lower_born_gg_unpolarized.frm"}],
  FileNameJoin[{root, "form", "lower_born_gg_bmhv.frm"}]
};
candidate = <|
  "schema" -> "qqbar_to_gg_direct_born_hard_v1",
  "process" -> "q_i qbar_i -> g g",
  "momenta" -> "q_i(pa)+qbar_i(pb)->g(pc observed)+g(pd)",
  "source_role" -> "direct FeynArts--minimal bridge--FORM",
  "direct_generation" -> True,
  "diagram_count" -> 3,
  "graph_ids" -> expectedIDs,
  "create_feyn_amp_prefactor" -> "1",
  "fcfaconvert_contract" -> False,
  "scheme" -> "physical CDR and explicit same-trace two-gamma5 BMHV",
  "initial_spin_colour_average" -> "1/(4 Nc^2)",
  "hard_normalization" -> "square/(16 Pi s)",
  "tagged_final_gluon_convention" ->
    "1/2! phase space times two tagged-gluon choices equals one",
  "tagged_final_combinatoric_factor" -> 1,
  "official_FORM_color_package" -> "configured NLO_FORM_COLOR_HEADER",
  "gamma5_implementation" ->
    "two independent explicit barred epsilons on the same incoming trace; native gamma5 forbidden",
  "ward_gate" -> True,
  "axial_reference_gate" -> True,
  "pair_reconstruction_gate" -> True,
  "physical_D4_P_equals_minus_U" -> True,
  "includes_Born_Oep" -> True,
  "unpolarized_square_D" -> uSquare,
  "polarized_square_D" -> pSquare,
  "unpolarized_hard_D" -> uHardD,
  "polarized_hard_D" -> pHardD,
  "unpolarized_hard_ep" -> uEp["coefficients"],
  "polarized_hard_ep" -> pEp["coefficients"],
  "unpolarized_hard_ep_exact" -> uEp["exact"],
  "polarized_hard_ep_exact" -> pEp["exact"],
  "bare_covariant_diagnostic_nonzero" -> True,
  "translation_metadata_sha256" -> sha256[metadataPath],
  "form_source_sha256" -> AssociationThread[
    FileNameTake /@ formFiles, sha256 /@ formFiles]
|>;

promote[path_, expression_] := Module[{candidatePath, parsed},
  candidatePath = path <> ".candidate";
  Export[candidatePath,
    ToString[InputForm[expression], PageWidth -> Infinity], "Text"];
  parsed = Quiet @ Check[Get[candidatePath], $Failed];
  If[parsed === $Failed || parsed =!= expression,
    fail["lower-Born candidate failed read-back promotion gate", candidatePath]];
  RenameFile[candidatePath, path, OverwriteTarget -> True]
];
artifactPath = FileNameJoin[
  {promotionBuild, "qqbar_to_gg_born_hard.wl"}];
promote[artifactPath, candidate];
pass["promoted direct FORM qqbar->gg lower-Born hard artifact"];
Print["LOWER-BORN-ARTIFACT=", artifactPath];
Print["UNPOLARIZED-SQUARE-D=", InputForm[uSquare]];
Print["POLARIZED-BMHV-SQUARE-D=", InputForm[pSquare]];
Print["UNPOLARIZED-HARD-EP=", InputForm[uEp["coefficients"]]];
Print["POLARIZED-HARD-EP=", InputForm[pEp["coefficients"]]];
Quit[0];
