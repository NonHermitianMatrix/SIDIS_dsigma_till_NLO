#!/usr/bin/env python3
"""Convert one BigTMD fchn1A function body into an exact Wolfram expression.
Floats are rationalised (they are all simple fractions) so the comparison in
s07 can be an exact rational-function identity rather than a numerical one."""
import re, sys
from fractions import Fraction

src = open(__file__.replace("to_wl.py", "fchn1A.py")).read()
name = sys.argv[1] if len(sys.argv) > 1 else "plus2B"
m = re.search(r'def ' + name + r'\([^)]*\):\n    return (.*?)\n(?=@jit|\Z)', src, re.S)
b = m.group(1)

def rat(mo):
    f = Fraction(mo.group(0)).limit_denominator(10**7)
    return f"({f.numerator}/{f.denominator})"

b = re.sub(r'\d+\.\d+(?:[eE][-+]?\d+)?', rat, b)      # floats -> exact rationals
b = b.replace("np.pi", "Pi").replace("np.log", "Log").replace("np.sqrt", "Sqrt")
b = b.replace("EulerGamma", "EulerGamma").replace("PolyLOG", "PolyLog")
b = b.replace("**", "^")
b = re.sub(r'\s+', ' ', b)
print(b)
