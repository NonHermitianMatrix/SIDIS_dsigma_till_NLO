<|"CutMasterParents" -> <|CutIntegral["R01", {1, 1, 0, 0}] -> 
    <|"ParentID" -> "P2_0110", "ActiveIndices" -> {1, 2}, 
     "RoutingSigns" -> {1, -1}, "OriginalShifts" -> {0, k1 - p - q}, 
     "Permutation" -> {1, 2}, "PhysicalCutSlots" -> {1, 2}, 
     "CutChordSymbol" -> c12, "PhysicalSubstitutions" -> {c12 -> -w}, 
     "OriginalChordMatrix" -> {{0, w}, {w, 0}}, "CutEnergyConditions" -> 
      {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "CutExtractionPerformed" -> False|>, CutIntegral["R01", {1, 1, 1, 1}] -> 
    <|"ParentID" -> "P4_0001001101011110", "ActiveIndices" -> {1, 2, 3, 4}, 
     "RoutingSigns" -> {1, -1, -1, 1}, "OriginalShifts" -> 
      {0, k1 - p - q, -p, k1}, "Permutation" -> {1, 3, 4, 2}, 
     "PhysicalCutSlots" -> {1, 4}, "CutChordSymbol" -> c14, 
     "PhysicalSubstitutions" -> {c14 -> -w, c23 -> -Q2 - s - t + w, 
       c24 -> -t, c34 -> -s}, "OriginalChordMatrix" -> 
      {{0, w, 0, 0}, {w, 0, t, s}, {0, t, 0, Q2 + s + t - w}, 
       {0, s, Q2 + s + t - w, 0}}, "CutEnergyConditions" -> 
      {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "CutExtractionPerformed" -> False|>, CutIntegral["R02", {1, 1, 1, 1}] -> 
    <|"ParentID" -> "P4_0011001111001100", "ActiveIndices" -> {1, 2, 3, 4}, 
     "RoutingSigns" -> {1, -1, -1, -1}, "OriginalShifts" -> 
      {0, k1 - p - q, -p, -p - q}, "Permutation" -> {1, 3, 2, 4}, 
     "PhysicalCutSlots" -> {1, 3}, "CutChordSymbol" -> c13, 
     "PhysicalSubstitutions" -> {c13 -> -w, c14 -> -s, c23 -> -t, c24 -> Q2}, 
     "OriginalChordMatrix" -> {{0, w, 0, s}, {w, 0, t, 0}, {0, t, 0, -Q2}, 
       {s, 0, -Q2, 0}}, "CutEnergyConditions" -> {energy[r] > 0, 
       energy[-k1 + p + q - r] > 0}, "CutExtractionPerformed" -> False|>, 
   CutIntegral["R03", {1, 1, 0, 1}] -> <|"ParentID" -> "P3_011101110", 
     "ActiveIndices" -> {1, 2, 4}, "RoutingSigns" -> {1, -1, -1}, 
     "OriginalShifts" -> {0, k1 - p - q, -q}, "Permutation" -> {1, 2, 3}, 
     "PhysicalCutSlots" -> {1, 2}, "CutChordSymbol" -> c12, 
     "PhysicalSubstitutions" -> {c12 -> -w, c13 -> Q2, 
       c23 -> Q2 + s + t - w}, "OriginalChordMatrix" -> 
      {{0, w, -Q2}, {w, 0, -Q2 - s - t + w}, {-Q2, -Q2 - s - t + w, 0}}, 
     "CutEnergyConditions" -> {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "CutExtractionPerformed" -> False|>, CutIntegral["R03", {1, 1, 1, 1}] -> 
    <|"ParentID" -> "P4_0011001111011110", "ActiveIndices" -> {1, 2, 3, 4}, 
     "RoutingSigns" -> {1, -1, -1, -1}, "OriginalShifts" -> 
      {0, k1 - p - q, -p, -q}, "Permutation" -> {1, 3, 2, 4}, 
     "PhysicalCutSlots" -> {1, 3}, "CutChordSymbol" -> c13, 
     "PhysicalSubstitutions" -> {c13 -> -w, c14 -> Q2, c23 -> -t, 
       c24 -> 2*Q2 + s, c34 -> Q2 + s + t - w}, "OriginalChordMatrix" -> 
      {{0, w, 0, -Q2}, {w, 0, t, -Q2 - s - t + w}, {0, t, 0, -2*Q2 - s}, 
       {-Q2, -Q2 - s - t + w, -2*Q2 - s, 0}}, "CutEnergyConditions" -> 
      {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "CutExtractionPerformed" -> False|>, CutIntegral["R04", {1, 1, 1, 1}] -> 
    <|"ParentID" -> "P4_0001001101011110", "ActiveIndices" -> {1, 2, 3, 4}, 
     "RoutingSigns" -> {1, -1, -1, 1}, "OriginalShifts" -> 
      {0, k1 - p - q, -p, k1 - p}, "Permutation" -> {3, 1, 4, 2}, 
     "PhysicalCutSlots" -> {2, 4}, "CutChordSymbol" -> c24, 
     "PhysicalSubstitutions" -> {c14 -> -t, c23 -> Q2 + s + t - w, c24 -> -w, 
       c34 -> Q2}, "OriginalChordMatrix" -> {{0, w, 0, -Q2 - s - t + w}, 
       {w, 0, t, -Q2}, {0, t, 0, 0}, {-Q2 - s - t + w, -Q2, 0, 0}}, 
     "CutEnergyConditions" -> {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "CutExtractionPerformed" -> False|>, CutIntegral["R09", {1, 1, 1, 1}] -> 
    <|"ParentID" -> "P4_0011001111011110", "ActiveIndices" -> {1, 2, 3, 4}, 
     "RoutingSigns" -> {1, -1, 1, -1}, "OriginalShifts" -> 
      {0, k1 - p - q, k1, -q}, "Permutation" -> {1, 3, 2, 4}, 
     "PhysicalCutSlots" -> {1, 3}, "CutChordSymbol" -> c13, 
     "PhysicalSubstitutions" -> {c13 -> -w, c14 -> Q2, c23 -> -s, 
       c24 -> 2*Q2 + t, c34 -> Q2 + s + t - w}, "OriginalChordMatrix" -> 
      {{0, w, 0, -Q2}, {w, 0, s, -Q2 - s - t + w}, {0, s, 0, -2*Q2 - t}, 
       {-Q2, -Q2 - s - t + w, -2*Q2 - t, 0}}, "CutEnergyConditions" -> 
      {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "CutExtractionPerformed" -> False|>, CutIntegral["R10", {1, 1, 1, 1}] -> 
    <|"ParentID" -> "P4_0001001101011110", "ActiveIndices" -> {1, 2, 3, 4}, 
     "RoutingSigns" -> {1, -1, 1, 1}, "OriginalShifts" -> 
      {0, k1 - p - q, k1, k1 - p}, "Permutation" -> {3, 1, 4, 2}, 
     "PhysicalCutSlots" -> {2, 4}, "CutChordSymbol" -> c24, 
     "PhysicalSubstitutions" -> {c14 -> -s, c23 -> Q2 + s + t - w, c24 -> -w, 
       c34 -> Q2}, "OriginalChordMatrix" -> {{0, w, 0, -Q2 - s - t + w}, 
       {w, 0, s, -Q2}, {0, s, 0, 0}, {-Q2 - s - t + w, -Q2, 0, 0}}, 
     "CutEnergyConditions" -> {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
     "CutExtractionPerformed" -> False|>|>, 
 "ParentInputs" -> <|"P2_0110" -> <|"ParentID" -> "P2_0110", 
     "Propagators" -> {SFAD[r], SFAD[pv2 + r]}, "ParentGram" -> {{-c12}}, 
     "ZeroPattern" -> {{0, 1}, {1, 0}}, "Representation" -> 
      {(x[1] + x[2])^(-2 + 2*eps)/(c12*x[1]*x[2])^eps, 
       I*Pi^(2 - eps)*Gamma[eps], {x[1], x[2]}, {x[1] + x[2], c12*x[1]*x[2], 
        {{x[1], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[r, D], 0, 0, {1, 1}]], 1}, 
         {x[2], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv2 + r, D], 0, 0, {1, 1}]], 1}}, {{x[1] + x[2]}}, 
        {-(Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv2, D]]*x[2])}, 
        -(c12*x[2]), 1, 0}}, "Gauge" -> x[2] -> 1, "SubTropicaInput" -> 
      {I*Pi^(2 - eps)*Gamma[eps], (x[1]*(1 + x[1])^(-2 + 2*eps))/
        (c12*x[1])^eps, {x[1]}, {c12}}, "EuclideanConditions" -> c12 > 0, 
     "MeasureConvention" -> 
      "Unnormalized Minkowski d^D r; FCFeynmanParametrize Unity", 
     "ParameterMeasure" -> 
      "Product d x_i / x_i after the recorded projective gauge", 
     "SourceHash" -> 75445560788560787466397076987600033106293018858269981357\
931068676826413468759, "IntegralEvaluationPerformed" -> False, 
     "Accepted" -> True|>, "P4_0001001101011110" -> 
    <|"ParentID" -> "P4_0001001101011110", "Propagators" -> 
      {SFAD[r], SFAD[pv2 + r], SFAD[pv3 + r], SFAD[pv4 + r]}, 
     "ParentGram" -> {{0, c23/2, (-c14 + c24)/2}, {c23/2, 0, (-c14 + c34)/2}, 
       {(-c14 + c24)/2, (-c14 + c34)/2, -c14}}, "ZeroPattern" -> 
      {{0, 0, 0, 1}, {0, 0, 1, 1}, {0, 1, 0, 1}, {1, 1, 1, 0}}, 
     "Representation" -> {(x[1] + x[2] + x[3] + x[4])^(2*eps)*
        (c23*x[2]*x[3] + c14*x[1]*x[4] + c24*x[2]*x[4] + c34*x[3]*x[4])^
         (-2 - eps), I*Pi^(2 - eps)*Gamma[2 + eps], {x[1], x[2], x[3], x[4]}, 
       {x[1] + x[2] + x[3] + x[4], c23*x[2]*x[3] + c14*x[1]*x[4] + 
         c24*x[2]*x[4] + c34*x[3]*x[4], 
        {{x[1], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[r, D], 0, 0, {1, 1}]], 1}, 
         {x[2], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv2 + r, D], 0, 0, {1, 1}]], 1}, 
         {x[3], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv3 + r, D], 0, 0, {1, 1}]], 1}, 
         {x[4], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv4 + r, D], 0, 0, {1, 1}]], 1}}, 
        {{x[1] + x[2] + x[3] + x[4]}}, 
        {-(Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv2, D]]*x[2]) - 
          Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv3, D]]*x[3] - 
          Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv4, D]]*x[4]}, 
        -(c14*x[4]), 1, 0}}, "Gauge" -> x[4] -> 1, "SubTropicaInput" -> 
      {I*Pi^(2 - eps)*Gamma[2 + eps], x[1]*x[2]*x[3]*(1 + x[1] + x[2] + x[3])^
         (2*eps)*(c14*x[1] + c24*x[2] + c34*x[3] + c23*x[2]*x[3])^(-2 - eps), 
       {x[1], x[2], x[3]}, {c14, c23, c24, c34}}, "EuclideanConditions" -> 
      c14 > 0 && c23 > 0 && c24 > 0 && c34 > 0, "MeasureConvention" -> 
      "Unnormalized Minkowski d^D r; FCFeynmanParametrize Unity", 
     "ParameterMeasure" -> 
      "Product d x_i / x_i after the recorded projective gauge", 
     "SourceHash" -> 75445560788560787466397076987600033106293018858269981357\
931068676826413468759, "IntegralEvaluationPerformed" -> False, 
     "Accepted" -> True|>, "P4_0011001111001100" -> 
    <|"ParentID" -> "P4_0011001111001100", "Propagators" -> 
      {SFAD[r], SFAD[pv2 + r], SFAD[pv3 + r], SFAD[pv4 + r]}, 
     "ParentGram" -> {{0, (-c13 + c23)/2, (-c14 + c24)/2}, 
       {(-c13 + c23)/2, -c13, (-c13 - c14)/2}, {(-c14 + c24)/2, 
        (-c13 - c14)/2, -c14}}, "ZeroPattern" -> {{0, 0, 1, 1}, {0, 0, 1, 1}, 
       {1, 1, 0, 0}, {1, 1, 0, 0}}, "Representation" -> 
      {(x[1] + x[2] + x[3] + x[4])^(2*eps)*(c13*x[1]*x[3] + c23*x[2]*x[3] + 
          c14*x[1]*x[4] + c24*x[2]*x[4])^(-2 - eps), 
       I*Pi^(2 - eps)*Gamma[2 + eps], {x[1], x[2], x[3], x[4]}, 
       {x[1] + x[2] + x[3] + x[4], c13*x[1]*x[3] + c23*x[2]*x[3] + 
         c14*x[1]*x[4] + c24*x[2]*x[4], 
        {{x[1], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[r, D], 0, 0, {1, 1}]], 1}, 
         {x[2], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv2 + r, D], 0, 0, {1, 1}]], 1}, 
         {x[3], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv3 + r, D], 0, 0, {1, 1}]], 1}, 
         {x[4], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv4 + r, D], 0, 0, {1, 1}]], 1}}, 
        {{x[1] + x[2] + x[3] + x[4]}}, 
        {-(Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv2, D]]*x[2]) - 
          Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv3, D]]*x[3] - 
          Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv4, D]]*x[4]}, 
        -(c13*x[3]) - c14*x[4], 1, 0}}, "Gauge" -> x[4] -> 1, 
     "SubTropicaInput" -> {I*Pi^(2 - eps)*Gamma[2 + eps], 
       x[1]*x[2]*x[3]*(1 + x[1] + x[2] + x[3])^(2*eps)*
        (c14*x[1] + c24*x[2] + c13*x[1]*x[3] + c23*x[2]*x[3])^(-2 - eps), 
       {x[1], x[2], x[3]}, {c13, c14, c23, c24}}, "EuclideanConditions" -> 
      c13 > 0 && c14 > 0 && c23 > 0 && c24 > 0, "MeasureConvention" -> 
      "Unnormalized Minkowski d^D r; FCFeynmanParametrize Unity", 
     "ParameterMeasure" -> 
      "Product d x_i / x_i after the recorded projective gauge", 
     "SourceHash" -> 75445560788560787466397076987600033106293018858269981357\
931068676826413468759, "IntegralEvaluationPerformed" -> False, 
     "Accepted" -> True|>, "P3_011101110" -> <|"ParentID" -> "P3_011101110", 
     "Propagators" -> {SFAD[r], SFAD[pv2 + r], SFAD[pv3 + r]}, 
     "ParentGram" -> {{-c12, (-c12 - c13 + c23)/2}, {(-c12 - c13 + c23)/2, 
        -c13}}, "ZeroPattern" -> {{0, 1, 1}, {1, 0, 1}, {1, 1, 0}}, 
     "Representation" -> {(x[1] + x[2] + x[3])^(-1 + 2*eps)*
        (c12*x[1]*x[2] + c13*x[1]*x[3] + c23*x[2]*x[3])^(-1 - eps), 
       (-I)*Pi^(2 - eps)*Gamma[1 + eps], {x[1], x[2], x[3]}, 
       {x[1] + x[2] + x[3], c12*x[1]*x[2] + c13*x[1]*x[3] + c23*x[2]*x[3], 
        {{x[1], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[r, D], 0, 0, {1, 1}]], 1}, 
         {x[2], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv2 + r, D], 0, 0, {1, 1}]], 1}, 
         {x[3], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv3 + r, D], 0, 0, {1, 1}]], 1}}, 
        {{x[1] + x[2] + x[3]}}, 
        {-(Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv2, D]]*x[2]) - 
          Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv3, D]]*x[3]}, 
        -(c12*x[2]) - c13*x[3], 1, 0}}, "Gauge" -> x[3] -> 1, 
     "SubTropicaInput" -> {(-I)*Pi^(2 - eps)*Gamma[1 + eps], 
       x[1]*x[2]*(1 + x[1] + x[2])^(-1 + 2*eps)*
        (c13*x[1] + c23*x[2] + c12*x[1]*x[2])^(-1 - eps), {x[1], x[2]}, 
       {c12, c13, c23}}, "EuclideanConditions" -> c12 > 0 && c13 > 0 && 
       c23 > 0, "MeasureConvention" -> 
      "Unnormalized Minkowski d^D r; FCFeynmanParametrize Unity", 
     "ParameterMeasure" -> 
      "Product d x_i / x_i after the recorded projective gauge", 
     "SourceHash" -> 75445560788560787466397076987600033106293018858269981357\
931068676826413468759, "IntegralEvaluationPerformed" -> False, 
     "Accepted" -> True|>, "P4_0011001111011110" -> 
    <|"ParentID" -> "P4_0011001111011110", "Propagators" -> 
      {SFAD[r], SFAD[pv2 + r], SFAD[pv3 + r], SFAD[pv4 + r]}, 
     "ParentGram" -> {{0, (-c13 + c23)/2, (-c14 + c24)/2}, 
       {(-c13 + c23)/2, -c13, (-c13 - c14 + c34)/2}, 
       {(-c14 + c24)/2, (-c13 - c14 + c34)/2, -c14}}, 
     "ZeroPattern" -> {{0, 0, 1, 1}, {0, 0, 1, 1}, {1, 1, 0, 1}, 
       {1, 1, 1, 0}}, "Representation" -> 
      {(x[1] + x[2] + x[3] + x[4])^(2*eps)*(c13*x[1]*x[3] + c23*x[2]*x[3] + 
          c14*x[1]*x[4] + c24*x[2]*x[4] + c34*x[3]*x[4])^(-2 - eps), 
       I*Pi^(2 - eps)*Gamma[2 + eps], {x[1], x[2], x[3], x[4]}, 
       {x[1] + x[2] + x[3] + x[4], c13*x[1]*x[3] + c23*x[2]*x[3] + 
         c14*x[1]*x[4] + c24*x[2]*x[4] + c34*x[3]*x[4], 
        {{x[1], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[r, D], 0, 0, {1, 1}]], 1}, 
         {x[2], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv2 + r, D], 0, 0, {1, 1}]], 1}, 
         {x[3], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv3 + r, D], 0, 0, {1, 1}]], 1}, 
         {x[4], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv4 + r, D], 0, 0, {1, 1}]], 1}}, 
        {{x[1] + x[2] + x[3] + x[4]}}, 
        {-(Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv2, D]]*x[2]) - 
          Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv3, D]]*x[3] - 
          Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv4, D]]*x[4]}, 
        -(c13*x[3]) - c14*x[4], 1, 0}}, "Gauge" -> x[4] -> 1, 
     "SubTropicaInput" -> {I*Pi^(2 - eps)*Gamma[2 + eps], 
       x[1]*x[2]*x[3]*(1 + x[1] + x[2] + x[3])^(2*eps)*
        (c14*x[1] + c24*x[2] + c34*x[3] + c13*x[1]*x[3] + c23*x[2]*x[3])^
         (-2 - eps), {x[1], x[2], x[3]}, {c13, c14, c23, c24, c34}}, 
     "EuclideanConditions" -> c13 > 0 && c14 > 0 && c23 > 0 && c24 > 0 && 
       c34 > 0, "MeasureConvention" -> 
      "Unnormalized Minkowski d^D r; FCFeynmanParametrize Unity", 
     "ParameterMeasure" -> 
      "Product d x_i / x_i after the recorded projective gauge", 
     "SourceHash" -> 75445560788560787466397076987600033106293018858269981357\
931068676826413468759, "IntegralEvaluationPerformed" -> False, 
     "Accepted" -> True|>|>, "SourceHash" -> 75445560788560787466397076987600\
033106293018858269981357931068676826413468759, 
 "ReductionHash" -> 540324767422391340294569867359158398448513257314091386192\
95632617918218969360, "Accepted" -> True, "IntegralEvaluationPerformed" -> 
  False, "CutExtractionPerformed" -> False|>
