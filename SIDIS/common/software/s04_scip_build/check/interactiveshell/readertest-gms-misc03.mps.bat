read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/misc03.mps"
write problem temp/misc03.mps.gms
presolve
write transproblem temp/misc03.mps_trans.gms
read temp/misc03.mps_trans.gms
optimize
read temp/misc03.mps.gms
optimize
validatesolve "3360" "3360"
quit
