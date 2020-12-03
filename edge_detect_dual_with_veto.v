//adapted from https://www.fpga4fun.com/CrossClockDomain2.html

//captures whether photon arrived during validA or validB points
//then generates pulses aligned to the rising (A) or falling (B) edge of phase shifted clock
//intention is that phase shifted clock should rise with or shortly before validA goes high and fall with or shortly before validB goes high
//pulses in phase shifted domain are then transferred via same mechanism to clk_out 
//veto supressed output for up to 3 clock cycles after photon is detected


module edge_detect_dual_with_veto(
    input validA, //aligned to positive edge of phase shifted clock
	 input validB, //aligned to negative edge of phase shifted clock
    input pulse,   // this is a pulse of indeterminate length
    input ps_clk,
	 input clk_out,// clock domain in which to send output pulse
	 input reg[2:0] vetoLast, //whether to suppress pulses that occur [3,2,1] clock cycles after another pulse
    output reg detA,
    output reg detB	 // output pulse registered to clk_out
);

reg pulseToggleA;
reg pulseToggleB;
reg vetoToggle;
always @(posedge pulse) begin
	pulseToggleA <= pulseToggleA ^ validA; 
	pulseToggleB <= pulseToggleB ^ validB;
	vetoToggle <= !vetoToggle;
end
	

reg [2:0] sync_pulseA;
reg [5:0] sync_vetoA;
reg toggleA;
always @(posedge ps_clk) begin
	sync_pulseA <= {sync_pulseA[1:0], pulseToggleA};  // now we cross the clock domains
	sync_vetoA <= {sync_vetoA[4:0], vetoToggle};
	 //suppress output if vetoLast is true and there was a pulse in the previous clock cycle, whether or not it was flagged as valid
	toggleA <= toggleA^(sync_pulseA[2] ^ sync_pulseA[1]) && !(vetoLast[0] && (sync_vetoA[3] ^ sync_vetoA[2])  || vetoLast[1] && (sync_vetoA[4] ^ sync_vetoA[3]) || vetoLast[2] && (sync_vetoA[5] ^ sync_vetoA[4])); 
end

reg [2:0] sync_pulseB;
reg [5:0] sync_vetoB;
reg toggleB;
always @(negedge ps_clk) begin
	sync_pulseB <= {sync_pulseB[1:0], pulseToggleB};  // now we cross the clock domains
	sync_vetoB <= {sync_vetoB[4:0], vetoToggle};
	 //suppress output if vetoLast is true and there was a pulse in the previous clock cycle, whether or not it was flagged as valid
	toggleB <= toggleB^(sync_pulseB[2] ^ sync_pulseB[1]) && !(vetoLast[0] && (sync_vetoB[3] ^ sync_vetoB[2])  || vetoLast[1] && (sync_vetoB[4] ^ sync_vetoB[3]) || vetoLast[2] && (sync_vetoB[5] ^ sync_vetoB[4])); 
end

reg [2:0] syncA;
reg [2:0] syncB;

always @(posedge clk_out) begin
	syncA <= {syncA[1:0], toggleA};
	detA <= syncA[2]^syncA[1];
	syncB <= {syncB[1:0], toggleB};
	detB <= syncB[2]^syncB[1];
end



endmodule