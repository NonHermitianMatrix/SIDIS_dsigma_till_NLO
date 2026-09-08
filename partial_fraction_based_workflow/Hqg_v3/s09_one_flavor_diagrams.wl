TopologyList[Process -> {V[5, {Index[Gluon, 1]}]} -> 
    {V[5, {Index[Gluon, 2]}]}, Model -> {"SMQCD"}, 
  GenericModel -> {"Lorentz"}, InsertionLevel -> {Particles}, 
  ExcludeParticles -> {-F[1], F[1], -F[2], F[2], -F[4], F[4], -F[1, {1}], 
    F[1, {1}], -F[1, {2}], F[1, {2}], -F[1, {3}], F[1, {3}], -F[2, {1}], 
    F[2, {1}], -F[2, {2}], F[2, {2}], -F[2, {3}], F[2, {3}], -F[3, {2, _}], 
    F[3, {2, _}], -F[3, {3, _}], F[3, {3, _}], -F[4, {1, _}], F[4, {1, _}], 
    -F[4, {2, _}], F[4, {2, _}], -F[4, {3, _}], F[4, {3, _}], S[1], S[2], 
    -S[3], S[3], -U[1], U[1], -U[2], U[2], -U[3], U[3], -U[4], U[4], -U[5], 
    U[5], -U[5, {_}], U[5, {_}], V[1], V[2], -V[3], V[3], V[5], V[5, {_}]}, 
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
       V[5, {Index[Gluon, 2]}], Field[3] -> -F[3, {1, Index[Colour, 3]}], 
      Field[4] -> F[3, {1, Index[Colour, 4]}]]]]]
