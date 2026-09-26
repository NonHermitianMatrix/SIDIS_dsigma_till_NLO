(* Cancel only factors measured in the actual coefficient denominators. *)
$HistoryLength = 0;
cancelSourcePath = FileNameJoin[{Directory[], "common", "s08_cancel_denominator_check.wls"}];
cancelBaselinePath = FileNameJoin[{Directory[], "common", "s08_denominator_sum_check.wls"}];
If[IntegerString[FileHash[cancelBaselinePath, "SHA256"], 16, 64] =!=
  "c2ba99a0039cbbc295b7aa918d336f697a1cc5a5546f3e670ec4ec9bb01bc47d",
  Print["FAIL: pinned denominator comparison source"]; Quit[1]];

cancelKnownDenominatorFactors[polynomial_, factors_List, powers_List, purpose_] := Module[
  {current, extracted, factor, candidates, variable, division, quotient, remainder, seconds, beforeBytes},
  current = polynomial; extracted = {};
  gate["matched measured denominator inventory", Length[factors] === Length[powers]];
  Do[
    factor = factors[[index]];
    candidates = Select[Variables[factor],
      Function[symbol, NumberQ[Coefficient[factor, symbol, Exponent[factor, symbol]]]]];
    gate["known denominator has constant leading coefficient", candidates =!= {}];
    variable = First[MinimalBy[candidates, Exponent[factor, #] &]];
    Do[
      beforeBytes = ByteCount[current];
      {seconds, division} = AbsoluteTiming[bounded[
        PolynomialQuotientRemainder[current, factor, variable], {purpose, "known-factor division", index, power}]];
      {quotient, remainder} = division;
      remainder = bounded[Expand[remainder], {purpose, "exact division remainder", index, power}];
      gate["exact known-factor quotient and remainder", bounded[
        Expand[current - factor quotient - remainder] === 0, {purpose, "division reconstruction", index, power}]];
      Print["KNOWN_FACTOR_DIVISION ", purpose, " factor ", InputForm[factor], " variable ", variable,
        " seconds ", seconds, " input_bytes ", beforeBytes, " quotient_bytes ", ByteCount[quotient],
        " divides ", remainder === 0];
      If[remainder =!= 0, Break[]];
      current = quotient; AppendTo[extracted, factor], {power, powers[[index]]}],
    {index, Length[factors]}];
  (Times @@ extracted) current];

cancelBaselineText = Import[cancelBaselinePath, "Text"];
cancelReplacements = {
  "denominatorSource = FileNameJoin[{Directory[], \"common\", \"s08_denominator_sum_check.wls\"}];" ->
    "denominatorSource = cancelSourcePath;",
  "factoredNumerator = bounded[Factor[numerator], {purpose, \"final numerator factorization\"}];" ->
    "factoredNumerator = cancelKnownDenominatorFactors[numerator, allFactors, commonPowers, purpose];",
  "\"cache\", \"s08_denominator_sum\"" -> "\"cache\", \"s08_cancel_denominator_sum\"",
  "\"s08_denominator_result\"" -> "\"s08_cancel_denominator_result\"",
  "\"polarized-sidis-denominator-sum-validation-v1\"" -> "\"polarized-sidis-known-denominator-validation-v1\"",
  "\"Definitions\" -> DownValues[factoredDenominatorSum]" ->
    "\"Definitions\" -> DownValues[factoredDenominatorSum], \"CancellationDefinitions\" -> DownValues[cancelKnownDenominatorFactors], \"DenominatorSourceHash\" -> FileHash[cancelBaselinePath, \"SHA256\"]",
  "\"PASS: s08_denominator_sum_check\"" -> "\"PASS: s08_cancel_denominator_check\""};
Do[If[StringCount[cancelBaselineText, First[replacement]] =!= 1,
  Print["FAIL: unique reviewed denominator replacement ", First[replacement]]; Quit[1]],
  {replacement, cancelReplacements}];
cancelProgram = StringReplace[cancelBaselineText, cancelReplacements];
If[!SyntaxQ[cancelProgram] || !SyntaxQ[Import[cancelSourcePath, "Text"]],
  Print["FAIL: complete known-denominator source syntax"]; Quit[1]];
ToExpression[cancelProgram, InputForm];
