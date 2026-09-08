read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/rgn.mps"
write problem temp/rgn.mps.cip
presolve
write transproblem temp/rgn.mps_trans.cip
read temp/rgn.mps_trans.cip
optimize
read temp/rgn.mps.cip
optimize
validatesolve "82.1999974" "82.1999974"
quit
