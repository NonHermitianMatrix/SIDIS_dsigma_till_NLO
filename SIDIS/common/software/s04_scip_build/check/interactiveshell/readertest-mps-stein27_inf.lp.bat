read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/stein27_inf.lp"
write problem temp/stein27_inf.lp.mps
presolve
write transproblem temp/stein27_inf.lp_trans.mps
read temp/stein27_inf.lp_trans.mps
optimize
read temp/stein27_inf.lp.mps
optimize
validatesolve "+infinity" "+infinity"
quit
