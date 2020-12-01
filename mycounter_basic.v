module mycounter_basic(
	input clkin,
	input [1:0] buffer,
	input resethist, 
	output integer histo[2]
	);
	
	reg[1:0] buff2;
	
	reg resethist2;
	
	always@(posedge clkin) begin
							
		//within a block
		//<= --> parallel execution (simultaneous update at the end of the clock cycle)
		// = --> serial execution
		
		buff2 <= buffer;
		
			
		resethist2 <= resethist;

		if (resethist2) begin
			histo[0] <= 0;
			histo[1] <= 0;			
		end
		else begin				
			histo[0] <= histo[0] + buff2[0];
			histo[1] <= histo[1] + buff2[1];			
		end
	end
	
	
endmodule
