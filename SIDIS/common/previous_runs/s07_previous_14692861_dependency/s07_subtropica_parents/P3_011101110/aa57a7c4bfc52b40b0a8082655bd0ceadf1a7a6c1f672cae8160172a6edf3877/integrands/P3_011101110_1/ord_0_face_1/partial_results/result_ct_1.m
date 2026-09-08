<|"result" -> ZeroInfPeriod[{-(c13/c23)}]*
    (ZeroInfPeriod[{Wm[1000001]}]/(c12*(Wm[1000001] - Wp[1000001])) - 
     ZeroInfPeriod[{Wp[1000001]}]/(c12*(Wm[1000001] - Wp[1000001]))) + 
   ZeroInfPeriod[{0, Wm[1000002]}]/(c12*(Wm[1000002] - Wp[1000002])) - 
   ZeroInfPeriod[{0, Wp[1000002]}]/(c12*(Wm[1000002] - Wp[1000002])) + 
   ZeroInfPeriod[{Wm[1000001], -1}]/(c12*(Wm[1000001] - Wp[1000001])) + 
   ZeroInfPeriod[{Wm[1000001], -(c23/c12)}]/
    (c12*(Wm[1000001] - Wp[1000001])) - ZeroInfPeriod[{Wp[1000001], -1}]/
    (c12*(Wm[1000001] - Wp[1000001])) - 
   ZeroInfPeriod[{Wp[1000001], -(c23/c12)}]/
    (c12*(Wm[1000001] - Wp[1000001])), "letterTable" -> 
  <|1000001 -> <|"Polynomial" -> c23 + c12*xx1 - c13*xx1 + c23*xx1 + 
       c12*xx1^2, "Variable" -> xx1, "LC" -> c12, 
     "Sum" -> (-c12 + c13 - c23)/c12, "Product" -> c23/c12, 
     "Discriminant" -> -4*c12*c23 + (c12 - c13 + c23)^2, 
     "WmValue" -> (-c12 + c13 - c23 - Sqrt[-4*c12*c23 + (c12 - c13 + c23)^2])/
       (2*c12), "WpValue" -> (-c12 + c13 - c23 + 
        Sqrt[-4*c12*c23 + (c12 - c13 + c23)^2])/(2*c12)|>, 
   1000002 -> <|"Polynomial" -> c23 + c12*xx1 - c13*xx1 + c23*xx1 + 
       c12*xx1^2, "Variable" -> xx1, "LC" -> c12, 
     "Sum" -> (-c12 + c13 - c23)/c12, "Product" -> c23/c12, 
     "Discriminant" -> -4*c12*c23 + (c12 - c13 + c23)^2, 
     "WmValue" -> (-c12 + c13 - c23 - Sqrt[-4*c12*c23 + (c12 - c13 + c23)^2])/
       (2*c12), "WpValue" -> (-c12 + c13 - c23 + 
        Sqrt[-4*c12*c23 + (c12 - c13 + c23)^2])/(2*c12)|>|>|>
