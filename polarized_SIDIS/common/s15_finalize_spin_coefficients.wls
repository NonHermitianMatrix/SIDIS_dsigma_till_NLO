(* Conventional helicity-scheme conversion and final partonic export. *)
$HistoryLength = 0; root = Directory[]; channel = Environment["POLARIZED_SIDIS_CHANNEL"];
sourcePath = FileNameJoin[{root, "common", "s15_finalize_spin_coefficients.wls"}]; checks = <||>;
gate[name_, test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
gate["complete source syntax", SyntaxQ[Import[sourcePath, "Text"]]];
SetAttributes[bounded, HoldFirst];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, 1200,
  gate[ToString[label, InputForm] <> " time limit", False]], 2*1024^3,
  gate[ToString[label, InputForm] <> " memory limit", False]];
put[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
zero[value_] := Factor[Together[value]] === 0;
zeroArray[value_] := And @@ (zero /@ Flatten[{value}]);
inputPaths = {};
readInput[relative_] := Module[{path = FileNameJoin[{root, relative}]},
  gate["required input " <> relative, FileExistsQ[path]]; AppendTo[inputPaths, path];
  If[StringEndsQ[path, ".json"], Import[path, "RawJSON"], Get[path]]];
config = readInput["common/s15_inputs.json"];
gate["explicit helicity scheme definition", config["schema"] === "polarized-sidis-helicity-scheme-definition-v1"];
Do[path = FileNameJoin[{root, row["destination"]}];
  gate["pinned scheme reference " <> row["destination"], IntegerString[FileHash[path, "SHA256"], 16, 64] === row["sha256"]];
  AppendTo[inputPaths, path], {row, config["files"]}];
base = readInput["common/s01_inputs.json"];
gate["known channel", KeyExistsQ[base["channel_contracts"], channel]];
core = base["channel_contracts"][channel]["amplitude_schema"] === "core";
basis = readInput["common/s02_result/s02_result.wl"];
kernels = readInput["common/s10_result/s10_result.wl"];
subtraction = readInput[channel <> "/s11_result/s11_result.wl"];
gate["accepted basis kernels and subtraction", And @@ Values[basis["Checks"]] &&
  And @@ Values[kernels["Checks"]] && And @@ Values[subtraction["Checks"]]];
gate["accepted channel subtraction schema", subtraction["Channel"] === channel &&
  subtraction["Schema"] === If[core, "polarized-sidis-collinear-convolutions-v1", "polarized-sidis-small-collinear-convolutions-v1"]];
subtractionSource = FileNameJoin[{root, "common", If[core,
  "s11_collinear_spin_convolutions.wls", "s11_small_collinear_spin.wls"]}];
gate["accepted subtraction source binding", subtraction["SourceHash"] === FileHash[subtractionSource, "SHA256"]];
AppendTo[inputPaths, subtractionSource];
gate["unconverted BMHV subtraction", subtraction["Gamma5Scheme"] === "BMHV" &&
  subtraction["FiniteAxialSchemeConversionApplied"] === False];
labels = basis["SpinLabels"];
gate["same physical basis", kernels["SpinLabels"] === labels && subtraction["SpinLabels"] === labels &&
  subtraction["PhotonLabels"] === basis["PhotonLabels"]];
uPosition = First[FirstPosition[labels, "U"]]; hPosition = First[FirstPosition[labels, "H"]];
colorRelative = base["channel_contracts"]["Hqq"]["unpolarized_born_file"];
color = readInput[colorRelative];
gate["pinned color normalization", IntegerString[FileHash[Last[inputPaths], "SHA256"], 16, 64] ===
  SelectFirst[base["files"], #["destination"] === colorRelative &]["sha256"]];
colorCF = color["ColorConstants"]["CF"];
qqDefinition = ToExpression[config["definitions"]["qq_regular"]];
epsilonDifference = ToExpression[config["definitions"]["epsilon_difference"]];
schemeKernel = ToExpression[config["definitions"]["scheme_kernel"]];
physicalPrefactor = ToExpression[config["definitions"]["physical_convolution_prefactor"]];
couplingSquare = Factor[gs^2 /. First[Solve[ToExpression[config["definitions"]["coupling_relation"]], gs]]];
gate["scheme kernel restores the defined epsilon difference", zero[Limit[epsilonDifference/eps, eps -> 0] + schemeKernel]];
standaloneText = Import[FileNameJoin[{root, "common", "s15_result", "reference", "s54_factorization_contract.wls"}], "Text"];
gate["inherited hard-counterterm sign", StringContainsQ[standaloneText,
  "hvbmHardCountertermTuple = -hvbmSchemeKernelTuple;"]];
kernelRatio = Factor[kernels["Responses"]["qq"]["RealKernel"][[uPosition, uPosition]]/qqDefinition];
gate["derived constant reference kernel normalization", FreeQ[kernelRatio, z | eps | _Missing | _Real] && kernelRatio =!= 0];
hardKernel = Factor[-kernelRatio schemeKernel];
gate["regular endpoint-vanishing finite kernel", FreeQ[hardKernel, _kernelPlus | _kernelDelta | eps] && Limit[hardKernel, z -> 1] === 0];
dimensions = {Length[basis["PhotonLabels"]], Length[labels], Length[labels]};
regular = ConstantArray[0, dimensions]; routeResults = <||>;
physical = Q > 0 && s > s23 > 0 && s23 - Q^2 - s < t < -Q^2 s23/s && B > 0 && SUNN > 1;
endpointRegion = Q > 0 && s > 0 && -Q^2 - s < t < 0 && B > 0 && SUNN > 1;
simplify[value_] := FullSimplify[value, Assumptions -> physical];
selectedRoutes = Select[subtraction["Routes"], MemberQ[{"qq", "aqaq"}, #[If[core, "KernelKey", "Kernel"]]] &];
If[core,
  gate["inherited subtraction prefactor", subtraction["Prefactor"] === kernels["ReferenceSubtractionPrefactor"]];
  originalAssembly = Import[FileNameJoin[{root, "common", "s14_result", "reference", "s20_final_hats.wl"}], "Text"];
  gate["inherited Born delta normalization", StringContainsQ[originalAssembly, "eq^2 couplingSquare 2Pi hardNormalization"]];
  hardNormalization = ToExpression[First[StringSplit[subtraction["HardTensorNormalization"], " applied at final assembly"]]];
  leadingNormalization = eq^2 couplingSquare 2Pi hardNormalization;
  nextNormalization = eq^2 couplingSquare^2 hardNormalization;
  gate["reference prefactor matches physical convolution convention", zero[
    nextNormalization subtraction["Prefactor"] kernelRatio - leadingNormalization physicalPrefactor]];
  convolutionText = Import[FileNameJoin[{root, "common", "s11_collinear_spin_convolutions.wls"}], "Text"];
  begin = First[First[StringPosition[convolutionText, "endpointBranchComparisons = {};"]]];
  finish = First[First[Select[StringPosition[convolutionText, "distributions = {"], First[#] > begin &]]];
  convolutionCode = StringTake[convolutionText, {begin, finish - 1}]; ToExpression[convolutionCode];
  roots = <|"PDF" -> subtraction["IncomingRoot"], "FF" -> subtraction["OutgoingRoot"]|>;
  weights = <|"PDF" -> subtraction["IncomingJacobian"]/roots["PDF"],
    "FF" -> subtraction["OutgoingJacobian"]/roots["FF"]^2|>;
  kernelMatrix = Normal[SparseArray[{{hPosition, hPosition} -> hardKernel}, {Length[labels], Length[labels]}]];
  Do[key = route["BornChannel"]; side = route["Side"]; name = route["ReferenceName"];
    born = readInput[key <> "/s03_result/s03_result.wl"];
    gate[name <> " accepted Born", born["Schema"] === "polarized-sidis-born-response-v2" &&
      born["Channel"] === key && And @@ Values[born["Checks"]]];
    bornResponse = born["ResponseD4"];
    mappedResponse = bounded[simplify[bornResponse /. subtraction["ScaledInvariantRules"][side]], name <> " mapped Born"];
    pieces = Table[terms = Table[
      kernel = If[side === "PDF", kernelMatrix[[k, i]], kernelMatrix[[j, k]]] /. z -> x;
      endpoint = If[side === "PDF", bornResponse[[a, j, k]], bornResponse[[a, k, i]]];
      mapped = If[side === "PDF", mappedResponse[[a, j, k]], mappedResponse[[a, k, i]]];
      If[kernel === 0 || (endpoint === 0 && mapped === 0), <|"Delta" -> 0, "L0" -> 0, "Regular" -> 0|>,
        bounded[convolution[endpoint, kernel, roots[side], simplify[weights[side] mapped]], {name, a, j, i, k}]],
      {k, Length[labels]}]; Merge[terms, Factor[Total[#]] &],
      {a, dimensions[[1]]}, {j, dimensions[[2]]}, {i, dimensions[[3]]}];
    gate[name <> " no finite endpoint distributions", zeroArray[Map[Lookup[#, {"Delta", "L0"}] &, pieces, {3}]]];
    value = Map[#["Regular"] &, pieces, {3}];
    gate[name <> " only the selected helicity leg changes", zeroArray[If[side === "PDF",
      value[[All, All, DeleteCases[Range[Length[labels]], hPosition]]],
      value[[All, DeleteCases[Range[Length[labels]], hPosition], All]]]]];
    AssociateTo[routeResults, name -> (nextNormalization subtraction["Prefactor"] value)], {route, selectedRoutes}];
  If[routeResults =!= <||>, regular = Map[Factor, Total[Values[routeResults]], {3}]],
  gate["no diagonal quark scheme route in the real-only channel", selectedRoutes === {}]];
gate["exact finite scheme tensor", FreeQ[regular, eps | D | gs | _Pair | _Missing | _Integrate | _Limit |
  _Series | _SeriesData | _ConditionalExpression | _Piecewise | _Real | $Failed | $Aborted]];
gate["unpolarized coefficient preserved", zeroArray[regular[[All, uPosition, uPosition]]]];
sourceHash = FileHash[sourcePath, "SHA256"];
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ DeleteDuplicates[inputPaths]];
scheme = <|"Schema" -> "polarized-sidis-finite-helicity-conversion-v1", "Channel" -> channel,
  "PhotonLabels" -> basis["PhotonLabels"], "SpinLabels" -> labels, "RegularCorrection" -> regular,
  "RouteCorrections" -> routeResults, "SelectedRoutes" -> selectedRoutes, "KernelNormalizationRatio" -> kernelRatio,
  "SchemeKernelDefinition" -> schemeKernel, "HardKernelInReferenceConvention" -> hardKernel,
  "SourceHash" -> sourceHash, "InputHashes" -> inputHashes, "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
schemeDirectory = FileNameJoin[{root, channel, "s15_scheme_result"}];
If[!DirectoryQ[schemeDirectory], CreateDirectory[schemeDirectory, CreateIntermediateDirectories -> True]];
schemePath = FileNameJoin[{schemeDirectory, "s15_result.wl"}]; put[scheme, schemePath];
If[Environment["POLARIZED_SIDIS_SCHEME_ONLY"] === "1",
  Export[FileNameJoin[{schemeDirectory, "s15_checks.json"}], <|"channel" -> channel, "checks" -> checks,
    "finite_nlo_fhats_computed" -> False, "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
  Print["PASS: s15_helicity_scheme"]; Quit[0]];
rawPath = FileNameJoin[{root, channel, "s14_result", "s14_result.wl"}]; raw = Get[rawPath];
gate["accepted componentwise finite BMHV tensor", raw["Schema"] === "polarized-sidis-finite-bmhv-response-v1" &&
  raw["Channel"] === channel && And @@ Values[raw["Checks"]] && TrueQ[raw["CompletePoleCancellationChecked"]] &&
  TrueQ[raw["FiniteMinimalSubtractionCoefficientsComputed"]] && raw["FiniteAxialSchemeConversionApplied"] === False];
gate["same final photon and spin basis", raw["PhotonLabels"] === scheme["PhotonLabels"] && raw["SpinLabels"] === labels];
response = Association@Table[sign -> Association@Table[distribution ->
  (raw["NLOResponse"][sign][distribution] + If[distribution === "Regular", regular /. t -> sign omega - s, 0]),
  {distribution, {"Delta", "L0", "L1", "Regular"}}], {sign, {1, -1, 0}}];
hatNames = Keys[raw["FhatsBMHV"]];
hats = AssociationThread[hatNames, Table[With[{name = hatNames[[index]]}, <|"LODelta" -> raw["FhatsBMHV"][name]["LODelta"],
  "NLO" -> Association@Table[sign -> Association@Table[distribution -> Table[
    Sum[(raw["FhatPhotonWeights"][[index, a]] /. t -> sign omega - s) response[sign][distribution][[a, j, i]],
      {a, dimensions[[1]]}], {j, dimensions[[2]]}, {i, dimensions[[3]]}],
    {distribution, {"Delta", "L0", "L1", "Regular"}}], {sign, {1, -1, 0}}]|>],
  {index, Length[hatNames]}]];
gate["complete finite partonic export", FreeQ[{response, hats}, eps | D | gs | _Missing | _GLI | _CutIntegral |
  _PaVe | _Integrate | _Limit | _Series | _SeriesData | _ConditionalExpression | _Piecewise | _Real | $Failed | $Aborted]];
result = Join[KeyTake[raw, {"Channel", "PhotonLabels", "SpinLabels", "IndexOrder", "LODeltaResponse", "PhysicalFrame",
    "FhatPhotonWeights", "ProjectorDefinitions", "Bookkeeping", "PlusDefinition", "BranchConvention", "PhysicalConditions", "FlavorDomain"}],
  <|"Schema" -> "polarized-sidis-finite-partonic-coefficients-v1", "NLOResponse" -> response, "Fhats" -> hats,
    "Gamma5Scheme" -> "BMHV with finite helicity restoration", "FactorizationScheme" -> config["scheme"],
    "FiniteAxialSchemeConversionApplied" -> True, "CompletePoleCancellationChecked" -> True,
    "FiniteNLOFHatsComputed" -> True, "SourceHash" -> sourceHash, "BMHVResultHash" -> FileHash[rawPath, "SHA256"],
    "SchemeResultHash" -> FileHash[schemePath, "SHA256"], "InputHashes" -> inputHashes, "Checks" -> checks|>];
resultDirectory = FileNameJoin[{root, channel, "s15_result"}];
If[!DirectoryQ[resultDirectory], CreateDirectory[resultDirectory, CreateIntermediateDirectories -> True]];
put[result, FileNameJoin[{resultDirectory, "s15_result.wl"}]];
KeyValueMap[put[#2, FileNameJoin[{resultDirectory, "s15_" <> #1 <> "_hat.wl"}]] &, hats];
Export[FileNameJoin[{resultDirectory, "s15_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "finite_nlo_fhats_computed" -> True, "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s15_finalize_spin_coefficients"]; Quit[0];
