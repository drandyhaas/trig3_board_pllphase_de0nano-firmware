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
