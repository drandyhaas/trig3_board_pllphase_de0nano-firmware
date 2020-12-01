#from deo-nano-user-manual sec 6.7
#clk80in = 70 MHz clock

create_clock -period 20.000 -name clk50 [get_ports clk50]
create_clock -period 14.285 -name clk80in [get_ports clk80in]
create_clock -period 14.285 -name lvds_second_input [get_ports lvds_second_input]
derive_pll_clocks
derive_clock_uncertainty