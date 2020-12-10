module hist10(
	input clkin,
	input [9:0] buffer,
	input [1:0] buffer2, //first or second half of cycle detection - for debugging
	input resethist, 
	output integer histo[16]
	);
	
	reg resethist2;
	
	always@(posedge clkin) begin
							
			
		resethist2 <= resethist;

		if (resethist2) begin
			histo[0] <= 0;
			histo[1] <= 0;	
			histo[2] <= 0;	
			histo[3] <= 0;	
			histo[4] <= 0;	
			histo[5] <= 0;	
			histo[6] <= 0;	
			histo[7] <= 0;	
			histo[8] <= 0;	
			histo[9] <= 0;	
			histo[10] <= 0;
			histo[11] <= 0;
			histo[12] <= 0;
			histo[13] <= 0;
			histo[14] <= 0;
			histo[15] <= 0;
		end
		else begin				
			histo[0] <= histo[0] + buffer[0];
			histo[1] <= histo[1] + buffer[1];			
			histo[2] <= histo[2] + buffer[2];			
			histo[3] <= histo[3] + buffer[3];			
			histo[4] <= histo[4] + buffer[4];			
			histo[5] <= histo[5] + buffer[5];			
			histo[6] <= histo[6] + buffer[6];			
			histo[7] <= histo[7] + buffer[7];			
			histo[8] <= histo[8] + buffer[8];			
			histo[9] <= histo[9] + buffer[9];
			histo[10] <= histo[10] + buffer2[0];
			histo[11] <= histo[11] + buffer2[1];
			histo[12] <= histo[12] + 1;
			histo[13] <= 255;
			histo[14] <= 65535;
			histo[15] <= 65536;
		end						
	end
	
	
endmodule
