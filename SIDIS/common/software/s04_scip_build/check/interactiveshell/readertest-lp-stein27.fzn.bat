read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/stein27.fzn"
write problem temp/stein27.fzn.lp
presolve
write transproblem temp/stein27.fzn_trans.lp
read temp/stein27.fzn_trans.lp
optimize
read temp/stein27.fzn.lp
optimize
validatesolve "18" "18"
quit
