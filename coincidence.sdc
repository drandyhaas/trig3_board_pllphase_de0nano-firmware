## Generated SDC file "coincidence.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.0.0 Build 614 04/24/2018 SJ Lite Edition"

## DATE    "Mon Jun 14 14:07:47 2021"

##
## DEVICE  "EP4CE22F17C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3


#**************************************************************
# Create Clock
#**************************************************************

#from deo-nano-user-manual sec 6.7
#clk80in = 70 MHz clock
create_clock -period 20.000 -name clk50 [get_ports clk50]
create_clock -period 14.285 -name clk80in [get_ports clk80in]
create_clock -period 14.285 -name lvds_second_input [get_ports lvds_second_input]
create_clock -name {scanclk} -period 100.000 -waveform { 0.000 50.000 } [get_registers {plls_and_photons:inst|pll_setter:inst10|scanclk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

#derive_pll_clocks
create_generated_clock -source {inst|inst1|altpll_component|auto_generated|pll1|inclk[0]} -duty_cycle 50.00 -name {laser_clk} {inst|inst1|altpll_component|auto_generated|pll1|clk[1]}
create_generated_clock -source {inst|inst1|altpll_component|auto_generated|pll1|inclk[0]} -phase 80.00 -duty_cycle 28.00 -name {test_pulse} {inst|inst1|altpll_component|auto_generated|pll1|clk[2]}
create_generated_clock -source {inst|inst8|altpll_component|auto_generated|pll1|inclk[0]} -duty_cycle 50.00 -name {valid1} {inst|inst8|altpll_component|auto_generated|pll1|clk[1]}
create_generated_clock -source {inst|inst8|altpll_component|auto_generated|pll1|inclk[0]} -phase 180.00 -duty_cycle 50.00 -name {valid2} {inst|inst8|altpll_component|auto_generated|pll1|clk[2]}
create_generated_clock -source {inst|inst8|altpll_component|auto_generated|pll1|inclk[0]} -phase 180.00 -duty_cycle 50.00 -name {valid3} {inst|inst8|altpll_component|auto_generated|pll1|clk[3]}
create_generated_clock -source {inst|inst8|altpll_component|auto_generated|pll1|inclk[0]} -duty_cycle 50.00 -name {valid4} {inst|inst8|altpll_component|auto_generated|pll1|clk[4]}
create_generated_clock -source {inst|inst12|inst2|altpll_component|auto_generated|pll1|inclk[0]} -phase 180.00 -duty_cycle 10.00 -name {v0} {inst|inst12|inst2|altpll_component|auto_generated|pll1|clk[0]}
create_generated_clock -source {inst|inst12|inst2|altpll_component|auto_generated|pll1|inclk[0]} -phase 216.00 -duty_cycle 10.00 -name {v1} {inst|inst12|inst2|altpll_component|auto_generated|pll1|clk[1]}
create_generated_clock -source {inst|inst12|inst2|altpll_component|auto_generated|pll1|inclk[0]} -phase 252.00 -duty_cycle 10.00 -name {v2} {inst|inst12|inst2|altpll_component|auto_generated|pll1|clk[2]}
create_generated_clock -source {inst|inst12|inst2|altpll_component|auto_generated|pll1|inclk[0]} -phase 288.00 -duty_cycle 10.00 -name {v3} {inst|inst12|inst2|altpll_component|auto_generated|pll1|clk[3]}
create_generated_clock -source {inst|inst12|inst2|altpll_component|auto_generated|pll1|inclk[0]} -phase 324.00 -duty_cycle 10.00 -name {v4} {inst|inst12|inst2|altpll_component|auto_generated|pll1|clk[4]}
create_generated_clock -source {inst|inst12|inst|altpll_component|auto_generated|pll1|inclk[0]} -duty_cycle 10.00 -name {v5} {inst|inst12|inst|altpll_component|auto_generated|pll1|clk[0]}
create_generated_clock -source {inst|inst12|inst|altpll_component|auto_generated|pll1|inclk[0]} -phase 36.00 -duty_cycle 10.00 -name {v6} {inst|inst12|inst|altpll_component|auto_generated|pll1|clk[1]}
create_generated_clock -source {inst|inst12|inst|altpll_component|auto_generated|pll1|inclk[0]} -phase 72.00 -duty_cycle 10.00 -name {v7} {inst|inst12|inst|altpll_component|auto_generated|pll1|clk[2]}
create_generated_clock -source {inst|inst12|inst|altpll_component|auto_generated|pll1|inclk[0]} -phase 108.00 -duty_cycle 10.00 -name {v8} {inst|inst12|inst|altpll_component|auto_generated|pll1|clk[3]}
create_generated_clock -source {inst|inst12|inst|altpll_component|auto_generated|pll1|inclk[0]} -phase 144.00 -duty_cycle 10.00 -name {v9} {inst|inst12|inst|altpll_component|auto_generated|pll1|clk[4]}

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group {laser_clk test_pulse v*} -group {clk50}

#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_keepers {**}] -to [get_keepers {*phasedone_state*}]
set_false_path -from [get_keepers {**}] -to [get_keepers {*internal_phasestep*}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************
