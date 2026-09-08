read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/stein27.fzn"
write problem temp/stein27.fzn.gms
presolve
write transproblem temp/stein27.fzn_trans.gms
read temp/stein27.fzn_trans.gms
optimize
read temp/stein27.fzn.gms
optimize
validatesolve "18" "18"
quit
