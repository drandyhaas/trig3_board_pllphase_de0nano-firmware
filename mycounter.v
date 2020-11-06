module mycounter(
	input clkin,
	input [1:0] buffer,
	output reg [1:0] out,
	input resethist, 
	output integer histo[2], 
	output integer ipihist[64], //70 Mhz / 64 = ~1.1 MHz
	input vetopmtlast
	);
	
	
	reg [7:0] j = 0;
	reg [7:0] k = 0;
	
	reg [7:0] cyclecounter;
	reg resetipi;
	reg resethist2;
	reg anyphot;
	reg lastphot;
	
	always@(posedge clkin) begin
							
		//within a block
		//<= --> parallel execution (simultaneous update at the end of the clock cycle)
		// = --> serial execution
		
		out[0] <= buffer[0];
		out[1] <= buffer[1];
		
		anyphot <= buffer != 0;
		lastphot <= buffer != 0 && vetopmtlast;
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
			
		resethist2 <= resethist;
		resetipi <= (resetipi || resethist);

		if (resethist2) begin
			histo[0] <= 0;
			histo[1] <= 0;			
		end
		else begin				
			histo[0] <= histo[0] + buffer[0];
			histo[1] <= histo[1] + buffer[1];			
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
