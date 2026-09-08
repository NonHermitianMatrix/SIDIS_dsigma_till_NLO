read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/p0033.osil"
write problem temp/p0033.osil.gms
presolve
write transproblem temp/p0033.osil_trans.gms
read temp/p0033.osil_trans.gms
optimize
read temp/p0033.osil.gms
optimize
validatesolve "3089" "3089"
quit
