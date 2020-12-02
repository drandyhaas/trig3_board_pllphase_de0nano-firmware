//converts integer histogram array to 64 bit register and clocks into/out of FIFO to shift between clock domains

`timescale 1ns/1ns
module fifo_manager_hist2toserial
  (
	input integer hist70[2],
	output integer hist50[2],	
	input clk70,
	input clk50,
	
	output reg[63:0] data,
	output reg wrreq,
	output wrclk,
	input wrfull,
	
	input reg[63:0] q,
	input reg rdempty,
	output reg rdreq = 1,
	output rdclk
   );

	assign wrclk = clk70;
	assign rdclk = clk50;
	
  always @(posedge clk70) begin
		wrreq <= !wrfull;
		data[31:0] <= hist70[0];
		data[63:32] <= hist70[1];
  end
  
  always @(posedge clk50) begin
		if (!rdempty) begin
			hist50[0] <= q[31:0];
			hist50[1] <= q[63:32];
		end
	end
endmodule