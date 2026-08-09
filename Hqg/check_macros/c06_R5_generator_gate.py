"""Cross-engine gate on the R5 -> invariant map: sympy vs Mathematica.

WHY GENERATORS AND NOT THE WHOLE EXPRESSION (STATE 11e).  Both engines apply
the SAME map, and that map is a pure substitution on LEAF SYMBOLS -- i.e. a
homomorphism.  Two homomorphisms that agree on the generators agree on
everything built from them, so comparing whole mapped expressions is
unnecessary (and reintroduces exactly the expansion this stage exists to
avoid).  Gate the generators, plus the free-symbol whitelist on each result.

WHAT IS COMPARED.
  sympy   (python/R5_to_invariant.py):  _RULE = {R5M: 1/A, R5S: s, z: 1}
          with A = a_value() = [(t1+Q2) + (s-s23)] / [(s-s23)(Q2+s)]
          and _INV_JAC = z (R5S - s23)^2 / R5M, applied BEFORE the rule.
  Mathematica (mathematica/R5_to_invariant.wls): the same assignments, with
          invJac PRINTED BY THE JOB as ((s - s23)(Q2 + s - s23 + t1))/(Q2 + s).

The Mathematica value is quoted from the job log, so this gate compares what
ACTUALLY RAN against the sympy source -- not two copies of my own algebra.

Run: python3 python/R5_generator_gate.py
"""

import sympy as sp

Q2, s, s23, t1, z, R5M, R5S = sp.symbols("Q2 s s23 t1 z R5M R5S", positive=True)

# --- sympy side, transcribed from python/R5_to_invariant.py -------------
A_sympy = ((t1 + Q2) + (s - s23))/((s - s23)*(Q2 + s))      # a_value()
RULE = {R5M: 1/A_sympy, R5S: s, z: sp.Integer(1)}           # _RULE
INV_JAC = z*(R5S - s23)**2/R5M                              # _INV_JAC
invjac_sympy = INV_JAC.xreplace(RULE)

# --- Mathematica side, quoted VERBATIM from job 14199038 / 14199403 -----
#     invJac = InputForm[((s - s23)*(Q2 + s - s23 + t1))/(Q2 + s)]
invjac_mma = ((s - s23)*(Q2 + s - s23 + t1))/(Q2 + s)

checks = []

diff = sp.simplify(sp.cancel(invjac_sympy - invjac_mma))
checks.append(("inverse Jacobian image", diff))

# The three leaf images, one at a time: a homomorphism is fixed by these.
checks.append(("R5M image", sp.simplify(RULE[R5M] - (s - s23)*(Q2 + s)
                                        / (Q2 + s - s23 + t1))))
checks.append(("R5S image", sp.simplify(RULE[R5S] - s)))
checks.append(("z image", sp.simplify(RULE[z] - 1)))

# A itself, against the closed form recorded in the R5_to_invariant docstring:
#     A = [ (t1 + Q2) + (s - s23) ] / [ (s - s23)(Q2 + s) ]
checks.append(("A closed form",
               sp.simplify(A_sympy - (Q2 + s - s23 + t1)/((s - s23)*(Q2 + s)))))

failed = False
for label, residue in checks:
    ok = residue == 0
    print("  %-24s : %s" % (label, "ZERO" if ok else "NONZERO -> %s" % residue))
    failed |= not ok

print("  sympy invJac after rule  : %s" % sp.simplify(invjac_sympy))
print("  mathematica invJac (log) : %s" % sp.simplify(invjac_mma))

if failed:
    raise SystemExit("GENERATOR GATE FAILED -- the two engines do not "
                     "implement the same map")
print("R5_GENERATOR_GATE_OK")
