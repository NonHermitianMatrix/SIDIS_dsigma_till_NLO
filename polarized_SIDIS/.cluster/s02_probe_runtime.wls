(* Read-only compute-node probe of the native script and user-base interface. *)
$HistoryLength = 0;
If[!StringQ[Environment["JOB_ID"]] || StringStartsQ[$MachineName, "login"], Quit[1]];
result = <|"WolframVersion" -> $Version, "MachineName" -> $MachineName,
  "InputFileName" -> $InputFileName, "ScriptCommandLine" -> $ScriptCommandLine,
  "UserBaseDirectory" -> $UserBaseDirectory,
  "MathematicaUserBaseEnvironment" -> Environment["MATHEMATICA_USERBASE"],
  "WolframUserBaseEnvironment" -> Environment["WOLFRAM_USERBASE"],
  "WorkingDirectory" -> Directory[], "JobID" -> Environment["JOB_ID"]|>;
Print[InputForm[result]];
target = FileNameJoin[{Directory[], ".cluster", "s02_result", "s02_runtime.wl"}];
If[!DirectoryQ[DirectoryName[target]], CreateDirectory[DirectoryName[target], CreateIntermediateDirectories -> True]];
Put[result, target];
Print["PASS: s02_probe_runtime"];
Quit[0];
