read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/stein27_inf.lp"
write problem temp/stein27_inf.lp.pbm
presolve
write transproblem temp/stein27_inf.lp_trans.pbm
read temp/stein27_inf.lp_trans.pbm
optimize
read temp/stein27_inf.lp.pbm
optimize
validatesolve "+infinity" "+infinity"
quit
