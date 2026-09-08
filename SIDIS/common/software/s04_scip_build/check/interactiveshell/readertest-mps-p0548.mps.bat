read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/p0548.mps"
write problem temp/p0548.mps.mps
presolve
write transproblem temp/p0548.mps_trans.mps
read temp/p0548.mps_trans.mps
optimize
read temp/p0548.mps.mps
optimize
validatesolve "8691" "8691"
quit
