(* Exact endpoint comparison using only native-proved radical identities. *)
Clear[endpointPhysicalComparison];
endpointPhysicalComparison[value_, assumptions_] := Module[
  {difference, roots, base, relations = {}, rules = {}, ratio, replacement,
   proof, normalized, simplified, seconds},
  {seconds, simplified} = AbsoluteTiming[
    difference = Together[value];
    If[difference === 0, 0,
      roots = DeleteDuplicates[Cases[difference,
        Power[b_, e_Rational] /; !IntegerQ[e] :> Power[b, e], Infinity]];
      If[roots =!= {},
        base = First[MinimalBy[roots, LeafCount]];
        Do[
          ratio = MemoryConstrained[TimeConstrained[
            FullSimplify[atom/base, assumptions], 60, $Aborted], 1024^3, $Aborted];
          If[ratio =!= $Aborted && FreeQ[ratio, Indeterminate | ComplexInfinity | _DirectedInfinity],
            replacement = base ratio;
            proof = MemoryConstrained[TimeConstrained[
              FullSimplify[atom == replacement, assumptions], 60, $Aborted], 1024^3, $Aborted];
            AppendTo[relations, <|"Original" -> atom, "Replacement" -> replacement,
              "Assumptions" -> assumptions, "IdentityProved" -> TrueQ[proof]|>];
            If[TrueQ[proof], AppendTo[rules, atom -> replacement]]],
          {atom, roots}]];
      normalized = difference /. rules;
      simplified = Factor[Together[normalized]];
      If[simplified === 0, 0,
        MemoryConstrained[TimeConstrained[FullSimplify[simplified, assumptions],
          60, $Aborted], 1024^3, $Aborted]]]];
  Print["ENDPOINT_ROOT_RELATIONS ", InputForm[relations]];
  Print["ENDPOINT_COMPARISON_RESULT ", InputForm[{simplified === 0, seconds}]];
  <|"Difference" -> difference, "Relations" -> relations,
    "SimplifiedDifference" -> simplified, "Seconds" -> seconds,
    "Equivalent" -> (simplified === 0)|>];
