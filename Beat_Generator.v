//Magda's

/*module Beat_Generator (
	clk,    // Clock
	//enable,
	rst,  // Asynchronous reset active low
	X_coordinate, //16 bit input from accelerometer
	Y_coordinate, //16 bit input from accelerometer
	Z_coordinate, //16 bit input from accelerometer
	beat_en, // Output if beat detected
	beat_intensity	 // Output of the beat intensity detected
);

input clk, rst;    // Clock, Asynchronous reset active low
input [15:0] X_coordinate, Y_coordinate, Z_coordinate;//16 bit input from accelerometer
output beat_en; // Output if beat detected
output [1:0] beat_intensity;	 // Output of the beat intensity detected
reg [1:0] beat_intensity;
reg beat_en;

//--------------------------------------------------------------------------------------------------------//
reg [3:0] counter;


always @(posedge clk or negedge rst) begin
	if (! rst) begin
		// reset
		beat_en <= 1'b0;
		beat_intensity <= 2'b00;
	end
	else begin 

		
	
	
		if (X_coordinate  >= 16'd15000) begin 
		//if (X_coordinate[15] == 1'b1 && old_X[15] == 1'b0) begin
			beat_en <= 1'b1;
			beat_intensity <= 2'b01;
		end
		
//		else if (Y_coordinate  >= 16'd20000) begin 
//		//if (Y_coordinate[15] == 1'b1 && old_X[15] == 1'b0) begin
//			beat_en <= 1'b1;
//			beat_intensity <= 2'b10;
//		end
//		
//		 else if (Z_coordinate  >= 16'd20000) begin 
//		//if (Z_coordinate[15] == 1'b1 && old_X[15] == 1'b0) begin
//			beat_en <= 1'b1;
//			beat_intensity <= 2'b11;
//		end

		else begin
			beat_en <= 1'b0;
			beat_intensity <= 2'b00;
		end
		
		//beat_en <= 1'b0;
		//beat_intensity <= 2'b00;
		
	end


end

endmodule*/



//************************************************************************************************************************************

//Sarthak's before changes

module Beat_Generator (
	clk,    // Clock
	//enable,
	rst,  // Asynchronous reset active low
	X_coordinate, //16 bit input from accelerometer
	Y_coordinate, //16 bit input from accelerometer
	Z_coordinate, //16 bit input from accelerometer
	beat_en, // Output if beat detected
	beat_intensity	 // Output of the beat intensity detected
	);
input clk, rst;    // Clock, Asynchronous reset active low
input [15:0] X_coordinate, Y_coordinate, Z_coordinate;//16 bit input from accelerometer
output beat_en; // Output if beat detected
output [1:0] beat_intensity;	 // Output of the beat intensity detected
reg [1:0] beat_intensity;
reg beat_en;
reg [7:0] count_length;
parameter delay_length = 8'd5;
parameter level1 = 16'd15000;
parameter level2 = 16'd25000;
parameter level3 = 16'd30000;
reg signed [15:0] Xsave, Ysave, Zsave;

//--------------------------------------------------------------------------------------------------------//
always @(posedge clk or negedge rst) begin
	if (! rst) begin
		// reset
		count_length <= delay_length;
		beat_en <= 1'b0;
		beat_intensity <= 2'b00;
	end
	else if (count_length > 8'd0) begin
		count_length <= count_length - 8'd1;
		beat_en <= 1'b0;
		beat_intensity <= 2'b00;
	end
	else if (count_length == 8'd0) begin
		if (Xsave >= level1 && Xsave < level2) begin // Greater than 20% of average.
			beat_en <= 1'b1;
			beat_intensity <= 2'b01;
			count_length <= delay_length;
		end
		/*if (Xsave <= -level1 && Xsave > -level2) begin
			beat_en <= 1'b1;
			beat_intensity <= 2'b01;
			count_length <= delay_length;
		end
		if (Xsave >= level2 && Xsave < level3) begin // Greater than 20% of average.
			beat_en <= 1'b1;
			beat_intensity <= 2'b10;
			count_length <= delay_length;
		end	
		if (Xsave <= -level2 && Xsave > -level3) begin
			beat_en <= 1'b1;
			beat_intensity <= 2'b10;
			count_length <= delay_length;
		end
		if (Xsave >= level3) begin // Greater than 20% of average.
			beat_en <= 1'b1;
			beat_intensity <= 2'b11;
			count_length <= delay_length;
		end
		if (Xsave <= -level3) begin
			beat_en <= 1'b1;
			beat_intensity <= 2'b11;
			count_length <= delay_length;
		end
		if (Ysave >= level1 && Ysave < level2) begin // Greater than 20% of average.
			beat_en <= 1'b1;
			beat_intensity <= 2'b01;
			count_length <= delay_length;
		end
		if (Ysave <= -level1 && Ysave > -level2) begin
			beat_en <= 1'b1;
			beat_intensity <= 2'b01;
			count_length <= delay_length;
		end
		if (Ysave >= level2 && Ysave < level3) begin // Greater than 20% of average.
			beat_en <= 1'b1;
			beat_intensity <= 2'b10;
			count_length <= delay_length;
		end	
		if (Ysave <= -level2 && Ysave > -level3) begin
			beat_en <= 1'b1;
			beat_intensity <= 2'b10;
			count_length <= delay_length;
		end
		if (Ysave >= level3) begin // Greater than 20% of average.
			beat_en <= 1'b1;
			beat_intensity <= 2'b11;
			count_length <= delay_length;
		end
		if (Ysave <= -level3) begin
			beat_en <= 1'b1;
			beat_intensity <= 2'b11;
			count_length <= delay_length;	
			end	
		if (Zsave >= level1 && Zsave < level2) begin // Greater than 20% of average.
			beat_en <= 1'b1;
			beat_intensity <= 2'b01;
			count_length <= delay_length;
		end
		if (Zsave <= -level1 && Zsave > -level2) begin
			beat_en <= 1'b1;
			beat_intensity <= 2'b01;
			count_length <= delay_length;
		end
		if (Zsave >= level2 && Zsave < level3) begin // Greater than 20% of average.
			beat_en <= 1'b1;
			beat_intensity <= 2'b10;
			count_length <= delay_length;
		end	
		if (Zsave <= -level2 && Zsave > -level3) begin
			beat_en <= 1'b1;
			beat_intensity <= 2'b10;
			count_length <= delay_length;
		end
		if (Zsave >= level3) begin // Greater than 20% of average.
			beat_en <= 1'b1;
			beat_intensity <= 2'b11;
			count_length <= delay_length;
		end
		if (Zsave <= -level3) begin
			beat_en <= 1'b1;
			beat_intensity <= 2'b11;
			count_length <= delay_length;
		end*/
		else begin
			beat_en <= 1'b0;
			beat_intensity <= 2'b00;
		end
	end
	else begin
	end
end

always @(posedge clk) begin
		Xsave <= X_coordinate;
		Ysave <= Y_coordinate;
		Zsave <= Z_coordinate;
end

endmodule

//**********************************************************************************888
//sarthak's newer

/*module Beat_Generator (
	clk,    // Clock
	//enable,
	rst,  // Asynchronous reset active low
	X_coordinate, //16 bit input from accelerometer
	Y_coordinate, //16 bit input from accelerometer
	Z_coordinate, //16 bit input from accelerometer
	beat_en, // Output if beat detected
	beat_intensity	 // Output of the beat intensity detected
	);
input clk, rst;    // Clock, Asynchronous reset active low
input [15:0] X_coordinate, Y_coordinate, Z_coordinate;//16 bit input from accelerometer
output beat_en; // Output if beat detected
output [1:0] beat_intensity;	 // Output of the beat intensity detected
reg [1:0] beat_intensity;
reg beat_en;
reg [7:0] count_length;
parameter delay_length = 8'd5;
parameter level1 = 16'd15000;
parameter level2 = 16'd25000;
parameter level3 = 16'd30000;
reg signed [15:0] Xsave, Ysave, Zsave;

//--------------------------------------------------------------------------------------------------------//
always @(posedge clk or negedge rst) begin
	if (! rst) begin
		// reset
		count_length <= delay_length;
		beat_en <= 1'b0;
		beat_intensity <= 2'b00;
	end
	else if (count_length > 8'd0) begin
		count_length <= count_length - 8'd1;
		beat_en <= 1'b0;
		beat_intensity <= 2'b00;
	end
	else if (count_length == 8'd0) begin
		if (Xsave >= level1) begin // Greater than 20% of average.
			if(Ysave < 16'd0) begin
				if(Zsave < 16'd0) begin
					beat_en <= 1'b1;
					beat_intensity <= 2'b01;
					count_length <= delay_length;
					
				end
				
			end
			
		end
		
		else begin
			beat_en <= 1'b0;
			beat_intensity <= 2'b00;
		end
	end
	else begin
	end
end

always @(posedge clk) begin
		Xsave <= X_coordinate;
		Ysave <= Y_coordinate;
		Zsave <= Z_coordinate;
end

endmodule*/