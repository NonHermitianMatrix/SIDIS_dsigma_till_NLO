<|"Schema" -> "polarized-sidis-selected-entry-cluster-reader-v1", 
 "Channel" -> "Hgg", "SourceHash" -> 8699307389942232555081084176302714938777\
0456481978456088094848199637401961337, "SelectedSourceHash" -> 
  417787644691491531103818416723052839985175507506433730598496796656519390107\
75, "ComponentSourceHash" -> 110014956793544233077116896373182606123128509575\
117104285296365397643589580750, "MetadataHash" -> 112330297712276313189334347\
587518782233099145580988091791921667126816975626455, 
 "InputHashes" -> <|"common/s08_inputs.json" -> 10327260080829766293091998126\
5737943958514832290209092866289162522612131409773, 
   "common/s08_result/reference/s03_real_families.wl" -> 79218334697979525256\
438460479090885281197883599741553752634627893927124665973, 
   "common/s08_result/reference/s11_real_master_coefficients.wl" -> 888010789\
93972289575052221948419753128618528285806282699543719722908442075194, 
   "Hgg/s05_result/s05_result.wl" -> 1029361418013729292672145888105236697076\
85486096477497984012230718236558484562, "common/s06_result/s06_result.wl" -> 
    1629893493036707090606236278450981817622056446909249767204950169338278543\
2993, "common/s06_result/reference/s02_result.wl" -> 
    8770265877483402774922788588147861102443996674038642942949748074715179433\
6781, "common/s06_result/reference/s04_result.wl" -> 
    5403247674223913402945698673591583984485132573140913861929563261791821896\
9360|>, "TargetInputHash" -> 
  102624139533433452980585954631843274506749042507831809276349711928957049011\
27, "NativeInputHash" -> 
  161609670950844788501356801104868491459900992223646955499587922181695002304\
14, "ResponseReaderProofHash" -> 
  174197719293880551197502516608281500340110201177932681621705945777559800081\
23, "TaskInventoryHash" -> 
  545168876007497877740244929850695364967563641959671912448890740929406676888\
10, "OriginalTaskDefinitions" -> {HoldPattern[hggTaskValue[index_]] :> 
    Module[{row, key, path, packet, positions, expected, actual}, 
     row = hggTaskSources[[index]]; key = {row["Payload"], row["Field"]}; 
      If[ !ValueQ[hggCachedKey] || hggCachedKey =!= key, 
       Clear[hggCachedValue, hggCachedKey]; ClearSystemCache[]; 
        path = FileNameJoin[{hggTaskRoot, row["Payload"]["File"]}]; 
        gate["Hgg pinned native mapping payload", FileExistsQ[path] && 
          FileHash[path, "SHA256"] === row["Payload"]["Hash"]]; 
        packet = hggMapRead[hggResponseNativeGet[path], 
          {"Hgg one native component", index}]; 
        gate["Hgg accepted native mapping payload", AssociationQ[packet] && 
          packet["Channel"] === "Hgg" && And @@ Values[packet["Checks"]] && 
          KeyExistsQ[packet, row["Field"]]]; hggCachedValue = 
         packet[row["Field"]]; positions = 
         Select[Range[Length[hggTaskSources]], 
          {hggTaskSources[[#1]]["Payload"], hggTaskSources[[#1]][
              "Field"]} === key & ]; expected = hggTaskMetadata[[positions]]; 
        actual = {}; If[row["Field"] === "Response", 
         MapIndexed[Function[{value, componentIndex}, If[value =!= 0, 
            AppendTo[actual, Association["Sector" -> First[expected][
                "Sector"], "Kind" -> "ExtendedResponse", "Index" -> Prepend[
                componentIndex, packet["Component"]]]]]], hggCachedValue, 
          {2}], gate["Hgg original dimensional metric task", 
           row["Field"] === "Value" && row["Index"] === {} && 
            packet["Key"] === "Scalar_PgD"]; actual = 
           {Association["Sector" -> First[expected]["Sector"], 
             "Kind" -> "PhotonMetricD", "Index" -> {}]}]; 
        gate["Hgg loaded component reproduces original task inventory", 
         actual === expected && And @@ MapThread[
            If[#1["Kind"] === "ExtendedResponse", Rest[#1["Index"]], {}] === 
              #2["Index"] & , {expected, hggTaskSources[[positions]]}]]; 
        Clear[packet]; hggCachedKey = key]; Extract[hggCachedValue, 
       row["Index"]]]}, "CandidateTaskDefinitions" -> 
  {HoldPattern[hggTaskValue[index_]] :> 
    Module[{row, path, text, held, shapes, shape, manifest, slots, 
      pieceIndex, oldResponse, newResponse, oldCDR, newCDR, location, 
      literal, candidate, packet, positions, selected}, 
     row = hggTaskSources[[index]]; path = FileNameJoin[
        {localRoot, row["Payload"]["File"]}]; 
      gate["selected input exact native identity", 
       FileHash[path, "SHA256"] === row["Payload"]["Hash"]]; 
      text = ReadString[path]; If[ !StringContainsQ[text, 
         "response=ArrayReshape[Table[readPiece[k]"], 
       Return[selectedOriginalTaskValue[index]]]; 
      gate["selected piece belongs to response", row["Field"] === 
        "Response"]; held = ToExpression[text, InputForm, HoldComplete]; 
      shapes = Cases[held, HoldPattern[ArrayReshape[_, shape_List]] :> shape, 
        Infinity]; gate["unique saved response shape", 
       Length[shapes] === 1 && AllTrue[First[shapes], 
         IntegerQ[#1] && #1 > 0 & ]]; shape = First[shapes]; 
      manifest = Import[FileNameJoin[{DirectoryName[path], 
          "s05_payload_manifest.json"}], "RawJSON"]; 
      gate["accepted exact piecewise serialization", 
       TrueQ[manifest["exact_round_trip"]] && manifest["result_sha256"] === 
         IntegerString[FileHash[path, "SHA256"], 16, 64] && 
        manifest["storage_source_sha256"] === IntegerString[
          FileHash[FileNameJoin[{localRoot, "common", 
             "s05_project_Hgg_piecewise_storage.wls"}], "SHA256"], 16, 64]]; 
      slots = Range[2, Length[manifest["piece_groups"]] - 1]; 
      gate["complete stored response slot count", Length[slots] === 
        Times @@ shape]; pieceIndex = Extract[ArrayReshape[slots, shape], 
        row["Index"]]; positions = Tuples[Range /@ shape]; 
      gate["selected read matches original writer ordering", 
       positions[[pieceIndex - 1]] === row["Index"] && 
        Extract[ArrayReshape[localStoredEntry /@ slots, shape], 
          row["Index"]] === localStoredEntry[pieceIndex]]; 
      oldResponse = StringJoin[
        "response=ArrayReshape[Table[readPiece[k],{k,2,Length[groups]-1}],", 
        ToString[shape, InputForm], "];"]; newResponse = 
       StringJoin["response=ArrayReshape[Table[If[k===", 
        ToString[pieceIndex, InputForm], ",readPiece[k],Missing[\"EntryNotReq\
uested\"]],{k,2,Length[groups]-1}],", ToString[shape, InputForm], "];"]; 
      oldCDR = "cdr=readPiece[Length[groups]];"; 
      newCDR = "cdr=Missing[\"CDRNotRequested\"];"; 
      location = "DirectoryName[$InputFileName]"; 
      literal = ToString[DirectoryName[path], InputForm]; 
      gate["exact selected-reader interfaces", 
       StringCount[text, oldResponse] === 1 && StringCount[text, oldCDR] === 
         1 && StringCount[text, location] === 1 && 
        StringCount[text, literal] === 0]; candidate = 
       StringReplace[text, {oldResponse -> newResponse, oldCDR -> newCDR, 
         location -> literal}]; 
      gate["all native payload identity checks retained", 
       SyntaxQ[candidate] && StringReplace[candidate, 
          {newResponse -> oldResponse, newCDR -> oldCDR, 
           literal -> location}] === text]; 
      packet = bounded[ToExpression[candidate, InputForm], 
        {"selected native entry", index}]; 
      gate["selected response retains original metadata", 
       AssociationQ[packet] && packet["Channel"] === channel && 
        packet["Component"] === First[hggTaskMetadata[[index]]["Index"]] && 
        Rest[hggTaskMetadata[[index]]["Index"]] === row["Index"] && 
        packet["NativeVersions"] === importedNativeVersions && 
        And @@ Values[packet["Checks"]] && packet["StorageDispatchHash"] === 
         FileHash[FileNameJoin[{localRoot, "common", 
            "s05_project_Hgg_piecewise_storage.wls"}], "SHA256"]]; 
      selected = Extract[packet["Response"], row["Index"]]; 
      gate["only requested response entry decompressed", 
        !MissingQ[selected] && Count[Flatten[packet["Response"]], 
          _Missing] === Length[slots] - 1 && 
        MissingQ[packet["CDRPhotonCoefficient"]]]; 
      Print["LOCAL_SELECTED_ENTRY_BYTES ", index, " ", ByteCount[selected]]; 
      selected]}, "ResponseReaderDefinitions" -> 
  {HoldPattern[responseOnlyRead[path_, identity_]] :> 
    Module[{text, old, new, candidate, location, literal, value}, 
     gate["response input native identity", FileExistsQ[path] && 
        FileHash[path, "SHA256"] === identity]; text = Import[path, "Text"]; 
      old = "cdr=readPiece[Length[groups]];"; 
      If[StringCount[text, old] === 0, Return[Get[path]]]; 
      gate["unique unused native CDR assignment", StringCount[text, old] === 
        1]; new = "cdr=Missing[\"CDRNotRequestedByResponseConsumer\"];"; 
      gate["new response-reader marker absent", StringCount[text, new] === 
        0]; candidate = StringReplace[text, old -> new]; 
      gate["all original response and payload checks retained", 
       SyntaxQ[candidate] && StringReplace[candidate, new -> old] === text]; 
      location = "DirectoryName[$InputFileName]"; 
      literal = ToString[DirectoryName[path], InputForm]; 
      gate["unique native payload directory binding", 
       StringCount[candidate, location] === 1 && 
        StringCount[candidate, literal] === 0]; 
      candidate = StringReplace[candidate, location -> literal]; 
      gate["only payload directory and unused field differ", 
       SyntaxQ[candidate] && StringReplace[candidate, {literal -> location, 
           new -> old}] === text]; value = ToExpression[candidate, 
        InputForm]; gate["same accepted piecewise projection writer", 
       AssociationQ[value] && value["Schema"] === 
         "polarized-sidis-complete-photon-spin-component-v1" && 
        value["Channel"] === "Hgg" && KeyExistsQ[value, "Response"] && 
        value["StorageDispatchHash"] === FileHash[FileNameJoin[
           {Directory[], "common", "s05_project_Hgg_piecewise_storage.wls"}], 
          "SHA256"] && MissingQ[value["CDRPhotonCoefficient"]] && 
        And @@ Values[value["Checks"]]]; value]}, 
 "ResponseDispatchDefinitions" -> 
  {HoldPattern[hggResponseNativeGet[path_]] :> responseOnlyRead[path, 
     FileHash[path, "SHA256"]]}, "OwnAcceptedComparison" -> True, 
 "SpeedupObserved" -> True, "OwnComponent" -> 36, 
 "OwnTask" -> <|"Sector" -> "Real", "Kind" -> "ExtendedResponse", 
   "Index" -> {4, 1, 1}|>, "OwnValueHash" -> 44835344796610584175375318403013\
109370278361948406651446818762181423634309151, 
 "OwnFile" -> "Hgg/s05_projected_components_result/Photon_4/s05_result.wl", 
 "OwnHash" -> 122799532638987923761535119319609199734740867384471119061519738\
81379409276318, "OwnManifestHash" -> 
  843395039187195902657706529794942339589696464891305994367027096162731883243\
03, "OwnReceiptHash" -> 
  250683391788352847359319395885585376812530718717901368987704493039951827320\
32, "OriginalReadSeconds" -> 550.46766, "SelectedReadSeconds" -> 84.667988, 
 "OriginalRetainedBytes" -> 7475973904, "SelectedRetainedBytes" -> 
  1110627984, "NativeVersions" -> 
  {"13.1.0 for Linux x86 (64-bit) (June 16, 2022)", "10.2.1"}, 
 "Checks" -> <|"compute allocation" -> True, "complete comparison syntax" -> 
    True, "accepted native identity \
Hgg/s08_mapping_inputs_result/s08_component_0008.wl" -> True, 
   "accepted native checks \
Hgg/s08_mapping_inputs_result/s08_component_0008.wl" -> True, 
   "own native mapping input" -> True, 
   "same scientific input common/s08_inputs.json" -> True, 
   "same scientific input common/s08_result/reference/s03_real_families.wl" \
-> True, "same scientific input \
common/s08_result/reference/s11_real_master_coefficients.wl" -> True, 
   "same scientific input Hgg/s05_result/s05_result.wl" -> True, 
   "same scientific input common/s06_result/s06_result.wl" -> True, 
   "same scientific input common/s06_result/reference/s02_result.wl" -> True, 
   "same scientific input common/s06_result/reference/s04_result.wl" -> True, 
   "accepted native identity Hgg/s08_response_read_result/s08_result.wl" -> 
    True, 
   "accepted native checks Hgg/s08_response_read_result/s08_result.wl" -> 
    True, "same accepted response reader" -> True, 
   "same original component loader" -> True, 
   "unique complete source block s08_map_Hgg_component_inputs.wls" -> True, 
   "complete source block syntax s08_map_Hgg_component_inputs.wls" -> True, 
   "exact existing production reader interface" -> True, 
   "accepted metadata checks" -> True, 
   "Hgg accepted bounded component interface" -> True, 
   "Hgg complete distinct native task inventory" -> True, 
   "Hgg deferred tasks retain exact ordering" -> True, 
   "same own task identity" -> True, 
   "exact existing selected-entry implementation" -> True, 
   "unique complete source block s06_map_Hgg_local.wls" -> True, 
   "complete source block syntax s06_map_Hgg_local.wls" -> True, 
   "only reader and fallback names change" -> True, 
   "exact accepted piecewise comparison fixture" -> True, 
   "nonempty actual piecewise task inventory" -> True, 
   "selected input exact native identity" -> True, 
   "selected piece belongs to response" -> True, 
   "unique saved response shape" -> True, 
   "accepted exact piecewise serialization" -> True, 
   "complete stored response slot count" -> True, 
   "selected read matches original writer ordering" -> True, 
   "exact selected-reader interfaces" -> True, 
   "all native payload identity checks retained" -> True, 
   "selected response retains original metadata" -> True, 
   "only requested response entry decompressed" -> True, 
   "Hgg pinned native mapping payload" -> True, 
   "response input native identity" -> True, 
   "unique unused native CDR assignment" -> True, 
   "new response-reader marker absent" -> True, 
   "all original response and payload checks retained" -> True, 
   "unique native payload directory binding" -> True, 
   "only payload directory and unused field differ" -> True, 
   "same accepted piecewise projection writer" -> True, 
   "Hgg accepted native mapping payload" -> True, 
   "Hgg loaded component reproduces original task inventory" -> True, 
   "complete selected value equals current reader" -> True, 
   "executed own selected-read improvement" -> True, 
   "comparison payload unchanged" -> True|>, "PeakKernelMemoryBytes" -> 
  15788596512, "FiniteNLOFHatsComputed" -> False|>
