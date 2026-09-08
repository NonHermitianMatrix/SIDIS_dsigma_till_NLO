read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/egout.mps"
write problem temp/egout.mps.rlp
presolve
write transproblem temp/egout.mps_trans.rlp
read temp/egout.mps_trans.rlp
optimize
read temp/egout.mps.rlp
optimize
validatesolve "568.1007" "568.1007"
quit
