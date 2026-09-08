read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/vpm2.fzn"
write problem temp/vpm2.fzn.ppm
presolve
write transproblem temp/vpm2.fzn_trans.ppm
read temp/vpm2.fzn_trans.ppm
optimize
read temp/vpm2.fzn.ppm
optimize
validatesolve "13.75" "13.75"
quit
