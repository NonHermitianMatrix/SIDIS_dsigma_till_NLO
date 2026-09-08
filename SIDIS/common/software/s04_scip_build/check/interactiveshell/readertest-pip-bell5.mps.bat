read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/bell5.mps"
write problem temp/bell5.mps.pip
presolve
write transproblem temp/bell5.mps_trans.pip
read temp/bell5.mps_trans.pip
optimize
read temp/bell5.mps.pip
optimize
validatesolve "8966406.49" "8966406.49"
quit
