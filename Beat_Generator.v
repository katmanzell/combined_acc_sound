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

//--------------------------------------------------------------------------------------------------------//
reg [15:0] old_Y;



always @(posedge clk or negedge rst) begin
	if (~rst) begin
		// reset
		beat_en <= 1'b0;
		beat_intensity <= 2'b00;
	end
	else begin 
	
		//if (X_coordinate  >= 16'd8000) begin 
		if (Y_coordinate[15] == 1'b1 && old_Y[15] == 1'b0) begin // && old_X >= 16'd8000) begin
			beat_en <= 1'b1;
			beat_intensity <= 2'b01;
		end
		
		else begin
			beat_en <= 1'b0;
			beat_intensity <= 2'b00;
		end
		old_Y <= Y_coordinate;
		
	end


end

endmodule