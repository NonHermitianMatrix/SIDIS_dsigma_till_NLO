<|"Amplitudes" -> {((2*I)/3)*Spinor[Momentum[k1, D], 0, 1] . 
     DiracGamma[Momentum[Polarization[q, I], D], D] . 
     Spinor[-Momentum[k2, D], 0, 1]*SMP["e"]*SUNFDelta[SUNFIndex[Col2], 
     SUNFIndex[Col3]]}, "Diagrams" -> 
  TopologyList[Process -> {V[1]} -> {F[3, {1, Index[Colour, 2]}], 
       -F[3, {1, Index[Colour, 3]}]}, Model -> {"SMQCD"}, 
    GenericModel -> {"Lorentz"}, InsertionLevel -> {Classes}, 
    ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], 
      -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], 
      -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], 
      -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
      V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
   Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][4], Field[1]], 
     Propagator[Outgoing][Vertex[1][2], Vertex[3][4], Field[2]], 
     Propagator[Outgoing][Vertex[1][3], Vertex[3][4], Field[3]]] -> 
    Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
       Field[2] -> -F[3, {1, Index[Colour, 2]}], 
       Field[3] -> F[3, {1, Index[Colour, 3]}]] -> Insertions[Classes][
       FeynmanGraph[1, Classes == 1][Field[1] -> V[1], 
        Field[2] -> -F[3, {1, Index[Colour, 2]}], Field[3] -> 
         F[3, {1, Index[Colour, 3]}]]]]], 
 "Raw" -> FAFeynAmpList[Process -> 
     {{V[1], FourMomentum[Incoming, 1], 0, {}}} -> 
      {{F[3, {1, Index[Colour, 2]}], FourMomentum[Outgoing, 1], FCGV["MU"], 
        {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}, 
       {-F[3, {1, Index[Colour, 3]}], FourMomentum[Outgoing, 2], FCGV["MU"], 
        {(-2*Charge)/3, (-2*ColorCharge)/Sqrt[3]}}}, Model -> {"SMQCD"}, 
    GenericModel -> {"Lorentz"}, AmplitudeLevel -> {Classes}, 
    ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], 
      -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], 
      -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], 
      -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
      V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
   FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, Number == 1], 
    Integral[], -(FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
       Index[Lorentz, 1]]*FermionChain[FANonCommutative[
        FADiracSpinor[FourMomentum[Outgoing, 1], FCGV["MU"]]], 
       ((-2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
          FAChiralityProjector[-1]]*FCGV["EL"]*IndexDelta[Index[Colour, 2], 
          Index[Colour, 3]] - ((2*I)/3)*FANonCommutative[
          FADiracMatrix[Index[Lorentz, 1]], FAChiralityProjector[1]]*
         FCGV["EL"]*IndexDelta[Index[Colour, 2], Index[Colour, 3]], 
       FANonCommutative[FADiracSpinor[-FourMomentum[Outgoing, 2], 
         FCGV["MU"]]]]*SumOver[Index[Colour, 2], 3, External]*
      SumOver[Index[Colour, 3], 3, External])]], "GraphCount" -> 1, 
 "CouplingDegrees" -> {{1, 0}}, "IncomingSpecies" -> {photon}, 
 "OutgoingSpecies" -> {quark, antiquark}, 
 "Request" -> <|"Loops" -> 0, "Incoming" -> {V[1]}, 
   "Outgoing" -> {F[3, {1}], -F[3, {1}]}, "IncomingMomenta" -> {q}, 
   "OutgoingMomenta" -> {k1, k2}|>, "InputHash" -> 59397662008334725151402580\
298825423834717923943279924514448775523032818664265|>
