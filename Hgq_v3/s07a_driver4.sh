#!/bin/bash
# Real-part extraction, remaining terms, both projectors, 3 at a time.
#
# RAM (10 GB free), not the 22 cores, sets the width: each kernel peaks ~2.5 GB.
# timeout uses -s KILL because the Wolfram kernel ignores SIGTERM - a batch that
# blew its 2400 s limit under plain `timeout` kept running and wedged the serial
# driver.  Batches are 10 terms so one pathological term costs less, and
# s07a_jobs.py emits only ranges no partial covers yet => resumable, no redo.
cd /home/physics/projects/AI_Assisted_SIDIS/scripts/Hgq_v3
export K=/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel
PAR=3

one () {                 # $1=proj $2=i0 $3=i1
  OUT="s07part_$1_$2_$3.m"
  if [ -f "$OUT" ]; then echo "skip $OUT"; return 0; fi
  HGQ_PROJ=$1 HGQ_I0=$2 HGQ_I1=$3 timeout -s KILL 1800 \
    $K -noprompt -script s07a_realpart.wls 2>&1 | grep -a "\[s07a\]"
  [ -f "$OUT" ]
}
export -f one

job () {                 # $1="proj i0 i1"
  read -r P A B <<< "$1"
  echo "=== $P $A-$B"
  if ! one "$P" "$A" "$B"; then
    echo "--- batch $P $A-$B failed, retrying term by term"
    for ((J=A; J<=B; J++)); do one "$P" "$J" "$J" || echo "!!! TERM $P $J FAILED"; done
  fi
}
export -f job

python3 s07a_jobs.py | xargs -P $PAR -I{} bash -c 'job "{}"'
echo "ALL BATCHES DONE"
ls s07part_*.m | wc -l
