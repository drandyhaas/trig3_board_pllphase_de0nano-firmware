module demultiplex_and_count(
	input read_clk,
	input [NBINS-1:0] lvds_in,
	input pmt,
	output photon_detection[1:0], 
	input passthrough,
	output integer histo[8], 
	input resethist, 
	input vetopmtlast,	//histo must have at least NBINS

	input [NBINS-1:0] mask1,
	input [NBINS-1:0] mask2,
	input [7:0] cyclesToVeto,
	output integer ipihist[64], //70 Mhz / 64 = ~1.1 MHz
	output reg inveto,
	output reg collision
	);
	
	
	parameter NBINS = 8;
	

	reg out1;assign photon_detection[0]=out1; // A6 // the out1
	reg out2;assign photon_detection[1]=out2; // B6 // the out2
	
		
	reg resethist1=0, resethist2=0, resetipi = 0;
	reg [NBINS-1:0] lvds_rx = 0;
	reg [NBINS-1:0] lvds_last=0;
	reg [NBINS-1:0] phot=0;
   reg [NBINS-1:0] lastphot = 0;

	reg [7:0] j = 0;
	reg [7:0] k = 0;
	
	reg [7:0] cyclecounter;
	reg anyphot;
	
	always@(posedge read_clk) begin
		lvds_rx <= lvds_in;
		lvds_last <= lvds_rx;
		
		if (passthrough) begin
			out1 <= pmt;
			out2 <= (lvds_rx != 0);
		end
		else begin			
			if (vetopmtlast) begin
				phot = lvds_rx & ~((lvds_rx >> 1) || (lvds_last << (NBINS-1)));
			end
			else begin
				phot = lvds_rx;
			end
			
			
			if (cyclecounter < cyclesToVeto) begin
				collision = (phot != 0);
				phot = 0;
				inveto <= 1'b1;				
			end		
			out1 <= (phot & mask1) != 0;
			out2 <= (phot & mask2) != 0;
			
			//within a block
			//<= --> parallel execution (simultaneous update at the end of the clock cycle)
			// = --> serial execution
			
			anyphot <= phot != 0;
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
				
			resethist1 <= resethist;
			resethist2 <= resethist2 || resethist1;
			resetipi <= resetipi || resethist1;
			
			
			lastphot <= phot;
			if (resethist2) begin
				if (j >= NBINS) begin
					j <= 0;
					resethist2 <= 0;
				end
				else begin
					histo[j] <= 0;
					j <= j+1'b1;
				end
				
			end
			else begin				
				histo[0] <= histo[0] + lastphot[0];
				histo[1] <= histo[1] + lastphot[1];
				histo[2] <= histo[2] + lastphot[2];
				histo[3] <= histo[3] + lastphot[3];
				histo[4] <= histo[4] + lastphot[4];
				histo[5] <= histo[5] + lastphot[5];
				histo[6] <= histo[6] + lastphot[6];
				histo[7] <= histo[7] + lastphot[7];
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
	end
	
	
endmodule
