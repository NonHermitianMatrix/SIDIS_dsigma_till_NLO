read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/blend2.mps"
write problem temp/blend2.mps.rlp
presolve
write transproblem temp/blend2.mps_trans.rlp
read temp/blend2.mps_trans.rlp
optimize
read temp/blend2.mps.rlp
optimize
validatesolve "7.598985" "7.598985"
quit
