# Emit "PROJ I0 I1" for every term range not already covered by a partial.
# Partial filenames carry their range, so finished work is never redone and
# batches of different widths mix safely.
import glob, os, re, sys
# Term counts differ per projector: s07a reports "of N" and caps i1 at N.
# Hardcoding 187 for both made Wpp3 emit a phantom 183-187 job that can never
# produce a partial.  Taken from s04_result via s07a's own term split.
NTERMS = {"Wg3": 187, "Wpp3": 182}
STEP = 20
for proj in ("Wg3", "Wpp3"):
    N = NTERMS[proj]
    done = set()
    for f in glob.glob("s07part_%s_*_*.m" % proj):
        a, b = re.search(r"_(\d+)_(\d+)\.m$", os.path.basename(f)).groups()
        done |= set(range(int(a), int(b) + 1))
    todo = [i for i in range(1, N + 1) if i not in done]
    runs = []
    for i in todo:
        if runs and i == runs[-1][1] + 1 and runs[-1][1] - runs[-1][0] + 1 < STEP:
            runs[-1][1] = i
        else:
            runs.append([i, i])
    for a, b in runs:
        print("%s %d %d" % (proj, a, b))
