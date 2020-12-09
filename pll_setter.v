module pll_setter(clk, update, pll_clksrc, phase_shifts, phase_done, areset, phasecounterselect,phaseupdown, phasestep,scanclk, clkswitch);
	
	input clk;
	input update;
	input pll_clksrc;
	input reg [7:0] phase_shifts[0:5]; //all, clock, start1, stop1, start2, stop2 - stop1, stop2 are negative shifts, all others are positive
	input phase_done;
	
	output reg areset = 0;
   output reg[2:0] phasecounterselect = 3'b000; // Dynamic phase shift counter Select. 000:all 001:M 010:C0 011:C1 100:C2 101:C3 110:C4. Registered in the rising edge of scanclk.
	output reg phaseupdown=1; // Dynamic phase shift direction; 1:UP, 0:DOWN. Registered in the PLL on the rising edge of scanclk.
	output reg phasestep=0;
	output reg scanclk=0;
	output reg clkswitch=0; // No matter what, inclk0 is the default clock
	
	//localparam ALL=3'b000, PSCLK = 3'b010, START1 = 3'b011, STOP1 = 3'b100, START2 = 3'b101, STOP2 = 3'b110;
	
	localparam bit [2:0] psbits[6] = '{3'b000, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110}; //ALL, C0, C1, c2, C3, C4 -> PS, START1, STOP1, START2, STOP2
	localparam bit psdir[6] = '{1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0};
	reg[3:0] psstep = 0;
	
	localparam WAIT=8'd0, ARESET=8'd1, CLKSWITCH=8'd2, PHASESTEP=8'd3, ONEPHASE=8'd4, SHIFTING = 8'd5;//SHIFTALL = 8'd5, SHIFTPS = 8'd6, SHIFTSTART1 = 8'd7, SHIFTSTOP1 = 8'd8, SHIFTSTART2 = 8'd9, SHIFTSTOP2 = 8'd10;
	reg[7:0] state=WAIT;
	
	integer pll_phase_setting;
	integer phasecounter;
	integer pll_clksrc_setting;
	
	
	integer pllclock_counter=0;
	integer scanclk_cycles=0;
	
	reg [7:0] phase_shifts_local[0:5];
	
	always @(posedge clk) begin
		case (state)
		WAIT: begin		  
			
			if (update) begin
				phase_shifts_local <= phase_shifts;
				pll_clksrc_setting <= pll_clksrc;
				pllclock_counter <= 0;
				state <= ARESET;
				psstep = 0;
			end
		end
		
		ARESET: begin // to switch between clock inputs, put clkswitch high for a few cycles, then back down low
			areset <= 1'b1;
			pllclock_counter<=pllclock_counter+1;
			if (pllclock_counter[3]) begin
				areset <= 1'b0;
				pllclock_counter<=0;
				if (pll_clksrc_setting) begin
					clkswitch <= 1;
					state<=CLKSWITCH;
				end
				else state <= SHIFTING;
			end
		end
		CLKSWITCH: begin // to switch between clock inputs, put clkswitch high for a few cycles, then back down low
			pllclock_counter<=pllclock_counter+1;
			if (pllclock_counter[3]) begin
				clkswitch <= 0;
				pllclock_counter<=0;
				state<=SHIFTING;
			end
		end
		
		
		
		SHIFTING: begin	
			if (psstep >= 6) begin
				state <= WAIT;
			end 
			else begin
				phasecounterselect<=psbits[psstep]; //see https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/cyc3/cyc3_ciii51006.pdf table 5-10.
				phaseupdown<=psdir[psstep]; // up
				phasecounter <= 0;
				pll_phase_setting <= phase_shifts_local[psstep];
				state <= PHASESTEP;
			end
		end
		
		
		
		PHASESTEP: begin //repeat the single phase step pll_phase times
			if (phasecounter <= pll_phase_setting) begin		
				scanclk<=1'b0; // start low
				phasestep<=1'b1; // assert!
				pllclock_counter<=0;
				scanclk_cycles<=0;
				state <= ONEPHASE;
			end
		   else begin
				psstep <= psstep + 1'b1;
				state <= SHIFTING;
			end
		end
		
		ONEPHASE: begin // to step the clock phase, you have to toggle scanclk a few times
			pllclock_counter<=pllclock_counter+1;
			if (pllclock_counter[4]) begin
				scanclk <= ~scanclk;
				pllclock_counter<=0;
				scanclk_cycles<=scanclk_cycles+1;
				if (scanclk_cycles>5) phasestep<=1'b0; // deassert! Q: why 1'b0 and not 0 ?
				
				if (scanclk_cycles>7 && phase_done) begin
					phasecounter <= phasecounter+1;
					state<=PHASESTEP;
				end
				
				if (scanclk_cycles > 107) begin
					state<=PHASESTEP; //give up
				end
			end
		end
		
		endcase
	end  
	
endmodule
