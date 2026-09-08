read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/gt2.mps"
write problem temp/gt2.mps.gms
presolve
write transproblem temp/gt2.mps_trans.gms
read temp/gt2.mps_trans.gms
optimize
read temp/gt2.mps.gms
optimize
validatesolve "21166" "21166"
quit
