(* S16: correction of the V07 branch of PolyLog[2,(Q^2+s)/Q^2] in the accepted S13-S15 records.
   The upstream S19 continuation took the principal value x-i0 for an argument x=(Q^2+s)/Q^2>1 that the
   Feynman prescription places at x+i0 (verified against AMFlow and the analytic one-mass box).  S13 was
   re-run with the corrected masters.  This stage
     1. proves that the re-run S13 equals the previous S13 with Li2(x) -> Li2(x)+2 Pi I Log[x],
     2. applies the same exact replacement to the accepted S14 and S15 records (linear in the S13 virtual
        tensor; the function enters only at order eps^0 and only through V07),
     3. checks that only absorptive (T-odd) responses change and that every other entry is unchanged,
     4. writes the corrected records and a receipt with input and output hashes. *)
$HistoryLength = 0;
root = Directory[];
channel = Environment["POLARIZED_SIDIS_CHANNEL"];
checks = <||>;
s16Gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; Quit[1]];
s16Gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
s16Gate["virtual channel", MemberQ[{"Hqq", "Hqg", "Hgq"}, channel]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
x0 = (Q^2 + s)/Q^2;
isX[a_] := TrueQ[Simplify[a - x0 /. Q2 -> Q^2] === 0];
rule = {PolyLog[2, a_] /; isX[a] :> PolyLog[2, a] + 2 Pi I Log[a]};
tidy = {Re[Log[a_]] /; isX[a] :> Log[a], Im[Log[a_]] /; isX[a] :> 0};
correct[e_] := (e /. rule) //. tidy;
points = {{Q -> 10, Q2 -> 100, s -> 300, t -> -150, omega -> 150},
          {Q -> Sqrt[7], Q2 -> 7, s -> 40, t -> -5, omega -> 35},
          {Q -> Sqrt[50], Q2 -> 50, s -> 20, t -> -60, omega -> 40}};
fixed = {mu -> 10, mu2 -> 100, SUNN -> 3, Nf -> 5, alphaS -> 1, eq -> 2/3, eq2 -> 4/9, B -> 50, s23 -> 7,
  otherChargeMoment[1] -> -1/3, otherChargeMoment[2] -> 7/9, chargeSum -> 11/9, sumChargeSquared -> 11/9};
num[e_, pt_] := N[e /. pt /. fixed, 40];
maxdev[a_, b_] := If[a === b, 0, maxdevN[a, b]];
maxdevN[a_, b_] := Max[Table[Max[Flatten[{Abs[num[a, pt] - num[b, pt]]}]], {pt, points}]];
(* 1. exact change of the S13 virtual tensor.  S13 forms, for every component key,
      pre = sum_master Series[measure * coefficient(D->4-2eps) * master, {eps,0,0}] /. TransverseSubstitution,
      value = Hermitian part of pre (ComplexExpand[pre + Conjugate[pre]]) + UV and counterterm pieces.
   Only V07 changes; its change is a finite O(eps^0) term.  The change of every component computed from the
   repository reduction coefficients must equal correct[old] - old for the accepted S13 output. *)
(* Optional two-kernel execution for records that do not fit in one 8 GB kernel together with step 1:
   S16_PHASE=check runs step 1 and records it; S16_PHASE=apply requires that record with unchanged input hashes. *)
phase = Replace[Environment["S16_PHASE"], $Failed -> "all"];
s16Gate["known phase", MemberQ[{"all", "check", "apply"}, phase]];
step1Inputs = {FileNameJoin[{channel, "s13_result", "s13_result.wl"}],
  If[channel === "Hqg", "Hqg/s09_reduction_result/s09_result.wl", channel <> "/s09_reduction_result/s09_result.wl"],
  FileNameJoin[{channel, "s07_result", "s07_result.wl"}],
  "common/s13_result/reference/s19_masters.wl", "common/s13_result/reference/s19_masters_before_V07_branch_fix.wl"};
step1Hashes := Association[# -> FileHash[FileNameJoin[{root, #}], "SHA256", "HexString"] & /@ step1Inputs];
step1File = FileNameJoin[{root, channel, "s16_branch_correction_result", "s16_step1.wl"}];
If[phase === "apply",
  step1 = Get[step1File];
  s16Gate["step 1 recorded with the same inputs and source", AssociationQ[step1] && step1["Accepted"] === True &&
    step1["InputHashes"] === step1Hashes && step1["SourceHash"] === FileHash[$InputFileName, "SHA256", "HexString"]];
  checks = Join[checks, step1["Checks"]],
s13 = Get[FileNameJoin[{root, channel, "s13_result", "s13_result.wl"}]];
mapRel = If[channel === "Hqg", "Hqg/s09_reduction_result/s09_result.wl", channel <> "/s09_reduction_result/s09_result.wl"];
mapped = Get[FileNameJoin[{root, mapRel}]];
spin = Get[FileNameJoin[{root, channel, "s07_result", "s07_result.wl"}]];
s16Gate["S13 used this reduction map", s13["InputHashes"][mapRel] === FileHash[FileNameJoin[{root, mapRel}], "SHA256"]];
newM = Get[FileNameJoin[{root, "common", "s13_result", "reference", "s19_masters.wl"}]]["Masters"];
oldM = Get[FileNameJoin[{root, "common", "s13_result", "reference", "s19_masters_before_V07_branch_fix.wl"}]]["Masters"];
changedMasters = Select[Keys[newM], (Normal[newM[#]] - Normal[oldM[#]] // Simplify) =!= 0 &];
Print["masters that differ: ", changedMasters];
s16Gate["only V07 differs", Length[changedMasters] === 1 && First[First[changedMasters]] === "V07"];
v07 = First[changedMasters];
dMaster = Normal[newM[v07] - oldM[v07]] /. Q2 -> Q^2;
s16Gate["V07 change is the branch term", Simplify[dMaster - (-2 I Pi^2/(s (Q^2 + s + t))) 2 Pi I Log[(Q^2 + s)/Q^2]] === 0];
devs = {}; changed = 0;
Do[
  old = s13["Components"][key]["RenormalizedVirtual"];
  coef = If[KeyExistsQ[mapped["Components"], key], Lookup[mapped["Components"][key], v07, 0], 0];
  dpre = If[coef === 0, 0, Normal[Series[(mapped["Measure"] /. Epsilon -> eps) (coef /. D -> 4 - 2 eps) dMaster, {eps, 0, 0}]] /. spin["TransverseSubstitution"]];
  dherm = If[dpre === 0, 0, ComplexExpand[dpre + Conjugate[dpre], TargetFunctions -> {Re, Im}]];
  drule = correct[old] - old;
  If[dherm =!= 0 || drule =!= 0, changed++;
    AppendTo[devs, Max[Table[Abs[num[Coefficient[Expand[dherm - drule], eps, k], pt]], {pt, points}, {k, -2, 0}]] /
      Max[10^-60, Max[Table[Abs[num[Coefficient[Expand[old], eps, k], pt]], {pt, points}, {k, -2, 0}]]]]],
  {key, Keys[s13["Components"]]}];
Print["S13 components affected: ", changed, " of ", Length[s13["Components"]], "; max relative |direct - rule| = ", N[Max[Append[devs, 0]], 5]];
s16Gate["rule reproduces the exact V07 change of every S13 component", Max[Append[devs, 0]] < 10^-25];
AssociateTo[checks, "S13 components changed" -> changed];
If[phase === "check",
  If[!DirectoryQ[DirectoryName[step1File]], CreateDirectory[DirectoryName[step1File], CreateIntermediateDirectories -> True]];
  Put[<|"Channel" -> channel, "Checks" -> checks, "InputHashes" -> step1Hashes,
    "SourceHash" -> FileHash[$InputFileName, "SHA256", "HexString"], "JobID" -> Environment["JOB_ID"], "Accepted" -> True|>, step1File];
  Print["PASS: step 1 recorded in ", step1File]; Quit[0]]];
(* release the S13 inputs before loading the S14/S15 records *)
Clear[s13, mapped, spin, newM, oldM, old, coef, dpre, dherm, drule]; ClearSystemCache[]; Share[];
(* 2-3. correct S14 and S15 records *)
s16Put[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
files = Select[{FileNameJoin[{channel, "s14_result", "s14_result.wl"}], FileNameJoin[{channel, "s15_result", "s15_result.wl"}],
  FileNameJoin[{channel, "s15_result", "s15_F1_hat.wl"}], FileNameJoin[{channel, "s15_result", "s15_F2_hat.wl"}]},
  FileExistsQ[FileNameJoin[{root, #}]] &];
inputHashes = Association[# -> FileHash[FileNameJoin[{root, #}], "SHA256", "HexString"] & /@ files];
outDir = FileNameJoin[{root, channel, "s16_branch_correction_result"}];
If[!DirectoryQ[outDir], CreateDirectory[outDir, CreateIntermediateDirectories -> True]];
summary = <||>;
(* the input is copied byte for byte; a compressed input is written back compressed *)
putCompressed[value_, path_] := Module[{st = OpenWrite[path <> ".tmp"]},
  WriteString[st, "Uncompress[", ToString[Compress[value], InputForm], "]
"]; Close[st];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]];
Do[
  src = FileNameJoin[{root, f}];
  compressed = StringJoin[ReadList[src, Character, 11]] === "Uncompress[";
  CopyFile[src, FileNameJoin[{outDir, StringReplace[f, "/" -> "__"] <> ".before"}], OverwriteTarget -> True];
  Print["   memory before loading ", f, ": ", N[MemoryInUse[]/10^9, 3], " GB"];
  data = Get[src];
  Print["   memory after loading: ", N[MemoryInUse[]/10^9, 3], " GB"];
  (* the rule is applied in place to each innermost entry (element of a List or Association) that contains the
     function; ReplaceAll and the tidy rules act inside such an entry, so this equals correct[data] *)
  (* the condition is tested once per distinct argument; the search then uses the literal forms *)
  xs = Select[DeleteDuplicates[Cases[data, PolyLog[2, a_] :> a, Infinity]], isX];
  occ = Position[data, PolyLog[2, Alternatives @@ xs]];
  occurrences = Length[occ];
  entries = DeleteDuplicates[Function[s16pos, Module[{s16q = s16pos},
      While[Length[s16q] > 0 && !MatchQ[Head[data[[Sequence @@ Most[s16q]]]], List | Association], s16q = Most[s16q]];
      s16q]] /@ occ];
  Do[data[[Sequence @@ s16e]] = correct[data[[Sequence @@ s16e]]], {s16e, entries}];
  Print["   corrected entries: ", Length[entries], "; memory ", N[MemoryInUse[]/10^9, 3], " GB"];
  corrected = data; Clear[data, occ, entries]; Share[];
  AssociateTo[summary, f -> <|"Occurrences" -> occurrences|>];
  Print[f, ": occurrences of Li2((Q^2+s)/Q^2) = ", occurrences, "; compressed: ", compressed];
  If[compressed, putCompressed[corrected, src], s16Put[corrected, src]];
  Clear[corrected]; ClearSystemCache[],
  {f, files}];
(* T-even / T-odd pattern of the final response *)
s15old = Get[FileNameJoin[{outDir, StringReplace[FileNameJoin[{channel, "s15_result", "s15_result.wl"}], "/" -> "__"] <> ".before"}]];
s15new = Get[FileNameJoin[{root, channel, "s15_result", "s15_result.wl"}]];
labels = s15new["PhotonLabels"];
pattern = Association@Table[labels[[c]] -> Association@Table[sign -> Association@Table[d ->
      Position[Map[# > 10^-25 &, Table[maxdev[s15old["NLOResponse"][sign][d][[c, j, i]], s15new["NLOResponse"][sign][d][[c, j, i]]], {j, 4}, {i, 4}], {2}], True],
      {d, {"Delta", "L0", "L1", "Regular"}}], {sign, {1, -1}}], {c, Length[labels]}];
Print["changed entries per photon component, branch and distribution: ", pattern];
quarkEven = If[channel === "Hgq", {}, {"LL", "XX", "YY", "ReLX"}];
s16Gate["T-even photon components of the quark channels unchanged",
  AllTrue[quarkEven, Function[c, AllTrue[Flatten[Values /@ Values[pattern[c]]], # === {} &]]]];
s16Gate["only Delta changes (virtual origin)", AllTrue[Values[pattern], Function[p,
  AllTrue[{1, -1}, Function[sg, AllTrue[{"L0", "L1", "Regular"}, p[sg][#] === {} &]]]]]];
If[channel =!= "Hgq",
  s16Gate["quark-channel F1, F2 unchanged", AllTrue[{"F1", "F2"}, Function[F,
    maxdev[s15old["Fhats"][F]["NLO"][1]["Delta"], s15new["Fhats"][F]["NLO"][1]["Delta"]] < 10^-30 &&
    maxdev[s15old["Fhats"][F]["NLO"][-1]["Delta"], s15new["Fhats"][F]["NLO"][-1]["Delta"]] < 10^-30]]]];
outputHashes = Association[# -> FileHash[FileNameJoin[{root, #}], "SHA256", "HexString"] & /@ files];
Put[<|"Schema" -> "polarized-sidis-V07-branch-correction-v1", "Channel" -> channel,
  "Rule" -> "PolyLog[2,(Q^2+s)/Q^2] -> PolyLog[2,(Q^2+s)/Q^2] + 2 Pi I Log[(Q^2+s)/Q^2]",
  "RegeneratedS13Hash" -> FileHash[FileNameJoin[{root, channel, "s13_result", "s13_result.wl"}], "SHA256", "HexString"],
  "InputHashes" -> inputHashes, "OutputHashes" -> outputHashes, "Files" -> summary,
  "ChangedEntries" -> pattern, "Checks" -> checks, "SourceHash" -> FileHash[$InputFileName, "SHA256", "HexString"],
  "JobID" -> Environment["JOB_ID"], "Accepted" -> True|>, FileNameJoin[{outDir, "s16_result.wl"}]];
Print["PASS: s16_correct_V07_branch ", channel]; Quit[0];
