module LED_4(
	input nrst,
	input clk_lvds,
	output reg [3:0] led,
	input [15:0] coax_in,
	output [15:0] coax_out,	
	input [7:0] deadticks, input [7:0] firingticks,
	input clk_test,
	input clkin, input passthrough,
	output integer histo[8], input resethist, input vetopmtlast,	//histo must have at least NBINS
	input [NBINS-1:0] lvds_rx,
	input [NBINS-1:0] mask1,
	input [NBINS-1:0] mask2,
	input [7:0] cyclesToVeto,
	output integer ipihist[64] //70 Mhz / 64 = ~1.1 MHz
	);
	
	//TODO: rewrite using bit shift operations 
	
	parameter NBINS = 8;
	
	// for testing logic
	reg pmt1test;
	reg [5:0] clk1counter=0;
	always@(posedge clk_test) begin // runs on the fast clock
		clk1counter <= clk1counter+1;		
		if (clk1counter == 1) pmt1test<=1; // make a test pulse
		else pmt1test<=0;
	end
	
	wire pmt1;
	//assign pmt1 = pmt1test; // pmt test input
	assign pmt1 = coax_in[3] ||coax_in[8]; // pmt input (LVDS) || (single-ended)
	
	assign coax_out[0]=pmt1test; //N11 // a test pulse
	assign coax_out[1]=clk_test; // P9 // the 4x input for test pulses
	reg out1;assign coax_out[2]=out1; // A6 // the out1
	reg out2;assign coax_out[3]=out2; // B6 // the out2
	
	
	
	assign coax_out[4]=clkin; // F9 // the input clock that can also have its phase adjusted
	assign coax_out[5]=clk_lvds; // E7 // the clk for lvds that can also have its phase adjusted
	
	
	assign led[0]=pmt1;
	assign led[1]=out1;
	assign led[2]=out2;
	assign led[3]=1;
		
	reg resethist1=0, resethist2=0;
	reg [NBINS-1:0] lvds_last=0;
	reg [NBINS-1:0] phot=0;
	reg [7:0] j;
	reg [7:0] k;
	
	reg [7:0] cyclecounter;
	reg wasphot;
	
	reg inveto; assign coax_out[6] = inveto; // check pin planner; whether new photons will be vetoed
	reg collision; assign coax_out[7] = collision; // check pin planner; two photons arrived within veto window
	
	always@(posedge clkin) begin
		if (passthrough) begin
			out1 <= pmt1;
			out2 <= (lvds_rx != 0);
		end
		else begin			
			if (vetopmtlast) begin
				lvds_last[NBINS-1] = lvds_last[0];
				for (j=0; j<NBINS-1; j=j+1) begin
					lvds_last[j] = lvds_rx[j+1];
				end
				phot = lvds_rx & ~lvds_last;
			end
			else begin
				phot = lvds_rx;
			end
			if (cyclecounter < cyclesToVeto) begin
				phot = 0;
			end
			
			
			//within a block
			//<= --> parallel execution (simultaneous update at the end of the clock cycle)
			// = --> serial execution
			
			if (phot) begin
				if (cyclecounter < 64) begin
					ipihist[cyclecounter] <= ipihist[cyclecounter] + 1;				
				end 
				cyclecounter = 0;								
			end 
			else begin
				if (cyclecounter < 254) begin
					cyclecounter <= cyclecounter + 1;
				end
			end
				

			out1 <= (phot & mask1) != 0;
			out2 <= (phot & mask2) != 0;
			lvds_last = lvds_rx;

			resethist1<=resethist;
			resethist2<=resethist1;
			
			
			if (resethist2) begin
				for (j=0; j<NBINS-1; j=j+1) begin
					histo[j] <= 0; 
				end
				
				for (k = 0; k < 64; k = k + 1) begin
					ipihist[k] <= 0;
				end
			end
			else begin
				
				for (j=0; j<NBINS-1; j=j+1) begin
					histo[j] <= histo[j] + phot[j]; 
				end
			end
			
		end		
	end
	
	
endmodule
