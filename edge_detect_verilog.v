//adapted from https://www.fpga4fun.com/CrossClockDomain2.html

module edge_detect_verilog(
    input valid, // if true when pulse edge arrives, passes on pulse
    input pulse,   // this is a pulse of indeterminate length
    input clk, // clock domain in which to send output pulse
    output pulseOut   // output pulse registered to clk
);

reg pulseToggle;

always @(posedge pulse) pulseToggle <= pulseToggle ^ valid;  // when flag is asserted, this signal toggles (clkA domain)


reg [2:0] SyncA_clkB;
always @(posedge clk) SyncA_clkB <= {SyncA_clkB[1:0], pulseToggle};  // now we cross the clock domains

assign pulseOut = (SyncA_clkB[2] ^ SyncA_clkB[1]);  // and create the clkB flag
endmodule