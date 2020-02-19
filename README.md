# trig3_board_pllphase_de0nano-firmware
Firmware for the Gershow FPGA worm analysis

Open coincidence.qpf with Quartus (tested with version 18.0.0)

## Serial command set
0: send the firmware version				

1 + byte: set deadticks

2 + byte: set firingticks

3: toggle output enable

4: toggle clk inputs

5: adjust clock phase

6: step phaseoffset (0 bin on lvds) by one		

7: toggle using first bin or first two bins

8: toggle PMT passthrough

9: toggle phase step direction

10: send histogram (4 bins for now) 

11: toggle vetopmtlast

12: adjust clock phase (c1)

## outputs
A6: out1 : coax_out[2] 

B6: out2 : coax_out[3] 

N11: test pulse : coax_out[0]

P9: 4x clock for test pulse : coax_out[1]

F9: phase shifted? input clock : coax_out[4] (shouldn't this always be 1 if loop runs on rising edge of clock?)

E7: lvds clock (4x) phase shifted : coax_out[5]




