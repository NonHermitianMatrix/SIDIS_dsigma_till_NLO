read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/lseu.mps"
write problem temp/lseu.mps.gms
presolve
write transproblem temp/lseu.mps_trans.gms
read temp/lseu.mps_trans.gms
optimize
read temp/lseu.mps.gms
optimize
validatesolve "1120" "1120"
quit
