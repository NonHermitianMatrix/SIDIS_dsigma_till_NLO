"""Hqq (channel 2), SECOND ATTEMPT: the single source of truth.

Every convention for the rebuilt Hqq chain lives HERE and nowhere else.  Any
script in the new chain imports these definitions rather than restating them.
The old chain's defect was never localized to a stage -- R1->R2, R2->R3 and
R3->R4 were each proven EXACT, and MR2gA passed three independent checks --
yet an LO-FREE test still showed a g/PP asymmetry (STATE 0z.109).  A fault
that is real but attributable to no single stage is a BOOKKEEPING fault, which
is why this file exists and why the rebuild starts from it.

===========================================================================
1. THE PROCESS AND WHAT IS OBSERVED
===========================================================================
    gamma*(q) + q(p)  ->  q(k1) + X ,      the OBSERVED parton is ALWAYS k1
                                            and it is ALWAYS the QUARK.
Table I, row 2 (arXiv:1903.01529 p.17):

    virtual : Hqq;g                        one loop on  gamma* q -> q g
    real    : Hqq;gg                       gamma* q -> q(k1) g g
            + Hqq;q qbar                   gamma* q -> q(k1) q qbar   SAME flavour
            + Hqq;q' qbar'                 gamma* q -> q(k1) q' qbar' OTHER flavours
    combined: Hqq

===========================================================================
2. THE GRAPHS, AND THE FLAVOUR WEIGHT EACH CARRIES
===========================================================================
The paper (p.16): "This pole term is canceled after adding the real processes
Hqq;q(bar q) AND Hqq;q'(bar q') with all massless flavors q' (OTHER THAN q)."

    piece   process            charge structure   flavour weight
    QGG     Hqq;gg             eq^2               1
    SF      Hqq;q qbar         eq^2               1        (same flavour)
    DFA     Hqq;q' qbar'       eq^2               nf - 1   (q' != q)
    DFB     Hqq;q' qbar'       eq*eq'             nf - 1
    DFC     Hqq;q' qbar'       eq'^2              nf - 1

WEIGHT CONVENTION, STATED ONCE:  the (nf - 1) is carried in the HARD FUNCTION
for the eq^2 case (DFA), because its charge factor does not distinguish q'.
For DFB and DFC the flavour sum is NOT a multiplicity -- it is
sum_{q'} eq' and sum_{q'} eq'^2 respectively -- and MUST be left to the
luminosity at convolution time (N1), exactly as BigTMD does.  Writing
(nf - 1) on DFB or DFC would be WRONG.

BigTMD carries (nf - 2) rather than (nf - 1) because its flavour index runs
over quarks AND antiquarks and its mask `qqp` removes both q and qbar per row,
with a compensating /2 in the case-C luminosity.  That is a different
convention for the same physics; we follow the PAPER.  The choice does NOT
affect the nf POLE (d/dnf of both weights is 1) -- only finite parts.
See STATE 0z.102.

===========================================================================
3. IDENTICAL-PARTICLE RULES  (these are where double counting hides)
===========================================================================
(a) SAME-FLAVOUR final state q(k1) q q~ has TWO identical quarks.  The
    amplitude must be ANTISYMMETRIZED between them, and the OBSERVED quark may
    be either one.  This is a physical configuration, NOT a double count.
(b) The paper's prohibition (p.16) is a DIFFERENT operation: "when a quark
    line links an outgoing spectator quark anti-quark pair, there is no need
    for the reversed quark flow ... interchanging the quark and anti-quark
    will double count".  That forbids adding a q <-> qbar REVERSED copy of a
    SPECTATOR pair.  It does NOT forbid (a).
(c) Hqq;gg has two identical GLUONS in the final state; the unobserved pair
    phase space already covers their interchange, so NO extra factor.

===========================================================================
4. CONVENTIONS FIXED ONCE  (the old chain restated these per script)
===========================================================================
  momenta      p incoming quark, q photon, k1 OBSERVED quark, k2/k3 unobserved
  invariants   s  = (p+q)^2 = 2 p.q - Q2      Q2 = -q^2 > 0
               ti = (q-ki)^2 = -Q2 - 2 q.ki   ui = (p-ki)^2 = -2 p.ki
               sij = (ki+kj)^2 = 2 ki.kj
  constraint   s + t1 + u1 = -Q2 + s23        (2->3)
  projections  g  : +MTD[mu,mu2]              (the SAME +g sign as the LO
                                               script that passed check 6)
               PP : FVD[p,mu] FVD[p,mu2]
               gauge check: FVD[q,mu] on the AMPLITUDE -> 0, and
                            q^mu q^mu2 on the SQUARED tensor -> 0
  averaging    1/2 initial spin, 1/Nc initial colour
  gluon pols   physical sum -g^{mu nu} + (k^mu n^nu + n^mu k^nu)/(k.n) whenever
               a triple-gluon vertex is present (required for Hqq;gg)
  dimensions   D -> 4 - 2 eps applied BEFORE export; FreeQ[expr, D] asserted
  symbol names s, t1, t2, t3, u1, u2, u3, s12, s13, s23, Q2, eps, Nc,
               ee, eq, eqp, gs, nf     -- `Nc`, never `SUNN`; `t1`, never `t`
               (the old chain mixed SUNN/Nc and t/t1 across stages, which is
               exactly how a name-keyed symbol dict silently drops one of two
               same-named symbols; see STATE 0z.109)

===========================================================================
5. WHAT THE NEW CHAIN MUST ASSERT AT EVERY HANDOFF
===========================================================================
  * no Float atoms anywhere, ever (no legacy-decimal exception in the new
    chain -- the angular code is now exact, so a Float means a bug);
  * no two free symbols sharing a name;
  * free symbols within the whitelist of section 4;
  * `D` absent, `eps` present;
  * each stage's identity where one exists (R2: R1 - R2 = 0 on the constraint
    surface of section 4).
"""

import sympy as sp

# ---------------------------------------------------------------- symbols
s, t1, t2, t3 = sp.symbols('s t1 t2 t3', real=True)
u1, u2, u3 = sp.symbols('u1 u2 u3', real=True)
s12, s13, s23 = sp.symbols('s12 s13 s23', real=True)
Q2, eps = sp.symbols('Q2 eps', real=True)
Nc, nf, ee, eq, eqp, gs = sp.symbols('Nc nf ee eq eqp gs', real=True)

INVARIANTS = (s, t1, t2, t3, u1, u2, u3, s12, s13, s23, Q2)
WHITELIST = {a.name for a in INVARIANTS} | {'eps', 'Nc', 'nf', 'ee', 'eq',
                                            'eqp', 'gs', 'CF', 'B', 'xh'}

# 2->3 momentum conservation, for the R2 identity check (section 5).
CONSTRAINTS = {t1: u2 + u3 + s23,
               u1: t2 + t3 + s23 + Q2,
               s: s12 + s13 + s23}

# ------------------------------------------------------------- the pieces
# (name, process, charge structure, flavour weight)   -- section 2
PIECES = (
    ('QGG', 'Hqq;gg',        'eq^2',    sp.Integer(1)),
    ('SF',  'Hqq;q qbar',    'eq^2',    sp.Integer(1)),
    ('DFA', 'Hqq;qp qbarp',  'eq^2',    nf - 1),
    ('DFB', 'Hqq;qp qbarp',  'eq*eqp',  sp.Integer(1)),   # flavour sum -> N1
    ('DFC', 'Hqq;qp qbarp',  'eqp^2',   sp.Integer(1)),   # flavour sum -> N1
)


def weight(name):
    for n, _proc, _chg, w in PIECES:
        if n == name:
            return w
    raise KeyError('unknown piece %r; known: %s'
                   % (name, [p[0] for p in PIECES]))


def canon(expr, label='expr'):
    """Canonicalize onto THIS module's symbols, and assert cleanliness.

    Maps by NAME over free_symbols DIRECTLY -- never through a name-keyed
    dict, which silently drops one of two same-named symbols (STATE 0z.109).
    Accepts the legacy aliases `SUNN`->Nc and `t`->t1 so old exports can be
    read once, but the new chain must not produce them.
    """
    alias = {'SUNN': Nc, 't': t1}
    target = {a.name: a for a in INVARIANTS}
    target.update({'eps': eps, 'Nc': Nc, 'nf': nf, 'ee': ee, 'eq': eq,
                   'eqp': eqp, 'gs': gs})
    target.update(alias)

    subs = {a: target[a.name] for a in expr.free_symbols
            if a.name in target and a is not target[a.name]}
    expr = expr.xreplace(subs) if subs else expr

    if expr.atoms(sp.Float):
        raise ValueError('%s: Float atoms %s -- the new chain is exact'
                         % (label, sorted(map(str, expr.atoms(sp.Float)))[:4]))
    names = [a.name for a in expr.free_symbols]
    dupes = sorted({n for n in names if names.count(n) > 1})
    if dupes:
        raise ValueError('%s: free symbols share names %s' % (label, dupes))
    stray = sorted(set(names) - WHITELIST)
    if stray:
        raise ValueError('%s: symbols outside the whitelist: %s'
                         % (label, stray))
    return expr


def check_r2_identity(before, after, label='R2'):
    """Partial fractioning is an identity ON THE CONSTRAINT SURFACE only."""
    d = sp.simplify(sp.cancel(sp.together(
        before.xreplace(CONSTRAINTS) - after.xreplace(CONSTRAINTS))))
    return d == 0, d
