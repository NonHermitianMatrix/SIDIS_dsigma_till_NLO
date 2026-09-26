<|"Schema" -> "polarized-sidis-response-only-native-read-v1", 
 "Channel" -> "Hgg", "SourceHash" -> 1056722995341239421242326257061153210573\
96295333425135972257297349453647393136, 
 "OwnFile" -> "Hgg/s05_projected_components_result/Photon_4/s05_result.wl", 
 "OwnHash" -> 122799532638987923761535119319609199734740867384471119061519738\
81379409276318, "OwnReceiptHash" -> 
  250683391788352847359319395885585376812530718717901368987704493039951827320\
32, "OwnManifestHash" -> 
  843395039187195902657706529794942339589696464891305994367027096162731883243\
03, "StorageSourceHash" -> 11426216483708545657515977232829519125570623531904\
1633535377098792555252919466, "NativeVersions" -> 
  {"13.1.0 for Linux x86 (64-bit) (June 16, 2022)", "10.2.1"}, 
 "ReaderDefinitions" -> {HoldPattern[responseOnlyRead[path_, identity_]] :> 
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
 "OwnAcceptedComparison" -> True, "OriginalReadSeconds" -> 534.066554, 
 "CandidateReadSeconds" -> 423.027802, "RetainedBytes" -> 7480156232, 
 "PeakKernelMemoryBytes" -> 12342279800, 
 "Checks" -> <|"compute allocation" -> True, "complete source syntax" -> 
    True, "own complete projection accepted" -> True, 
   "own exact native payload round trip" -> True, 
   "original complete native conventions" -> True, 
   "response input native identity" -> True, 
   "unique unused native CDR assignment" -> True, 
   "new response-reader marker absent" -> True, 
   "all original response and payload checks retained" -> True, 
   "unique native payload directory binding" -> True, 
   "only payload directory and unused field differ" -> True, 
   "same accepted piecewise projection writer" -> True, 
   "entire own response and every retained field reproduced" -> True, 
   "unchanged original native file" -> True|>, 
 "FiniteNLOFHatsComputed" -> False|>
