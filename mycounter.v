module mycounter(
	input clkin,
	input [7:0] buffer,
	input resethist, 
	output integer histo[8], 
	output integer ipihist[64] //70 Mhz / 64 = ~1.1 MHz
	);
	
	
	reg [7:0] j = 0;
	reg [7:0] k = 0;
	
	reg [7:0] cyclecounter;
	reg resetipi;
	reg resethist2;
	reg anyphot;
	
	always@(posedge clkin) begin
							
		//within a block
		//<= --> parallel execution (simultaneous update at the end of the clock cycle)
		// = --> serial execution
		
		anyphot <= buffer != 0;
		if (anyphot) begin
			if (cyclecounter < 64) begin
				ipihist[cyclecounter] <= ipihist[cyclecounter] + 1;				
			end 
			cyclecounter = 0;								
		end 
		else begin
			if (cyclecounter < 254) begin
				cyclecounter <= cyclecounter + 1'b1;
			end
		end
			
		resethist2 <= (resethist2 || resethist);
		resetipi <= (resetipi || resethist);

		if (resethist2) begin
			if (j >= 8) begin
				j <= 0;
				resethist2 <= 0;
			end
			else begin
				histo[j] <= 0;
				j <= j+1'b1;
			end			
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
		end
		if (resetipi) begin
			if (k >= 64) begin
				k <= 0;
				resetipi <= 0;
			end
			else begin
				ipihist[k] <= 0;
				k <= k+1'b1;
			end				
		end					
	end
	
	
endmodule
