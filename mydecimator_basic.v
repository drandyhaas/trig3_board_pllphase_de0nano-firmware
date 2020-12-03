module mydecimator_basic(
	input clkin,
	output decimated 
	);
	
	reg[3:0] ctr = 0;
	reg valid;

	assign decimated = valid && clkin;
	
	always@(negedge clkin) begin
							
		//within a block
		//<= --> parallel execution (simultaneous update at the end of the clock cycle)
		// = --> serial execution
		
		ctr <= ctr+1;
		valid <= ctr == 0;
	end
	
	
endmodule
