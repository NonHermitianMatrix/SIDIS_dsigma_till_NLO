read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/enigma.mps"
write problem temp/enigma.mps.ccg
presolve
write transproblem temp/enigma.mps_trans.ccg
read temp/enigma.mps_trans.ccg
optimize
read temp/enigma.mps.ccg
optimize
validatesolve "0" "0"
quit
