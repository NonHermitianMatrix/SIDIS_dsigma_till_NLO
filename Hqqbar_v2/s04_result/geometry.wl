<|"means" -> {(t - w)/2, (t - w)/2, (s - w)/2, (s - w)/2, (-2*Q2 - s - t)/2, 
   (-2*Q2 - s - t)/2}, "spatial_gram" -> 
  {{(t - w)^2/4, -1/4*(t - w)^2, (s*t + 2*Q2*w + s*w + t*w - w^2)/4, 
    (-(s*t) - 2*Q2*w - s*w - t*w + w^2)/4, 
    (-(s*t) - t^2 - 2*Q2*w - s*w + t*w)/4, (s*t + t^2 + 2*Q2*w + s*w - t*w)/
     4}, {-1/4*(t - w)^2, (t - w)^2/4, (-(s*t) - 2*Q2*w - s*w - t*w + w^2)/4, 
    (s*t + 2*Q2*w + s*w + t*w - w^2)/4, (s*t + t^2 + 2*Q2*w + s*w - t*w)/4, 
    (-(s*t) - t^2 - 2*Q2*w - s*w + t*w)/4}, 
   {(s*t + 2*Q2*w + s*w + t*w - w^2)/4, (-(s*t) - 2*Q2*w - s*w - t*w + w^2)/
     4, (s - w)^2/4, -1/4*(s - w)^2, (-s^2 - s*t - 2*Q2*w + s*w - t*w)/4, 
    (s^2 + s*t + 2*Q2*w - s*w + t*w)/4}, 
   {(-(s*t) - 2*Q2*w - s*w - t*w + w^2)/4, (s*t + 2*Q2*w + s*w + t*w - w^2)/
     4, -1/4*(s - w)^2, (s - w)^2/4, (s^2 + s*t + 2*Q2*w - s*w + t*w)/4, 
    (-s^2 - s*t - 2*Q2*w + s*w - t*w)/4}, 
   {(-(s*t) - t^2 - 2*Q2*w - s*w + t*w)/4, (s*t + t^2 + 2*Q2*w + s*w - t*w)/
     4, (-s^2 - s*t - 2*Q2*w + s*w - t*w)/4, (s^2 + s*t + 2*Q2*w - s*w + t*w)/
     4, (s^2 + 2*s*t + t^2 + 4*Q2*w)/4, (-s^2 - 2*s*t - t^2 - 4*Q2*w)/4}, 
   {(s*t + t^2 + 2*Q2*w + s*w - t*w)/4, (-(s*t) - t^2 - 2*Q2*w - s*w + t*w)/
     4, (s^2 + s*t + 2*Q2*w - s*w + t*w)/4, (-s^2 - s*t - 2*Q2*w + s*w - t*w)/
     4, (-s^2 - 2*s*t - t^2 - 4*Q2*w)/4, (s^2 + 2*s*t + t^2 + 4*Q2*w)/4}}, 
 "scales" -> {(t - w)/2, (t - w)/2, (s - w)/2, (s - w)/2, -rho, -rho}, 
 "rho_squared" -> (s^2 + 2*s*t + t^2 + 4*Q2*w)/4, "rho_branch" -> "positive", 
 "physical_region" -> HoldForm[Q2 > 0 && s > w > 0 && 
    w - Q2 - s < t < (-Q2)*(w/s)]|>
