(* Lossless native storage with a small, hash-verifying Get entry point. *)
writeChunkedNativeResult[value_, resultPath_, chunkCharacters_Integer, relativeBase_String] := Module[
  {directory, compressed, count, parts, names, hashes, chunk, path, reader,
   manifestPath, manifest, started, roundTrip, totalBytes},
  gate["valid native payload chunk bound", 0 < chunkCharacters <= 32*1024^2];
  directory = DirectoryName[resultPath]; started = AbsoluteTime[];
  If[!DirectoryQ[directory], CreateDirectory[directory, CreateIntermediateDirectories -> True]];
  Print["RESULT_STORAGE_INPUT_BYTES ", ByteCount[value]];
  compressed = MemoryConstrained[TimeConstrained[Compress[value], 1800,
    gate["native payload compression time bound", False]], 8*1024^3,
    gate["native payload compression memory bound", False]];
  gate["native payload is text", StringQ[compressed] && StringLength[compressed] > 0];
  count = Ceiling[StringLength[compressed]/chunkCharacters];
  parts = Table[
    chunk = StringTake[compressed, {(index - 1)*chunkCharacters + 1, Min[index*chunkCharacters, StringLength[compressed]]}];
    path = FileNameJoin[{directory, "s05_payload_" <> IntegerString[index, 10, 4] <> ".txt"}];
    Export[path <> ".tmp", chunk, "Text"];
    gate["native payload part below file bound", FileByteCount[path <> ".tmp"] < 128*1024^2];
    gate["native payload text round trip", Import[path <> ".tmp", "Text"] === chunk];
    RenameFile[path <> ".tmp", path, OverwriteTarget -> True];
    Print["NATIVE_PAYLOAD_PART ", index, "/", count, " bytes ", FileByteCount[path]];
    <|"file" -> relativeBase <> "/" <> FileNameTake[path], "name" -> FileNameTake[path],
      "bytes" -> FileByteCount[path], "sha256" -> IntegerString[FileHash[path, "SHA256"], 16, 64]|>,
    {index, count}];
  names = Lookup[parts, "name"]; hashes = FromDigits[#, 16] & /@ Lookup[parts, "sha256"];
  reader = "Module[{paths = FileNameJoin[{DirectoryName[$InputFileName], #}] & /@ " <>
    ToString[names, InputForm] <> ", hashes = " <> ToString[hashes, InputForm] <>
    "}, If[And @@ (FileExistsQ /@ paths) && (FileHash[#, \"SHA256\"] & /@ paths) === hashes, " <>
    "Uncompress[StringJoin[Import[#, \"Text\"] & /@ paths]], Print[\"FAIL: native payload identity\"]; $Failed]]\n";
  gate["complete native payload reader syntax", SyntaxQ[reader]];
  Export[resultPath <> ".tmp", reader, "Text"];
  gate["native payload reader below file bound", FileByteCount[resultPath <> ".tmp"] < 128*1024^2];
  Clear[compressed, chunk]; ClearSystemCache[];
  roundTrip = MemoryConstrained[TimeConstrained[Get[resultPath <> ".tmp"] === value, 1800,
    gate["native payload reload time bound", False]], 8*1024^3,
    gate["native payload reload memory bound", False]];
  gate["complete native payload exact round trip", roundTrip];
  RenameFile[resultPath <> ".tmp", resultPath, OverwriteTarget -> True];
  totalBytes = Total[Lookup[parts, "bytes"]];
  manifest = <|"schema" -> "polarized-sidis-chunked-wolfram-result-v1", "result" -> relativeBase <> "/" <> FileNameTake[resultPath],
    "result_sha256" -> IntegerString[FileHash[resultPath, "SHA256"], 16, 64], "payloads" -> parts,
    "expression_bytes" -> ByteCount[value], "payload_bytes" -> totalBytes,
    "exact_round_trip" -> roundTrip, "serialization_seconds" -> AbsoluteTime[] - started|>;
  manifestPath = FileNameJoin[{directory, "s05_payload_manifest.json"}];
  Export[manifestPath <> ".tmp", manifest, "RawJSON"];
  gate["native payload manifest round trip", KeyDrop[Import[manifestPath <> ".tmp", "RawJSON"], "serialization_seconds"] ===
    KeyDrop[manifest, "serialization_seconds"]];
  RenameFile[manifestPath <> ".tmp", manifestPath, OverwriteTarget -> True];
  Print["RESULT_STORAGE payload_bytes ", totalBytes, " parts ", count,
    " serialization_seconds ", manifest["serialization_seconds"]]; manifest];
