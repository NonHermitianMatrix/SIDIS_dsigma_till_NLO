<|"Amplitudes" -> {((-2*I)/3)*Spinor[Momentum[k2, D], 0, 1] . 
      DiracGamma[Momentum[Polarization[k1, -I], D], D] . 
      DiracGamma[Momentum[k1, D], D] . DiracGamma[
       Momentum[Polarization[q, I], D], D] . Spinor[Momentum[p, D], 0, 1]*
     FeynAmpDenominator[PropagatorDenominator[-Momentum[k1 + k2, D], 0]]*
     SMP["e"]*SMP["g_s"]*SUNTF[{SUNIndex[Glu3]}, SUNFIndex[Col4], 
      SUNFIndex[Col2]] - ((4*I)/3)*Spinor[Momentum[k2, D], 0, 1] . 
      DiracGamma[Momentum[Polarization[q, I], D], D] . 
      Spinor[Momentum[p, D], 0, 1]*FeynAmpDenominator[
      PropagatorDenominator[-Momentum[k1 + k2, D], 0]]*
     Pair[Momentum[k2, D], Momentum[Polarization[k1, -I], D]]*SMP["e"]*
     SMP["g_s"]*SUNTF[{SUNIndex[Glu3]}, SUNFIndex[Col4], SUNFIndex[Col2]], 
   ((2*I)/3)*Spinor[Momentum[k2, D], 0, 1] . 
      DiracGamma[Momentum[Polarization[q, I], D], D] . 
      DiracGamma[Momentum[k1, D], D] . DiracGamma[
       Momentum[Polarization[k1, -I], D], D] . Spinor[Momentum[p, D], 0, 1]*
     FeynAmpDenominator[PropagatorDenominator[Momentum[k1 - p, D], 0]]*
     SMP["e"]*SMP["g_s"]*SUNTF[{SUNIndex[Glu3]}, SUNFIndex[Col4], 
      SUNFIndex[Col2]] - ((4*I)/3)*Spinor[Momentum[k2, D], 0, 1] . 
      DiracGamma[Momentum[Polarization[q, I], D], D] . 
      Spinor[Momentum[p, D], 0, 1]*FeynAmpDenominator[
      PropagatorDenominator[Momentum[k1 - p, D], 0]]*
     Pair[Momentum[p, D], Momentum[Polarization[k1, -I], D]]*SMP["e"]*
     SMP["g_s"]*SUNTF[{SUNIndex[Glu3]}, SUNFIndex[Col4], SUNFIndex[Col2]]}, 
 "Diagrams" -> TopologyList[Process -> {V[1], F[3, {1, Index[Colour, 2]}]} -> 
      {V[5, {Index[Gluon, 3]}], F[3, {1, Index[Colour, 4]}]}, 
    Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
    InsertionLevel -> {Classes}, ExcludeParticles -> 
     {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], -F[1, {2}], F[1, {2}], 
      -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], F[2, {2}], 
      -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], -U[1], U[1], -U[2], 
      U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], V[3]}, 
    ExcludeFieldPoints -> {}, LastSelections -> {}][
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
 "Raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, {}}, 
       {F[3, {1, Index[Colour, 2]}], FourMomentum[Incoming, 2], FCGV["MU"], 
        {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}} -> 
      {{V[5, {Index[Gluon, 3]}], FourMomentum[Outgoing, 1], 0, 
        {Sqrt[3]*ColorCharge}}, {F[3, {1, Index[Colour, 4]}], 
        FourMomentum[Outgoing, 2], FCGV["MU"], {(2*Charge)/3, 
         (2*ColorCharge)/Sqrt[3]}}}, Model -> {"SMQCD"}, 
    GenericModel -> {"Lorentz"}, AmplitudeLevel -> {Classes}, 
    ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], 
      -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], 
      -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], S[3], 
      -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], 
      V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
   FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, Number == 1], 
    Integral[], I*FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
      Index[Lorentz, 1]]*FAPropagatorDenominator[-FourMomentum[Outgoing, 1] - 
       FourMomentum[Outgoing, 2], FCGV["MU"]]*
     FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 2], 
        FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 2]], FAChiralityProjector[-1]]*
        FASUNT[Index[Gluon, 3], Index[Colour, 4], Index[Colour, 2]] - 
       I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
         FAChiralityProjector[1]]*FASUNT[Index[Gluon, 3], Index[Colour, 4], 
         Index[Colour, 2]], FANonCommutative[
       FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 2]] + 
        FCGV["MU"]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
       ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
         FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
       FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
     SumOver[Index[Colour, 2], 3, External]*SumOver[Index[Colour, 4], 3, 
      External]*SumOver[Index[Gluon, 3], 8, External]*
     Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 3]}], 
      FourMomentum[Outgoing, 1], Index[Lorentz, 2]]], 
   FAFeynAmp[GraphID[Topology == 1, Generic == 1, Classes == 1, Number == 2], 
    Integral[], I*FAPolarizationVector[V[1], FourMomentum[Incoming, 1], 
      Index[Lorentz, 1]]*FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
       FourMomentum[Outgoing, 1], FCGV["MU"]]*
     FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 2], 
        FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
       ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
         FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
       FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 1]] + 
        FCGV["MU"]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 2]], FAChiralityProjector[-1]]*
        FASUNT[Index[Gluon, 3], Index[Colour, 4], Index[Colour, 2]] - 
       I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
         FAChiralityProjector[1]]*FASUNT[Index[Gluon, 3], Index[Colour, 4], 
         Index[Colour, 2]], FANonCommutative[FADiracSpinor[
        FourMomentum[Incoming, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 2], 3, 
      External]*SumOver[Index[Colour, 4], 3, External]*
     SumOver[Index[Gluon, 3], 8, External]*Conjugate[FAPolarizationVector][
      V[5, {Index[Gluon, 3]}], FourMomentum[Outgoing, 1], 
      Index[Lorentz, 2]]]], "GraphCount" -> 2, "CouplingDegrees" -> {{1, 1}}, 
 "IncomingSpecies" -> {photon, quark}, "OutgoingSpecies" -> {gluon, quark}, 
 "Request" -> <|"Loops" -> 0, "Incoming" -> {V[1], F[3, {1}]}, 
   "Outgoing" -> {V[5], F[3, {1}]}, "IncomingMomenta" -> {q, p}, 
   "OutgoingMomenta" -> {k1, k2}|>, "InputHash" -> 63001532003837941933809530\
444602493970203564732560883096079224437955352972499|>
