read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/MANN_a9.clq.lp"
write problem temp/MANN_a9.clq.lp.mps
presolve
write transproblem temp/MANN_a9.clq.lp_trans.mps
read temp/MANN_a9.clq.lp_trans.mps
optimize
read temp/MANN_a9.clq.lp.mps
optimize
validatesolve "16" "16"
quit
