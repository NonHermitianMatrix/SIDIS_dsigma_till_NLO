# Hqqbar macro chain

Run `s01` through `s09` in order. The channel is real-only: the sequence
covers shared kinematics/LO inputs, the dedicated Hqqbar real trace, exact R5
mapping and subtraction, the required pole gate, F-hat assembly, and the
checkpointed acceptance finish.

- `s07_Hqqbar_pole_check.wls` is the required finiteness gate.
- `output/` contains the separate accepted F1hat/F2hat expressions and the
  convolution statement.
- `check_macros/` contains the counterterm-ratio and promotion checks; these
  are not producers.

The accepted channel-specific 1/2 symmetry factor and FF-only pole
subtraction are implemented in the numbered scripts.

