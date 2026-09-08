<|"Born" -> <|"Diagrams" -> 
    TopologyList[Process -> {V[1], F[3, {1, Index[Colour, 2]}]} -> 
        {F[3, {1, Index[Colour, 3]}], V[5, {Index[Gluon, 4]}]}, 
      Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
      InsertionLevel -> {Classes}, ExcludeParticles -> 
       {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], -F[1, {2}], 
        F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], 
        F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], -U[1], 
        U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
        V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
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
   "InputHash" -> 23361479030541863387698816794937136703717005147161788790689\
570402254609921567|>, "RealQGG" -> 
  <|"Diagrams" -> TopologyList[Process -> 
       {V[1], F[3, {1, Index[Colour, 2]}]} -> {F[3, {1, Index[Colour, 3]}], 
         V[5, {Index[Gluon, 4]}], V[5, {Index[Gluon, 5]}]}, 
      Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
      InsertionLevel -> {Classes}, ExcludeParticles -> 
       {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], -F[1, {2}], 
        F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], 
        F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], -U[1], 
        U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
        V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][7], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> V[5, {Index[Gluon, 5]}], Field[6] -> F, 
         Field[7] -> F] -> Insertions[Classes][FeynmanGraph[1, Classes == 1][
          Field[1] -> V[1], Field[2] -> F[3, {1, Index[Colour, 2]}], 
          Field[3] -> -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           V[5, {Index[Gluon, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> F[3, {1, Index[Colour, 2]}], Field[7] -> 
           -F[3, {1, Index[Colour, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][7], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> V[5, {Index[Gluon, 5]}], Field[6] -> F, 
         Field[7] -> F] -> Insertions[Classes][FeynmanGraph[1, Classes == 1][
          Field[1] -> V[1], Field[2] -> F[3, {1, Index[Colour, 2]}], 
          Field[3] -> -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           V[5, {Index[Gluon, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> F[3, {1, Index[Colour, 2]}], Field[7] -> 
           -F[3, {1, Index[Colour, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> V[5, {Index[Gluon, 5]}], Field[6] -> F, 
         Field[7] -> V] -> Insertions[Classes][FeynmanGraph[1, Classes == 1][
          Field[1] -> V[1], Field[2] -> F[3, {1, Index[Colour, 2]}], 
          Field[3] -> -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           V[5, {Index[Gluon, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> F[3, {1, Index[Colour, 2]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][7], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> V[5, {Index[Gluon, 5]}], Field[6] -> F, 
         Field[7] -> F] -> Insertions[Classes][FeynmanGraph[1, Classes == 1][
          Field[1] -> V[1], Field[2] -> F[3, {1, Index[Colour, 2]}], 
          Field[3] -> -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           V[5, {Index[Gluon, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
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
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> V[5, {Index[Gluon, 5]}], Field[6] -> F, 
         Field[7] -> F] -> Insertions[Classes][FeynmanGraph[1, Classes == 1][
          Field[1] -> V[1], Field[2] -> F[3, {1, Index[Colour, 2]}], 
          Field[3] -> -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           V[5, {Index[Gluon, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> -F[3, {1, Index[Colour, 3]}], Field[7] -> 
           F[3, {1, Index[Colour, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> V[5, {Index[Gluon, 5]}], Field[6] -> F, 
         Field[7] -> V] -> Insertions[Classes][FeynmanGraph[1, Classes == 1][
          Field[1] -> V[1], Field[2] -> F[3, {1, Index[Colour, 2]}], 
          Field[3] -> -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           V[5, {Index[Gluon, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> -F[3, {1, Index[Colour, 3]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][8], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][7], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> V[5, {Index[Gluon, 5]}], Field[6] -> F, 
         Field[7] -> F] -> Insertions[Classes][FeynmanGraph[1, Classes == 1][
          Field[1] -> V[1], Field[2] -> F[3, {1, Index[Colour, 2]}], 
          Field[3] -> -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           V[5, {Index[Gluon, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> -F[3, {1, Index[Colour, 6]}], Field[7] -> 
           F[3, {1, Index[Colour, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][8], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][7], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> V[5, {Index[Gluon, 5]}], Field[6] -> F, 
         Field[7] -> F] -> Insertions[Classes][FeynmanGraph[1, Classes == 1][
          Field[1] -> V[1], Field[2] -> F[3, {1, Index[Colour, 2]}], 
          Field[3] -> -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           V[5, {Index[Gluon, 4]}], Field[5] -> V[5, {Index[Gluon, 5]}], 
          Field[6] -> -F[3, {1, Index[Colour, 6]}], Field[7] -> 
           F[3, {1, Index[Colour, 6]}]]]]], 
   "Raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, 
          {}}, {F[3, {1, Index[Colour, 2]}], FourMomentum[Incoming, 2], 
          FCGV["MU"], {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}} -> 
        {{F[3, {1, Index[Colour, 3]}], FourMomentum[Outgoing, 1], FCGV["MU"], 
          {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}, {V[5, {Index[Gluon, 4]}], 
          FourMomentum[Outgoing, 2], 0, {Sqrt[3]*ColorCharge}}, 
         {V[5, {Index[Gluon, 5]}], FourMomentum[Outgoing, 3], 0, 
          {Sqrt[3]*ColorCharge}}}, Model -> {"SMQCD"}, 
      GenericModel -> {"Lorentz"}, AmplitudeLevel -> {Classes}, 
      ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], 
        -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], 
        -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], 
        S[3], -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], 
        -V[3], V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 1], Integral[], -(FAPolarizationVector[V[1], 
         FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
        FAPropagatorDenominator[-FourMomentum[Outgoing, 1] - 
          FourMomentum[Outgoing, 2], FCGV["MU"]]*FAPropagatorDenominator[
         -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2] - 
          FourMomentum[Outgoing, 3], FCGV["MU"]]*FermionChain[
         FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
           FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 4], Index[Colour, 3], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 3], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 6], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 2]], FANonCommutative[
          FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
              2] + FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
         ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[-1]]*FCGV["EL"] - ((2*I)/3)*
           FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 6], 3]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
         External]*SumOver[Index[Gluon, 5], 8, External]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 5]}], 
         FourMomentum[Outgoing, 3], Index[Lorentz, 3]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 2], Integral[], -(FAPolarizationVector[V[1], 
         FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
        FAPropagatorDenominator[-FourMomentum[Outgoing, 1] - 
          FourMomentum[Outgoing, 3], FCGV["MU"]]*FAPropagatorDenominator[
         -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2] - 
          FourMomentum[Outgoing, 3], FCGV["MU"]]*FermionChain[
         FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
           FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
              3]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 4], Index[Colour, 6], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 6], Index[Colour, 2]], FANonCommutative[
          FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
              2] + FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
         ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[-1]]*FCGV["EL"] - ((2*I)/3)*
           FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 6], 3]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
         External]*SumOver[Index[Gluon, 5], 8, External]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 5]}], 
         FourMomentum[Outgoing, 3], Index[Lorentz, 3]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 3], Integral[], 
      FAGS*(FAFourVector[FourMomentum[Outgoing, 2] - FourMomentum[Outgoing, 
            3], Index[Lorentz, 5]]*FAMetricTensor[Index[Lorentz, 2], 
          Index[Lorentz, 3]] + FAFourVector[-2*FourMomentum[Outgoing, 2] - 
           FourMomentum[Outgoing, 3], Index[Lorentz, 3]]*
         FAMetricTensor[Index[Lorentz, 2], Index[Lorentz, 5]] + 
        FAFourVector[FourMomentum[Outgoing, 2] + 2*FourMomentum[Outgoing, 3], 
          Index[Lorentz, 2]]*FAMetricTensor[Index[Lorentz, 3], 
          Index[Lorentz, 5]])*FAMetricTensor[Index[Lorentz, 4], 
        Index[Lorentz, 5]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
         1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2] - 
         FourMomentum[Outgoing, 3], FCGV["MU"]]*FAPropagatorDenominator[
        FourMomentum[Outgoing, 2] + FourMomentum[Outgoing, 3], 0]*
       FASUNF[Index[Gluon, 4], Index[Gluon, 5], Index[Gluon, 6]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 4]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 6], Index[Colour, 3], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], Index[Colour, 3], 
           Index[Colour, 2]], FANonCommutative[
         FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 2] + 
            FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
        ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
       SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 2], 3, External]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
        External]*SumOver[Index[Gluon, 5], 8, External]*
       Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
        FourMomentum[Outgoing, 2], Index[Lorentz, 2]]*
       Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 5]}], 
        FourMomentum[Outgoing, 3], Index[Lorentz, 3]]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 4], Integral[], -(FAPolarizationVector[V[1], 
         FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
        FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
          FourMomentum[Outgoing, 2], FCGV["MU"]]*FAPropagatorDenominator[
         -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2] + 
          FourMomentum[Outgoing, 3], FCGV["MU"]]*FermionChain[
         FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
           FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
          ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
              2] - FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 4], Index[Colour, 6], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 6], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 6], 3]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
         External]*SumOver[Index[Gluon, 5], 8, External]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 5]}], 
         FourMomentum[Outgoing, 3], Index[Lorentz, 3]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 5], Integral[], -(FAPolarizationVector[V[1], 
         FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
        FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
          FourMomentum[Outgoing, 3], FCGV["MU"]]*FAPropagatorDenominator[
         -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2] + 
          FourMomentum[Outgoing, 3], FCGV["MU"]]*FermionChain[
         FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
           FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
          ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
              2] - FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 3], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 3], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
              3]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 6], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 6], 3]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
         External]*SumOver[Index[Gluon, 5], 8, External]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 5]}], 
         FourMomentum[Outgoing, 3], Index[Lorentz, 3]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 6], Integral[], 
      FAGS*(FAFourVector[FourMomentum[Outgoing, 2] - FourMomentum[Outgoing, 
            3], Index[Lorentz, 5]]*FAMetricTensor[Index[Lorentz, 2], 
          Index[Lorentz, 3]] + FAFourVector[-2*FourMomentum[Outgoing, 2] - 
           FourMomentum[Outgoing, 3], Index[Lorentz, 3]]*
         FAMetricTensor[Index[Lorentz, 2], Index[Lorentz, 5]] + 
        FAFourVector[FourMomentum[Outgoing, 2] + 2*FourMomentum[Outgoing, 3], 
          Index[Lorentz, 2]]*FAMetricTensor[Index[Lorentz, 3], 
          Index[Lorentz, 5]])*FAMetricTensor[Index[Lorentz, 4], 
        Index[Lorentz, 5]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
         1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        FourMomentum[Outgoing, 2] + FourMomentum[Outgoing, 3], 0]*
       FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
         FourMomentum[Outgoing, 2] + FourMomentum[Outgoing, 3], FCGV["MU"]]*
       FASUNF[Index[Gluon, 4], Index[Gluon, 5], Index[Gluon, 6]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 2] - 
            FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 6], 
           Index[Colour, 3], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], Index[Colour, 3], 
           Index[Colour, 2]], FANonCommutative[FADiracSpinor[
          FourMomentum[Incoming, 2], FCGV["MU"]]]]*SumOver[Index[Gluon, 6], 
        8]*SumOver[Index[Colour, 2], 3, External]*SumOver[Index[Colour, 3], 
        3, External]*SumOver[Index[Gluon, 4], 8, External]*
       SumOver[Index[Gluon, 5], 8, External]*Conjugate[FAPolarizationVector][
        V[5, {Index[Gluon, 4]}], FourMomentum[Outgoing, 2], 
        Index[Lorentz, 2]]*Conjugate[FAPolarizationVector][
        V[5, {Index[Gluon, 5]}], FourMomentum[Outgoing, 3], 
        Index[Lorentz, 3]]], FAFeynAmp[GraphID[Topology == 1, Generic == 1, 
       Classes == 1, Number == 7], Integral[], 
      -(FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
         Index[Lorentz, 1]]*FAPropagatorDenominator[
         -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2], FCGV["MU"]]*
        FAPropagatorDenominator[-FourMomentum[Outgoing, 1] - 
          FourMomentum[Outgoing, 3], FCGV["MU"]]*FermionChain[
         FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
           FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
              3]] + FCGV["MU"]], ((-2*I)/3)*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
           FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
         FANonCommutative[FADiracSlash[FourMomentum[Incoming, 2] - 
             FourMomentum[Outgoing, 2]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 6], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 6], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 6], 3]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
         External]*SumOver[Index[Gluon, 5], 8, External]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 5]}], 
         FourMomentum[Outgoing, 3], Index[Lorentz, 3]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 8], Integral[], -(FAPolarizationVector[V[1], 
         FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
        FAPropagatorDenominator[-FourMomentum[Outgoing, 1] - 
          FourMomentum[Outgoing, 2], FCGV["MU"]]*FAPropagatorDenominator[
         -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 3], FCGV["MU"]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 4], Index[Colour, 3], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 3], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], ((-2*I)/3)*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
           FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
         FANonCommutative[FADiracSlash[FourMomentum[Incoming, 2] - 
             FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 6], 3]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
         External]*SumOver[Index[Gluon, 5], 8, External]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 5]}], 
         FourMomentum[Outgoing, 3], Index[Lorentz, 3]])]], 
   "Request" -> <|"Loops" -> 0, "Incoming" -> {V[1], F[3, {1}]}, 
     "Outgoing" -> {F[3, {1}], V[5], V[5]}, "IncomingMomenta" -> {q, p}, 
     "OutgoingMomenta" -> {k1, k2, k3}|>, "InputHash" -> 20863470118964186655\
746963409078518037115906590765898129182450262112739647924|>, 
 "RealSame" -> <|"Diagrams" -> 
    TopologyList[Process -> {V[1], F[3, {1, Index[Colour, 2]}]} -> 
        {F[3, {1, Index[Colour, 3]}], F[3, {1, Index[Colour, 4]}], 
         -F[3, {1, Index[Colour, 5]}]}, Model -> {"SMQCD"}, 
      GenericModel -> {"Lorentz"}, InsertionLevel -> {Classes}, 
      ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], 
        -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], 
        -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], 
        S[3], -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], 
        -V[3], V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][7], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          -F[3, {1, Index[Colour, 4]}], Field[5] -> 
          F[3, {1, Index[Colour, 5]}], Field[6] -> F, Field[7] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           -F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 5]}], Field[6] -> 
           F[3, {1, Index[Colour, 2]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          -F[3, {1, Index[Colour, 4]}], Field[5] -> 
          F[3, {1, Index[Colour, 5]}], Field[6] -> F, Field[7] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           -F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 5]}], Field[6] -> 
           F[3, {1, Index[Colour, 2]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][7], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          -F[3, {1, Index[Colour, 4]}], Field[5] -> 
          F[3, {1, Index[Colour, 5]}], Field[6] -> F, Field[7] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           -F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 5]}], Field[6] -> 
           -F[3, {1, Index[Colour, 3]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          -F[3, {1, Index[Colour, 4]}], Field[5] -> 
          F[3, {1, Index[Colour, 5]}], Field[6] -> F, Field[7] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           -F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 5]}], Field[6] -> 
           -F[3, {1, Index[Colour, 3]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          -F[3, {1, Index[Colour, 4]}], Field[5] -> 
          F[3, {1, Index[Colour, 5]}], Field[6] -> F, Field[7] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           -F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 5]}], Field[6] -> 
           -F[3, {1, Index[Colour, 4]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][6], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          -F[3, {1, Index[Colour, 4]}], Field[5] -> 
          F[3, {1, Index[Colour, 5]}], Field[6] -> F, Field[7] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           -F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 5]}], Field[6] -> 
           F[3, {1, Index[Colour, 5]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][8], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          -F[3, {1, Index[Colour, 4]}], Field[5] -> 
          F[3, {1, Index[Colour, 5]}], Field[6] -> F, Field[7] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           -F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 5]}], Field[6] -> 
           -F[3, {1, Index[Colour, 4]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][8], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][7], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][6], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          -F[3, {1, Index[Colour, 4]}], Field[5] -> 
          F[3, {1, Index[Colour, 5]}], Field[6] -> F, Field[7] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           -F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 5]}], Field[6] -> 
           F[3, {1, Index[Colour, 5]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]]], 
   "Raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, 
          {}}, {F[3, {1, Index[Colour, 2]}], FourMomentum[Incoming, 2], 
          FCGV["MU"], {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}} -> 
        {{F[3, {1, Index[Colour, 3]}], FourMomentum[Outgoing, 1], FCGV["MU"], 
          {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}, 
         {F[3, {1, Index[Colour, 4]}], FourMomentum[Outgoing, 2], FCGV["MU"], 
          {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}, 
         {-F[3, {1, Index[Colour, 5]}], FourMomentum[Outgoing, 3], 
          FCGV["MU"], {(-2*Charge)/3, (-2*ColorCharge)/Sqrt[3]}}}, 
      Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
      AmplitudeLevel -> {Classes}, ExcludeParticles -> 
       {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], -F[1, {2}], 
        F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], 
        F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], -U[1], 
        U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
        V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 1], Integral[], FAMetricTensor[Index[Lorentz, 2], 
        Index[Lorentz, 3]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
         1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 3], 0]*
       FAPropagatorDenominator[-FourMomentum[Outgoing, 1] - 
         FourMomentum[Outgoing, 2] - FourMomentum[Outgoing, 3], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 6], Index[Colour, 3], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], Index[Colour, 3], 
           Index[Colour, 5]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 3], FCGV["MU"]]]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 2], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 6], Index[Colour, 4], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], Index[Colour, 4], 
           Index[Colour, 2]], FANonCommutative[
         FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 2] + 
            FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
        ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
       SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 2], 3, External]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
        External]*SumOver[Index[Colour, 5], 3, External]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 2], Integral[], -(FAMetricTensor[Index[Lorentz, 2], 
         Index[Lorentz, 3]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPropagatorDenominator[
         -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2] - 
          FourMomentum[Outgoing, 3], FCGV["MU"]]*FAPropagatorDenominator[
         FourMomentum[Outgoing, 2] + FourMomentum[Outgoing, 3], 0]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            2], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 4], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 4], Index[Colour, 5]], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 3], FCGV["MU"]]]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 3], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 2]], FANonCommutative[
          FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
              2] + FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
         ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[-1]]*FCGV["EL"] - ((2*I)/3)*
           FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
         External]*SumOver[Index[Colour, 5], 3, External])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 3], Integral[], FAMetricTensor[Index[Lorentz, 2], 
        Index[Lorentz, 3]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
         1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 2], 0]*
       FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
         FourMomentum[Outgoing, 2] + FourMomentum[Outgoing, 3], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 2], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 6], Index[Colour, 4], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], Index[Colour, 4], 
           Index[Colour, 2]], FANonCommutative[FADiracSpinor[
          FourMomentum[Incoming, 2], FCGV["MU"]]]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 2] - 
            FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 6], 
           Index[Colour, 3], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], Index[Colour, 3], 
           Index[Colour, 5]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 3], FCGV["MU"]]]]*SumOver[Index[Gluon, 6], 
        8]*SumOver[Index[Colour, 2], 3, External]*SumOver[Index[Colour, 3], 
        3, External]*SumOver[Index[Colour, 4], 3, External]*
       SumOver[Index[Colour, 5], 3, External]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 4], Integral[], -(FAMetricTensor[Index[Lorentz, 2], 
         Index[Lorentz, 3]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPropagatorDenominator[
         FourMomentum[Outgoing, 2] + FourMomentum[Outgoing, 3], 0]*
        FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
          FourMomentum[Outgoing, 2] + FourMomentum[Outgoing, 3], FCGV["MU"]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            2], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 4], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 4], Index[Colour, 5]], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 3], FCGV["MU"]]]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
          ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
              2] - FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
         External]*SumOver[Index[Colour, 5], 3, External])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 5], Integral[], -(FAMetricTensor[Index[Lorentz, 2], 
         Index[Lorentz, 3]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPropagatorDenominator[
         FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], 0]*
        FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
          FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 3], FCGV["MU"]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 3], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            2], FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
          ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
              1] - FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 4], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 4], Index[Colour, 5]], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 3], FCGV["MU"]]]]*
        SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
         External]*SumOver[Index[Colour, 5], 3, External])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 6], Integral[], -(FAMetricTensor[Index[Lorentz, 2], 
         Index[Lorentz, 3]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPropagatorDenominator[
         FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], 0]*
        FAPropagatorDenominator[FourMomentum[Incoming, 2] - 
          FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], FCGV["MU"]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 3], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            2], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 4], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 4], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
              1] + FourMomentum[Outgoing, 2]] + FCGV["MU"]], 
         ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[-1]]*FCGV["EL"] - ((2*I)/3)*
           FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 3], FCGV["MU"]]]]*
        SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
         External]*SumOver[Index[Colour, 5], 3, External])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 7], Integral[], FAMetricTensor[Index[Lorentz, 2], 
        Index[Lorentz, 3]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
         1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 3], 0]*
       FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
         FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 3], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 6], Index[Colour, 3], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], Index[Colour, 3], 
           Index[Colour, 5]], FANonCommutative[FADiracSpinor[
          -FourMomentum[Outgoing, 3], FCGV["MU"]]]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 2], 
          FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1] - 
            FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 6], 
           Index[Colour, 4], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], Index[Colour, 4], 
           Index[Colour, 2]], FANonCommutative[FADiracSpinor[
          FourMomentum[Incoming, 2], FCGV["MU"]]]]*SumOver[Index[Gluon, 6], 
        8]*SumOver[Index[Colour, 2], 3, External]*SumOver[Index[Colour, 3], 
        3, External]*SumOver[Index[Colour, 4], 3, External]*
       SumOver[Index[Colour, 5], 3, External]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 8], Integral[], FAMetricTensor[Index[Lorentz, 2], 
        Index[Lorentz, 3]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
         1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 2], 0]*
       FAPropagatorDenominator[FourMomentum[Incoming, 2] - 
         FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 2], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 6], Index[Colour, 4], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], Index[Colour, 4], 
           Index[Colour, 2]], FANonCommutative[FADiracSpinor[
          FourMomentum[Incoming, 2], FCGV["MU"]]]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 6], Index[Colour, 3], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], Index[Colour, 3], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
             1] + FourMomentum[Outgoing, 2]] + FCGV["MU"]], 
        ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSpinor[-FourMomentum[Outgoing, 3], FCGV["MU"]]]]*
       SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 2], 3, External]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
        External]*SumOver[Index[Colour, 5], 3, External]]], 
   "Request" -> <|"Loops" -> 0, "Incoming" -> {V[1], F[3, {1}]}, 
     "Outgoing" -> {F[3, {1}], F[3, {1}], -F[3, {1}]}, 
     "IncomingMomenta" -> {q, p}, "OutgoingMomenta" -> {k1, k2, k3}|>, 
   "InputHash" -> 11627609759017786203330451746948327118585012136763016234641\
442376317356248435|>, "RealDistinct" -> 
  <|"Diagrams" -> TopologyList[Process -> 
       {V[1], F[3, {1, Index[Colour, 2]}]} -> {F[3, {1, Index[Colour, 3]}], 
         F[3, {2, Index[Colour, 4]}], -F[3, {2, Index[Colour, 5]}]}, 
      Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
      InsertionLevel -> {Classes}, ExcludeParticles -> 
       {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], -F[1, {2}], 
        F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], 
        F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], -U[1], 
        U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
        V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          -F[3, {2, Index[Colour, 4]}], Field[5] -> 
          F[3, {2, Index[Colour, 5]}], Field[6] -> F, Field[7] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           -F[3, {2, Index[Colour, 4]}], Field[5] -> 
           F[3, {2, Index[Colour, 5]}], Field[6] -> 
           F[3, {1, Index[Colour, 2]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          -F[3, {2, Index[Colour, 4]}], Field[5] -> 
          F[3, {2, Index[Colour, 5]}], Field[6] -> F, Field[7] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           -F[3, {2, Index[Colour, 4]}], Field[5] -> 
           F[3, {2, Index[Colour, 5]}], Field[6] -> 
           -F[3, {1, Index[Colour, 3]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][8], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          -F[3, {2, Index[Colour, 4]}], Field[5] -> 
          F[3, {2, Index[Colour, 5]}], Field[6] -> F, Field[7] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           -F[3, {2, Index[Colour, 4]}], Field[5] -> 
           F[3, {2, Index[Colour, 5]}], Field[6] -> 
           -F[3, {2, Index[Colour, 4]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][6], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][7], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[Outgoing][Vertex[1][5], Vertex[3][6], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[Internal][Vertex[3][7], Vertex[3][8], Field[7]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> 
          -F[3, {2, Index[Colour, 4]}], Field[5] -> 
          F[3, {2, Index[Colour, 5]}], Field[6] -> F, Field[7] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> 
           -F[3, {2, Index[Colour, 4]}], Field[5] -> 
           F[3, {2, Index[Colour, 5]}], Field[6] -> 
           F[3, {2, Index[Colour, 5]}], Field[7] -> 
           V[5, {Index[Gluon, 6]}]]]]], 
   "Raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, 
          {}}, {F[3, {1, Index[Colour, 2]}], FourMomentum[Incoming, 2], 
          FCGV["MU"], {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}} -> 
        {{F[3, {1, Index[Colour, 3]}], FourMomentum[Outgoing, 1], FCGV["MU"], 
          {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}, 
         {F[3, {2, Index[Colour, 4]}], FourMomentum[Outgoing, 2], FCGV["MC"], 
          {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}, 
         {-F[3, {2, Index[Colour, 5]}], FourMomentum[Outgoing, 3], 
          FCGV["MC"], {(-2*Charge)/3, (-2*ColorCharge)/Sqrt[3]}}}, 
      Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
      AmplitudeLevel -> {Classes}, ExcludeParticles -> 
       {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], -F[1, {2}], 
        F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], 
        F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], -U[1], 
        U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
        V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 1], Integral[], -(FAMetricTensor[Index[Lorentz, 2], 
         Index[Lorentz, 3]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPropagatorDenominator[
         -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2] - 
          FourMomentum[Outgoing, 3], FCGV["MU"]]*FAPropagatorDenominator[
         FourMomentum[Outgoing, 2] + FourMomentum[Outgoing, 3], 0]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            2], FCGV["MC"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 4], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 4], Index[Colour, 5]], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 3], FCGV["MC"]]]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 3], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 2]], FANonCommutative[
          FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
              2] + FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
         ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[-1]]*FCGV["EL"] - ((2*I)/3)*
           FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
         External]*SumOver[Index[Colour, 5], 3, External])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 2], Integral[], -(FAMetricTensor[Index[Lorentz, 2], 
         Index[Lorentz, 3]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPropagatorDenominator[
         FourMomentum[Outgoing, 2] + FourMomentum[Outgoing, 3], 0]*
        FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
          FourMomentum[Outgoing, 2] + FourMomentum[Outgoing, 3], FCGV["MU"]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            2], FCGV["MC"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 4], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 4], Index[Colour, 5]], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 3], FCGV["MC"]]]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
          ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
              2] - FourMomentum[Outgoing, 3]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
         External]*SumOver[Index[Colour, 5], 3, External])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 3], Integral[], -(FAMetricTensor[Index[Lorentz, 2], 
         Index[Lorentz, 3]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPropagatorDenominator[
         FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], 0]*
        FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
          FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 3], FCGV["MC"]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 3], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            2], FCGV["MC"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
          ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
              1] - FourMomentum[Outgoing, 3]] + FCGV["MC"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 4], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 4], Index[Colour, 5]], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 3], FCGV["MC"]]]]*
        SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
         External]*SumOver[Index[Colour, 5], 3, External])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 4], Integral[], -(FAMetricTensor[Index[Lorentz, 2], 
         Index[Lorentz, 3]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPropagatorDenominator[
         FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], 0]*
        FAPropagatorDenominator[FourMomentum[Incoming, 2] - 
          FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], FCGV["MC"]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 3], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 3], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            2], FCGV["MC"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 6], Index[Colour, 4], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], 
            Index[Colour, 4], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 
              1] + FourMomentum[Outgoing, 2]] + FCGV["MC"]], 
         ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[-1]]*FCGV["EL"] - ((2*I)/3)*
           FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSpinor[-FourMomentum[Outgoing, 3], FCGV["MC"]]]]*
        SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
         External]*SumOver[Index[Colour, 5], 3, External])]], 
   "Request" -> <|"Loops" -> 0, "Incoming" -> {V[1], F[3, {1}]}, 
     "Outgoing" -> {F[3, {1}], F[3, {2}], -F[3, {2}]}, 
     "IncomingMomenta" -> {q, p}, "OutgoingMomenta" -> {k1, k2, k3}|>, 
   "InputHash" -> 83852251055931916722401586480071565105647465360960566909016\
489058856621190034|>, "Virtual" -> 
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
       Propagator[Outgoing][Vertex[1][4], Vertex[3][7], Field[4]], 
       Propagator[Internal][Vertex[3][5], Vertex[3][8], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> F, Field[6] -> F, Field[7] -> V, Field[8] -> F] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> F[3, {1, Index[Colour, 2]}], Field[6] -> 
           -F[3, {1, Index[Colour, 5]}], Field[7] -> V[5, {Index[Gluon, 5]}], 
          Field[8] -> -F[3, {1, Index[Colour, 6]}]]], 
       FeynmanGraph[1, Generic == 2][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> F, Field[6] -> V, Field[7] -> F, Field[8] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> F[3, {1, Index[Colour, 2]}], Field[6] -> 
           V[5, {Index[Gluon, 5]}], Field[7] -> -F[3, {1, Index[Colour, 5]}], 
          Field[8] -> V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][5], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][7], Field[4]], 
       Propagator[Internal][Vertex[3][5], Vertex[3][8], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][7], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> F, Field[6] -> F, Field[7] -> V, Field[8] -> F] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> -F[3, {1, Index[Colour, 3]}], Field[6] -> 
           F[3, {1, Index[Colour, 5]}], Field[7] -> V[5, {Index[Gluon, 5]}], 
          Field[8] -> F[3, {1, Index[Colour, 6]}]]], 
       FeynmanGraph[1, Generic == 2][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> F, Field[6] -> V, Field[7] -> F, Field[8] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> -F[3, {1, Index[Colour, 3]}], Field[6] -> 
           V[5, {Index[Gluon, 5]}], Field[7] -> F[3, {1, Index[Colour, 5]}], 
          Field[8] -> V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][7], Field[4]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][7], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> V, Field[6] -> F, Field[7] -> F, Field[8] -> F] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> V[5, {Index[Gluon, 5]}], Field[6] -> 
           -F[3, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[7] -> F[3, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[8] -> -F[3, {Index[Generation, 5], Index[Colour, 6]}]], 
         FeynmanGraph[1, Classes == 2][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> V[5, {Index[Gluon, 5]}], Field[6] -> 
           F[3, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[7] -> -F[3, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[8] -> F[3, {Index[Generation, 5], Index[Colour, 6]}]], 
         FeynmanGraph[1, Classes == 3][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> V[5, {Index[Gluon, 5]}], Field[6] -> 
           -F[4, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[7] -> F[4, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[8] -> -F[4, {Index[Generation, 5], Index[Colour, 6]}]], 
         FeynmanGraph[1, Classes == 4][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> V[5, {Index[Gluon, 5]}], Field[6] -> 
           F[4, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[7] -> -F[4, {Index[Generation, 5], Index[Colour, 5]}], 
          Field[8] -> F[4, {Index[Generation, 5], Index[Colour, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][7], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> F, Field[6] -> F, Field[7] -> F, Field[8] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> F[3, {1, Index[Colour, 5]}], Field[6] -> 
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
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> F, Field[6] -> F, Field[7] -> F, Field[8] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> -F[3, {1, Index[Colour, 5]}], Field[6] -> 
           -F[3, {1, Index[Colour, 6]}], Field[7] -> 
           F[3, {1, Index[Colour, 6]}], Field[8] -> 
           V[5, {Index[Gluon, 5]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][6], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][7], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> F, Field[6] -> F, Field[7] -> V, Field[8] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> -F[3, {1, Index[Colour, 5]}], Field[6] -> 
           F[3, {1, Index[Colour, 5]}], Field[7] -> V[5, {Index[Gluon, 5]}], 
          Field[8] -> V[5, {Index[Gluon, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][6], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][8], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][7], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> F, Field[6] -> F, Field[7] -> V, Field[8] -> F] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> -F[3, {1, Index[Colour, 5]}], Field[6] -> 
           F[3, {1, Index[Colour, 5]}], Field[7] -> V[5, {Index[Gluon, 5]}], 
          Field[8] -> -F[3, {1, Index[Colour, 6]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][7], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][8], Field[4]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][7], Field[5]], 
       Propagator[FALoop[1]][Vertex[3][5], Vertex[3][8], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][7], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][6], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> F, Field[6] -> F, Field[7] -> V, Field[8] -> F] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> F[3, {1, Index[Colour, 5]}], Field[6] -> 
           -F[3, {1, Index[Colour, 5]}], Field[7] -> V[5, {Index[Gluon, 5]}], 
          Field[8] -> F[3, {1, Index[Colour, 6]}]]]], 
     Topology[2][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][5], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Internal][Vertex[3][5], Vertex[3][7], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> F, Field[6] -> F, Field[7] -> F, Field[8] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> F[3, {1, Index[Colour, 2]}], Field[6] -> 
           -F[3, {1, Index[Colour, 5]}], Field[7] -> 
           F[3, {1, Index[Colour, 6]}], Field[8] -> 
           V[5, {Index[Gluon, 5]}]]]], 
     Topology[2][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][5], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
       Propagator[Internal][Vertex[3][5], Vertex[3][7], Field[5]], 
       Propagator[Internal][Vertex[3][6], Vertex[3][8], Field[6]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[7]], 
       Propagator[FALoop[1]][Vertex[3][7], Vertex[3][8], Field[8]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
         Field[5] -> F, Field[6] -> F, Field[7] -> F, Field[8] -> V] -> 
        Insertions[Classes][FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
           -F[3, {1, Index[Colour, 3]}], Field[4] -> V[5, {Index[Gluon, 4]}], 
          Field[5] -> -F[3, {1, Index[Colour, 3]}], Field[6] -> 
           F[3, {1, Index[Colour, 5]}], Field[7] -> 
           -F[3, {1, Index[Colour, 6]}], Field[8] -> 
           V[5, {Index[Gluon, 5]}]]]]], 
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
       Number == 1], Integral[FourMomentum[Internal, 1]], 
      -(FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 
           1], FCGV["MU"]], FAPropagatorDenominator[
          FourMomentum[Internal, 1] + FourMomentum[Outgoing, 1], 0], 
         FAPropagatorDenominator[FourMomentum[Internal, 1] - 
           FourMomentum[Outgoing, 2], FCGV["MU"]]]*FAMetricTensor[
         Index[Lorentz, 3], Index[Lorentz, 4]]*FAPolarizationVector[V[1], 
         FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
        FAPropagatorDenominator[-FourMomentum[Outgoing, 1] - 
          FourMomentum[Outgoing, 2], FCGV["MU"]]*FermionChain[
         FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
           FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[-FourMomentum[Internal, 1]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 5], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 5], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[-FourMomentum[Internal, 1] + FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 4]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 6], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 2]], FANonCommutative[
          FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], ((-2*I)/3)*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
           FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
         FANonCommutative[FADiracSpinor[FourMomentum[Incoming, 2], 
           FCGV["MU"]]]]*SumOver[Index[Colour, 5], 3]*
        SumOver[Index[Colour, 6], 3]*SumOver[Index[Gluon, 5], 8]*
        SumOver[Index[Colour, 2], 3, External]*SumOver[Index[Colour, 3], 3, 
         External]*SumOver[Index[Gluon, 4], 8, External]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 2, Classes == 1, 
       Number == 2], Integral[FourMomentum[Internal, 1]], 
      FAGS*FAFeynAmpDenominator[FAPropagatorDenominator[
         FourMomentum[Internal, 1], 0], FAPropagatorDenominator[
         FourMomentum[Internal, 1] + FourMomentum[Outgoing, 1], FCGV["MU"]], 
        FAPropagatorDenominator[FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 2], 0]]*FAMetricTensor[Index[Lorentz, 3], 
        Index[Lorentz, 4]]*(FAFourVector[FourMomentum[Internal, 1] + 
           FourMomentum[Outgoing, 2], Index[Lorentz, 5]]*
         FAMetricTensor[Index[Lorentz, 2], Index[Lorentz, 4]] + 
        FAFourVector[FourMomentum[Internal, 1] - 2*FourMomentum[Outgoing, 2], 
          Index[Lorentz, 4]]*FAMetricTensor[Index[Lorentz, 2], 
          Index[Lorentz, 5]] + FAFourVector[-2*FourMomentum[Internal, 1] + 
           FourMomentum[Outgoing, 2], Index[Lorentz, 2]]*
         FAMetricTensor[Index[Lorentz, 4], Index[Lorentz, 5]])*
       FAMetricTensor[Index[Lorentz, 5], Index[Lorentz, 6]]*
       FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
        Index[Lorentz, 1]]*FAPropagatorDenominator[
        -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], FCGV["MU"]]*
       FASUNF[Index[Gluon, 4], Index[Gluon, 5], Index[Gluon, 6]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[FourMomentum[Internal, 1] + FourMomentum[Outgoing, 
             1]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 6]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 6], Index[Colour, 5], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 6]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], Index[Colour, 5], 
           Index[Colour, 2]], FANonCommutative[
         FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
             2]] + FCGV["MU"]], ((-2*I)/3)*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
          FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
        FANonCommutative[FADiracSpinor[FourMomentum[Incoming, 2], 
          FCGV["MU"]]]]*SumOver[Index[Colour, 5], 3]*SumOver[Index[Gluon, 5], 
        8]*SumOver[Index[Gluon, 6], 8]*SumOver[Index[Colour, 2], 3, External]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
        External]*Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
        FourMomentum[Outgoing, 2], Index[Lorentz, 2]]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 3], Integral[FourMomentum[Internal, 1]], 
      -(FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 
           1], FCGV["MU"]], FAPropagatorDenominator[
          -FourMomentum[Incoming, 2] + FourMomentum[Internal, 1], 0], 
         FAPropagatorDenominator[FourMomentum[Internal, 1] - 
           FourMomentum[Outgoing, 2], FCGV["MU"]]]*FAMetricTensor[
         Index[Lorentz, 3], Index[Lorentz, 4]]*FAPolarizationVector[V[1], 
         FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
        FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
          FourMomentum[Outgoing, 2], FCGV["MU"]]*FermionChain[
         FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
           FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
          ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 4]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Internal, 1] - FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 4], Index[Colour, 6], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 6], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[FourMomentum[Internal, 1]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 5], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 5], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 5], 3]*SumOver[Index[Colour, 6], 3]*
        SumOver[Index[Gluon, 5], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
         External]*Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 2, Classes == 1, 
       Number == 4], Integral[FourMomentum[Internal, 1]], 
      FAGS*FAFeynAmpDenominator[FAPropagatorDenominator[
         FourMomentum[Internal, 1], 0], FAPropagatorDenominator[
         -FourMomentum[Incoming, 2] + FourMomentum[Internal, 1], FCGV["MU"]], 
        FAPropagatorDenominator[FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 2], 0]]*FAMetricTensor[Index[Lorentz, 3], 
        Index[Lorentz, 4]]*(FAFourVector[FourMomentum[Internal, 1] + 
           FourMomentum[Outgoing, 2], Index[Lorentz, 5]]*
         FAMetricTensor[Index[Lorentz, 2], Index[Lorentz, 4]] + 
        FAFourVector[FourMomentum[Internal, 1] - 2*FourMomentum[Outgoing, 2], 
          Index[Lorentz, 4]]*FAMetricTensor[Index[Lorentz, 2], 
          Index[Lorentz, 5]] + FAFourVector[-2*FourMomentum[Internal, 1] + 
           FourMomentum[Outgoing, 2], Index[Lorentz, 2]]*
         FAMetricTensor[Index[Lorentz, 4], Index[Lorentz, 5]])*
       FAMetricTensor[Index[Lorentz, 5], Index[Lorentz, 6]]*
       FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
        Index[Lorentz, 1]]*FAPropagatorDenominator[
        -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2], FCGV["MU"]]*
       FASUNF[Index[Gluon, 4], Index[Gluon, 5], Index[Gluon, 6]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
             2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 6]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 6], Index[Colour, 3], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 6]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], Index[Colour, 3], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Internal, 
             1]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 5], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 5], 
           Index[Colour, 2]], FANonCommutative[FADiracSpinor[
          FourMomentum[Incoming, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 5], 
        3]*SumOver[Index[Gluon, 5], 8]*SumOver[Index[Gluon, 6], 8]*
       SumOver[Index[Colour, 2], 3, External]*SumOver[Index[Colour, 3], 3, 
        External]*SumOver[Index[Gluon, 4], 8, External]*
       Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
        FourMomentum[Outgoing, 2], Index[Lorentz, 2]]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 5], Integral[FourMomentum[Internal, 1]], 
      FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 1], 
         MQU[Index[Generation, 5]]], FAPropagatorDenominator[
         FourMomentum[Internal, 1] - FourMomentum[Outgoing, 2], 
         MQU[Index[Generation, 5]]], FAPropagatorDenominator[
         FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], 
         MQU[Index[Generation, 5]]]]*FAMetricTensor[Index[Lorentz, 3], 
        Index[Lorentz, 4]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
         1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], 0]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 2]], FANonCommutative[FADiracSpinor[
          FourMomentum[Incoming, 2], FCGV["MU"]]]]*
       MatrixTrace[FANonCommutative[FADiracSlash[FourMomentum[Incoming, 2] + 
            FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
            FourMomentum[Outgoing, 2]] + MQU[Index[Generation, 5]]], 
        I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
           Index[Colour, 6], Index[Colour, 5]] + 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 6], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[FourMomentum[Internal, 1] - FourMomentum[Outgoing, 
             2]] + MQU[Index[Generation, 5]]], 
        I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 4], 
           Index[Colour, 5], Index[Colour, 6]] + 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], Index[Colour, 5], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[FourMomentum[Internal, 1]] + 
          MQU[Index[Generation, 5]]], ((2*I)/3)*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
          FCGV["EL"] + ((2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"]]*
       SumOver[Index[Colour, 5], 3]*SumOver[Index[Colour, 6], 3]*
       SumOver[Index[Generation, 5], 3]*SumOver[Index[Gluon, 5], 8]*
       SumOver[Index[Colour, 2], 3, External]*SumOver[Index[Colour, 3], 3, 
        External]*SumOver[Index[Gluon, 4], 8, External]*
       Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
        FourMomentum[Outgoing, 2], Index[Lorentz, 2]]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 2, 
       Number == 6], Integral[FourMomentum[Internal, 1]], 
      FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 1], 
         MQU[Index[Generation, 5]]], FAPropagatorDenominator[
         FourMomentum[Internal, 1] - FourMomentum[Outgoing, 2], 
         MQU[Index[Generation, 5]]], FAPropagatorDenominator[
         FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], 
         MQU[Index[Generation, 5]]]]*FAMetricTensor[Index[Lorentz, 3], 
        Index[Lorentz, 4]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
         1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], 0]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 2]], FANonCommutative[FADiracSpinor[
          FourMomentum[Incoming, 2], FCGV["MU"]]]]*
       MatrixTrace[FANonCommutative[FADiracSlash[FourMomentum[Incoming, 2] + 
            FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
            FourMomentum[Outgoing, 2]] + MQU[Index[Generation, 5]]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
           Index[Colour, 5], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 5], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[FourMomentum[Internal, 1] - FourMomentum[Outgoing, 
             2]] + MQU[Index[Generation, 5]]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 4], 
           Index[Colour, 6], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], Index[Colour, 6], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[FourMomentum[Internal, 1]] + 
          MQU[Index[Generation, 5]]], ((-2*I)/3)*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
          FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"]]*
       SumOver[Index[Colour, 5], 3]*SumOver[Index[Colour, 6], 3]*
       SumOver[Index[Generation, 5], 3]*SumOver[Index[Gluon, 5], 8]*
       SumOver[Index[Colour, 2], 3, External]*SumOver[Index[Colour, 3], 3, 
        External]*SumOver[Index[Gluon, 4], 8, External]*
       Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
        FourMomentum[Outgoing, 2], Index[Lorentz, 2]]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 3, 
       Number == 7], Integral[FourMomentum[Internal, 1]], 
      FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 1], 
         MQD[Index[Generation, 5]]], FAPropagatorDenominator[
         FourMomentum[Internal, 1] - FourMomentum[Outgoing, 2], 
         MQD[Index[Generation, 5]]], FAPropagatorDenominator[
         FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], 
         MQD[Index[Generation, 5]]]]*FAMetricTensor[Index[Lorentz, 3], 
        Index[Lorentz, 4]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
         1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], 0]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 2]], FANonCommutative[FADiracSpinor[
          FourMomentum[Incoming, 2], FCGV["MU"]]]]*
       MatrixTrace[FANonCommutative[FADiracSlash[FourMomentum[Incoming, 2] + 
            FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
            FourMomentum[Outgoing, 2]] + MQD[Index[Generation, 5]]], 
        I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
           Index[Colour, 6], Index[Colour, 5]] + 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 6], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[FourMomentum[Internal, 1] - FourMomentum[Outgoing, 
             2]] + MQD[Index[Generation, 5]]], 
        I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 4], 
           Index[Colour, 5], Index[Colour, 6]] + 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], Index[Colour, 5], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[FourMomentum[Internal, 1]] + 
          MQD[Index[Generation, 5]]], 
        (-1/3*I)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[-1]]*FCGV["EL"] - 
         (I/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"]]*SumOver[Index[Colour, 5], 3]*
       SumOver[Index[Colour, 6], 3]*SumOver[Index[Generation, 5], 3]*
       SumOver[Index[Gluon, 5], 8]*SumOver[Index[Colour, 2], 3, External]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
        External]*Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
        FourMomentum[Outgoing, 2], Index[Lorentz, 2]]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 4, 
       Number == 8], Integral[FourMomentum[Internal, 1]], 
      FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 1], 
         MQD[Index[Generation, 5]]], FAPropagatorDenominator[
         FourMomentum[Internal, 1] - FourMomentum[Outgoing, 2], 
         MQD[Index[Generation, 5]]], FAPropagatorDenominator[
         FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
          FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], 
         MQD[Index[Generation, 5]]]]*FAMetricTensor[Index[Lorentz, 3], 
        Index[Lorentz, 4]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
         1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1], 0]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 3]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 3], 
           Index[Colour, 2]], FANonCommutative[FADiracSpinor[
          FourMomentum[Incoming, 2], FCGV["MU"]]]]*
       MatrixTrace[FANonCommutative[FADiracSlash[FourMomentum[Incoming, 2] + 
            FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
            FourMomentum[Outgoing, 2]] + MQD[Index[Generation, 5]]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
           Index[Colour, 5], Index[Colour, 6]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 5], 
           Index[Colour, 6]], FANonCommutative[
         FADiracSlash[FourMomentum[Internal, 1] - FourMomentum[Outgoing, 
             2]] + MQD[Index[Generation, 5]]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 4], 
           Index[Colour, 6], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], Index[Colour, 6], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[FourMomentum[Internal, 1]] + 
          MQD[Index[Generation, 5]]], 
        (I/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[-1]]*FCGV["EL"] + 
         (I/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"]]*SumOver[Index[Colour, 5], 3]*
       SumOver[Index[Colour, 6], 3]*SumOver[Index[Generation, 5], 3]*
       SumOver[Index[Gluon, 5], 8]*SumOver[Index[Colour, 2], 3, External]*
       SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
        External]*Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
        FourMomentum[Outgoing, 2], Index[Lorentz, 2]]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 9], Integral[FourMomentum[Internal, 1]], 
      -(FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 
           1], FCGV["MU"]], FAPropagatorDenominator[
          FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1], 0], 
         FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
           FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
           FourMomentum[Outgoing, 2], FCGV["MU"]]]*FAMetricTensor[
         Index[Lorentz, 3], Index[Lorentz, 4]]*FAPolarizationVector[V[1], 
         FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
        FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
          FourMomentum[Outgoing, 2], FCGV["MU"]]*FermionChain[
         FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
           FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 3]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Internal, 1]] + FCGV["MU"]], 
         ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[-1]]*FCGV["EL"] - ((2*I)/3)*
           FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] + FourMomentum[Internal, 
              1] - FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2]] + 
           FCGV["MU"]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 4]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 6], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 4], Index[Colour, 5], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 5], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 5], 3]*SumOver[Index[Colour, 6], 3]*
        SumOver[Index[Gluon, 5], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
         External]*Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 10], Integral[FourMomentum[Internal, 1]], 
      -(FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 
           1], FCGV["MU"]], FAPropagatorDenominator[
          FourMomentum[Incoming, 2] + FourMomentum[Internal, 1], 0], 
         FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
           FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
           FourMomentum[Outgoing, 2], FCGV["MU"]]]*FAMetricTensor[
         Index[Lorentz, 3], Index[Lorentz, 4]]*FAPolarizationVector[V[1], 
         FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
        FAPropagatorDenominator[-FourMomentum[Outgoing, 1] - 
          FourMomentum[Outgoing, 2], FCGV["MU"]]*FermionChain[
         FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
           FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 4], Index[Colour, 3], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 3], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 4]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 5], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 5], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[-FourMomentum[Incoming, 2] - FourMomentum[Internal, 
              1] + FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 2]] + 
           FCGV["MU"]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
          ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSlash[-FourMomentum[Internal, 1]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 5], 3]*SumOver[Index[Colour, 6], 3]*
        SumOver[Index[Gluon, 5], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
         External]*Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 11], Integral[FourMomentum[Internal, 1]], 
      FAGS*FAFeynAmpDenominator[FAPropagatorDenominator[
         FourMomentum[Internal, 1], FCGV["MU"]], FAPropagatorDenominator[
         FourMomentum[Incoming, 2] + FourMomentum[Internal, 1], 0], 
        FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
          FourMomentum[Internal, 1] - FourMomentum[Outgoing, 2], 0], 
        FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
          FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
          FourMomentum[Outgoing, 2], FCGV["MU"]]]*FAMetricTensor[
        Index[Lorentz, 3], Index[Lorentz, 4]]*
       (FAFourVector[FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] + 
           FourMomentum[Outgoing, 2], Index[Lorentz, 6]]*
         FAMetricTensor[Index[Lorentz, 2], Index[Lorentz, 4]] + 
        FAFourVector[FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
           2*FourMomentum[Outgoing, 2], Index[Lorentz, 4]]*
         FAMetricTensor[Index[Lorentz, 2], Index[Lorentz, 6]] + 
        FAFourVector[-2*FourMomentum[Incoming, 2] - 
           2*FourMomentum[Internal, 1] + FourMomentum[Outgoing, 2], 
          Index[Lorentz, 2]]*FAMetricTensor[Index[Lorentz, 4], 
          Index[Lorentz, 6]])*FAMetricTensor[Index[Lorentz, 5], 
        Index[Lorentz, 6]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
         1], Index[Lorentz, 1]]*FASUNF[Index[Gluon, 4], Index[Gluon, 5], 
        Index[Gluon, 6]]*FermionChain[FANonCommutative[
         FADiracSpinor[FourMomentum[Outgoing, 1], FCGV["MU"]]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 5]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 6], 
           Index[Colour, 3], Index[Colour, 5]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 5]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 6], Index[Colour, 3], 
           Index[Colour, 5]], FANonCommutative[
         FADiracSlash[-FourMomentum[Incoming, 2] - FourMomentum[Internal, 
             1] + FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 2]] + 
          FCGV["MU"]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[-FourMomentum[Internal, 1]] + FCGV["MU"]], 
        (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
           Index[Colour, 5], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], Index[Colour, 5], 
           Index[Colour, 2]], FANonCommutative[FADiracSpinor[
          FourMomentum[Incoming, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 5], 
        3]*SumOver[Index[Gluon, 5], 8]*SumOver[Index[Gluon, 6], 8]*
       SumOver[Index[Colour, 2], 3, External]*SumOver[Index[Colour, 3], 3, 
        External]*SumOver[Index[Gluon, 4], 8, External]*
       Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
        FourMomentum[Outgoing, 2], Index[Lorentz, 2]]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 12], Integral[FourMomentum[Internal, 1]], 
      -(FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 
           1], FCGV["MU"]], FAPropagatorDenominator[
          FourMomentum[Incoming, 2] + FourMomentum[Internal, 1], 0], 
         FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
           FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1], 
          FCGV["MU"]], FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
           FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
           FourMomentum[Outgoing, 2], FCGV["MU"]]]*FAMetricTensor[
         Index[Lorentz, 3], Index[Lorentz, 4]]*FAPolarizationVector[V[1], 
         FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
        FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 
            1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 4]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 3], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[-FourMomentum[Incoming, 2] - FourMomentum[Internal, 
              1] + FourMomentum[Outgoing, 1]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 6], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 6], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[-FourMomentum[Incoming, 2] - FourMomentum[Internal, 
              1] + FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 2]] + 
           FCGV["MU"]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
          ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
          FADiracSlash[-FourMomentum[Internal, 1]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 5], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 5], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 5], 3]*SumOver[Index[Colour, 6], 3]*
        SumOver[Index[Gluon, 5], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
         External]*Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 13], Integral[FourMomentum[Internal, 1]], 
      -(FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 
           1], FCGV["MU"]], FAPropagatorDenominator[
          FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1], 0], 
         FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
           FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1], 
          FCGV["MU"]], FAPropagatorDenominator[FourMomentum[Incoming, 2] + 
           FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
           FourMomentum[Outgoing, 2], FCGV["MU"]]]*FAMetricTensor[
         Index[Lorentz, 3], Index[Lorentz, 4]]*FAPolarizationVector[V[1], 
         FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
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
             Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 4], Index[Colour, 5], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 5], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] + FourMomentum[Internal, 
              1] - FourMomentum[Outgoing, 1]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 5], 3]*SumOver[Index[Colour, 6], 3]*
        SumOver[Index[Gluon, 5], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
         External]*Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 14], Integral[FourMomentum[Internal, 1]], 
      -(FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 
           1], FCGV["MU"]], FAPropagatorDenominator[
          FourMomentum[Internal, 1] - FourMomentum[Outgoing, 1] - 
           FourMomentum[Outgoing, 2], 0]]*FAMetricTensor[Index[Lorentz, 3], 
         Index[Lorentz, 4]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPropagatorDenominator[
         -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], FCGV["MU"], 
         2]*FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[
            Outgoing, 1], FCGV["MU"]]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 4], Index[Colour, 3], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 3], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 4]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 5], Index[Colour, 5], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 5], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[FourMomentum[Internal, 1]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 2]], FANonCommutative[
          FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], ((-2*I)/3)*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
           FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
         FANonCommutative[FADiracSpinor[FourMomentum[Incoming, 2], 
           FCGV["MU"]]]]*SumOver[Index[Colour, 5], 3]*
        SumOver[Index[Colour, 6], 3]*SumOver[Index[Gluon, 5], 8]*
        SumOver[Index[Colour, 2], 3, External]*SumOver[Index[Colour, 3], 3, 
         External]*SumOver[Index[Gluon, 4], 8, External]*
        Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]])], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 15], Integral[FourMomentum[Internal, 1]], 
      -(FAFeynAmpDenominator[FAPropagatorDenominator[FourMomentum[Internal, 
           1], FCGV["MU"]], FAPropagatorDenominator[
          FourMomentum[Incoming, 2] + FourMomentum[Internal, 1] - 
           FourMomentum[Outgoing, 2], 0]]*FAMetricTensor[Index[Lorentz, 3], 
         Index[Lorentz, 4]]*FAPolarizationVector[V[1], FourMomentum[Incoming, 
          1], Index[Lorentz, 1]]*FAPropagatorDenominator[
         -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 2], FCGV["MU"], 
         2]*FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[
            Outgoing, 1], FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
           FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
         FANonCommutative[FADiracSlash[FourMomentum[Incoming, 2] - 
             FourMomentum[Outgoing, 2]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 6]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 3]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 3], Index[Colour, 6]], FANonCommutative[
          FADiracSlash[-FourMomentum[Internal, 1]] + FCGV["MU"]], 
         (-I)*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[-1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 5]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 4]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 5], 
            Index[Colour, 6], Index[Colour, 5]], FANonCommutative[
          FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
              2]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
            FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
           FASUNT[Index[Gluon, 4], Index[Colour, 5], Index[Colour, 2]] - 
          I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
            FAChiralityProjector[1]]*FASUNT[Index[Gluon, 4], 
            Index[Colour, 5], Index[Colour, 2]], FANonCommutative[
          FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
        SumOver[Index[Colour, 5], 3]*SumOver[Index[Colour, 6], 3]*
        SumOver[Index[Gluon, 5], 8]*SumOver[Index[Colour, 2], 3, External]*
        SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Gluon, 4], 8, 
         External]*Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 4]}], 
         FourMomentum[Outgoing, 2], Index[Lorentz, 2]])]], 
   "Request" -> <|"Loops" -> 1, "Incoming" -> {V[1], F[3, {1}]}, 
     "Outgoing" -> {F[3, {1}], V[5]}, "IncomingMomenta" -> {q, p}, 
     "OutgoingMomenta" -> {k1, k2}|>, "InputHash" -> 198486706668002580161897\
11981546966598760226751063347885244581095997314475355|>, 
 "AuxHgqBorn" -> 
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
     "OutgoingMomenta" -> {k1, k2}|>, "InputHash" -> 727562760179382818365728\
73270562486284710178050237510051581108141236280201383|>, 
 "AuxHqgBorn" -> 
  <|"Diagrams" -> TopologyList[Process -> 
       {V[1], F[3, {1, Index[Colour, 2]}]} -> {V[5, {Index[Gluon, 3]}], 
         F[3, {1, Index[Colour, 4]}]}, Model -> {"SMQCD"}, 
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
          V[5, {Index[Gluon, 3]}], Field[4] -> -F[3, {1, Index[Colour, 4]}], 
         Field[5] -> F] -> Insertions[Classes][FeynmanGraph[1, Classes == 1][
          Field[1] -> V[1], Field[2] -> F[3, {1, Index[Colour, 2]}], 
          Field[3] -> V[5, {Index[Gluon, 3]}], Field[4] -> 
           -F[3, {1, Index[Colour, 4]}], Field[5] -> 
           F[3, {1, Index[Colour, 2]}]]]], 
     Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
       Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
       Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
       Propagator[Outgoing][Vertex[1][4], Vertex[3][5], Field[4]], 
       Propagator[Internal][Vertex[3][5], Vertex[3][6], Field[5]]] -> 
      Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
         Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
          V[5, {Index[Gluon, 3]}], Field[4] -> -F[3, {1, Index[Colour, 4]}], 
         Field[5] -> F] -> Insertions[Classes][FeynmanGraph[1, Classes == 1][
          Field[1] -> V[1], Field[2] -> F[3, {1, Index[Colour, 2]}], 
          Field[3] -> V[5, {Index[Gluon, 3]}], Field[4] -> 
           -F[3, {1, Index[Colour, 4]}], Field[5] -> 
           -F[3, {1, Index[Colour, 4]}]]]]], 
   "Raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, 
          {}}, {F[3, {1, Index[Colour, 2]}], FourMomentum[Incoming, 2], 
          FCGV["MU"], {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}} -> 
        {{V[5, {Index[Gluon, 3]}], FourMomentum[Outgoing, 1], 0, 
          {Sqrt[3]*ColorCharge}}, {F[3, {1, Index[Colour, 4]}], 
          FourMomentum[Outgoing, 2], FCGV["MU"], {(2*Charge)/3, 
           (2*ColorCharge)/Sqrt[3]}}}, Model -> {"SMQCD"}, 
      GenericModel -> {"Lorentz"}, AmplitudeLevel -> {Classes}, 
      ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], 
        -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], 
        -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], 
        S[3], -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], 
        -V[3], V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 1], Integral[], I*FAPolarizationVector[V[1], 
        FourMomentum[Incoming, 1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        -FourMomentum[Outgoing, 1] - FourMomentum[Outgoing, 2], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 2], 
          FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 3], Index[Colour, 4], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 3], Index[Colour, 4], 
           Index[Colour, 2]], FANonCommutative[
         FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 
             2]] + FCGV["MU"]], ((-2*I)/3)*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[-1]]*
          FCGV["EL"] - ((2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[1]]*FCGV["EL"], 
        FANonCommutative[FADiracSpinor[FourMomentum[Incoming, 2], 
          FCGV["MU"]]]]*SumOver[Index[Colour, 2], 3, External]*
       SumOver[Index[Colour, 4], 3, External]*SumOver[Index[Gluon, 3], 8, 
        External]*Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 3]}], 
        FourMomentum[Outgoing, 1], Index[Lorentz, 2]]], 
     FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, 
       Number == 2], Integral[], I*FAPolarizationVector[V[1], 
        FourMomentum[Incoming, 1], Index[Lorentz, 1]]*FAPropagatorDenominator[
        -FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 1], FCGV["MU"]]*
       FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 2], 
          FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
            Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
         ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
           FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
         FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 
             1]] + FCGV["MU"]], (-I)*FAGS*FANonCommutative[
           FADiracMatrix[Index[Lorentz, 2]], FAChiralityProjector[-1]]*
          FASUNT[Index[Gluon, 3], Index[Colour, 4], Index[Colour, 2]] - 
         I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
           FAChiralityProjector[1]]*FASUNT[Index[Gluon, 3], Index[Colour, 4], 
           Index[Colour, 2]], FANonCommutative[FADiracSpinor[
          FourMomentum[Incoming, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 2], 
        3, External]*SumOver[Index[Colour, 4], 3, External]*
       SumOver[Index[Gluon, 3], 8, External]*Conjugate[FAPolarizationVector][
        V[5, {Index[Gluon, 3]}], FourMomentum[Outgoing, 1], 
        Index[Lorentz, 2]]]], "Request" -> <|"Loops" -> 0, 
     "Incoming" -> {V[1], F[3, {1}]}, "Outgoing" -> {V[5], F[3, {1}]}, 
     "IncomingMomenta" -> {q, p}, "OutgoingMomenta" -> {k1, k2}|>, 
   "InputHash" -> 63001532003837941933809530444602493970203564732560883096079\
224437955352972499|>, "ChargeVertex" -> 
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
     "OutgoingMomenta" -> {k1, k2}|>, "InputHash" -> 496293531650161952692152\
45261805922751870457078072442201157176936168376312707|>, 
 "OtherChargeVertex" -> 
  <|"Diagrams" -> TopologyList[Process -> {V[1]} -> 
        {F[3, {2, Index[Colour, 2]}], -F[3, {2, Index[Colour, 3]}]}, 
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
         Field[2] -> -F[3, {2, Index[Colour, 2]}], Field[3] -> 
          F[3, {2, Index[Colour, 3]}]] -> Insertions[Classes][
         FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
          Field[2] -> -F[3, {2, Index[Colour, 2]}], Field[3] -> 
           F[3, {2, Index[Colour, 3]}]]]]], 
   "Raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, 
          {}}} -> {{F[3, {2, Index[Colour, 2]}], FourMomentum[Outgoing, 1], 
          FCGV["MC"], {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}, 
         {-F[3, {2, Index[Colour, 3]}], FourMomentum[Outgoing, 2], 
          FCGV["MC"], {(-2*Charge)/3, (-2*ColorCharge)/Sqrt[3]}}}, 
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
            1], FCGV["MC"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
             Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"]*
           IndexDelta[Index[Colour, 2], Index[Colour, 3]] - 
          ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
            FAChiralityProjector[1]]*FCGV["EL"]*IndexDelta[Index[Colour, 2], 
            Index[Colour, 3]], FANonCommutative[FADiracSpinor[
           -FourMomentum[Outgoing, 2], FCGV["MC"]]]]*
        SumOver[Index[Colour, 2], 3, External]*SumOver[Index[Colour, 3], 3, 
         External])]], "Request" -> <|"Loops" -> 0, "Incoming" -> {V[1]}, 
     "Outgoing" -> {F[3, {2}], -F[3, {2}]}, "IncomingMomenta" -> {q}, 
     "OutgoingMomenta" -> {k1, k2}|>, "InputHash" -> 618997626928371620553333\
48944810796635587249484205154778017505829889676674161|>|>
