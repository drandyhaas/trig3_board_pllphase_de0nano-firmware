module test_pulse(
	input clk1x,
	input clk4x,
	input enabletest,
	output testpulse	
	);
	
	parameter pulseEvery = 70;
	
	reg [7:0] counter = 0;
	reg armed = 0;
	reg pulse = 0; assign testpulse = pulse;
	
	always@(posedge clk4x) begin
	
		armed <= ~clk1x;
		if (armed && clk1x) begin
			if (counter >= pulseEvery) begin
				counter <= 0;
				pulse <= 1'b1;
			end 
			else begin
				counter <= counter + 1;
				pulse <= 0;
			end
		end
		else begin
			pulse <= 0;
		end		
		
	end
	
	
endmodule
