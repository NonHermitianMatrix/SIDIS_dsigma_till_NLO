(* Compute the missing O(eps) term of
   I(1,2) = Int_0^pi db1 Int_0^pi db2 sin^(1-2eps)b1 sin^(-2eps)b2
            / [ (D - cos b1) (1 - C cos b1 - S sin b1 cos b2)^2 ],  S=Sqrt[1-C^2]
   Step 1: do the b2 integral exactly in eps.
   Step 2: check it against the table's known 1/eps and eps^0 parts before
           trying to get the eps^1 term.                                     *)
$Assumptions = {0 < cc < 1, dd > 1, -1 < x < 1, eps < 0};
S = Sqrt[1 - cc^2];
A = 1 - cc x; B = S Sqrt[1 - x^2];
Print["A^2-B^2 simplifies to (x-C)^2 ? ", Simplify[A^2 - B^2 - (x - cc)^2] === 0];
J = Integrate[Sin[b2]^(-2 eps)/(A - B Cos[b2])^2, {b2, 0, Pi},
     Assumptions -> {0 < cc < 1, -1 < x < 1, eps < 0, A > B > 0}];
Print["b2 integral J = ", InputForm[Short[Simplify[J], 12]]];
Print["J free of b2? ", FreeQ[J, b2]];
(* the full integral, measure (1-x^2)^(-eps) dx /(D-x) *)
Print["--- integrand ready; leading eps behaviour of J near x -> cc ---"];
Print["  J series at x -> cc: ", InputForm[Short[Series[J, {x, cc, 0}] // Normal // Simplify, 10]]];
Print["T09DONE"];
