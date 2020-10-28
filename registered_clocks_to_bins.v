module registered_clocks_to_bins(
	input clkin,
	input photonFirstHalf, //whether a photon was detected on first half of clock cycle
	input photonSecondHalf, //whether a photon was detected on second half of clock cycle
	input photon2x, //whether a photon was detected in even quarter (0-1/4 1/2-3/4) of cycle
	input photon4x, //whether a photon was detected in even eigth (0-1/8 1/4-3/8 etc.) of cycle
	output reg [7:0] data, //binned data, whether a photon arrived in the each 8th of a cycle
	output wire [3:0] detection //0 -> photon first half, 1-> photon second half, 2-> photon2x, 3-> photon4x 
	);
	
	
	assign detection[0] = photonFirstHalf;
	assign detection[1] = photonSecondHalf;
	assign detection[2] = photon2x;
	assign detection[3] = photon4x;
	
	always@(posedge clkin) begin
							
		data[0] <= photonFirstHalf && photon2x && photon4x;
		data[1] <= photonFirstHalf && photon2x && !photon4x;
		data[2] <= photonFirstHalf && !photon2x && photon4x;
		data[3] <= photonFirstHalf && !photon2x && !photon4x;							
		data[4] <= photonSecondHalf && photon2x && photon4x;
		data[5] <= photonSecondHalf && photon2x && !photon4x;
		data[6] <= photonSecondHalf && !photon2x && photon4x;
		data[7] <= photonSecondHalf && !photon2x && !photon4x;
	end
	
	
endmodule
