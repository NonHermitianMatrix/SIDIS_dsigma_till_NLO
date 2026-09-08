read "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c"/check/"instances/MIP/enigma.mps"
write problem temp/enigma.mps.pbm
presolve
write transproblem temp/enigma.mps_trans.pbm
read temp/enigma.mps_trans.pbm
optimize
read temp/enigma.mps.pbm
optimize
validatesolve "0" "0"
quit
