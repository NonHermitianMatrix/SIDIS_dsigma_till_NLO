read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/flugpl.mps"
write problem temp/flugpl.mps.ppm
presolve
write transproblem temp/flugpl.mps_trans.ppm
read temp/flugpl.mps_trans.ppm
optimize
read temp/flugpl.mps.ppm
optimize
validatesolve "1201500" "1201500"
quit
