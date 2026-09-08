read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/vpm2.fzn"
write problem temp/vpm2.fzn.pbm
presolve
write transproblem temp/vpm2.fzn_trans.pbm
read temp/vpm2.fzn_trans.pbm
optimize
read temp/vpm2.fzn.pbm
optimize
validatesolve "13.75" "13.75"
quit
