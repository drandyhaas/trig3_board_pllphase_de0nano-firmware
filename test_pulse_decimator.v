module test_pulse_decimator(
	input clk1x,
	input enabletest,
	output testvalid	
	);
	
	parameter pulseEvery = 10;
	
	reg [7:0] counter = 0;
	reg valid = 0; assign testvalid = valid;
	
	always@(posedge clk1x) begin
		if (counter >= pulseEvery) begin
			counter <= 0;
			valid <= enabletest;
		end 
		else begin
			counter <= counter + 1;
			valid <= 0;
		end			
	end
	
	
endmodule
