read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/flugpl.mps"
write problem temp/flugpl.mps.mps
presolve
write transproblem temp/flugpl.mps_trans.mps
read temp/flugpl.mps_trans.mps
optimize
read temp/flugpl.mps.mps
optimize
validatesolve "1201500" "1201500"
quit
