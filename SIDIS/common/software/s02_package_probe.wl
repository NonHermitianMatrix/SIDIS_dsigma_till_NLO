$HistoryLength = 0;
root = DirectoryName[$InputFileName];
fail[message_] := (Print["FAIL: ", message]; Quit[1]);
If[$VersionNumber < 13.1, fail["Wolfram version is below the package minimum"]];
Get[FileNameJoin[{root, "SubTropica-1.2.10", "Kernel", "init.m"}]];
If[ToString[SubTropica`$SubTropicaVersion] =!= "1.2.10",
  fail["unexpected SubTropica version"]];
SubTropica`$PolymakeCommand = FileNameJoin[{root, "s01_polymake"}];
SubTropica`STCheckDependencies[];
If[Lookup[SubTropica`$STDependencies["polymake"], "status", ""] =!= "ok",
  fail["configured polymake dependency did not pass"]];
SetOptions[HyperIntica`HyperInt, "EvaluatePeriodsQ" -> True];
If[!TrueQ["EvaluatePeriodsQ" /. Options[HyperIntica`HyperInt]],
  fail["scalar period evaluation is not configured"]];
Put[<|"WolframVersion" -> $Version, "SubTropicaVersion" -> SubTropica`$SubTropicaVersion,
  "Polymake" -> SubTropica`$STDependencies["polymake"],
  "PackageRoot" -> SubTropica`$SubTropicaInstallDir, "Accepted" -> True|>,
  FileNameJoin[{root, "s02_result.wl"}]];
Print["S02_SUCCESS: SubTropica and its selected polymake runtime loaded."];
Quit[0];
