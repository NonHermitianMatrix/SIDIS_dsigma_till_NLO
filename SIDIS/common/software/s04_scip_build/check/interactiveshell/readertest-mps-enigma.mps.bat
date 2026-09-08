read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/enigma.mps"
write problem temp/enigma.mps.mps
presolve
write transproblem temp/enigma.mps_trans.mps
read temp/enigma.mps_trans.mps
optimize
read temp/enigma.mps.mps
optimize
validatesolve "0" "0"
quit
