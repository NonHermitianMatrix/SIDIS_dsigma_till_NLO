<|"graphs" -> TopologyList[Process -> {V[1], V[5, {Index[Gluon, 2]}]} -> 
      {F[3, {1, Index[Colour, 3]}], -F[3, {1, Index[Colour, 4]}]}, 
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
        -F[3, {1, Index[Colour, 3]}], Field[4] -> 
        F[3, {1, Index[Colour, 4]}], Field[5] -> F] -> 
      Insertions[Particles][FeynmanGraph[1, Particles == 1][Field[1] -> V[1], 
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
      Insertions[Particles][FeynmanGraph[1, Particles == 1][Field[1] -> V[1], 
        Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> 
         -F[3, {1, Index[Colour, 3]}], Field[4] -> 
         F[3, {1, Index[Colour, 4]}], Field[5] -> 
         F[3, {1, Index[Colour, 4]}]]]]], 
 "raw" -> FAFeynAmpList[Process -> {{V[1], FourMomentum[Incoming, 1], 0, {}}, 
       {V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 0, 
        {Sqrt[3]*ColorCharge}}} -> {{F[3, {1, Index[Colour, 3]}], 
        FourMomentum[Outgoing, 1], FCGV["MU"], {(2*Charge)/3, 
         (2*ColorCharge)/Sqrt[3]}}, {-F[3, {1, Index[Colour, 4]}], 
        FourMomentum[Outgoing, 2], FCGV["MU"], {(-2*Charge)/3, 
         (-2*ColorCharge)/Sqrt[3]}}}, Model -> {"SMQCD"}, 
    GenericModel -> {"Lorentz"}, AmplitudeLevel -> {Particles}, 
    ExcludeParticles -> {}, ExcludeFieldPoints -> {}, LastSelections -> {}][
   FAFeynAmp[GraphID[Topology == 1, Generic == 1, Particles == 1, 
     Number == 1], Integral[], (-I)*FAPolarizationVector[V[1], 
      FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
     FAPolarizationVector[V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 
      Index[Lorentz, 2]]*FAPropagatorDenominator[-FourMomentum[Incoming, 2] + 
       FourMomentum[Outgoing, 2], FCGV["MU"]]*
     FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
        FCGV["MU"]]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
       ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
         FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
       FADiracSlash[FourMomentum[Incoming, 2] - FourMomentum[Outgoing, 2]] + 
        FCGV["MU"]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 2]], FAChiralityProjector[-1]]*
        FASUNT[Index[Gluon, 2], Index[Colour, 3], Index[Colour, 4]] - 
       I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
         FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 3], 
         Index[Colour, 4]], FANonCommutative[FADiracSpinor[
        -FourMomentum[Outgoing, 2], FCGV["MU"]]]]*SumOver[Index[Colour, 3], 
      3, External]*SumOver[Index[Colour, 4], 3, External]*
     SumOver[Index[Gluon, 2], 8, External]], 
   FAFeynAmp[GraphID[Topology == 2, Generic == 1, Particles == 1, 
     Number == 2], Integral[], (-I)*FAPolarizationVector[V[1], 
      FourMomentum[Incoming, 1], Index[Lorentz, 1]]*
     FAPolarizationVector[V[5, {Index[Gluon, 2]}], FourMomentum[Incoming, 2], 
      Index[Lorentz, 2]]*FAPropagatorDenominator[FourMomentum[Incoming, 2] - 
       FourMomentum[Outgoing, 1], FCGV["MU"]]*
     FermionChain[FANonCommutative[FADiracSpinor[FourMomentum[Outgoing, 1], 
        FCGV["MU"]]], (-I)*FAGS*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 2]], FAChiralityProjector[-1]]*
        FASUNT[Index[Gluon, 2], Index[Colour, 3], Index[Colour, 4]] - 
       I*FAGS*FANonCommutative[FADiracMatrix[Index[Lorentz, 2]], 
         FAChiralityProjector[1]]*FASUNT[Index[Gluon, 2], Index[Colour, 3], 
         Index[Colour, 4]], FANonCommutative[
       FADiracSlash[-FourMomentum[Incoming, 2] + FourMomentum[Outgoing, 1]] + 
        FCGV["MU"]], ((-2*I)/3)*FANonCommutative[FADiracMatrix[
          Index[Lorentz, 1]], FAChiralityProjector[-1]]*FCGV["EL"] - 
       ((2*I)/3)*FANonCommutative[FADiracMatrix[Index[Lorentz, 1]], 
         FAChiralityProjector[1]]*FCGV["EL"], FANonCommutative[
       FADiracSpinor[-FourMomentum[Outgoing, 2], FCGV["MU"]]]]*
     SumOver[Index[Colour, 3], 3, External]*SumOver[Index[Colour, 4], 3, 
      External]*SumOver[Index[Gluon, 2], 8, External]]], 
 "amplitudes" -> {(-I)*Spinor[Momentum[k1, D], 0, 1] . 
     ((-I)*ee*eq*DiracGamma[LorentzIndex[Lor1, D], D]) . 
     DiracGamma[Momentum[-k2 + p, D], D] . 
     ((-I)*gs*DiracGamma[LorentzIndex[Lor2, D], D]*SUNTF[{SUNIndex[Glu2]}, 
       SUNFIndex[Col3], SUNFIndex[Col4]]) . Spinor[-Momentum[k2, D], 0, 1]*
    FeynAmpDenominator[PropagatorDenominator[Momentum[k2 - p, D], 0]]*
    Pair[LorentzIndex[Lor1, D], Momentum[Polarization[q, I], D]]*
    Pair[LorentzIndex[Lor2, D], Momentum[Polarization[p, I], D]], 
   (-I)*Spinor[Momentum[k1, D], 0, 1] . 
     ((-I)*gs*DiracGamma[LorentzIndex[Lor2, D], D]*SUNTF[{SUNIndex[Glu2]}, 
       SUNFIndex[Col3], SUNFIndex[Col4]]) . DiracGamma[Momentum[k1 - p, D], 
      D] . ((-I)*ee*eq*DiracGamma[LorentzIndex[Lor1, D], D]) . 
     Spinor[-Momentum[k2, D], 0, 1]*FeynAmpDenominator[
     PropagatorDenominator[Momentum[-k1 + p, D], 0]]*
    Pair[LorentzIndex[Lor1, D], Momentum[Polarization[q, I], D]]*
    Pair[LorentzIndex[Lor2, D], Momentum[Polarization[p, I], D]]}, 
 "incoming" -> {q, p}, "outgoing" -> {k1, k2}|>
