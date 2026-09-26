(* Compare actual saved endpoint coefficients using proved small root identities. *)
$HistoryLength = 0;
If[!StringQ[Environment["JOB_ID"]], Quit[1]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
r = Directory[];
p = FileNameJoin[{r, "common", "s12_compare_endpoint_roots.wls"}];
helper = FileNameJoin[{r, "common", "s12_endpoint_equivalence.wl"}];
If[!TrueQ[And @@ (SyntaxQ[Import[#, "Text"]] & /@ {p, helper})], Quit[1]];
Get[helper];
oldFiles = FileNames["component_0025.wl", FileNameJoin[{r, "cache", "s12", "Hqq"}], Infinity];
newFiles = FileNames["component_0025.wl", FileNameJoin[{r, "cache", "s12_transverse_endpoint", "Hqq"}], Infinity];
If[Length[oldFiles] =!= 1 || Length[newFiles] =!= 1, Print["FAIL: unique saved own comparison"]; Quit[1]];
old = Get[First[oldFiles]]; new = Get[First[newFiles]];
If[old["InputHash"] =!= new["InputHash"] ||
   KeyTake[old, {"Sector", "Kind", "Index"}] =!= KeyTake[new, {"Sector", "Kind", "Index"}],
  Print["FAIL: own comparison provenance"]; Quit[1]];
rows = Association@Table[
  assumptions = old["Branches"][sign]["Assumptions"];
  If[assumptions =!= new["Branches"][sign]["Assumptions"], Print["FAIL: branch assumptions"]; Quit[1]];
  values = Association@Table[
    Print["COMPARE_SAVED_DISTRIBUTION ", InputForm[{sign, key}]];
    key -> endpointPhysicalComparison[new["Branches"][sign][key] - old["Branches"][sign][key], assumptions],
    {key, {"Delta", "L0", "L1", "Regular"}}];
  oldSoft = old["Branches"][sign]["SoftCoefficients"];
  newSoft = new["Branches"][sign]["SoftCoefficients"];
  If[(Take[#, 2] & /@ oldSoft) =!= (Take[#, 2] & /@ newSoft), Print["FAIL: soft support"]; Quit[1]];
  soft = MapThread[endpointPhysicalComparison[Last[#1] - Last[#2], assumptions] &, {newSoft, oldSoft}];
  sign -> <|"Assumptions" -> assumptions, "Distributions" -> values, "Soft" -> soft|>,
  {sign, {1, -1}}];
comparisons = Flatten[Join[Values[#["Distributions"]], #["Soft"]] & /@ Values[rows]];
result = <|"SourceHash" -> FileHash[p, "SHA256"], "HelperHash" -> FileHash[helper, "SHA256"],
  "OriginalHash" -> FileHash[First[oldFiles], "SHA256"], "CandidateHash" -> FileHash[First[newFiles], "SHA256"],
  "InputHash" -> old["InputHash"], "Rows" -> rows,
  "AllPhysicalDifferencesZero" -> AllTrue[comparisons, TrueQ[#["Equivalent"]] &]|>;
dir = FileNameJoin[{r, "Hqq", "s12_endpoint_root_comparison_result"}];
If[!DirectoryQ[dir], CreateDirectory[dir, CreateIntermediateDirectories -> True]];
file = FileNameJoin[{dir, "s12_result.wl"}]; Put[result, file];
If[Get[file] =!= result, Print["FAIL: root comparison reload"]; Quit[1]];
If[!TrueQ[result["AllPhysicalDifferencesZero"]], Print["FAIL: endpoint root comparison"]; Quit[1]];
Print["PASS: exact endpoint root comparison"]; Quit[0];
