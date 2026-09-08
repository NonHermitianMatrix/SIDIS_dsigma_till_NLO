read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/egout.mps"
write problem temp/egout.mps.mps
presolve
write transproblem temp/egout.mps_trans.mps
read temp/egout.mps_trans.mps
optimize
read temp/egout.mps.mps
optimize
validatesolve "568.1007" "568.1007"
quit
