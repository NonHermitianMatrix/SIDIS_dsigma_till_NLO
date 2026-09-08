read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/p0033.osil"
write problem temp/p0033.osil.ppm
presolve
write transproblem temp/p0033.osil_trans.ppm
read temp/p0033.osil_trans.ppm
optimize
read temp/p0033.osil.ppm
optimize
validatesolve "3089" "3089"
quit
