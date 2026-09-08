
find_program(GIT git)
if(EXISTS ${DST})
   file(STRINGS ${DST} GITHASH_OLD)
   string(REGEX REPLACE "#define SCIP_GITHASH \"(.*)\"" "\\1" GITHASH_OLD ${GITHASH_OLD})
endif()
if((GIT) AND (EXISTS /u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c/.git))
   execute_process(
      COMMAND ${GIT} describe --always --dirty
      WORKING_DIRECTORY /u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/software/scip-source/scip-e639a0059d28e97a67f62f7764f49626d4054e9c
      OUTPUT_VARIABLE GITHASH OUTPUT_STRIP_TRAILING_WHITESPACE)
   string(REGEX REPLACE "^.*-g" "" GITHASH ${GITHASH})
   if(NOT ${GITHASH} STREQUAL "${GITHASH_OLD}")
      file(WRITE ${DST} "#define SCIP_GITHASH \"${GITHASH}\"
")
   endif()
else()
   set(GITHASH ${GITHASH_OLD})
endif()
message(STATUS "Git hash: " ${GITHASH})
