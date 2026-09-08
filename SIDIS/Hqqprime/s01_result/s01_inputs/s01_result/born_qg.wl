<|"graphs" -> TopologyList[Process -> {V[1], F[3, {1, Index[Colour, 2]}]} -> 
      {V[5, {Index[Gluon, 3]}], F[3, {1, Index[Colour, 4]}]}, 
    Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
    InsertionLevel -> {Particles}, ExcludeParticles -> {}, 
    ExcludeFieldPoints -> {}, LastSelections -> {}][
   Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
     Propagator[Incoming][Vertex[1][2], Vertex[3][5], Field[2]], 
     Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
     Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
     Propagator[Internal][Vertex[3][5], Vertex[3][6], Field[5]]] -> 
    Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
       Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
        V[5, {Index[Gluon, 3]}], Field[4] -> -F[3, {1, Index[Colour, 4]}], 
       Field[5] -> F] -> Insertions[Particles][
       FeynmanGraph[1, Particles == 1][Field[1] -> V[1], 
        Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
         V[5, {Index[Gluon, 3]}], Field[4] -> -F[3, {1, Index[Colour, 4]}], 
        Field[5] -> F[3, {1, Index[Colour, 2]}]]]], 
   Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
     Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
     Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
     Propagator[Outgoing][Vertex[1][4], Vertex[3][5], Field[4]], 
     Propagator[Internal][Vertex[3][5], Vertex[3][6], Field[5]]] -> 
    Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
       Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
        V[5, {Index[Gluon, 3]}], Field[4] -> -F[3, {1, Index[Colour, 4]}], 
       Field[5] -> F] -> Insertions[Particles][
       FeynmanGraph[1, Particles == 1][Field[1] -> V[1], 
        Field[2] -> F[3, {1, Index[Colour, 2]}], Field[3] -> 
         V[5, {Index[Gluon, 3]}], Field[4] -> -F[3, {1, Index[Colour, 4]}], 
        Field[5] -> -F[3, {1, Index[Colour, 4]}]]]]], 
 "raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, {}}, 
       {F[3, {1, Index[Colour, 2]}], FourMomentum[Incoming, 2], FCGV["MU"], 
        {(2*Charge)/3, (2*ColorCharge)/Sqrt[3]}}} -> 
      {{V[5, {Index[Gluon, 3]}], FourMomentum[Outgoing, 1], 0, 
        {Sqrt[3]*ColorCharge}}, {F[3, {1, Index[Colour, 4]}], 
        FourMomentum[Outgoing, 2], FCGV["MU"], {(2*Charge)/3, 
         (2*ColorCharge)/Sqrt[3]}}}, Model -> {"SMQCD"}, 
    GenericModel -> {"Lorentz"}, AmplitudeLevel -> {Particles}, 
    ExcludeParticles -> {}, ExcludeFieldPoints -> {}, LastSelections -> {}][
   FAFeynAmp[GraphID[Topology == 1, Generic == 1, Particles == 1, 
     Number == 1], Integral[], I*FAPolarizationVector[V[1], 
      FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
     FAPropagatorDenominator[-FourMomentum[Outgoing, 1] - 
       FourMomentum[Outgoing, 2], FCGV["MU"]]*
     FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 2], 
        FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 2]], FAChiralityProjector[-1]]*
        FASUNT[Index[Gluon, 3], Index[Colour, 4], Index[Colour, 2]] - 
       I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
         FAChiralityProjector[1]]*FASUNT[Index[Gluon, 3], Index[Colour, 4], 
         Index[Colour, 2]], FANonCommutative[
       FADiracSlash[FourMomentum[Outgoing, 1] + FourMomentum[Outgoing, 2]] + 
        FCGV["MU"]], (-I)*eq*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
       I*eq*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
         FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
       FADiracSpinor[FourMomentum[Incoming, 2], FCGV["MU"]]]]*
     SumOver[Index[Colour, 2], 3, External]*SumOver[Index[Colour, 4], 3, 
      External]*SumOver[Index[Gluon, 3], 8, External]*
     Conjugate[FAPolarizationVector][V[5, {Index[Gluon, 3]}], 
      FourMomentum[Outgoing, 1], Index[Lorentz, 2]]], 
   FAFeynAmp[GraphID[Topology == 2, Generic == 1, Particles == 1, 
     Number == 2], Integral[], I*FAPolarizationVector[V[1], 
      FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
     FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
       FourMomentum[Outgoing, 1], FCGV["MU"]]*
     FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 2], 
        FCGV["MU"]]], (-I)*eq*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
       I*eq*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
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
      Index[Lorentz, 2]]]], "amplitudes" -> 
  {(-I)*ee*eq*gs*Spinor[Momentum[k2, D], 0, 1] . 
     DiracGamma[LorentzIndex[Lor2, D], D] . DiracGamma[Momentum[k1 + k2, D], 
      D] . DiracGamma[LorentzIndex[Lor1, D], D] . Spinor[Momentum[p, D], 0, 
      1]*FeynAmpDenominator[PropagatorDenominator[Momentum[-k1 - k2, D], 0]]*
    Pair[LorentzIndex[Lor1, D], Momentum[Polarization[q, I], D]]*
    Pair[LorentzIndex[Lor2, D], Momentum[Polarization[k1, -I], D]]*
    SUNTF[{SUNIndex[Glu3]}, SUNFIndex[Col4], SUNFIndex[Col2]], 
   (-I)*ee*eq*gs*Spinor[Momentum[k2, D], 0, 1] . 
     DiracGamma[LorentzIndex[Lor1, D], D] . DiracGamma[Momentum[-k1 + p, D], 
      D] . DiracGamma[LorentzIndex[Lor2, D], D] . Spinor[Momentum[p, D], 0, 
      1]*FeynAmpDenominator[PropagatorDenominator[Momentum[k1 - p, D], 0]]*
    Pair[LorentzIndex[Lor1, D], Momentum[Polarization[q, I], D]]*
    Pair[LorentzIndex[Lor2, D], Momentum[Polarization[k1, -I], D]]*
    SUNTF[{SUNIndex[Glu3]}, SUNFIndex[Col4], SUNFIndex[Col2]]}, 
 "incoming" -> {q, p}, "outgoing" -> {k1, k2}, 
 "incoming_fields" -> {V[1], F[3, {1}]}, "outgoing_fields" -> 
  {V[5], F[3, {1}]}, "all_diagram_count" -> 2, "symmetry_weight" -> 1, 
 "model_charges" -> <|"eq" -> 2/3, "eqp" -> -1/3|>|>
