# Hgq BigTMD channel-1A consistency check

Signed difference: **BigTMD minus local**.

Charge-stripped, case A, all four distribution coefficients (regular, plus1B, plus2B, delta), both projectors and both structure functions.  Conventions: EL=1, g_s=1 (as = 1/(4 Pi)), ScaleMu = Q, no Jacobian on either side.

| Benchmark | Component | Quantity | Local | BigTMD | BigTMD-local | Relative | Close |
|---|:---:|---|---:|---:|---:|---:|:---:|
| interior_1 | reg | Hg | 8.190379842830e-04 | 5.400600371257e-04 | -2.789779471574e-04 | 3.40617e-01 | False |
| interior_1 | reg | Hpp | -1.362082673293e-02 | -3.216169714584e-03 | 1.040465701835e-02 | 7.63879e-01 | False |
| interior_1 | reg | F1hat | -6.373330630497e-04 | -3.238218132738e-04 | 3.135112497759e-04 | 4.91911e-01 | False |
| interior_1 | reg | F2hat | -8.242002528499e-04 | -3.253221069508e-04 | 4.988781458990e-04 | 6.05288e-01 | False |
| interior_1 | p1 | Hg | 1.130000295118e-02 | 1.897214709410e-03 | -9.402788241766e-03 | 8.32105e-01 | False |
| interior_1 | p1 | Hpp | -1.764165330299e-01 | -1.486196153053e-01 | 2.779691772461e-02 | 1.57564e-01 | False |
| interior_1 | p1 | F1hat | -8.600642384035e-03 | -3.434333092457e-03 | 5.166309291578e-03 | 6.00689e-01 | False |
| interior_1 | p1 | F2hat | -1.093587726627e-02 | -6.338788362725e-03 | 4.597088903549e-03 | 4.20368e-01 | False |
| interior_1 | p2 | Hg | -2.694486647955e-03 | -1.027905154496e-03 | 1.666581493459e-03 | 6.18515e-01 | False |
| interior_1 | p2 | Hpp | 4.206653704264e-02 | 4.934564450465e-02 | 7.279107462013e-03 | 1.47513e-01 | False |
| interior_1 | p2 | F1hat | 2.050823895157e-03 | 1.339279290275e-03 | -7.115446048825e-04 | 3.46955e-01 | False |
| interior_1 | p2 | F2hat | 2.607660847963e-03 | 2.254703359854e-03 | -3.529574881095e-04 | 1.35354e-01 | False |
| interior_1 | del | Hg | 9.062609958168e-03 | 9.741476219473e-04 | -8.088462336221e-03 | 8.92509e-01 | False |
| interior_1 | del | Hpp | 2.167472371280e-02 | -1.561473435978e-02 | -3.728945807258e-02 | 1.72041e+00 | False |
| interior_1 | del | F1hat | -4.168786084920e-03 | -7.482368277567e-04 | 3.420549257163e-03 | 8.20514e-01 | False |
| interior_1 | del | F2hat | -2.596924944971e-03 | -9.581293708336e-04 | 1.638795574137e-03 | 6.31052e-01 | False |
| interior_2 | reg | Hg | 1.661068268835e-03 | 9.703119933523e-04 | -6.907562754830e-04 | 4.15851e-01 | False |
| interior_2 | reg | Hpp | -1.365430231944e-02 | -5.566564388095e-03 | 8.087737931341e-03 | 5.92322e-01 | False |
| interior_2 | reg | F1hat | -1.023353032611e-03 | -5.637641003290e-04 | 4.595889322817e-04 | 4.49101e-01 | False |
| interior_2 | reg | F2hat | -1.135604548744e-03 | -5.810886061533e-04 | 5.545159425904e-04 | 4.88300e-01 | False |
| interior_2 | p1 | Hg | 1.572119538937e-02 | 3.894712526552e-03 | -1.182648286282e-02 | 7.52264e-01 | False |
| interior_2 | p1 | Hpp | -2.318260528982e-01 | -1.545094789361e-01 | 7.731657396205e-02 | 3.33511e-01 | False |
| interior_2 | p1 | F1hat | -1.113432366373e-02 | -4.129258113101e-03 | 7.005065550626e-03 | 6.29142e-01 | False |
| interior_2 | p1 | F2hat | -1.425098332086e-02 | -6.845154296845e-03 | 7.405829024017e-03 | 5.19671e-01 | False |
| interior_2 | p2 | Hg | -3.460823631262e-03 | -1.669068770647e-03 | 1.791754860615e-03 | 5.17725e-01 | False |
| interior_2 | p2 | Hpp | 5.103359269707e-02 | 5.306843605714e-02 | 2.034843360072e-03 | 3.83438e-02 | False |
| interior_2 | p2 | F1hat | 2.451081453997e-03 | 1.583939014720e-03 | -8.671424392765e-04 | 3.53780e-01 | False |
| interior_2 | p2 | F2hat | 3.137174917303e-03 | 2.484603086115e-03 | -6.525718311877e-04 | 2.08013e-01 | False |
| interior_2 | del | Hg | 1.159872624778e-02 | 3.846114916048e-04 | -1.121411475617e-02 | 9.66840e-01 | False |
| interior_2 | del | Hpp | 9.248145773312e-03 | -5.702613071671e-02 | -6.627427649002e-02 | 1.16217e+00 | False |
| interior_2 | del | F1hat | -5.668765658225e-03 | -9.975988641009e-04 | 4.671166794124e-03 | 8.24018e-01 | False |
| interior_2 | del | F2hat | -4.358340585856e-03 | -2.102119334891e-03 | 2.256221250965e-03 | 5.17679e-01 | False |
| interior_3 | reg | Hg | 2.720118556984e-03 | 1.610301654916e-03 | -1.109816902068e-03 | 4.08003e-01 | False |
| interior_3 | reg | Hpp | 5.618189462224e-04 | 8.360657472219e-03 | 7.798838525997e-03 | 9.32802e-01 | False |
| interior_3 | reg | F1hat | -1.352672840288e-03 | -6.952302201509e-04 | 6.574426201370e-04 | 4.86032e-01 | False |
| interior_3 | reg | F2hat | -1.168307010712e-03 | -4.151284273702e-04 | 7.531785833413e-04 | 6.44675e-01 | False |
| interior_3 | p1 | Hg | 8.936719971624e-03 | -7.252986751960e-03 | -1.618970672358e-02 | 1.81159e+00 | False |
| interior_3 | p1 | Hpp | -2.817955290762e-01 | -3.482253511772e-01 | -6.642982210102e-02 | 1.90767e-01 | False |
| interior_3 | p1 | F1hat | -8.173228388253e-03 | -9.517520799887e-04 | 7.221476308264e-03 | 8.83552e-01 | False |
| interior_3 | p1 | F2hat | -1.360765974612e-02 | -8.826916415485e-03 | 4.780743330633e-03 | 3.51327e-01 | False |
| interior_3 | p2 | Hg | -1.777347823484e-03 | 6.128904344432e-04 | 2.390238257928e-03 | 1.34483e+00 | False |
| interior_3 | p2 | Hpp | 5.604390334054e-02 | 7.908317316205e-02 | 2.303926982151e-02 | 2.91330e-01 | False |
| interior_3 | p2 | F1hat | 1.625503510553e-03 | 7.332900488891e-04 | -8.922134616636e-04 | 5.48884e-01 | False |
| interior_3 | p2 | F2hat | 2.706311097279e-03 | 2.456213465195e-03 | -2.500976320835e-04 | 9.24127e-02 | False |
| interior_3 | del | Hg | 8.559052421930e-03 | 3.912221598858e-03 | -4.646830823072e-03 | 5.42914e-01 | False |
| interior_3 | del | Hpp | 4.025751373757e-02 | -1.908924194707e-02 | -5.934675568465e-02 | 1.47418e+00 | False |
| interior_3 | del | F1hat | -3.750246022965e-03 | -2.207084012340e-03 | 1.543162010624e-03 | 4.11483e-01 | False |
| interior_3 | del | F2hat | -2.350486057912e-03 | -2.365632213607e-03 | -1.514615569527e-05 | 6.40258e-03 | False |

All channel-1 B/C generated functions are exact zero: `True`.

Maximum absolute difference: `7.731657396205e-02`.

Maximum relative difference: `1.811593825810e+00`.

All 48 compared coefficients within tolerance: `False`.

Overall tested agreement: `False`.

Tolerance: `abs(diff) <= 1e-10 + 1e-7*max(abs(BigTMD),abs(local))`.

BigTMD decimal coefficients were executed as written; the local inputs remained exact until final benchmark evaluation.
