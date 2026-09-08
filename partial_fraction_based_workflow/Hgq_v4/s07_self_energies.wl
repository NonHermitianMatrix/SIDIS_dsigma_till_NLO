<|"Quark" -> <|"ReducedInsertion" -> 
    -1/4*((-2 + D)*Pi^2*(-1 + SUNN)*(1 + SUNN)*PaVe[0, {rho}, {0, 0}])/SUNN, 
   "OnShell" -> ((-1 + SUNN)*(1 + SUNN))/(32*EpsilonIR*Pi^2*SUNN) - 
     ((-1 + SUNN)*(1 + SUNN))/(32*EpsilonUV*Pi^2*SUNN)|>, 
 "GluonGauge" -> <|"ReducedInsertion" -> 
    ((-2 + 3*D)*Pi^2*SUNN*PaVe[0, {rho}, {0, 0}])/(2*(-1 + D)), 
   "OnShell" -> (-5*SUNN)/(48*EpsilonIR*Pi^2) + 
     (5*SUNN)/(48*EpsilonUV*Pi^2)|>, "GluonOneFlavor" -> 
  <|"ReducedInsertion" -> -(((-2 + D)*Pi^2*PaVe[0, {rho}, {0, 0}])/(-1 + D)), 
   "OnShell" -> 1/(24*EpsilonIR*Pi^2) - 1/(24*EpsilonUV*Pi^2)|>, 
 "FieldResidues" -> 
  <|quark -> ((-1 + SUNN)*(1 + SUNN))/(32*EpsilonIR*Pi^2*SUNN) - 
     ((-1 + SUNN)*(1 + SUNN))/(32*EpsilonUV*Pi^2*SUNN), 
   antiquark -> -1/32*1/(EpsilonIR*Pi^2*SUNN) + 1/(32*EpsilonUV*Pi^2*SUNN) + 
     SUNN/(32*EpsilonIR*Pi^2) - SUNN/(32*EpsilonUV*Pi^2), 
   gluon -> Nf*(1/(24*EpsilonIR*Pi^2) - 1/(24*EpsilonUV*Pi^2)) - 
     (5*SUNN)/(48*EpsilonIR*Pi^2) + (5*SUNN)/(48*EpsilonUV*Pi^2)|>, 
 "GeneratedInputs" -> 
  {<|"Diagrams" -> TopologyList[Process -> {F[3, {1, Index[Colour, 1]}]} -> 
         {F[3, {1, Index[Colour, 2]}]}, Model -> {"SMQCD"}, 
       GenericModel -> {"Lorentz"}, InsertionLevel -> {Particles}, 
       ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], 
         -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], F[2, {1}], 
         -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], S[1], S[2], -S[3], 
         S[3], -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], V[1], 
         V[2], -V[3], V[3]}, ExcludeFieldPoints -> {}, LastSelections -> {}][
      Topology[2][Propagator[Incoming][Vertex[1][1], Vertex[3][3], Field[1]], 
        Propagator[Outgoing][Vertex[1][2], Vertex[3][4], Field[2]], 
        Propagator[FALoop[1]][Vertex[3][3], Vertex[3][4], Field[3]], 
        Propagator[FALoop[1]][Vertex[3][3], Vertex[3][4], Field[4]]] -> 
       Insertions[Generic][FeynmanGraph[1, Generic == 1][
          Field[1] -> F[3, {1, Index[Colour, 1]}], Field[2] -> 
           -F[3, {1, Index[Colour, 2]}], Field[3] -> F, Field[4] -> V] -> 
         Insertions[Particles][FeynmanGraph[1, Particles == 1][
           Field[1] -> F[3, {1, Index[Colour, 1]}], Field[2] -> 
            -F[3, {1, Index[Colour, 2]}], Field[3] -> 
            F[3, {1, Index[Colour, 3]}], Field[4] -> 
            V[5, {Index[Gluon, 3]}]]]]], "Amplitudes" -> 
     {-2*DiracGamma[Momentum[ell, D], D]*FeynAmpDenominator[
         PropagatorDenominator[Momentum[ell, D], 0], PropagatorDenominator[
          Momentum[ell - v, D], 0]]*SUNTF[{SUNIndex[Glu3]}, SUNFIndex[Col2], 
         SUNFIndex[Col3]]*SUNTF[{SUNIndex[Glu3]}, SUNFIndex[Col3], 
         SUNFIndex[Col1]] + D*DiracGamma[Momentum[ell, D], D]*
        FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
         PropagatorDenominator[Momentum[ell - v, D], 0]]*
        SUNTF[{SUNIndex[Glu3]}, SUNFIndex[Col2], SUNFIndex[Col3]]*
        SUNTF[{SUNIndex[Glu3]}, SUNFIndex[Col3], SUNFIndex[Col1]]}|>, 
   <|"Diagrams" -> TopologyList[Process -> {V[5, {Index[Gluon, 1]}]} -> 
         {V[5, {Index[Gluon, 2]}]}, Model -> {"SMQCD"}, 
       GenericModel -> {"Lorentz"}, InsertionLevel -> {Particles}, 
       ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[3], F[3], -F[4], 
         F[4], -F[1, {1}], F[1, {1}], -F[1, {2}], F[1, {2}], -F[1, {3}], 
         F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], F[2, {2}], -F[2, {3}], 
         F[2, {3}], -F[3, {1, _}], F[3, {1, _}], -F[3, {2, _}], F[3, {2, _}], 
         -F[3, {3, _}], F[3, {3, _}], -F[4, {1, _}], F[4, {1, _}], 
         -F[4, {2, _}], F[4, {2, _}], -F[4, {3, _}], F[4, {3, _}], S[1], 
         S[2], -S[3], S[3], -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], 
         U[4], V[1], V[2], -V[3], V[3]}, ExcludeFieldPoints -> {}, 
       LastSelections -> {}][Topology[2][Propagator[Incoming][Vertex[1][1], 
         Vertex[4][3], Field[1]], Propagator[Outgoing][Vertex[1][2], 
         Vertex[4][3], Field[2]], Propagator[FALoop[1]][Vertex[4][3], 
         Vertex[4][3], Field[3]]] -> Insertions[Generic][
        FeynmanGraph[2, Generic == 1][Field[1] -> V[5, {Index[Gluon, 1]}], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> V] -> 
         Insertions[Particles][FeynmanGraph[2, Particles == 1][
           Field[1] -> V[5, {Index[Gluon, 1]}], Field[2] -> 
            V[5, {Index[Gluon, 2]}], Field[3] -> V[5, {Index[Gluon, 3]}]]]], 
      Topology[2][Propagator[Incoming][Vertex[1][1], Vertex[3][3], Field[1]], 
        Propagator[Outgoing][Vertex[1][2], Vertex[3][4], Field[2]], 
        Propagator[FALoop[1]][Vertex[3][3], Vertex[3][4], Field[3]], 
        Propagator[FALoop[1]][Vertex[3][3], Vertex[3][4], Field[4]]] -> 
       Insertions[Generic][FeynmanGraph[2, Generic == 1][
          Field[1] -> V[5, {Index[Gluon, 1]}], Field[2] -> 
           V[5, {Index[Gluon, 2]}], Field[3] -> U, Field[4] -> U] -> 
         Insertions[Particles][FeynmanGraph[1, Particles == 1][
           Field[1] -> V[5, {Index[Gluon, 1]}], Field[2] -> 
            V[5, {Index[Gluon, 2]}], Field[3] -> -U[5, {Index[Gluon, 3]}], 
           Field[4] -> U[5, {Index[Gluon, 4]}]]], 
        FeynmanGraph[2, Generic == 2][Field[1] -> V[5, {Index[Gluon, 1]}], 
          Field[2] -> V[5, {Index[Gluon, 2]}], Field[3] -> V, 
          Field[4] -> V] -> Insertions[Particles][
          FeynmanGraph[2, Particles == 1][Field[1] -> 
            V[5, {Index[Gluon, 1]}], Field[2] -> V[5, {Index[Gluon, 2]}], 
           Field[3] -> V[5, {Index[Gluon, 3]}], Field[4] -> 
            V[5, {Index[Gluon, 4]}]]]]], "Amplitudes" -> 
     {(-1/2*I)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0]]*
       Pair[LorentzIndex[Lor3, D], LorentzIndex[Lor4, D]]*
       (I*Pair[LorentzIndex[Lor1, D], LorentzIndex[Lor4, D]]*
         Pair[LorentzIndex[Lor2, D], LorentzIndex[Lor3, D]]*
         SUNF[SUNIndex[Glu1], SUNIndex[Glu3], SUNIndex[$AL$10113]]*
         SUNF[SUNIndex[Glu2], SUNIndex[Glu3], SUNIndex[$AL$10113]] - 
        I*Pair[LorentzIndex[Lor1, D], LorentzIndex[Lor2, D]]*
         Pair[LorentzIndex[Lor3, D], LorentzIndex[Lor4, D]]*
         (SUNF[SUNIndex[Glu1], SUNIndex[Glu3], SUNIndex[$AL$10114]]*
           SUNF[SUNIndex[Glu2], SUNIndex[Glu3], SUNIndex[$AL$10114]] + 
          SUNF[SUNIndex[Glu1], SUNIndex[Glu3], SUNIndex[$AL$10115]]*
           SUNF[SUNIndex[Glu2], SUNIndex[Glu3], SUNIndex[$AL$10115]]) + 
        I*Pair[LorentzIndex[Lor1, D], LorentzIndex[Lor3, D]]*
         Pair[LorentzIndex[Lor2, D], LorentzIndex[Lor4, D]]*
         SUNF[SUNIndex[Glu1], SUNIndex[Glu3], SUNIndex[$AL$10117]]*
         SUNF[SUNIndex[Glu2], SUNIndex[Glu3], SUNIndex[$AL$10117]]), 
      -(FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
         PropagatorDenominator[Momentum[ell - v, D], 0]]*
        Pair[LorentzIndex[Lor1, D], Momentum[ell - v, D]]*
        Pair[LorentzIndex[Lor2, D], Momentum[ell, D]]*SUNF[SUNIndex[Glu1], 
         SUNIndex[Glu3], SUNIndex[Glu4]]*SUNF[SUNIndex[Glu2], SUNIndex[Glu3], 
         SUNIndex[Glu4]]), -1/2*(FeynAmpDenominator[PropagatorDenominator[
          Momentum[ell, D], 0], PropagatorDenominator[Momentum[ell - v, D], 
          0]]*Pair[LorentzIndex[Lor3, D], LorentzIndex[Lor4, D]]*
        Pair[LorentzIndex[Lor5, D], LorentzIndex[Lor6, D]]*
        (Pair[LorentzIndex[Lor1, D], Momentum[2*ell - v, D]]*
          Pair[LorentzIndex[Lor3, D], LorentzIndex[Lor5, D]] + 
         Pair[LorentzIndex[Lor1, D], LorentzIndex[Lor5, D]]*
          Pair[LorentzIndex[Lor3, D], Momentum[-ell + 2*v, D]] + 
         Pair[LorentzIndex[Lor1, D], LorentzIndex[Lor3, D]]*
          Pair[LorentzIndex[Lor5, D], Momentum[-ell - v, D]])*
        (Pair[LorentzIndex[Lor2, D], Momentum[-2*ell + v, D]]*
          Pair[LorentzIndex[Lor4, D], LorentzIndex[Lor6, D]] + 
         Pair[LorentzIndex[Lor2, D], LorentzIndex[Lor6, D]]*
          Pair[LorentzIndex[Lor4, D], Momentum[ell - 2*v, D]] + 
         Pair[LorentzIndex[Lor2, D], LorentzIndex[Lor4, D]]*
          Pair[LorentzIndex[Lor6, D], Momentum[ell + v, D]])*
        SUNF[SUNIndex[Glu1], SUNIndex[Glu3], SUNIndex[Glu4]]*
        SUNF[SUNIndex[Glu2], SUNIndex[Glu3], SUNIndex[Glu4]])}|>, 
   <|"Diagrams" -> TopologyList[Process -> {V[5, {Index[Gluon, 1]}]} -> 
         {V[5, {Index[Gluon, 2]}]}, Model -> {"SMQCD"}, 
       GenericModel -> {"Lorentz"}, InsertionLevel -> {Particles}, 
       ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[4], F[4], 
         -F[1, {1}], F[1, {1}], -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], 
         -F[2, {1}], F[2, {1}], -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], 
         -F[3, {2, _}], F[3, {2, _}], -F[3, {3, _}], F[3, {3, _}], 
         -F[4, {1, _}], F[4, {1, _}], -F[4, {2, _}], F[4, {2, _}], 
         -F[4, {3, _}], F[4, {3, _}], S[1], S[2], -S[3], S[3], -U[1], U[1], 
         -U[2], U[2], -U[3], U[3], -U[4], U[4], -U[5], U[5], -U[5, {_}], 
         U[5, {_}], V[1], V[2], -V[3], V[3], V[5], V[5, {_}]}, 
       ExcludeFieldPoints -> {}, LastSelections -> {}][
      Topology[2][Propagator[Incoming][Vertex[1][1], Vertex[3][3], Field[1]], 
        Propagator[Outgoing][Vertex[1][2], Vertex[3][4], Field[2]], 
        Propagator[FALoop[1]][Vertex[3][3], Vertex[3][4], Field[3]], 
        Propagator[FALoop[1]][Vertex[3][3], Vertex[3][4], Field[4]]] -> 
       Insertions[Generic][FeynmanGraph[2, Generic == 1][
          Field[1] -> V[5, {Index[Gluon, 1]}], Field[2] -> 
           V[5, {Index[Gluon, 2]}], Field[3] -> F, Field[4] -> F] -> 
         Insertions[Particles][FeynmanGraph[1, Particles == 1][
           Field[1] -> V[5, {Index[Gluon, 1]}], Field[2] -> 
            V[5, {Index[Gluon, 2]}], Field[3] -> 
            -F[3, {1, Index[Colour, 3]}], Field[4] -> 
            F[3, {1, Index[Colour, 4]}]]]]], "Amplitudes" -> 
     {-8*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
         PropagatorDenominator[Momentum[ell - v, D], 0]]*
        Pair[LorentzIndex[Lor1, D], Momentum[ell, D]]*
        Pair[LorentzIndex[Lor2, D], Momentum[ell, D]]*SUNTF[{SUNIndex[Glu1]}, 
         SUNFIndex[Col4], SUNFIndex[Col3]]*SUNTF[{SUNIndex[Glu2]}, 
         SUNFIndex[Col3], SUNFIndex[Col4]] + 
       4*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
         PropagatorDenominator[Momentum[ell - v, D], 0]]*
        Pair[LorentzIndex[Lor1, D], Momentum[v, D]]*
        Pair[LorentzIndex[Lor2, D], Momentum[ell, D]]*SUNTF[{SUNIndex[Glu1]}, 
         SUNFIndex[Col4], SUNFIndex[Col3]]*SUNTF[{SUNIndex[Glu2]}, 
         SUNFIndex[Col3], SUNFIndex[Col4]] + 
       4*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
         PropagatorDenominator[Momentum[ell - v, D], 0]]*
        Pair[LorentzIndex[Lor1, D], Momentum[ell, D]]*
        Pair[LorentzIndex[Lor2, D], Momentum[v, D]]*SUNTF[{SUNIndex[Glu1]}, 
         SUNFIndex[Col4], SUNFIndex[Col3]]*SUNTF[{SUNIndex[Glu2]}, 
         SUNFIndex[Col3], SUNFIndex[Col4]] + 
       4*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
         PropagatorDenominator[Momentum[ell - v, D], 0]]*
        Pair[LorentzIndex[Lor1, D], LorentzIndex[Lor2, D]]*
        Pair[Momentum[ell, D], Momentum[ell, D]]*SUNTF[{SUNIndex[Glu1]}, 
         SUNFIndex[Col4], SUNFIndex[Col3]]*SUNTF[{SUNIndex[Glu2]}, 
         SUNFIndex[Col3], SUNFIndex[Col4]] - 
       4*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
         PropagatorDenominator[Momentum[ell - v, D], 0]]*
        Pair[LorentzIndex[Lor1, D], LorentzIndex[Lor2, D]]*
        Pair[Momentum[ell, D], Momentum[v, D]]*SUNTF[{SUNIndex[Glu1]}, 
         SUNFIndex[Col4], SUNFIndex[Col3]]*SUNTF[{SUNIndex[Glu2]}, 
         SUNFIndex[Col3], SUNFIndex[Col4]]}|>}|>
