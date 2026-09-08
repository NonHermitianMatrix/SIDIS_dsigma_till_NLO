<|"graphs" -> TopologyList[Process -> {V[1], V[5, {Index[Gluon, 2]}]} -> 
      {F[4, {1, Index[Colour, 3]}], -F[4, {1, Index[Colour, 4]}]}, 
    Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
    InsertionLevel -> {Particles}, ExcludeParticles -> {}, 
    ExcludeFieldPoints -> {}, LastSelections -> {}][
   Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
     Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
     Propagator[Outgoing][Vertex[1][3], Vertex[3][5], Field[3]], 
     Propagator[Outgoing][Vertex[1][4], Vertex[3][6], Field[4]], 
     Propagator[Internal][Vertex[3][5], Vertex[3][6], Field[5]]] -> 
    Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
       Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
        -F[4, {1, Index[Colour, 3]}], Field[4] -> 
        F[4, {1, Index[Colour, 4]}], Field[5] -> F] -> 
      Insertions[Particles][FeynmanGraph[1, Particles == 1][Field[1] -> V[1], 
        Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
         -F[4, {1, Index[Colour, 3]}], Field[4] -> 
         F[4, {1, Index[Colour, 4]}], Field[5] -> 
         -F[4, {1, Index[Colour, 3]}]]]], 
   Topology[1][Propagator[Incoming][Vertex[1][1], Vertex[3][5], Field[1]], 
     Propagator[Incoming][Vertex[1][2], Vertex[3][6], Field[2]], 
     Propagator[Outgoing][Vertex[1][3], Vertex[3][6], Field[3]], 
     Propagator[Outgoing][Vertex[1][4], Vertex[3][5], Field[4]], 
     Propagator[Internal][Vertex[3][5], Vertex[3][6], Field[5]]] -> 
    Insertions[Generic][FeynmanGraph[1, Generic == 1][Field[1] -> V[1], 
       Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
        -F[4, {1, Index[Colour, 3]}], Field[4] -> 
        F[4, {1, Index[Colour, 4]}], Field[5] -> F] -> 
      Insertions[Particles][FeynmanGraph[1, Particles == 1][Field[1] -> V[1], 
        Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
         -F[4, {1, Index[Colour, 3]}], Field[4] -> 
         F[4, {1, Index[Colour, 4]}], Field[5] -> 
         F[4, {1, Index[Colour, 4]}]]]]], 
 "raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, {}}, 
       {V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 0, 
        {Sqrt[3]*ColorCharge}}} -> {{F[4, {1, Index[Colour, 3]}], 
        FourMomentum[Outgoing, 1], FCGV["MD"], {-1/3*Charge, 
         (2*ColorCharge)/Sqrt[3]}}, {-F[4, {1, Index[Colour, 4]}], 
        FourMomentum[Outgoing, 2], FCGV["MD"], {Charge/3, 
         (-2*ColorCharge)/Sqrt[3]}}}, Model -> {"SMQCD"}, 
    GenericModel -> {"Lorentz"}, AmplitudeLevel -> {Particles}, 
    ExcludeParticles -> {}, ExcludeFieldPoints -> {}, LastSelections -> {}][
   FAFeynAmp[GraphID[Topology == 1, Generic == 1, Particles == 1, 
     Number == 1], Integral[], (-I)*FAPolarizationVector[V[1], 
      FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
     FAPolarizationVector[V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 
      Index[Lorentz, 2]]*FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
       FourMomentum[Outgoing, 2], FCGV["MD"]]*
     FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
        FCGV["MD"]]], (-I)*eqp*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
       I*eqp*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
         FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
       FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 2]] + 
        FCGV["MD"]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 2]], FAChiralityProjector[-1]]*
        FASUNT[Index[Gluon, 2], Index[Colour, 3], Index[Colour, 4]] - 
       I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
         FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 3], 
         Index[Colour, 4]], FANonCommutative[FADiracSpinor[
        -FourMomentum[Outgoing, 2], FCGV["MD"]]]]*SumOver[Index[Colour, 3], 
      3, External]*SumOver[Index[Colour, 4], 3, External]*
     SumOver[Index[Gluon, 2], 8, External]], 
   FAFeynAmp[GraphID[Topology == 2, Generic == 1, Particles == 1, 
     Number == 2], Integral[], (-I)*FAPolarizationVector[V[1], 
      FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
     FAPolarizationVector[V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 
      Index[Lorentz, 2]]*FAPropagatorDenominator[FourMomentum[Incoming, 2] - 
       FourMomentum[Outgoing, 1], FCGV["MD"]]*
     FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
        FCGV["MD"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 2]], FAChiralityProjector[-1]]*
        FASUNT[Index[Gluon, 2], Index[Colour, 3], Index[Colour, 4]] - 
       I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
         FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 3], 
         Index[Colour, 4]], FANonCommutative[
       FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 1]] + 
        FCGV["MD"]], (-I)*eqp*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
       I*eqp*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
         FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
       FADiracSpinor[-FourMomentum[Outgoing, 2], FCGV["MD"]]]]*
     SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
      External]*SumOver[Index[Gluon, 2], 8, External]]], 
 "amplitudes" -> {I*ee*eqp*gs*Spinor[Momentum[k1, D], 0, 1] . 
     DiracGamma[LorentzIndex[Lor1, D], D] . DiracGamma[Momentum[-k2 + p, D], 
      D] . DiracGamma[LorentzIndex[Lor2, D], D] . Spinor[-Momentum[k2, D], 0, 
      1]*FeynAmpDenominator[PropagatorDenominator[Momentum[k2 - p, D], 0]]*
    Pair[LorentzIndex[Lor1, D], Momentum[Polarization[q, I], D]]*
    Pair[LorentzIndex[Lor2, D], Momentum[Polarization[p, I], D]]*
    SUNTF[{SUNIndex[Glu2]}, SUNFIndex[Col3], SUNFIndex[Col4]], 
   I*ee*eqp*gs*Spinor[Momentum[k1, D], 0, 1] . 
     DiracGamma[LorentzIndex[Lor2, D], D] . DiracGamma[Momentum[k1 - p, D], 
      D] . DiracGamma[LorentzIndex[Lor1, D], D] . Spinor[-Momentum[k2, D], 0, 
      1]*FeynAmpDenominator[PropagatorDenominator[Momentum[-k1 + p, D], 0]]*
    Pair[LorentzIndex[Lor1, D], Momentum[Polarization[q, I], D]]*
    Pair[LorentzIndex[Lor2, D], Momentum[Polarization[p, I], D]]*
    SUNTF[{SUNIndex[Glu2]}, SUNFIndex[Col3], SUNFIndex[Col4]]}, 
 "incoming" -> {q, p}, "outgoing" -> {k1, k2}, 
 "incoming_fields" -> {V[1], V[5]}, "outgoing_fields" -> 
  {F[4, {1}], -F[4, {1}]}, "all_diagram_count" -> 2, "symmetry_weight" -> 1, 
 "model_charges" -> <|"eq" -> 2/3, "eqp" -> -1/3|>|>
