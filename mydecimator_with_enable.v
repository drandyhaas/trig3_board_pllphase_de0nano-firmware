module mydecimator_with_enable(
	input clkin,
	input enable,
	output decimated 
	);
	
	reg[2:0] enable_shift;
	reg[3:0] ctr = 0;
	reg valid;

	assign decimated = valid && clkin;
	
	always@(negedge clkin) begin
							
		//within a block
		//<= --> parallel execution (simultaneous update at the end of the clock cycle)
		// = --> serial execution
		enable_shift <= {enable_shift[1:0], enable};
		ctr <= ctr+1'b1;
		valid <= (ctr == 0) && enable_shift[2];
	end
	
	
endmodule
