<|"Born" -> <|"Diagrams" -> 
    TopologyList[Process -> {V[1], V[5, {Index[Gluon, 2]}]} -> 
        {F[3, {1, Index[Colour, 3]}], -F[3, {1, Index[Colour, 4]}]}, 
      Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
      InsertionLevel -> {Classes}, ExcludeParticles -> 
       {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], -F[1, {2}], 
        F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], 
        F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], -U[1], 
        U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
        V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][5], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Internal][Vertex[3][5], Vertex[3][6], Field[5]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> F] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> 
           -F[3, {1, Index[Colour, 3]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][5], Field[4]], 
       Propagator[Internal][Vertex[3][5], Vertex[3][6], Field[5]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> F] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 4]}]]]]], 
   "Raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, 
          {}}, {V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 0, 
          {Sqrt[3]*ColorCharge}}} -> {{F[3, {1, Index[Colour, 3]}], 
          FourMomentum[Outgoing, 1], FCGV["MU"], {(2*Charge)/3, 
           (2*ColorCharge)/Sqrt[3]}}, {-F[3, {1, Index[Colour, 4]}], 
          FourMomentum[Outgoing, 2], FCGV["MU"], {(-2*Charge)/3, 
           (-2*ColorCharge)/Sqrt[3]}}}, Model -> {"SMQCD"}, 
      GenericModel -> {"Lorentz"}, AmplitudeLevel -> {Classes}, 
      ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], 
        -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], 
        -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], 
        S[3], -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], 
        -V[3], V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 1], Integral[], (-I)*FAPolarizationVector[V[1], 
        FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
       FAPolarizationVector[V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 
         2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
             2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 2], Index[Colour, 3], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 3], 
           Index[Colour, 4]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 3], 
        3, External]*SumOver[Index[Colour, 4], 3, External]*
       SumOver[Index[Gluon, 2], 8, External]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 2], Integral[], (-I)*FAPolarizationVector[V[1], 
        FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
       FAPolarizationVector[V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 
         2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 2], Index[Colour, 3], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 3], 
           Index[Colour, 4]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
             1]] + FCGV["MU"]], ((-2*I)/3)*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
          FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
        FANonCommutative[FADiracSpinor[-FourMomentum[Outgoing, 2], 
          FCGV["MU"]]]]*SumOver[Index[Colour, 3], 3, External]*
       SumOver[Index[Colour, 4], 3, External]*SumOver[Index[Gluon, 2], 8, 
        External]]], "Request" -> <|"Loops" -> 0, "Incoming" -> {V[1], V[5]}, 
     "Outgoing" -> {F[3, {1}], -F[3, {1}]}, "IncomingMomenta" -> {q, p}, 
     "OutgoingMomenta" -> {k1, k2}|>, "InputHash" -> 110227263864432709188442\
049047360004727265580627867474025696680432420546554811|>, 
 "Real" -> <|"Diagrams" -> 
    TopologyList[Process -> {V[1], V[5, {Index[Gluon, 2]}]} -> 
        {F[3, {1, Index[Colour, 3]}], -F[3, {1, Index[Colour, 4]}], 
         V[5, {Index[Gluon, 5]}]}, Model -> {"SMQCD"}, 
      GenericModel -> {"Lorentz"}, InsertionLevel -> {Classes}, 
      ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], 
        -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], 
        -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], 
        S[3], -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], 
        -V[3], V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][7], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
         Field[6] -> F, Field[7] -> F] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> -F[3, {1, Index[Colour, 3]}], Field[7] -> 
           F[3, {1, Index[Colour, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][7], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
         Field[6] -> F, Field[7] -> V] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> -F[3, {1, Index[Colour, 3]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
         Field[6] -> F, Field[7] -> F] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> -F[3, {1, Index[Colour, 3]}], Field[7] -> 
           -F[3, {1, Index[Colour, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
         Field[6] -> F, Field[7] -> F] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> F[3, {1, Index[Colour, 4]}], Field[7] -> 
           -F[3, {1, Index[Colour, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
         Field[6] -> F, Field[7] -> F] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> F[3, {1, Index[Colour, 6]}], Field[7] -> 
           -F[3, {1, Index[Colour, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][8], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][7], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
         Field[6] -> F, Field[7] -> V] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> F[3, {1, Index[Colour, 4]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][8], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
         Field[6] -> F, Field[7] -> F] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> F[3, {1, Index[Colour, 4]}], Field[7] -> 
           F[3, {1, Index[Colour, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][8], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][7], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
         Field[6] -> F, Field[7] -> F] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> -F[3, {1, Index[Colour, 6]}], Field[7] -> 
           F[3, {1, Index[Colour, 6]}]]]]], 
   "Raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, 
          {}}, {V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 0, 
          {Sqrt[3]*ColorCharge}}} -> {{F[3, {1, Index[Colour, 3]}], 
          FourMomentum[Outgoing, 1], FCGV["MU"], {(2*Charge)/3, 
           (2*ColorCharge)/Sqrt[3]}}, {-F[3, {1, Index[Colour, 4]}], 
          FourMomentum[Outgoing, 2], FCGV["MU"], {(-2*Charge)/3, 
           (-2*ColorCharge)/Sqrt[3]}}, {V[5, {Index[Gluon, 5]}], 
          FourMomentum[Outgoing, 3], 0, {Sqrt[3]*ColorCharge}}}, 
      Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
      AmplitudeLevel -> {Classes}, ExcludeParticles -> 
       {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], -F[1, {2}], 
        F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], 
        F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], -U[1], 
        U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
        V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 1], Integral[], FAPolarizationVector[V[1], 
        FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
       FAPolarizationVector[V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 
         2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2], FCGV["MU"]]*
       FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
         FourMomentum[Outgoing, 2] + FourMomentum[Outgoing, 3], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 2] - 
            FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
           Index[Colour, 3], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
             2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 2], Index[Colour, 6], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 6], 
           Index[Colour, 4]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 6], 
        3]*SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 
        3, External]*SumOver[Index[Gluon, 2], 8, External]*
       SumOver[Index[Gluon, 5], 8, External]*Conjugate[FAPolarizationVector][
        V[5, {Index[Gluon, 5]}], FourMomentum[Outgoing, 3], 
        Index[Lorentz, 3]]], FAFeynAmp[GraphID[Topology == 1, Generic == 1, 
       Classes == 1, Number == 2], Integral[], 
      -(FAGS*(FAFourVector[-FourMomentum[Incoming, 2] - FourMomentum[
             Outgoing, 3], Index[Lorentz, 4]]*FAMetricTensor[
           Index[Lorentz, 2], Index[Lorentz, 3]] + 
         FAFourVector[2*FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
             3], Index[Lorentz, 3]]*FAMetricTensor[Index[Lorentz, 2], 
           Index[Lorentz, 4]] + FAFourVector[-FourMomentum[Incoming, 2] + 
            2*FourMomentum[Outgoing, 3], Index[Lorentz, 2]]*
          FAMetricTensor[Index[Lorentz, 3], Index[Lorentz, 4]])*
        FAMetricTensor[Index[Lorentz, 4], Index[Lorentz, 5]]*
        FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
         Index[Lorentz, 1]]*FAPolarizationVector[V[5, {Index[Gluon, 2]}], 
         FourMomentum[Incoming, 2], Index[Lorentz, 2]]*
        FAPropagatorDenominator[FourMomentum[Incoming, 2] - 
          FourMomentum[Outgoing, 3], 0]*FAPropagatorDenominator[
         -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2] + 
          FourMomentum[Outgoing, 3], FCGV["MU"]]*FASUNF[Index[Gluon, 2], 
         Index[Gluon, 5], Index[Gluon, 6]]*FermionChain[
         FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
           FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
          ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
              2] - FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 5]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 4]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 5]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 4]], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 2], FCGV["MU"]]]]*
        SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 3], 3, External]*
        SumOver[Index[Colour, 4], 3, External]*SumOver[Index[Gluon, 2], 8, 
         External]*SumOver[Index[Gluon, 5], 8, External]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 5]}], 
         FourMomentum[Outgoing, 3], Index[Lorentz, 3]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 3], Integral[], FAPolarizationVector[V[1], 
        FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
       FAPolarizationVector[V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 
         2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        FourMomentum[Outgoing, 2] + FourMomentum[Outgoing, 3], FCGV["MU"]]*
       FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
         FourMomentum[Outgoing, 2] + FourMomentum[Outgoing, 3], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 2] - 
            FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 2], 
           Index[Colour, 3], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 3], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[-FourMomentum[Outgoing, 2] - FourMomentum[Outgoing, 
             3]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 6], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 6], 
           Index[Colour, 4]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 6], 
        3]*SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 
        3, External]*SumOver[Index[Gluon, 2], 8, External]*
       SumOver[Index[Gluon, 5], 8, External]*Conjugate[FAPolarizationVector][
        V[5, {Index[Gluon, 5]}], FourMomentum[Outgoing, 3], 
        Index[Lorentz, 3]]], FAFeynAmp[GraphID[Topology == 1, Generic == 1, 
       Classes == 1, Number == 4], Integral[], 
      FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
        Index[Lorentz, 1]]*FAPolarizationVector[V[5, {Index[Gluon, 2]}], 
        FourMomentum[Incoming, 2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], FCGV["MU"]]*
       FAPropagatorDenominator[FourMomentum[Incoming, 2] - 
         FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 3], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 2], Index[Colour, 3], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 3], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
             1]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 6], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 6], 
           Index[Colour, 4]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
             1] + FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
        ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSpinor[-FourMomentum[Outgoing, 2], FCGV["MU"]]]]*
       SumOver[Index[Colour, 6], 3]*SumOver[Index[Colour, 3], 3, External]*
       SumOver[Index[Colour, 4], 3, External]*SumOver[Index[Gluon, 2], 8, 
        External]*SumOver[Index[Gluon, 5], 8, External]*
       Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 5]}], 
        FourMomentum[Outgoing, 3], Index[Lorentz, 3]]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 5], Integral[], FAPolarizationVector[V[1], 
        FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
       FAPolarizationVector[V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 
         2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], FCGV["MU"]]*
       FAPropagatorDenominator[FourMomentum[Outgoing, 2] + 
         FourMomentum[Outgoing, 3], FCGV["MU"]]*FermionChain[
        FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 2], Index[Colour, 3], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 3], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
             1]] + FCGV["MU"]], ((-2*I)/3)*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
          FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
        FANonCommutative[FADiracSlash[-FourMomentum[Outgoing, 2] - 
            FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
           Index[Colour, 6], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 6], 
           Index[Colour, 4]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 6], 
        3]*SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 
        3, External]*SumOver[Index[Gluon, 2], 8, External]*
       SumOver[Index[Gluon, 5], 8, External]*Conjugate[FAPolarizationVector][
        V[5, {Index[Gluon, 5]}], FourMomentum[Outgoing, 3], 
        Index[Lorentz, 3]]], FAFeynAmp[GraphID[Topology == 1, Generic == 1, 
       Classes == 1, Number == 6], Integral[], 
      -(FAGS*(FAFourVector[-FourMomentum[Incoming, 2] - FourMomentum[
             Outgoing, 3], Index[Lorentz, 4]]*FAMetricTensor[
           Index[Lorentz, 2], Index[Lorentz, 3]] + 
         FAFourVector[2*FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
             3], Index[Lorentz, 3]]*FAMetricTensor[Index[Lorentz, 2], 
           Index[Lorentz, 4]] + FAFourVector[-FourMomentum[Incoming, 2] + 
            2*FourMomentum[Outgoing, 3], Index[Lorentz, 2]]*
          FAMetricTensor[Index[Lorentz, 3], Index[Lorentz, 4]])*
        FAMetricTensor[Index[Lorentz, 4], Index[Lorentz, 5]]*
        FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
         Index[Lorentz, 1]]*FAPolarizationVector[V[5, {Index[Gluon, 2]}], 
         FourMomentum[Incoming, 2], Index[Lorentz, 2]]*
        FAPropagatorDenominator[FourMomentum[Incoming, 2] - 
          FourMomentum[Outgoing, 3], 0]*FAPropagatorDenominator[
         FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1] - 
          FourMomentum[Outgoing, 3], FCGV["MU"]]*FASUNF[Index[Gluon, 2], 
         Index[Gluon, 5], Index[Gluon, 6]]*FermionChain[
         FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
           FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 5]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 3], Index[Colour, 4]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 5]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 4]], FANonCommutative[
          FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
              1] + FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
         ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[-1]]*FCGV["EL"] - ((2*I)/3)*
           FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 2], FCGV["MU"]]]]*
        SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 3], 3, External]*
        SumOver[Index[Colour, 4], 3, External]*SumOver[Index[Gluon, 2], 8, 
         External]*SumOver[Index[Gluon, 5], 8, External]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 5]}], 
         FourMomentum[Outgoing, 3], Index[Lorentz, 3]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 7], Integral[], FAPolarizationVector[V[1], 
        FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
       FAPolarizationVector[V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 
         2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 3], FCGV["MU"]]*
       FAPropagatorDenominator[FourMomentum[Incoming, 2] - 
         FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 3], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
             3]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 2], Index[Colour, 6], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 6], 
           Index[Colour, 4]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
             1] + FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
        ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSpinor[-FourMomentum[Outgoing, 2], FCGV["MU"]]]]*
       SumOver[Index[Colour, 6], 3]*SumOver[Index[Colour, 3], 3, External]*
       SumOver[Index[Colour, 4], 3, External]*SumOver[Index[Gluon, 2], 8, 
        External]*SumOver[Index[Gluon, 5], 8, External]*
       Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 5]}], 
        FourMomentum[Outgoing, 3], Index[Lorentz, 3]]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 8], Integral[], FAPolarizationVector[V[1], 
        FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
       FAPolarizationVector[V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 
         2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2], FCGV["MU"]]*
       FAPropagatorDenominator[-FourMomentum[Outgoing, 1] - 
         FourMomentum[Outgoing, 3], FCGV["MU"]]*FermionChain[
        FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
             3]] + FCGV["MU"]], ((-2*I)/3)*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
          FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
        FANonCommutative[FADiracSlash[FourMomentum[Incoming, 2] - 
            FourMomentum[Outgoing, 2]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 2], 
           Index[Colour, 6], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 6], 
           Index[Colour, 4]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 6], 
        3]*SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 
        3, External]*SumOver[Index[Gluon, 2], 8, External]*
       SumOver[Index[Gluon, 5], 8, External]*Conjugate[FAPolarizationVector][
        V[5, {Index[Gluon, 5]}], FourMomentum[Outgoing, 3], 
        Index[Lorentz, 3]]]], "Request" -> <|"Loops" -> 0, 
     "Incoming" -> {V[1], V[5]}, "Outgoing" -> {F[3, {1}], -F[3, {1}], V[5]}, 
     "IncomingMomenta" -> {q, p}, "OutgoingMomenta" -> {k1, k2, k3}|>, 
   "InputHash" -> 50752216767066263921436796536416408957605953297964646151516\
8590044042516833|>, "Virtual" -> 
  <|"Diagrams" -> TopologyList[Process -> {V[1], V[5, {Index[Gluon, 2]}]} -> 
        {F[3, {1, Index[Colour, 3]}], -F[3, {1, Index[Colour, 4]}]}, 
      Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
      InsertionLevel -> {Classes}, ExcludeParticles -> 
       {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], -F[1, {2}], 
        F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], 
        F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], -U[1], 
        U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
        V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][5], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][7], Field[4]], 
       Propagator[Internal][Vertex[3][5], Vertex[3][8], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> F, Field[6] -> F, 
         Field[7] -> F, Field[8] -> V] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> 
           -F[3, {1, Index[Colour, 3]}], Field[6] -> 
           -F[3, {1, Index[Colour, 5]}], Field[7] -> 
           F[3, {1, Index[Colour, 6]}], Field[8] -> 
           V[5, {Index[Gluon, 5]}]]], FeynmanGraph[1, Generic == 2][
         Field[1] -> V[1], Field[2] -> V[5, {Index[Gluon, 2]}], 
         Field[3] -> -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> F, Field[6] -> V, 
         Field[7] -> V, Field[8] -> F] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> 
           -F[3, {1, Index[Colour, 3]}], Field[6] -> V[5, {Index[Gluon, 5]}], 
          Field[7] -> V[5, {Index[Gluon, 6]}], Field[8] -> 
           F[3, {1, Index[Colour, 5]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][7], Field[4]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][7], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> F, Field[6] -> F, 
         Field[7] -> F, Field[8] -> V] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> 
           -F[3, {1, Index[Colour, 5]}], Field[6] -> 
           -F[3, {1, Index[Colour, 6]}], Field[7] -> 
           F[3, {1, Index[Colour, 6]}], Field[8] -> 
           V[5, {Index[Gluon, 5]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][5], Field[4]], 
       Propagator[Internal][Vertex[3][5], Vertex[3][8], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> F, Field[6] -> F, 
         Field[7] -> F, Field[8] -> V] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 4]}], Field[6] -> 
           F[3, {1, Index[Colour, 5]}], Field[7] -> 
           -F[3, {1, Index[Colour, 6]}], Field[8] -> 
           V[5, {Index[Gluon, 5]}]]], FeynmanGraph[1, Generic == 2][
         Field[1] -> V[1], Field[2] -> V[5, {Index[Gluon, 2]}], 
         Field[3] -> -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> F, Field[6] -> V, 
         Field[7] -> V, Field[8] -> F] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 4]}], Field[6] -> V[5, {Index[Gluon, 5]}], 
          Field[7] -> V[5, {Index[Gluon, 6]}], Field[8] -> 
           -F[3, {1, Index[Colour, 5]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][7], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> F, Field[6] -> F, 
         Field[7] -> F, Field[8] -> V] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 5]}], Field[6] -> 
           F[3, {1, Index[Colour, 6]}], Field[7] -> 
           -F[3, {1, Index[Colour, 6]}], Field[8] -> 
           V[5, {Index[Gluon, 5]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][7], Field[4]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][6], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> V, Field[6] -> F, 
         Field[7] -> F, Field[8] -> F] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> -F[3, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[7] -> F[3, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[8] -> -F[3, {Index[Generation, 5], Index[Colour, 6]}]], 
         FeynmanGraph[1, Classes == 2][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> F[3, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[7] -> -F[3, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[8] -> F[3, {Index[Generation, 5], Index[Colour, 6]}]], 
         FeynmanGraph[1, Classes == 3][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> -F[4, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[7] -> F[4, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[8] -> -F[4, {Index[Generation, 5], Index[Colour, 6]}]], 
         FeynmanGraph[1, Classes == 4][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> F[4, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[7] -> -F[4, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[8] -> F[4, {Index[Generation, 5], Index[Colour, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][6], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][7], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> F, Field[6] -> F, 
         Field[7] -> F, Field[8] -> V] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> 
           -F[3, {1, Index[Colour, 5]}], Field[6] -> 
           F[3, {1, Index[Colour, 5]}], Field[7] -> 
           -F[3, {1, Index[Colour, 6]}], Field[8] -> 
           V[5, {Index[Gluon, 5]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][6], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][8], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][7], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> F, Field[6] -> F, 
         Field[7] -> F, Field[8] -> V] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 5]}], Field[6] -> 
           -F[3, {1, Index[Colour, 5]}], Field[7] -> 
           F[3, {1, Index[Colour, 6]}], Field[8] -> 
           V[5, {Index[Gluon, 5]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][7], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][8], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][7], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> F, Field[6] -> F, 
         Field[7] -> V, Field[8] -> V] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 5]}], Field[6] -> 
           -F[3, {1, Index[Colour, 5]}], Field[7] -> V[5, {Index[Gluon, 5]}], 
          Field[8] -> V[5, {Index[Gluon, 6]}]]]], 
     Topology[2][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][5], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Internal][Vertex[3][5], Vertex[3][7], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> F, Field[6] -> F, 
         Field[7] -> F, Field[8] -> V] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> 
           -F[3, {1, Index[Colour, 3]}], Field[6] -> 
           F[3, {1, Index[Colour, 5]}], Field[7] -> 
           -F[3, {1, Index[Colour, 6]}], Field[8] -> 
           V[5, {Index[Gluon, 5]}]]]], 
     Topology[2][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][5], Field[4]], 
       Propagator[Internal][Vertex[3][5], Vertex[3][7], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          F[3, {1, Index[Colour, 4]}], Field[5] -> F, Field[6] -> F, 
         Field[7] -> F, Field[8] -> V] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 4]}], Field[6] -> 
           -F[3, {1, Index[Colour, 5]}], Field[7] -> 
           F[3, {1, Index[Colour, 6]}], Field[8] -> 
           V[5, {Index[Gluon, 5]}]]]]], 
   "Raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, 
          {}}, {V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 0, 
          {Sqrt[3]*ColorCharge}}} -> {{F[3, {1, Index[Colour, 3]}], 
          FourMomentum[Outgoing, 1], FCGV["MU"], {(2*Charge)/3, 
           (2*ColorCharge)/Sqrt[3]}}, {-F[3, {1, Index[Colour, 4]}], 
          FourMomentum[Outgoing, 2], FCGV["MU"], {(-2*Charge)/3, 
           (-2*ColorCharge)/Sqrt[3]}}}, Model -> {"SMQCD"}, 
      GenericModel -> {"Lorentz"}, AmplitudeLevel -> {Classes}, 
      ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], 
        -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], 
        -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], 
        S[3], -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], 
        -V[3], V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 1], Integral[FourMomentum[Internal, 1]], 
      FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 1], 
         FCGV["MU"]], FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
          FourMomentum[Internal, 1], FCGV["MU"]], FAPropagatorDenominator[
         FourMomentum[Internal, 1] - FourMomentum[Outgoing, 2], 0]]*
       FAMetricTensor[Index[Lorentz, 3], Index[Lorentz, 4]]*
       FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
        Index[Lorentz, 1]]*FAPolarizationVector[V[5, {Index[Gluon, 2]}], 
        FourMomentum[Incoming, 2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
             2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 4]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Internal, 
             1]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 2], Index[Colour, 6], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 6], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[-FourMomentum[Internal, 1]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
           Index[Colour, 5], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 5], 
           Index[Colour, 4]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 5], 
        3]*SumOver[Index[Colour, 6], 3]*SumOver[Index[Gluon, 5], 8]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
        External]*SumOver[Index[Gluon, 2], 8, External]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 2, Classes == 1, 
       Number == 2], Integral[FourMomentum[Internal, 1]], 
      -(FAGS*FAFeynAmpDenominator[FAPropagatorDenominator[
          FourMomentum[Internal, 1], 0], FAPropagatorDenominator[
          -FourMomentum[Incoming, 2] + FourMomentum[Internal, 1], 0], 
         FAPropagatorDenominator[FourMomentum[Internal, 1] - 
           FourMomentum[Outgoing, 2], FCGV["MU"]]]*FAMetricTensor[
         Index[Lorentz, 3], Index[Lorentz, 4]]*
        (FAFourVector[-FourMomentum[Incoming, 2] - FourMomentum[Internal, 1], 
           Index[Lorentz, 5]]*FAMetricTensor[Index[Lorentz, 2], 
           Index[Lorentz, 3]] + FAFourVector[2*FourMomentum[Incoming, 2] - 
            FourMomentum[Internal, 1], Index[Lorentz, 3]]*
          FAMetricTensor[Index[Lorentz, 2], Index[Lorentz, 5]] + 
         FAFourVector[-FourMomentum[Incoming, 2] + 2*FourMomentum[Internal, 
              1], Index[Lorentz, 2]]*FAMetricTensor[Index[Lorentz, 3], 
           Index[Lorentz, 5]])*FAMetricTensor[Index[Lorentz, 5], 
         Index[Lorentz, 6]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPolarizationVector[
         V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 
         Index[Lorentz, 2]]*FAPropagatorDenominator[
         -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2], FCGV["MU"]]*
        FASUNF[Index[Gluon, 2], Index[Gluon, 5], Index[Gluon, 6]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
          ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 6]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 3], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 6]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[FourMomentum[Internal, 1] - FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 4]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 5], Index[Colour, 4]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 5], Index[Colour, 4]], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 5], 3]*SumOver[Index[Gluon, 5], 8]*
        SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 3], 3, External]*
        SumOver[Index[Colour, 4], 3, External]*SumOver[Index[Gluon, 2], 8, 
         External])], FAFeynAmp[GraphID[Topology == 1, Generic == 1, 
       Classes == 1, Number == 3], Integral[FourMomentum[Internal, 1]], 
      FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 1], 
         FCGV["MU"]], FAPropagatorDenominator[FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 2], 0], FAPropagatorDenominator[
         FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], FCGV["MU"]]]*
       FAMetricTensor[Index[Lorentz, 3], Index[Lorentz, 4]]*
       FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
        Index[Lorentz, 1]]*FAPolarizationVector[V[5, {Index[Gluon, 2]}], 
        FourMomentum[Incoming, 2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 2], Index[Colour, 3], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 3], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
             1]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 4]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 5], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 5], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] - FourMomentum[Internal, 
             1] + FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 2]] + 
          FCGV["MU"]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[-FourMomentum[Internal, 1]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
           Index[Colour, 6], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 6], 
           Index[Colour, 4]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 5], 
        3]*SumOver[Index[Colour, 6], 3]*SumOver[Index[Gluon, 5], 8]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
        External]*SumOver[Index[Gluon, 2], 8, External]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 4], Integral[FourMomentum[Internal, 1]], 
      FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 1], 
         FCGV["MU"]], FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
          FourMomentum[Internal, 1], FCGV["MU"]], FAPropagatorDenominator[
         FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1], 0]]*
       FAMetricTensor[Index[Lorentz, 3], Index[Lorentz, 4]]*
       FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
        Index[Lorentz, 1]]*FAPolarizationVector[V[5, {Index[Gluon, 2]}], 
        FourMomentum[Incoming, 2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[FourMomentum[Internal, 1]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 2], 
           Index[Colour, 5], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 5], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Internal, 
             1]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 4]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 6], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 6], 
           Index[Colour, 4]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
             1]] + FCGV["MU"]], ((-2*I)/3)*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
          FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
        FANonCommutative[FADiracSpinor[-FourMomentum[Outgoing, 2], 
          FCGV["MU"]]]]*SumOver[Index[Colour, 5], 3]*
       SumOver[Index[Colour, 6], 3]*SumOver[Index[Gluon, 5], 8]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
        External]*SumOver[Index[Gluon, 2], 8, External]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 2, Classes == 1, 
       Number == 5], Integral[FourMomentum[Internal, 1]], 
      -(FAGS*FAFeynAmpDenominator[FAPropagatorDenominator[
          FourMomentum[Internal, 1], 0], FAPropagatorDenominator[
          -FourMomentum[Incoming, 2] + FourMomentum[Internal, 1], 0], 
         FAPropagatorDenominator[FourMomentum[Internal, 1] - 
           FourMomentum[Outgoing, 1], FCGV["MU"]]]*FAMetricTensor[
         Index[Lorentz, 3], Index[Lorentz, 4]]*
        (FAFourVector[-FourMomentum[Incoming, 2] - FourMomentum[Internal, 1], 
           Index[Lorentz, 5]]*FAMetricTensor[Index[Lorentz, 2], 
           Index[Lorentz, 3]] + FAFourVector[2*FourMomentum[Incoming, 2] - 
            FourMomentum[Internal, 1], Index[Lorentz, 3]]*
          FAMetricTensor[Index[Lorentz, 2], Index[Lorentz, 5]] + 
         FAFourVector[-FourMomentum[Incoming, 2] + 2*FourMomentum[Internal, 
              1], Index[Lorentz, 2]]*FAMetricTensor[Index[Lorentz, 3], 
           Index[Lorentz, 5]])*FAMetricTensor[Index[Lorentz, 5], 
         Index[Lorentz, 6]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPolarizationVector[
         V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 
         Index[Lorentz, 2]]*FAPropagatorDenominator[
         FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], FCGV["MU"]]*
        FASUNF[Index[Gluon, 2], Index[Gluon, 5], Index[Gluon, 6]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 4]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[-FourMomentum[Internal, 1] + FourMomentum[Outgoing, 
              1]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 6]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 5], Index[Colour, 4]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 6]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 5], Index[Colour, 4]], FANonCommutative[
          FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
              1]] + FCGV["MU"]], ((-2*I)/3)*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
           FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
         FANonCommutative[FADiracSpinor[-FourMomentum[Outgoing, 2], 
           FCGV["MU"]]]]*SumOver[Index[Colour, 5], 3]*
        SumOver[Index[Gluon, 5], 8]*SumOver[Index[Gluon, 6], 8]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
         External]*SumOver[Index[Gluon, 2], 8, External])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 6], Integral[FourMomentum[Internal, 1]], 
      FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 1], 
         FCGV["MU"]], FAPropagatorDenominator[FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 1], 0], FAPropagatorDenominator[
         FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], FCGV["MU"]]]*
       FAMetricTensor[Index[Lorentz, 3], Index[Lorentz, 4]]*
       FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
        Index[Lorentz, 1]]*FAPolarizationVector[V[5, {Index[Gluon, 2]}], 
        FourMomentum[Incoming, 2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[FourMomentum[Internal, 1]] + FCGV["MU"]], 
        ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
            FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2]] + 
          FCGV["MU"]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 4]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 6], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 6], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
             2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 2], Index[Colour, 5], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 5], 
           Index[Colour, 4]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 5], 
        3]*SumOver[Index[Colour, 6], 3]*SumOver[Index[Gluon, 5], 8]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
        External]*SumOver[Index[Gluon, 2], 8, External]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 7], Integral[FourMomentum[Internal, 1]], 
      -(FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 
           1], MQU[Index[Generation, 5]]], FAPropagatorDenominator[
          FourMomentum[Incoming, 2] + FourMomentum[Internal, 1], 
          MQU[Index[Generation, 5]]], FAPropagatorDenominator[
          FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
           FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], 
          MQU[Index[Generation, 5]]]]*FAMetricTensor[Index[Lorentz, 3], 
         Index[Lorentz, 4]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPolarizationVector[
         V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 
         Index[Lorentz, 2]]*FAPropagatorDenominator[
         -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], 0]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 4]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 4]], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 2], FCGV["MU"]]]]*
        MatrixTrace[FANonCommutative[FADiracSlash[FourMomentum[Incoming, 2] + 
             FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
             FourMomentum[Outgoing, 2]] + MQU[Index[Generation, 5]]], 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 5]] + 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] + FourMomentum[Internal, 
              1]] + MQU[Index[Generation, 5]]], 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 2], 
            Index[Colour, 5], Index[Colour, 6]] + 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], 
            Index[Colour, 5], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Internal, 1]] + 
           MQU[Index[Generation, 5]]], ((2*I)/3)*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
           FCGV["EL"] + ((2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"]]*
        SumOver[Index[Colour, 5], 3]*SumOver[Index[Colour, 6], 3]*
        SumOver[Index[Generation, 5], 3]*SumOver[Index[Gluon, 5], 8]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
         External]*SumOver[Index[Gluon, 2], 8, External])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 2, 
       Number == 8], Integral[FourMomentum[Internal, 1]], 
      -(FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 
           1], MQU[Index[Generation, 5]]], FAPropagatorDenominator[
          FourMomentum[Incoming, 2] + FourMomentum[Internal, 1], 
          MQU[Index[Generation, 5]]], FAPropagatorDenominator[
          FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
           FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], 
          MQU[Index[Generation, 5]]]]*FAMetricTensor[Index[Lorentz, 3], 
         Index[Lorentz, 4]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPolarizationVector[
         V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 
         Index[Lorentz, 2]]*FAPropagatorDenominator[
         -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], 0]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 4]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 4]], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 2], FCGV["MU"]]]]*
        MatrixTrace[FANonCommutative[FADiracSlash[FourMomentum[Incoming, 2] + 
             FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
             FourMomentum[Outgoing, 2]] + MQU[Index[Generation, 5]]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 5], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 5], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] + FourMomentum[Internal, 
              1]] + MQU[Index[Generation, 5]]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 2], 
            Index[Colour, 6], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], 
            Index[Colour, 6], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[FourMomentum[Internal, 1]] + 
           MQU[Index[Generation, 5]]], ((-2*I)/3)*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
           FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"]]*
        SumOver[Index[Colour, 5], 3]*SumOver[Index[Colour, 6], 3]*
        SumOver[Index[Generation, 5], 3]*SumOver[Index[Gluon, 5], 8]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
         External]*SumOver[Index[Gluon, 2], 8, External])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 3, 
       Number == 9], Integral[FourMomentum[Internal, 1]], 
      -(FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 
           1], MQD[Index[Generation, 5]]], FAPropagatorDenominator[
          FourMomentum[Incoming, 2] + FourMomentum[Internal, 1], 
          MQD[Index[Generation, 5]]], FAPropagatorDenominator[
          FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
           FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], 
          MQD[Index[Generation, 5]]]]*FAMetricTensor[Index[Lorentz, 3], 
         Index[Lorentz, 4]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPolarizationVector[
         V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 
         Index[Lorentz, 2]]*FAPropagatorDenominator[
         -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], 0]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 4]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 4]], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 2], FCGV["MU"]]]]*
        MatrixTrace[FANonCommutative[FADiracSlash[FourMomentum[Incoming, 2] + 
             FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
             FourMomentum[Outgoing, 2]] + MQD[Index[Generation, 5]]], 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 5]] + 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] + FourMomentum[Internal, 
              1]] + MQD[Index[Generation, 5]]], 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 2], 
            Index[Colour, 5], Index[Colour, 6]] + 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], 
            Index[Colour, 5], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Internal, 1]] + 
           MQD[Index[Generation, 5]]], (-1/3*I)*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
           FCGV["EL"] - (I/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"]]*
        SumOver[Index[Colour, 5], 3]*SumOver[Index[Colour, 6], 3]*
        SumOver[Index[Generation, 5], 3]*SumOver[Index[Gluon, 5], 8]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
         External]*SumOver[Index[Gluon, 2], 8, External])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 4, 
       Number == 10], Integral[FourMomentum[Internal, 1]], 
      -(FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 
           1], MQD[Index[Generation, 5]]], FAPropagatorDenominator[
          FourMomentum[Incoming, 2] + FourMomentum[Internal, 1], 
          MQD[Index[Generation, 5]]], FAPropagatorDenominator[
          FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
           FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], 
          MQD[Index[Generation, 5]]]]*FAMetricTensor[Index[Lorentz, 3], 
         Index[Lorentz, 4]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPolarizationVector[
         V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 
         Index[Lorentz, 2]]*FAPropagatorDenominator[
         -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], 0]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 4]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 4]], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 2], FCGV["MU"]]]]*
        MatrixTrace[FANonCommutative[FADiracSlash[FourMomentum[Incoming, 2] + 
             FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
             FourMomentum[Outgoing, 2]] + MQD[Index[Generation, 5]]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 5], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 5], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] + FourMomentum[Internal, 
              1]] + MQD[Index[Generation, 5]]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 2], 
            Index[Colour, 6], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], 
            Index[Colour, 6], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[FourMomentum[Internal, 1]] + 
           MQD[Index[Generation, 5]]], 
         (I/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[-1]]*FCGV["EL"] + 
          (I/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"]]*SumOver[Index[Colour, 5], 3]*
        SumOver[Index[Colour, 6], 3]*SumOver[Index[Generation, 5], 3]*
        SumOver[Index[Gluon, 5], 8]*SumOver[Index[Colour, 3], 3, External]*
        SumOver[Index[Colour, 4], 3, External]*SumOver[Index[Gluon, 2], 8, 
         External])], FAFeynAmp[GraphID[Topology == 1, Generic == 1, 
       Classes == 1, Number == 11], Integral[FourMomentum[Internal, 1]], 
      FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 1], 
         FCGV["MU"]], FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
          FourMomentum[Internal, 1], FCGV["MU"]], FAPropagatorDenominator[
         FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 2], 0], FAPropagatorDenominator[
         FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], FCGV["MU"]]]*
       FAMetricTensor[Index[Lorentz, 3], Index[Lorentz, 4]]*
       FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
        Index[Lorentz, 1]]*FAPolarizationVector[V[5, {Index[Gluon, 2]}], 
        FourMomentum[Incoming, 2], Index[Lorentz, 2]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] - FourMomentum[Internal, 
             1] + FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 2]] + 
          FCGV["MU"]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[-FourMomentum[Internal, 1]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 2], 
           Index[Colour, 5], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 5], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] - FourMomentum[Internal, 
             1]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 4]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 6], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 6], 
           Index[Colour, 4]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 5], 
        3]*SumOver[Index[Colour, 6], 3]*SumOver[Index[Gluon, 5], 8]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
        External]*SumOver[Index[Gluon, 2], 8, External]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 12], Integral[FourMomentum[Internal, 1]], 
      FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 1], 
         FCGV["MU"]], FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
          FourMomentum[Internal, 1], FCGV["MU"]], FAPropagatorDenominator[
         FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 1], 0], FAPropagatorDenominator[
         FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], FCGV["MU"]]]*
       FAMetricTensor[Index[Lorentz, 3], Index[Lorentz, 4]]*
       FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
        Index[Lorentz, 1]]*FAPolarizationVector[V[5, {Index[Gluon, 2]}], 
        FourMomentum[Incoming, 2], Index[Lorentz, 2]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] + FourMomentum[Internal, 
             1]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 2], Index[Colour, 6], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 6], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[FourMomentum[Internal, 1]] + FCGV["MU"]], 
        ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
            FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2]] + 
          FCGV["MU"]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 4]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 5], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 5], 
           Index[Colour, 4]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 5], 
        3]*SumOver[Index[Colour, 6], 3]*SumOver[Index[Gluon, 5], 8]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
        External]*SumOver[Index[Gluon, 2], 8, External]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 13], Integral[FourMomentum[Internal, 1]], 
      -(FAGS*FAFeynAmpDenominator[FAPropagatorDenominator[
          FourMomentum[Internal, 1], FCGV["MU"]], FAPropagatorDenominator[
          FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1], 0], 
         FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
           FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1], 0], 
         FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
           FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
           FourMomentum[Outgoing, 2], FCGV["MU"]]]*FAMetricTensor[
         Index[Lorentz, 3], Index[Lorentz, 4]]*
        (FAFourVector[-FourMomentum[Incoming, 2] + FourMomentum[Internal, 
             1] - FourMomentum[Outgoing, 1], Index[Lorentz, 5]]*
          FAMetricTensor[Index[Lorentz, 2], Index[Lorentz, 3]] + 
         FAFourVector[2*FourMomentum[Incoming, 2] + FourMomentum[Internal, 
             1] - FourMomentum[Outgoing, 1], Index[Lorentz, 3]]*
          FAMetricTensor[Index[Lorentz, 2], Index[Lorentz, 5]] + 
         FAFourVector[-FourMomentum[Incoming, 2] - 2*FourMomentum[Internal, 
              1] + 2*FourMomentum[Outgoing, 1], Index[Lorentz, 2]]*
          FAMetricTensor[Index[Lorentz, 3], Index[Lorentz, 5]])*
        FAMetricTensor[Index[Lorentz, 5], Index[Lorentz, 6]]*
        FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
         Index[Lorentz, 1]]*FAPolarizationVector[V[5, {Index[Gluon, 2]}], 
         FourMomentum[Incoming, 2], Index[Lorentz, 2]]*
        FASUNF[Index[Gluon, 2], Index[Gluon, 5], Index[Gluon, 6]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 4]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[FourMomentum[Internal, 1]] + FCGV["MU"]], 
         ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[-1]]*FCGV["EL"] - ((2*I)/3)*
           FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] + FourMomentum[Internal, 
              1] - FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2]] + 
           FCGV["MU"]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 6]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 5], Index[Colour, 4]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 6]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 5], Index[Colour, 4]], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 5], 3]*SumOver[Index[Gluon, 5], 8]*
        SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 3], 3, External]*
        SumOver[Index[Colour, 4], 3, External]*SumOver[Index[Gluon, 2], 8, 
         External])], FAFeynAmp[GraphID[Topology == 1, Generic == 1, 
       Classes == 1, Number == 14], Integral[FourMomentum[Internal, 1]], 
      FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 1], 
         FCGV["MU"]], FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
          FourMomentum[Internal, 1] - FourMomentum[Outgoing, 2], 0]]*
       FAMetricTensor[Index[Lorentz, 3], Index[Lorentz, 4]]*
       FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
        Index[Lorentz, 1]]*FAPolarizationVector[V[5, {Index[Gluon, 2]}], 
        FourMomentum[Incoming, 2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2], FCGV["MU"], 
        2]*FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
           1], FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
             2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[-FourMomentum[Internal, 1]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
           Index[Colour, 6], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 6], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
             2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 2], Index[Colour, 5], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 5], 
           Index[Colour, 4]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 5], 
        3]*SumOver[Index[Colour, 6], 3]*SumOver[Index[Gluon, 5], 8]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
        External]*SumOver[Index[Gluon, 2], 8, External]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 15], Integral[FourMomentum[Internal, 1]], 
      FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 1], 
         FCGV["MU"]], FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
          FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1], 0]]*
       FAMetricTensor[Index[Lorentz, 3], Index[Lorentz, 4]]*
       FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
        Index[Lorentz, 1]]*FAPolarizationVector[V[5, {Index[Gluon, 2]}], 
        FourMomentum[Incoming, 2], Index[Lorentz, 2]]*FAPropagatorDenominator[
        FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], FCGV["MU"], 2]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 2], Index[Colour, 3], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 3], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
             1]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 4]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 5], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 5], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[FourMomentum[Internal, 1]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
           Index[Colour, 6], Index[Colour, 4]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 6], 
           Index[Colour, 4]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
             1]] + FCGV["MU"]], ((-2*I)/3)*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
          FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
        FANonCommutative[FADiracSpinor[-FourMomentum[Outgoing, 2], 
          FCGV["MU"]]]]*SumOver[Index[Colour, 5], 3]*
       SumOver[Index[Colour, 6], 3]*SumOver[Index[Gluon, 5], 8]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
        External]*SumOver[Index[Gluon, 2], 8, External]]], 
   "Request" -> <|"Loops" -> 1, "Incoming" -> {V[1], V[5]}, 
     "Outgoing" -> {F[3, {1}], -F[3, {1}]}, "IncomingMomenta" -> {q, p}, 
     "OutgoingMomenta" -> {k1, k2}|>, "InputHash" -> 103899141362631114740491\
042229218990237879789141359123759560121681215483263977|>, 
 "AuxHqqBorn" -> 
  <|"Diagrams" -> TopologyList[Process -> 
       {V[1], F[3, {1, Index[Colour, 2]}]} -> {F[3, {1, Index[Colour, 3]}], 
         V[5, {Index[Gluon, 4]}]}, Model -> {"SMQCD"}, 
      GenericModel -> {"Lorentz"}, InsertionLevel -> {Classes}, 
      ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], 
        -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], 
        -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], 
        S[3], -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], 
        -V[3], V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][5], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Internal][Vertex[3][5], Vertex[3][6], Field[5]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> F] -> Insertions[Classes][FeynmanGraph[1, Classes == 1][
          Field[1] -> V[1], Field[2] -> F[3, {1, Index[Colour, 2]}], 
          Field[3] -> -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           V[5, {Index[Gluon, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 2]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][5], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Internal][Vertex[3][5], Vertex[3][6], Field[5]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> F] -> Insertions[Classes][FeynmanGraph[1, Classes == 1][
          Field[1] -> V[1], Field[2] -> F[3, {1, Index[Colour, 2]}], 
          Field[3] -> -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           V[5, {Index[Gluon, 4]}], Field[5] -> 
           -F[3, {1, Index[Colour, 3]}]]]]], 
   "Raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, 
          {}}, {F[3, {1, Index[Colour, 2]}], FourMomentum[Incoming, 2], 
          FCGV["MU"], {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}} -> 
        {{F[3, {1, Index[Colour, 3]}], FourMomentum[Outgoing, 1], FCGV["MU"], 
          {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}, {V[5, {Index[Gluon, 4]}], 
          FourMomentum[Outgoing, 2], 0, {Sqrt[3]*ColorCharge}}}, 
      Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
      AmplitudeLevel -> {Classes}, ExcludeParticles -> 
       {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], -F[1, {2}], 
        F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], 
        F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], -U[1], 
        U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
        V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 1], Integral[], I*FAPolarizationVector[V[1], 
        FourMomentum[Incoming, 1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 4], Index[Colour, 3], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], Index[Colour, 3], 
           Index[Colour, 2]], FANonCommutative[
         FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
             2]] + FCGV["MU"]], ((-2*I)/3)*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
          FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
        FANonCommutative[FADiracSpinor[FourMomentum[Incoming, 2], 
          FCGV["MU"]]]]*SumOver[Index[Colour, 2], 3, External]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
        External]*Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
        FourMomentum[Outgoing, 2], Index[Lorentz, 2]]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 2], Integral[], I*FAPolarizationVector[V[1], 
        FourMomentum[Incoming, 1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
             2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 4], Index[Colour, 3], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], Index[Colour, 3], 
           Index[Colour, 2]], FANonCommutative[FADiracSpinor[
          FourMomentum[Incoming, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 2], 
        3, External]*SumOver[Index[Colour, 3], 3, External]*
       SumOver[Index[Gluon, 4], 8, External]*Conjugate[FAPolarizationVector][
        V[5, {Index[Gluon, 4]}], FourMomentum[Outgoing, 2], 
        Index[Lorentz, 2]]]], "Request" -> <|"Loops" -> 0, 
     "Incoming" -> {V[1], F[3, {1}]}, "Outgoing" -> {F[3, {1}], V[5]}, 
     "IncomingMomenta" -> {q, p}, "OutgoingMomenta" -> {k1, k2}|>, 
   "InputHash" -> 10147681528743167339006965382378633522152396264318691679624\
9818489339507835639|>, "ChargeVertex" -> 
  <|"Diagrams" -> TopologyList[Process -> {V[1]} -> 
        {F[3, {1, Index[Colour, 2]}], -F[3, {1, Index[Colour, 3]}]}, 
      Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
      InsertionLevel -> {Classes}, ExcludeParticles -> 
       {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], -F[1, {2}], 
        F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], 
        F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], -U[1], 
        U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
        V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][4], Field[1]], 
       Propagator[Outgoing][Vertex[1][2], Vertex[3][4], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][4], Field[3]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> -F[3, {1, Index[Colour, 2]}], Field[3] -> 
          F[3, {1, Index[Colour, 3]}]] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> -F[3, {1, Index[Colour, 2]}], Field[3] -> 
           F[3, {1, Index[Colour, 3]}]]]]], 
   "Raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, 
          {}}} -> {{F[3, {1, Index[Colour, 2]}], FourMomentum[Outgoing, 1], 
          FCGV["MU"], {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}, 
         {-F[3, {1, Index[Colour, 3]}], FourMomentum[Outgoing, 2], 
          FCGV["MU"], {(-2*Charge)/3, (-2*ColorCharge)/Sqrt[3]}}}, 
      Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
      AmplitudeLevel -> {Classes}, ExcludeParticles -> 
       {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], -F[1, {2}], 
        F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], 
        F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], -U[1], 
        U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
        V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 1], Integral[], -(FAPolarizationVector[V[1], 
         FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"]*
           IndexDelta[Index[Colour, 2], Index[Colour, 3]] - 
          ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"]*IndexDelta[Index[Colour, 2], 
            Index[Colour, 3]], FANonCommutative[FADiracSpinor[
           -FourMomentum[Outgoing, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 2], 3, External]*SumOver[Index[Colour, 3], 3, 
         External])]], "Request" -> <|"Loops" -> 0, "Incoming" -> {V[1]}, 
     "Outgoing" -> {F[3, {1}], -F[3, {1}]}, "IncomingMomenta" -> {q}, 
     "OutgoingMomenta" -> {k1, k2}|>, "InputHash" -> 593976620083347251514025\
80298825423834717923943279924514448775523032818664265|>|>
