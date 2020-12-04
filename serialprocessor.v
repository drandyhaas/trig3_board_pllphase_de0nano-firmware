module serialprocessor(clk, rxReady, rxData, txBusy, txStart, txData, readdata,
	disable_line_drivers, enable_debug_outputs, updatepll, pll_clk_src, pll_shifts,
	passthrough, h, h_out, resethist, vetopmtlast, useInternalTestPulse, useExternalTestPulse);
	
	

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
	
	typedef enum bit[7:0] {VERSION, SET_OUTPUTS, SET_PLL, SET_PASSTHROUGH, SEND_HISTOGRAM, SET_PMT_VETO, RESET_PLL, SET_TEST_INPUTS} command_T; 
	localparam bit[7:0] numToRead = '{0, 1, 6, 1, 0, 1, 0, 1};
	localparam bit[7:0] numToSend = '{1, 0, 0, 0, 136, 0, 0, 0};
	
	command_T command;
		
	
	reg[7:0] state=READ;
	integer bytesread, byteswanted;
	output reg passthrough=0;
	output reg[2:0] vetopmtlast=3'b001;
	output reg useInternalTestPulse = 0;
	output reg useExternalTestPulse = 0;
	
	input integer h[32];
	input integer h_out[2];
	output reg resethist=0;
	reg resethist_int = 0;
	
	output reg updatepll = 0;
	output reg pll_clk_src = 0;
	output reg[7:0] pll_shifts[0:5] = '{0,0,0,0,0,0};

		
	integer ioCount, ioCountToSend;
	reg[7:0] data[136];//for writing out data in WRITE1,2 //32* 4 + 8 = 136
	reg[7:0] q; //loop counter
	
	integer h_out_reg[2];
	
	parameter[7:0] version = 8'd23;
	
	always @(posedge clk) begin
	h_out_reg <= h_out;
	resethist <= resethist_int;
	case (state)
	READ: begin		  
		txStart<=0;
		bytesread<=0;
      ioCount <= 0;
		resethist_int <=0;
		updatepll <= 0;
      if (rxReady) begin
			byteswanted <= numToRead[rxData];
			readdata <= rxData;
			$cast(command, rxData);
         state <= SOLVING;
      end
	end
	READMORE: begin
		if (bytesread>=byteswanted) state <= SOLVING;
		if (rxReady) begin
			extradata[bytesread] <= rxData;
			bytesread <= bytesread+1;			
		end
	end
   SOLVING: begin
		
		case(command)
		VERSION: begin
			ioCountToSend <= numToSend[VERSION];
			data[0] <= version; // this is the firmware version
			state <= WRITE1;				
		end
		SET_OUTPUTS: begin
			if (bytesread<byteswanted) state <= READMORE;
			else begin
				disable_line_drivers <= !extradata[0][0];
				enable_debug_outputs <= extradata[0][1];
				state <= READ;
			end
		end
		SET_PLL: begin // set clock phase
			if (bytesread<byteswanted) state <= READMORE;
			else begin
				pll_shifts <= extradata[0:5];
				state <= UPDATEPLL;
			end
		end
		SET_PASSTHROUGH: begin
			if (bytesread<byteswanted) state <= READMORE;
			else begin
				passthrough <= extradata[0] != 0;
				state <= READ;
			end
		end
		SEND_HISTOGRAM: begin //send out histo
			ioCountToSend <= numToSend[SEND_HISTOGRAM] ; //32*4 + 8
			data[128] <= h_out_reg[0][7:0];
			data[129] <= h_out_reg[0][15:8];
			data[130] <= h_out_reg[0][23:16];
			data[131] <= h_out_reg[0][31:24];
			data[132] <= h_out_reg[1][7:0];
			data[133] <= h_out_reg[1][15:8];
			data[134] <= h_out_reg[1][23:16];
			data[135] <= h_out_reg[1][31:24];
			
			for (q = 0; q < 32; q = q+8'd1) begin
				data[q*4] <= h[q][7:0];
				data[q*4 + 1] <= h[q][15:8];
				data[q*4 + 2] <= h[q][23:16];
				data[q*4 + 3] <= h[q][31:24];				
			end
			
			
			state <= WRITE1;	
			resethist_int <= 1'b1;
		end
		SET_PMT_VETO: begin
			if (bytesread<byteswanted) state <= READMORE;
			else begin
				vetopmtlast <= extradata[0][2:0];
				state <= READ;
			end
		end
		
		
		RESET_PLL: begin // reset PLL
			pll_shifts = '{0,0,0,0,0,0};
			pll_clk_src = 0;
			state = UPDATEPLL;
		end
		
		SET_TEST_INPUTS: begin
			if (bytesread<byteswanted) state <= READMORE;
			else begin
				useInternalTestPulse <= extradata[0][0];
				useExternalTestPulse <= extradata[0][1];
				state <= READ;
			end
		end
		endcase
	end
	
	
	
	UPDATEPLL: begin // to switch between clock inputs, put clkswitch high for a few cycles, then back down low
		updatepll <= 1;
		state <= READ;
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
