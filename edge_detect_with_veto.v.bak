//adapted from https://www.fpga4fun.com/CrossClockDomain2.html

module edge_detect_with_veto(
    input valid, // if true when pulse edge arrives, passes on pulse
    input pulse,   // this is a pulse of indeterminate length
    input clk, // clock domain in which to send output pulse
	 input vetoLast, //whether to suppress pulses that occur one clock cycle after another pulse
    output reg pulseOut   // output pulse registered to clk
);

reg pulseToggle;
reg vetoToggle;
always @(posedge pulse) begin
	pulseToggle <= pulseToggle ^ valid;  // when flag is asserted, this signal toggles (clkA domain)
	vetoToggle <= !vetoToggle;
end
	

reg [2:0] sync_pulse;
reg [3:0] sync_veto;
always @(posedge clk) begin
	sync_pulse <= {sync_pulse[1:0], pulseToggle};  // now we cross the clock domains
	sync_veto <= {sync_veto[2:0], vetoToggle};
	 //suppress output if vetoLast is true and there was a pulse in the previous clock cycle, whether or not it was flagged as valid
	pulseOut <= (sync_pulse[2] ^ sync_pulse[1]) && !(vetoLast && (sync_veto[3] ^ sync_veto[2])); 
end
endmodule