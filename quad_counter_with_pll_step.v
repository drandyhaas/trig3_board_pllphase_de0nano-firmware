module quad_counter_with_pll_step(
	input clkin,
	input locked,
	input [1:0] phase_bin,
	input [3:0] detect,
	input resethist, 
	output integer hist[32] //0-15 = cycles; 16-31 = photons
	);
	
	
	reg [5:0] j = 0;
	reg resethist2;

	integer  c0[4];
	integer  c1[4];
	integer  c2[4];
	integer  c3[4];
	
	integer  p0[4];
	integer  p1[4];
	integer  p2[4];
	integer  p3[4];
	
	
	always@(posedge clkin) begin
		
		hist[0] = c0[0];
		hist[1] = c0[1];
		hist[2] = c0[2];
		hist[3] = c0[3];
		hist[4] = c1[0];
		hist[5] = c1[1];
		hist[6] = c1[2];
		hist[7] = c1[3];
		hist[8] = c2[0];
		hist[9] = c2[1];
		hist[10] = c2[2];
		hist[11] = c2[3];
		hist[12] = c3[0];
		hist[13] = c3[1];
		hist[14] = c3[2];
		hist[15] = c3[3];
		
		
		hist[16] = p0[0];
		hist[17] = p0[1];
		hist[18] = p0[2];
		hist[19] = p0[3];
		hist[20] = p1[0];
		hist[21] = p1[1];
		hist[22] = p1[2];
		hist[23] = p1[3];
		hist[24] = p2[0];
		hist[25] = p2[1];
		hist[26] = p2[2];
		hist[27] = p2[3];
		hist[28] = p3[0];
		hist[29] = p3[1];
		hist[30] = p3[2];
		hist[31] = p3[3];
		
		resethist2 <= (resethist2 || resethist);
		if (resethist2) begin
			c0[0] <= 0;
			c0[1] <= 0;
			c0[2] <= 0;
			c0[3] <= 0;
			c1[0] <= 0;
			c1[1] <= 0;
			c1[2] <= 0;
			c1[3] <= 0;
			c2[0] <= 0;
			c2[1] <= 0;
			c2[2] <= 0;
			c2[3] <= 0;
			c3[0] <= 0;
			c3[1] <= 0;
			c3[2] <= 0;
			c3[3] <= 0;
			
			p0[0] <= 0;
			p0[1] <= 0;
			p0[2] <= 0;
			p0[3] <= 0;
			p1[0] <= 0;
			p1[1] <= 0;
			p1[2] <= 0;
			p1[3] <= 0;
			p2[0] <= 0;
			p2[1] <= 0;
			p2[2] <= 0;
			p2[3] <= 0;
			p3[0] <= 0;
			p3[1] <= 0;
			p3[2] <= 0;
			p3[3] <= 0;			
		end else begin
			if (locked) begin
				c0[phase_bin] <= c0[phase_bin] + 1'b1;
				c1[phase_bin] <= c1[phase_bin] + 1'b1;
				c2[phase_bin] <= c2[phase_bin] + 1'b1;
				c3[phase_bin] <= c3[phase_bin] + 1'b1;
					
				p0[phase_bin] <= p0[phase_bin] + detect[0];
				p1[phase_bin] <= p1[phase_bin] + detect[1];
				p2[phase_bin] <= p2[phase_bin] + detect[2];
				p3[phase_bin] <= p3[phase_bin] + detect[3];						
			end
		end											
	end
	
	
endmodule
