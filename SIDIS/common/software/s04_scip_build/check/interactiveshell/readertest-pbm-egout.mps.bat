read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/egout.mps"
write problem temp/egout.mps.pbm
presolve
write transproblem temp/egout.mps_trans.pbm
read temp/egout.mps_trans.pbm
optimize
read temp/egout.mps.pbm
optimize
validatesolve "568.1007" "568.1007"
quit
