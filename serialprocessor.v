module processor(clk, rxReady, rxData, txBusy, txStart, txData, readdata,
	deadticks, firingticks, enable_outputs, updatepll, pll_clk_src, pll_clk_phase,
	mask1, mask2, passthrough, h, ipihist, resethist, vetopmtlast, cyclesToVeto, useClockAsInput);
	
	//phasecounterselect,phaseupdown,phasestep,scanclk, clkswitch,
	
	
	input clk;
	input[7:0] rxData;
	input rxReady;
	input txBusy;
	output reg txStart;
	output reg[7:0] txData;
	output reg[7:0] readdata;//first byte we got
	output reg enable_outputs=0;//set low to enable outputs
	reg [7:0] extradata[10];//to store command extra data, like arguemnts (up to 10 bytes)
	localparam READ=0, SOLVING=1, WRITE1=3, WRITE2=4, READMORE=5,  UPDATEPLL=8;
	integer state=READ;
	integer bytesread, byteswanted;
	output reg[7:0] mask1 = 8'b00001111;
	output reg[7:0] mask2 = 8'b11110000;
	output reg passthrough=0;
	output reg vetopmtlast=1;
	output reg[7:0] cyclesToVeto = 0;
	output reg useClockAsInput = 0;
	
	input integer h[8];
	input integer ipihist[64];
	output reg resethist=0;
	
	//integer pllclock_counter=0;
	//integer scanclk_cycles=0;
	// output reg[2:0] phasecounterselect; // Dynamic phase shift counter Select. 000:all 001:M 010:C0 011:C1 100:C2 101:C3 110:C4. Registered in the rising edge of scanclk.
	// output reg phaseupdown=1; // Dynamic phase shift direction; 1:UP, 0:DOWN. Registered in the PLL on the rising edge of scanclk.
	// output reg phasestep=0;
	// output reg scanclk=0;
	// output reg clkswitch=0; // No matter what, inclk0 is the default clock
	
//	output reg areset = 0; //output to reset the PLL

	output reg updatepll = 0;
	output reg pll_clk_src = 0;
	output reg[7:0] pll_clk_phase;

		
	integer ioCount, ioCountToSend;
	reg[7:0] data[288];//for writing out data in WRITE1,2 //72* 4 = 288
	reg[7:0] q; //loop counter
	output reg[7:0] deadticks=10; // dead for 200 ns
	output reg[7:0] firingticks=9; // 50 ns wide pulse

	parameter version = 8'd17;
	
	always @(posedge clk) begin
	case (state)
	READ: begin		  
		txStart<=0;
		bytesread<=0;
		byteswanted<=0;
      ioCount = 0;
		resethist=0;
		updatepll = 0;
      if (rxReady) begin
			readdata = rxData;
         state = SOLVING;
      end
	end
	READMORE: begin
		if (rxReady) begin
			extradata[bytesread] = rxData;
			bytesread = bytesread+1;
			if (bytesread>=byteswanted) state=SOLVING;
		end
	end
   SOLVING: begin
		if (readdata==0) begin // send the firmware version				
			ioCountToSend = 1;
			data[0]=version; // this is the firmware version
			state=WRITE1;				
		end
		else if (readdata==1) begin //wait for next byte: number of 20ns ticks to remain dead for after firing outputs
			byteswanted=1; if (bytesread<byteswanted) state=READMORE;
			else begin
				deadticks=extradata[0];
				state=READ;
			end
		end
		else if (readdata==2) begin //wait for next byte: number of 5ns ticks to fire outputs for
			byteswanted=1; if (bytesread<byteswanted) state=READMORE;
			else begin
				firingticks=extradata[0];
				state=READ;
			end
		end
		else if (readdata==3) begin //toggle output enable
			enable_outputs = ~enable_outputs;
			state=READ;
		end
		else if (readdata==4) begin //toggle clk inputs
			pll_clk_src = ~pll_clk_src;
			state = UPDATEPLL;
		end
//		else if (readdata==5) begin //adjust clock phase
//			phasecounterselect=3'b000; // all clocks - see https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/cyc3/cyc3_ciii51006.pdf table 5-10.
//			//phaseupdown=1'b1; // up
//			scanclk=1'b0; // start low
//			phasestep=1'b1; // assert!
//			pllclock_counter=0;
//			scanclk_cycles=0;
//			state=PLLCLOCK;
//		end
		else if (readdata == 5) begin // set clock phase
			byteswanted=1; if (bytesread<byteswanted) state=READMORE;
			else begin
				pll_clk_phase=extradata[0];
				state=UPDATEPLL;
			end
		end


		else if (readdata==6) begin //set mask 1 
			byteswanted=1; if (bytesread<byteswanted) state=READMORE;
			else begin
				mask1=extradata[0];
				state=READ;
			end
		end
		else if (readdata==7) begin //set mask 2
			byteswanted=1; if (bytesread<byteswanted) state=READMORE;
			else begin
				mask2=extradata[0];
				state=READ;
			end
		end
		else if (readdata==8) begin //toggle use of pmt passthrough
			passthrough = ~passthrough;
			state=READ;
		end

		else if (readdata==10) begin //send out histo
			ioCountToSend = 288 ;
			data[0]=h[0][7:0];
			data[1]=h[0][15:8];
			data[2]=h[0][23:16];
			data[3]=h[0][31:24];
			data[4]=h[1][7:0];
			data[5]=h[1][15:8];
			data[6]=h[1][23:16];
			data[7]=h[1][31:24];
			data[8]=h[2][7:0];
			data[9]=h[2][15:8];
			data[10]=h[2][23:16];
			data[11]=h[2][31:24];
			data[12]=h[3][7:0];
			data[13]=h[3][15:8];
			data[14]=h[3][23:16];
			data[15]=h[3][31:24];
			data[16]=h[4][7:0];
			data[17]=h[4][15:8];
			data[18]=h[4][23:16];
			data[19]=h[4][31:24];
			data[20]=h[5][7:0];
			data[21]=h[5][15:8];
			data[22]=h[5][23:16];
			data[23]=h[5][31:24];
			data[24]=h[6][7:0];
			data[25]=h[6][15:8];
			data[26]=h[6][23:16];
			data[27]=h[6][31:24];
			data[28]=h[7][7:0];
			data[29]=h[7][15:8];
			data[30]=h[7][23:16];
			data[31]=h[7][31:24];
			
			for (q = 0; q < 64; q = q+1) begin
				data[32 + q*4] = ipihist[q][7:0];
				data[q*4 + 33] = ipihist[q][15:8];
				data[q*4 + 34] = ipihist[q][23:16];
				data[q*4 + 35] = ipihist[q][31:24];				
			end
			state=WRITE1;	
			resethist=1;
		end
		else if (readdata==11) begin //toggle vetopmtlast
			vetopmtlast = ~vetopmtlast;
			state=READ;
		end

		else if (readdata==13) begin // reset PLL
			pll_clk_phase = 0;
			pll_clk_src = 0;
			state = UPDATEPLL;
		end
		
		else if (readdata == 14) begin // set veto counter
			byteswanted=1; if (bytesread<byteswanted) state=READMORE;
			else begin
				cyclesToVeto=extradata[0];
				state=READ;
			end
		end
		
		else if (readdata==15) begin //toggle using clock as a pmt input
			useClockAsInput = ~useClockAsInput;
			state=READ;
		end
		
		else state=READ; // if we got some other command, just ignore it
	end
	
	
	
	UPDATEPLL: begin // to switch between clock inputs, put clkswitch high for a few cycles, then back down low
		updatepll = 1;
		state=READ;
	end
	
	
	
	//just writng out some data bytes over serial
	WRITE1: begin
		if (!txBusy) begin
			txData = data[ioCount];
         txStart = 1;
         state = WRITE2;
		end
	end
   WRITE2: begin
		txStart = 0;
      if (ioCount < ioCountToSend-1) begin
			ioCount = ioCount + 1;
         state = WRITE1;
      end
		else state = READ;
	end

	endcase
	end  
	
endmodule
