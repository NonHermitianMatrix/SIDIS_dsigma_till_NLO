read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/gt2.mps"
write problem temp/gt2.mps.ppm
presolve
write transproblem temp/gt2.mps_trans.ppm
read temp/gt2.mps_trans.ppm
optimize
read temp/gt2.mps.ppm
optimize
validatesolve "21166" "21166"
quit
