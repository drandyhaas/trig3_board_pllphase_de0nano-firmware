module serialprocessor(clk, rxReady, rxData, txBusy, txStart, txData, readdata,
	disable_line_drivers, enable_debug_outputs, updatepll, pll_clk_src, pll_shifts,
	passthrough, h, h_out, resethist, vetopmtlast, useInternalTestPulse, useExternalTestPulse, ledIndicators);
	
	

	input clk;
	input[7:0] rxData;
	input rxReady;
	input txBusy;
	output reg txStart;
	output reg[7:0] txData;
	output reg[7:0] readdata;//first byte we got
	output reg disable_line_drivers = 0; //set low to enable outputs
	output reg enable_debug_outputs = 0;
	reg [7:0] extradata[10];//to store command extra data, like arguemnts (up to 10 bytes)
	localparam READ=0, SOLVING=1, WRITE1=3, WRITE2=4, READMORE=5,  UPDATEPLL=8;
	
	localparam VERSION=0, SET_OUTPUTS=1, SET_PLL=2, SET_PASSTHROUGH=3, SEND_HISTOGRAM=4, SET_PMT_VETO=5, RESET_PLL=6, SET_TEST_INPUTS=7; 
	localparam bit[7:0] numToRead[16] = '{0, 1, 6, 1, 0, 1, 0, 1, 0,0,0,0,0,0,0,0};
	
	localparam MSGA = 8'b10000000, MSGB = 8'b01000000, MSGC = 8'b00100000, MSGD = 8'b00010000;
	
	reg[3:0] command;
		
	
	reg[7:0] state=READ;
	integer bytesread, byteswanted;
	output reg passthrough=0;
	output reg[2:0] vetopmtlast=3'b001;
	output reg useInternalTestPulse = 0;
	output reg useExternalTestPulse = 0;
	
	input integer h[10];
	input integer h_out[2];
	output reg resethist=0;
	reg resethist_int = 0;
	
	output reg updatepll = 0;
	output reg pll_clk_src = 0;
	output reg[7:0] pll_shifts[0:5] = '{0,0,0,0,0,0};

	output reg[7:0] ledIndicators;
		
	integer ioCount, ioCountToSend;
	reg[7:0] data[136];//for writing out data in WRITE1,2 //32* 4 + 8 = 136
	reg[7:0] q; //loop counter
	integer hh[32];
	integer h_out_reg[2];
	
	parameter[7:0] version = 8'd23;
	
	always @(posedge clk) begin
	h_out_reg <= h_out;
	resethist <= resethist_int;
	hh[0:9] <= h[0:9];
	
	case (state)
	READ: begin		  
		txStart<=0;
		bytesread<=0;
      ioCount <= 0;
		resethist_int <=0;
		updatepll <= 0;
      if (rxReady) begin
			if (rxData < 16) begin
				byteswanted <= numToRead[rxData[3:0]]; //currently only 3 bits used (0-7) but numToRead is defined up to 15 
				readdata <= rxData;
				command <= rxData[3:0];
				state <= SOLVING;
				ledIndicators <= rxData;
			end
			else begin
				ledIndicators <= 255; //error, bad rxData
			end
      end
	end
	READMORE: begin
		if (bytesread>=byteswanted) begin
			state <= SOLVING;
			ledIndicators <= ledIndicators & ~MSGA;
		end
		if (rxReady) begin
			extradata[bytesread] <= rxData;
			bytesread <= bytesread+1;
			ledIndicators <= ledIndicators | MSGA;
		end
	end
   SOLVING: begin
		
		if (command == VERSION) begin
			ioCountToSend <= 1;
			data[0] <= version; // this is the firmware version
			state <= WRITE1;	
			ledIndicators <= 255; //flash all on - should go to 0 then 1 if write is working			
		end
		else if (command == SET_OUTPUTS) begin
			if (bytesread<byteswanted) state <= READMORE;
			else begin
				disable_line_drivers <= !extradata[0][0];
				enable_debug_outputs <= extradata[0][1];
				state <= READ;
			end
		end
		else if (command == SET_PLL) begin // set clock phase
			if (bytesread<byteswanted) begin
				state <= READMORE;
				ledIndicators <= ledIndicators & ~MSGC;
				ledIndicators <= ledIndicators | MSGD;
			end
			else begin
				pll_shifts <= extradata[0:5];
				state <= UPDATEPLL;
				ledIndicators <= ledIndicators & ~MSGD;
				ledIndicators <= ledIndicators | MSGC;
			end
			
		end
		else if (command == SET_PASSTHROUGH) begin
			if (bytesread<byteswanted) state <= READMORE;
			else begin
				passthrough <= extradata[0] != 0;
				state <= READ;
			end
		end
		else if (command == SEND_HISTOGRAM) begin //send out histo
			ioCountToSend <= 136 ; //32*4 + 8
			data[128] <= h_out_reg[0][7:0];
			data[129] <= h_out_reg[0][15:8];
			data[130] <= h_out_reg[0][23:16];
			data[131] <= h_out_reg[0][31:24];
			data[132] <= h_out_reg[1][7:0];
			data[133] <= h_out_reg[1][15:8];
			data[134] <= h_out_reg[1][23:16];
			data[135] <= h_out_reg[1][31:24];
			
			for (q = 0; q < 32; q = q+8'd1) begin
				data[q*4] <=  hh[q][7:0];
				data[q*4 + 1] <= hh[q][15:8];
				data[q*4 + 2] <= hh[q][23:16];
				data[q*4 + 3] <= hh[q][31:24];				
			end
			
			
			state <= WRITE1;	
			resethist_int <= 1'b1;
		end
		else if (command == SET_PMT_VETO) begin
			if (bytesread<byteswanted) state <= READMORE;
			else begin
				vetopmtlast <= extradata[0][2:0];
				state <= READ;
			end
		end
		
		
		else if (command == RESET_PLL) begin // reset PLL
			pll_shifts = '{0,0,0,0,0,0};
			pll_clk_src = 0;
			state = UPDATEPLL;
		end
		
		else if (command == SET_TEST_INPUTS) begin
			if (bytesread<byteswanted) state <= READMORE;
			else begin
				useInternalTestPulse <= extradata[0][0];
				useExternalTestPulse <= extradata[0][1];
				state <= READ;
			end
		end
		
	end
	
	UPDATEPLL: begin // to switch between clock inputs, put clkswitch high for a few cycles, then back down low
		updatepll <= 1;
		state <= READ;
	end
	
	
	
	//just writing out some data bytes over serial
	WRITE1: begin
		if (!txBusy) begin
			txData = data[ioCount];
         txStart = 1;
         state = WRITE2;
		end
		ledIndicators <= ledIndicators | MSGB;
	end
   WRITE2: begin
		txStart = 0;
      if (ioCount < ioCountToSend-1) begin
			ioCount = ioCount + 1;
         state = WRITE1;
      end
		else begin
			state = READ;
			ledIndicators <= ledIndicators & ~MSGB;
		end
	end
endcase
end //posedge

endmodule
