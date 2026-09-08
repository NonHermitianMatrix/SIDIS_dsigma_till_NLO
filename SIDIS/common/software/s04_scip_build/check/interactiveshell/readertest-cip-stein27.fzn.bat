read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/stein27.fzn"
write problem temp/stein27.fzn.cip
presolve
write transproblem temp/stein27.fzn_trans.cip
read temp/stein27.fzn_trans.cip
optimize
read temp/stein27.fzn.cip
optimize
validatesolve "18" "18"
quit
