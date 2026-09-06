(* Where does MISSINGEPS sit in the partial, and at what order in eps?
   If it reaches del or p1, del = s0*Mcoef[0] divides by eps and it MUST
   appear at eps^0 in the final answer.  If it only sits in reg at O(eps),
   dropping it is correct.                                                  *)
dir = "/home/physics/projects/AI_Assisted_SIDIS/scripts/Hgq_v3/";
a = Get[dir <> "s07part_Wg3_1_20.m"];
Do[Module[{c = If[k === "del", a["del"], If[k === "reg", a["reg"], a["p"][[ToExpression[StringTake[k, -1]]]]]], tl, bad},
   tl = If[Head[c] === Plus, List @@ c, {c}];
   bad = Select[tl, ! FreeQ[#, MISSINGEPS] &];
   Print[k, ": ", Length[bad], " term(s) with MISSINGEPS",
     If[bad =!= {}, "   eps exponents: " <> ToString[Union[Flatten[Exponent[#, eps, List] & /@ bad]]], ""]]],
 {k, {"del", "reg", "p1", "p2"}}];
(* and the decisive one: does it survive to eps^0 anywhere? *)
Module[{tot},
  tot = a["del"] + a["reg"] + a["p"][[1]] + a["p"][[2]];
  Print["MISSINGEPS present anywhere in partial? ", ! FreeQ[tot, MISSINGEPS]]];
Print["--- s03: is the O(eps) term of I(1,2) multiplied by a pole downstream? ---"];
Print["  del  contains MISSINGEPS? ", ! FreeQ[a["del"], MISSINGEPS]];
Print["  p1   contains MISSINGEPS? ", ! FreeQ[a["p"][[1]], MISSINGEPS]];
Print["  reg  contains MISSINGEPS? ", ! FreeQ[a["reg"], MISSINGEPS]];
Print["T10DONE"];
