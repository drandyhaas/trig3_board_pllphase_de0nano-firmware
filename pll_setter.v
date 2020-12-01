module pll_setter(clk, update, pll_clksrc, pll_phase, phase_done, areset, phasecounterselect,phaseupdown, phasestep,scanclk, clkswitch);
	
	input clk;
	input update;
	input pll_clksrc;
	input[7:0] pll_phase;
	input phase_done;
	
	output reg areset = 0;
   output reg[2:0] phasecounterselect = 3'b000; // Dynamic phase shift counter Select. 000:all 001:M 010:C0 011:C1 100:C2 101:C3 110:C4. Registered in the rising edge of scanclk.
	output reg phaseupdown=1; // Dynamic phase shift direction; 1:UP, 0:DOWN. Registered in the PLL on the rising edge of scanclk.
	output reg phasestep=0;
	output reg scanclk=0;
	output reg clkswitch=0; // No matter what, inclk0 is the default clock
	
	
	localparam WAIT=0, ARESET=1, CLKSWITCH=2, PHASESTEP=3, ONEPHASE=4;
	reg[7:0] state=WAIT;
	
	integer pll_phase_setting;
	integer phasecounter;
	integer pll_clksrc_setting;
	
	
	integer pllclock_counter=0;
	integer scanclk_cycles=0;
	
	always @(posedge clk) begin
		case (state)
		WAIT: begin		  
			
			if (update) begin
				pll_phase_setting <= pll_phase;
				pll_clksrc_setting <= pll_clksrc;
				phasecounter <= 0;
				pllclock_counter <= 0;
				state <= ARESET;
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
				else state <= PHASESTEP;
			end
		end
		CLKSWITCH: begin // to switch between clock inputs, put clkswitch high for a few cycles, then back down low
			pllclock_counter<=pllclock_counter+1;
			if (pllclock_counter[3]) begin
				clkswitch <= 0;
				pllclock_counter<=0;
				state<=PHASESTEP;
			end
		end
		
		PHASESTEP: begin //repeat the single phase step pll_phase times
			if (phasecounter <= pll_phase_setting) begin
				phasecounterselect<=3'b000; // all clocks - see https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/cyc3/cyc3_ciii51006.pdf table 5-10.
				phaseupdown<=1'b1; // up
				scanclk<=1'b0; // start low
				phasestep<=1'b1; // assert!
				pllclock_counter<=0;
				scanclk_cycles<=0;
				state <= ONEPHASE;
			end
		   else begin
				state <= WAIT;
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
