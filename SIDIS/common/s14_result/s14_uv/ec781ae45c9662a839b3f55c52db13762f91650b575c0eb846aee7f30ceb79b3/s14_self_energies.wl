<|"Generated" -> 
  <|"quark" -> <|"Diagrams" -> 
      TopologyList[Process -> {F[3, {1, Index[Colour, 1]}]} -> 
          {F[3, {1, Index[Colour, 2]}]}, Model -> {"SMQCD"}, 
        GenericModel -> {"Lorentz"}, InsertionLevel -> {Particles}, 
        ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[1, {1}], F[1, {1}], 
          -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], 
          F[2, {1}], -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], S[1], 
          S[2], -S[3], S[3], -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], 
          U[4], V[1], V[2], -V[3], V[3]}, ExcludeFieldPoints -> {}, 
        LastSelections -> {}][Topology[2][Propagator[Incoming][Vertex[1][1], 
          Vertex[3][3], Field[1]], Propagator[Outgoing][Vertex[1][2], 
          Vertex[3][4], Field[2]], Propagator[FALoop[1]][Vertex[3][3], 
          Vertex[3][4], Field[3]], Propagator[FALoop[1]][Vertex[3][3], 
          Vertex[3][4], Field[4]]] -> Insertions[Generic][
         FeynmanGraph[1, Generic == 1][Field[1] -> 
            F[3, {1, Index[Colour, 1]}], Field[2] -> 
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
         SUNTF[{SUNIndex[Glu3]}, SUNFIndex[Col3], SUNFIndex[Col1]]}, 
     "MassSpecialization" -> {}|>, 
   "gauge" -> <|"Diagrams" -> TopologyList[Process -> 
         {V[5, {Index[Gluon, 1]}]} -> {V[5, {Index[Gluon, 2]}]}, 
        Model -> {"SMQCD"}, GenericModel -> {"Lorentz"}, 
        InsertionLevel -> {Particles}, ExcludeParticles -> 
         {-F[1], F[1], -F[2], F[2], -F[3], F[3], -F[4], F[4], -F[1, {1}], 
          F[1, {1}], -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], 
          -F[2, {1}], F[2, {1}], -F[2, {2}], F[2, {2}], -F[2, {3}], 
          F[2, {3}], -F[3, {1, _}], F[3, {1, _}], -F[3, {2, _}], 
          F[3, {2, _}], -F[3, {3, _}], F[3, {3, _}], -F[4, {1, _}], 
          F[4, {1, _}], -F[4, {2, _}], F[4, {2, _}], -F[4, {3, _}], 
          F[4, {3, _}], S[1], S[2], -S[3], S[3], -U[1], U[1], -U[2], U[2], 
          -U[3], U[3], -U[4], U[4], V[1], V[2], -V[3], V[3]}, 
        ExcludeFieldPoints -> {}, LastSelections -> {}][
       Topology[2][Propagator[Incoming][Vertex[1][1], Vertex[4][3], 
          Field[1]], Propagator[Outgoing][Vertex[1][2], Vertex[4][3], 
          Field[2]], Propagator[FALoop[1]][Vertex[4][3], Vertex[4][3], 
          Field[3]]] -> Insertions[Generic][FeynmanGraph[2, Generic == 1][
           Field[1] -> V[5, {Index[Gluon, 1]}], Field[2] -> 
            V[5, {Index[Gluon, 2]}], Field[3] -> V] -> Insertions[Particles][
           FeynmanGraph[2, Particles == 1][Field[1] -> 
             V[5, {Index[Gluon, 1]}], Field[2] -> V[5, {Index[Gluon, 2]}], 
            Field[3] -> V[5, {Index[Gluon, 3]}]]]], 
       Topology[2][Propagator[Incoming][Vertex[1][1], Vertex[3][3], 
          Field[1]], Propagator[Outgoing][Vertex[1][2], Vertex[3][4], 
          Field[2]], Propagator[FALoop[1]][Vertex[3][3], Vertex[3][4], 
          Field[3]], Propagator[FALoop[1]][Vertex[3][3], Vertex[3][4], 
          Field[4]]] -> Insertions[Generic][FeynmanGraph[2, Generic == 1][
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
      {(-1/2*I)*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
          0]]*Pair[LorentzIndex[Lor3, D], LorentzIndex[Lor4, D]]*
        (I*Pair[LorentzIndex[Lor1, D], LorentzIndex[Lor4, D]]*
          Pair[LorentzIndex[Lor2, D], LorentzIndex[Lor3, D]]*
          SUNF[SUNIndex[Glu1], SUNIndex[Glu3], SUNIndex[$AL$10159]]*
          SUNF[SUNIndex[Glu2], SUNIndex[Glu3], SUNIndex[$AL$10159]] - 
         I*Pair[LorentzIndex[Lor1, D], LorentzIndex[Lor2, D]]*
          Pair[LorentzIndex[Lor3, D], LorentzIndex[Lor4, D]]*
          (SUNF[SUNIndex[Glu1], SUNIndex[Glu3], SUNIndex[$AL$10160]]*
            SUNF[SUNIndex[Glu2], SUNIndex[Glu3], SUNIndex[$AL$10160]] + 
           SUNF[SUNIndex[Glu1], SUNIndex[Glu3], SUNIndex[$AL$10161]]*
            SUNF[SUNIndex[Glu2], SUNIndex[Glu3], SUNIndex[$AL$10161]]) + 
         I*Pair[LorentzIndex[Lor1, D], LorentzIndex[Lor3, D]]*
          Pair[LorentzIndex[Lor2, D], LorentzIndex[Lor4, D]]*
          SUNF[SUNIndex[Glu1], SUNIndex[Glu3], SUNIndex[$AL$10163]]*
          SUNF[SUNIndex[Glu2], SUNIndex[Glu3], SUNIndex[$AL$10163]]), 
       -(FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
          PropagatorDenominator[Momentum[ell - v, D], 0]]*
         Pair[LorentzIndex[Lor1, D], Momentum[ell - v, D]]*
         Pair[LorentzIndex[Lor2, D], Momentum[ell, D]]*SUNF[SUNIndex[Glu1], 
          SUNIndex[Glu3], SUNIndex[Glu4]]*SUNF[SUNIndex[Glu2], 
          SUNIndex[Glu3], SUNIndex[Glu4]]), 
       -1/2*(FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
          PropagatorDenominator[Momentum[ell - v, D], 0]]*
         Pair[LorentzIndex[Lor3, D], LorentzIndex[Lor4, D]]*
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
         SUNF[SUNIndex[Glu2], SUNIndex[Glu3], SUNIndex[Glu4]])}, 
     "MassSpecialization" -> {}|>, "one_flavor" -> 
    <|"Diagrams" -> TopologyList[Process -> {V[5, {Index[Gluon, 1]}]} -> 
          {V[5, {Index[Gluon, 2]}]}, Model -> {"SMQCD"}, 
        GenericModel -> {"Lorentz"}, InsertionLevel -> {Particles}, 
        ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[4], F[4], 
          -F[1, {1}], F[1, {1}], -F[1, {2}], F[1, {2}], -F[1, {3}], 
          F[1, {3}], -F[2, {1}], F[2, {1}], -F[2, {2}], F[2, {2}], 
          -F[2, {3}], F[2, {3}], -F[3, {2, _}], F[3, {2, _}], -F[3, {3, _}], 
          F[3, {3, _}], -F[4, {1, _}], F[4, {1, _}], -F[4, {2, _}], 
          F[4, {2, _}], -F[4, {3, _}], F[4, {3, _}], S[1], S[2], -S[3], S[3], 
          -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], -U[5], U[5], 
          -U[5, {_}], U[5, {_}], V[1], V[2], -V[3], V[3], V[5], V[5, {_}]}, 
        ExcludeFieldPoints -> {}, LastSelections -> {}][
       Topology[2][Propagator[Incoming][Vertex[1][1], Vertex[3][3], 
          Field[1]], Propagator[Outgoing][Vertex[1][2], Vertex[3][4], 
          Field[2]], Propagator[FALoop[1]][Vertex[3][3], Vertex[3][4], 
          Field[3]], Propagator[FALoop[1]][Vertex[3][3], Vertex[3][4], 
          Field[4]]] -> Insertions[Generic][FeynmanGraph[2, Generic == 1][
           Field[1] -> V[5, {Index[Gluon, 1]}], Field[2] -> 
            V[5, {Index[Gluon, 2]}], Field[3] -> F, Field[4] -> F] -> 
          Insertions[Particles][FeynmanGraph[1, Particles == 1][
            Field[1] -> V[5, {Index[Gluon, 1]}], Field[2] -> 
             V[5, {Index[Gluon, 2]}], Field[3] -> -F[3, {1, Index[Colour, 
                 3]}], Field[4] -> F[3, {1, Index[Colour, 4]}]]]]], 
     "Amplitudes" -> {-8*FeynAmpDenominator[PropagatorDenominator[
           Momentum[ell, D], 0], PropagatorDenominator[Momentum[ell - v, D], 
           0]]*Pair[LorentzIndex[Lor1, D], Momentum[ell, D]]*
         Pair[LorentzIndex[Lor2, D], Momentum[ell, D]]*
         SUNTF[{SUNIndex[Glu1]}, SUNFIndex[Col4], SUNFIndex[Col3]]*
         SUNTF[{SUNIndex[Glu2]}, SUNFIndex[Col3], SUNFIndex[Col4]] + 
        4*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
          PropagatorDenominator[Momentum[ell - v, D], 0]]*
         Pair[LorentzIndex[Lor1, D], Momentum[v, D]]*
         Pair[LorentzIndex[Lor2, D], Momentum[ell, D]]*
         SUNTF[{SUNIndex[Glu1]}, SUNFIndex[Col4], SUNFIndex[Col3]]*
         SUNTF[{SUNIndex[Glu2]}, SUNFIndex[Col3], SUNFIndex[Col4]] + 
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
          SUNFIndex[Col3], SUNFIndex[Col4]]}, "MassSpecialization" -> {}|>|>, 
 "Maps" -> <|"quark" -> <|"OriginalIntegrand" -> 
      (-1/4*I)*((4*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
            0], PropagatorDenominator[Momentum[ell, D] - Momentum[q, D], 0]]*
          Pair[Momentum[ell, D], Momentum[q, D]])/(Q2*SUNN) - 
        (2*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
           PropagatorDenominator[Momentum[ell, D] - Momentum[q, D], 0]]*
          Pair[Momentum[ell, D], Momentum[q, D]])/(Q2*SUNN) - 
        (4*SUNN*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
            0], PropagatorDenominator[Momentum[ell, D] - Momentum[q, D], 0]]*
          Pair[Momentum[ell, D], Momentum[q, D]])/Q2 + 
        (2*D*SUNN*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
            0], PropagatorDenominator[Momentum[ell, D] - Momentum[q, D], 0]]*
          Pair[Momentum[ell, D], Momentum[q, D]])/Q2), 
     "LoopRouting" -> ell -> -ell, "Full" -> 
      <|GLI["SE", {1, 0, 0, 0}] -> ((I/4)*(-2 + D)*(-1 + SUNN)*(1 + SUNN))/
         (Q2*SUNN), GLI["SE", {0, 1, 0, 0}] -> 
        ((-1/4*I)*(-2 + D)*(-1 + SUNN)*(1 + SUNN))/(Q2*SUNN), 
       GLI["SE", {1, 1, 0, 0}] -> ((I/4)*(-2 + D)*(-1 + SUNN)*(1 + SUNN))/
         SUNN|>, "UVPowers" -> 
      <|3 -> <|GLI["UV", {2, 0, 0, 0}] -> ((I/4)*(-2 + D)*(-1 + SUNN)*
            (1 + SUNN))/SUNN, GLI["UV", {1, 0, 0, 0}] -> 
          ((-1/4*I)*(-2 + D)*(-1 + SUNN)*(1 + SUNN))/(Q2*SUNN), 
         GLI["UV", {2, 0, -1, 0}] -> ((I/4)*(-2 + D)*(-1 + SUNN)*(1 + SUNN))/
           (Q2*SUNN)|>, 4 -> <|GLI["UV", {3, 0, 0, 0}] -> 
          ((-1/4*I)*(-2 + D)*Q2*(-1 + SUNN)*(1 + SUNN))/SUNN, 
         GLI["UV", {2, 0, 0, 0}] -> ((I/2)*(-2 + D)*(-1 + SUNN)*(1 + SUNN))/
           SUNN, GLI["UV", {1, 0, 0, 0}] -> ((-1/4*I)*(-2 + D)*(-1 + SUNN)*
            (1 + SUNN))/(Q2*SUNN), GLI["UV", {3, 0, -1, 0}] -> 
          ((-1/2*I)*(-2 + D)*(-1 + SUNN)*(1 + SUNN))/SUNN, 
         GLI["UV", {2, 0, -1, 0}] -> ((I/2)*(-2 + D)*(-1 + SUNN)*(1 + SUNN))/
           (Q2*SUNN), GLI["UV", {3, 0, -2, 0}] -> 
          ((-1/4*I)*(-2 + D)*(-1 + SUNN)*(1 + SUNN))/(Q2*SUNN)|>|>, 
     "Longitudinal" -> <||>|>, "gauge" -> 
    <|"OriginalIntegrand" -> ((-1/2*I)*SUNN*
        (-2*Q2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
            0]] + 4*D*Q2*FeynAmpDenominator[PropagatorDenominator[
            Momentum[ell, D], 0]] - 2*D^2*Q2*FeynAmpDenominator[
           PropagatorDenominator[Momentum[ell, D], 0]] + 
         5*Q2^2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
            0], PropagatorDenominator[Momentum[ell, D] - Momentum[q, D], 
            0]] - 5*D*Q2^2*FeynAmpDenominator[PropagatorDenominator[
            Momentum[ell, D], 0], PropagatorDenominator[Momentum[ell, D] - 
             Momentum[q, D], 0]] - 10*Q2*FeynAmpDenominator[
           PropagatorDenominator[Momentum[ell, D], 0], PropagatorDenominator[
            Momentum[ell, D] - Momentum[q, D], 0]]*Pair[Momentum[ell, D], 
           Momentum[ell, D]] + 6*D*Q2*FeynAmpDenominator[
           PropagatorDenominator[Momentum[ell, D], 0], PropagatorDenominator[
            Momentum[ell, D] - Momentum[q, D], 0]]*Pair[Momentum[ell, D], 
           Momentum[ell, D]] + 2*Q2*FeynAmpDenominator[PropagatorDenominator[
            Momentum[ell, D], 0], PropagatorDenominator[Momentum[ell, D] - 
             Momentum[q, D], 0]]*Pair[Momentum[ell, D], Momentum[q, D]] - 
         2*D*Q2*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 
            0], PropagatorDenominator[Momentum[ell, D] - Momentum[q, D], 0]]*
          Pair[Momentum[ell, D], Momentum[q, D]] - 
         8*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
           PropagatorDenominator[Momentum[ell, D] - Momentum[q, D], 0]]*
          Pair[Momentum[ell, D], Momentum[q, D]]^2 + 
         4*D*FeynAmpDenominator[PropagatorDenominator[Momentum[ell, D], 0], 
           PropagatorDenominator[Momentum[ell, D] - Momentum[q, D], 0]]*
          Pair[Momentum[ell, D], Momentum[q, D]]^2))/((1 - D)*Q2^2), 
     "LoopRouting" -> ell -> -ell, "Full" -> 
      <|GLI["SE", {0, 0, 0, 0}] -> ((-I)*(-2 + D)*SUNN)/((-1 + D)*Q2^2), 
       GLI["SE", {1, 0, 0, 0}] -> ((-1/2*I)*(7 - 7*D + 2*D^2)*SUNN)/
         ((-1 + D)*Q2), GLI["SE", {0, 1, 0, 0}] -> ((I/2)*(-5 + 3*D)*SUNN)/
         ((-1 + D)*Q2), GLI["SE", {1, 1, 0, 0}] -> ((-1/2*I)*(-2 + 3*D)*SUNN)/
         (-1 + D), GLI["SE", {-1, 1, 0, 0}] -> ((I/2)*(-2 + D)*SUNN)/
         ((-1 + D)*Q2^2), GLI["SE", {1, -1, 0, 0}] -> ((I/2)*(-2 + D)*SUNN)/
         ((-1 + D)*Q2^2)|>, "UVPowers" -> 
      <|2 -> <|GLI["UV", {0, 0, 0, 0}] -> ((I/2)*(-2 + D)*SUNN)/
           ((-1 + D)*Q2^2), GLI["UV", {2, 0, 0, 0}] -> ((I/2)*(-2 + D)*SUNN)/
           (-1 + D), GLI["UV", {1, 0, 0, 0}] -> ((-I)*(-2 + D)^2*SUNN)/
           ((-1 + D)*Q2), GLI["UV", {2, 0, -1, 0}] -> (I*(-2 + D)*SUNN)/
           ((-1 + D)*Q2), GLI["UV", {1, 0, -1, 0}] -> ((-I)*(-2 + D)*SUNN)/
           ((-1 + D)*Q2^2), GLI["UV", {2, 0, -2, 0}] -> ((I/2)*(-2 + D)*SUNN)/
           ((-1 + D)*Q2^2)|>, 3 -> <|GLI["UV", {0, 0, 0, 0}] -> 
          ((I/2)*(-2 + D)*SUNN)/((-1 + D)*Q2^2), GLI["UV", {3, 0, 0, 0}] -> 
          ((-1/2*I)*(-2 + D)*Q2*SUNN)/(-1 + D), GLI["UV", {2, 0, 0, 0}] -> 
          ((-1/2*I)*(-3 + 2*D)*SUNN)/(-1 + D), GLI["UV", {1, 0, 0, 0}] -> 
          ((I/2)*(-3 + 2*D)*SUNN)/((-1 + D)*Q2), GLI["UV", {3, 0, -1, 0}] -> 
          (((-3*I)/2)*(-2 + D)*SUNN)/(-1 + D), GLI["UV", {2, 0, -1, 0}] -> 
          ((I/2)*(-3 + D)*SUNN)/((-1 + D)*Q2), GLI["UV", {1, 0, -1, 0}] -> 
          (((-3*I)/2)*(-2 + D)*SUNN)/((-1 + D)*Q2^2), 
         GLI["UV", {3, 0, -2, 0}] -> (((-3*I)/2)*(-2 + D)*SUNN)/
           ((-1 + D)*Q2), GLI["UV", {2, 0, -2, 0}] -> 
          (((3*I)/2)*(-2 + D)*SUNN)/((-1 + D)*Q2^2), 
         GLI["UV", {3, 0, -3, 0}] -> ((-1/2*I)*(-2 + D)*SUNN)/
           ((-1 + D)*Q2^2)|>, 4 -> <|GLI["UV", {0, 0, 0, 0}] -> 
          ((I/2)*(-2 + D)*SUNN)/((-1 + D)*Q2^2), GLI["UV", {4, 0, 0, 0}] -> 
          ((I/2)*(-2 + D)*Q2^2*SUNN)/(-1 + D), GLI["UV", {3, 0, 0, 0}] -> 
          ((I/2)*(-3 + 2*D)*Q2*SUNN)/(-1 + D), GLI["UV", {2, 0, 0, 0}] -> 
          ((-5*I)/2)*SUNN, GLI["UV", {1, 0, 0, 0}] -> ((I/2)*(-3 + 2*D)*SUNN)/
           ((-1 + D)*Q2), GLI["UV", {4, 0, -1, 0}] -> 
          ((2*I)*(-2 + D)*Q2*SUNN)/(-1 + D), GLI["UV", {3, 0, -1, 0}] -> 
          (I*SUNN)/(-1 + D), GLI["UV", {2, 0, -1, 0}] -> 
          ((-I)*SUNN)/((-1 + D)*Q2), GLI["UV", {1, 0, -1, 0}] -> 
          ((-2*I)*(-2 + D)*SUNN)/((-1 + D)*Q2^2), GLI["UV", {4, 0, -2, 0}] -> 
          ((3*I)*(-2 + D)*SUNN)/(-1 + D), GLI["UV", {3, 0, -2, 0}] -> 
          ((-1/2*I)*(-13 + 6*D)*SUNN)/((-1 + D)*Q2), 
         GLI["UV", {2, 0, -2, 0}] -> ((3*I)*(-2 + D)*SUNN)/((-1 + D)*Q2^2), 
         GLI["UV", {4, 0, -3, 0}] -> ((2*I)*(-2 + D)*SUNN)/((-1 + D)*Q2), 
         GLI["UV", {3, 0, -3, 0}] -> ((-2*I)*(-2 + D)*SUNN)/((-1 + D)*Q2^2), 
         GLI["UV", {4, 0, -4, 0}] -> ((I/2)*(-2 + D)*SUNN)/
           ((-1 + D)*Q2^2)|>|>, "Longitudinal" -> 
      <|GLI["SE", {0, 0, 0, 0}] -> -(((-2 + D)*SUNN)/Q2^2), 
       GLI["SE", {1, 0, 0, 0}] -> ((-3 + 2*D)*SUNN)/(2*Q2), 
       GLI["SE", {0, 1, 0, 0}] -> -1/2*SUNN/Q2, GLI["SE", {-1, 1, 0, 0}] -> 
        ((-2 + D)*SUNN)/(2*Q2^2), GLI["SE", {1, -1, 0, 0}] -> 
        ((-2 + D)*SUNN)/(2*Q2^2)|>|>, "one_flavor" -> 
    <|"OriginalIntegrand" -> ((-2*I)*FeynAmpDenominator[PropagatorDenominator[
          Momentum[ell, D], 0], PropagatorDenominator[Momentum[ell, D] - 
           Momentum[q, D], 0]]*(-3*Q2*Pair[Momentum[ell, D], 
           Momentum[ell, D]] + D*Q2*Pair[Momentum[ell, D], 
           Momentum[ell, D]] + Q2*Pair[Momentum[ell, D], Momentum[q, D]] - 
         D*Q2*Pair[Momentum[ell, D], Momentum[q, D]] - 
         2*Pair[Momentum[ell, D], Momentum[q, D]]^2))/((1 - D)*Q2^2), 
     "LoopRouting" -> ell -> -ell, "Full" -> 
      <|GLI["SE", {0, 0, 0, 0}] -> (2*I)/((-1 + D)*Q2^2), 
       GLI["SE", {1, 0, 0, 0}] -> (I*(-3 + D))/((-1 + D)*Q2), 
       GLI["SE", {0, 1, 0, 0}] -> (I*(-3 + D))/((-1 + D)*Q2), 
       GLI["SE", {1, 1, 0, 0}] -> (I*(-2 + D))/(-1 + D), 
       GLI["SE", {-1, 1, 0, 0}] -> (-I)/((-1 + D)*Q2^2), 
       GLI["SE", {1, -1, 0, 0}] -> (-I)/((-1 + D)*Q2^2)|>, 
     "UVPowers" -> <|2 -> <|GLI["UV", {0, 0, 0, 0}] -> (-I)/((-1 + D)*Q2^2), 
         GLI["UV", {2, 0, 0, 0}] -> (-I)/(-1 + D), GLI["UV", {1, 0, 0, 0}] -> 
          ((2*I)*(-2 + D))/((-1 + D)*Q2), GLI["UV", {2, 0, -1, 0}] -> 
          (-2*I)/((-1 + D)*Q2), GLI["UV", {1, 0, -1, 0}] -> 
          (2*I)/((-1 + D)*Q2^2), GLI["UV", {2, 0, -2, 0}] -> 
          (-I)/((-1 + D)*Q2^2)|>, 3 -> <|GLI["UV", {0, 0, 0, 0}] -> 
          (-I)/((-1 + D)*Q2^2), GLI["UV", {3, 0, 0, 0}] -> (I*Q2)/(-1 + D), 
         GLI["UV", {2, 0, 0, 0}] -> ((-I)*(-2 + D))/(-1 + D), 
         GLI["UV", {1, 0, 0, 0}] -> (I*(-2 + D))/((-1 + D)*Q2), 
         GLI["UV", {3, 0, -1, 0}] -> (3*I)/(-1 + D), 
         GLI["UV", {2, 0, -1, 0}] -> ((-I)*(1 + D))/((-1 + D)*Q2), 
         GLI["UV", {1, 0, -1, 0}] -> (3*I)/((-1 + D)*Q2^2), 
         GLI["UV", {3, 0, -2, 0}] -> (3*I)/((-1 + D)*Q2), 
         GLI["UV", {2, 0, -2, 0}] -> (-3*I)/((-1 + D)*Q2^2), 
         GLI["UV", {3, 0, -3, 0}] -> I/((-1 + D)*Q2^2)|>, 
       4 -> <|GLI["UV", {0, 0, 0, 0}] -> (-I)/((-1 + D)*Q2^2), 
         GLI["UV", {4, 0, 0, 0}] -> ((-I)*Q2^2)/(-1 + D), 
         GLI["UV", {3, 0, 0, 0}] -> (I*(-2 + D)*Q2)/(-1 + D), 
         GLI["UV", {1, 0, 0, 0}] -> (I*(-2 + D))/((-1 + D)*Q2), 
         GLI["UV", {4, 0, -1, 0}] -> ((-4*I)*Q2)/(-1 + D), 
         GLI["UV", {3, 0, -1, 0}] -> ((2*I)*D)/(-1 + D), 
         GLI["UV", {2, 0, -1, 0}] -> ((-2*I)*D)/((-1 + D)*Q2), 
         GLI["UV", {1, 0, -1, 0}] -> (4*I)/((-1 + D)*Q2^2), 
         GLI["UV", {4, 0, -2, 0}] -> (-6*I)/(-1 + D), 
         GLI["UV", {3, 0, -2, 0}] -> (I*(6 + D))/((-1 + D)*Q2), 
         GLI["UV", {2, 0, -2, 0}] -> (-6*I)/((-1 + D)*Q2^2), 
         GLI["UV", {4, 0, -3, 0}] -> (-4*I)/((-1 + D)*Q2), 
         GLI["UV", {3, 0, -3, 0}] -> (4*I)/((-1 + D)*Q2^2), 
         GLI["UV", {4, 0, -4, 0}] -> (-I)/((-1 + D)*Q2^2)|>|>, 
     "Longitudinal" -> <|GLI["SE", {0, 0, 0, 0}] -> 2/Q2^2, 
       GLI["SE", {1, 0, 0, 0}] -> -Q2^(-1), GLI["SE", {0, 1, 0, 0}] -> 
        -Q2^(-1), GLI["SE", {-1, 1, 0, 0}] -> -Q2^(-2), 
       GLI["SE", {1, -1, 0, 0}] -> -Q2^(-2)|>|>|>, 
 "InputHash" -> 1069580395154477262309619518489508102460671838512807530395364\
12641261848852915|>
