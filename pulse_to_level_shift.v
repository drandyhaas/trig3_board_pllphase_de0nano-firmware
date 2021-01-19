module pulse_to_level_shift(
	input clkin,
	input det[1:0],
	input encodeAsShift,
	output encoded[1:0],
	output reg encshft
	);
	
	reg[2:0] enc_shift;
	always@(posedge clkin) begin
							
		enc_shift <= {enc_shift[1:0], encodeAsShift};
		encshft <= enc_shift[2];
		if (enc_shift[2]) begin
			encoded[0] <= encoded[0]^det[0];
			encoded[1] <= encoded[1]^det[1];
		end 
		else begin 
			encoded <= det;
		end
	end
	
	
endmodule