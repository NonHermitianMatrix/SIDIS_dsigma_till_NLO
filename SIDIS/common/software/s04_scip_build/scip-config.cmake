if(NOT TARGET libscip)
  include("${CMAKE_CURRENT_LIST_DIR}/scip-targets.cmake")
endif()

if(0)
   set(ZIMPL_DIR "")
   find_package(ZIMPL QUIET CONFIG)
endif()

if(0)
   set(SOPLEX_DIR "")
   find_package(SOPLEX QUIET CONFIG)
endif()

set(SCIP_LIBRARIES libscip)
set(SCIP_INCLUDE_DIRS "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c/src;/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/s04_scip_build")
set(SCIP_FOUND TRUE)
