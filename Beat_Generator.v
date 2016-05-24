module Beat_Generator (
	clk,    // Clock
	enable,
	rst,  // Asynchronous reset active low
	X_coordinate, //16 bit input from accelerometer
	Y_coordinate, //16 bit input from accelerometer
	Z_coordinate, //16 bit input from accelerometer
	beat_en, // Output if beat detected
	beat_intensity	 // Output of the beat intensity detected
	);
input clk, enable, rst;    // Clock, Asynchronous reset active low
input [15:0] X_coordinate, Y_coordinate, Z_coordinate;//16 bit input from accelerometer
output beat_en; // Output if beat detected
output [1:0] beat_intensity;	 // Output of the beat intensity detected
//--------------------------------------------------------------------------------------------------------
wire [15:0] X_save; //Wire to send one instance of X_coordinate data recieved at clk
wire [15:0] Y_save; //Wire to send one instance of Y_coordinate data recieved at clk
wire [15:0] Z_save; //Wire to send one instance of Z_coordinate data recieved at clk
//parameter [15:0] level_1, level_2, level_3;
reg [1:0] beat_intensity;
reg beat_en;
//--------------------------------------------------------------------------------------------------------
parameter	level_1 = 16'b0000000001100100; //Binary 100 - level to compare difference.
parameter	level_2 = 16'b0000000100101100; //Binary 300 - level to compare difference.
parameter	level_3 = 16'b0000000111110100; //Binary 500 - level to compare difference.


//------------------------------------------Instantiantion of PIPO-------------------------------------------
PIPO u0 (
	.clk (clk),
	.rst (rst),
	.din (X_coordinate),
	.dout (X_save)
	);

PIPO u1 (
	.clk (clk),
	.rst (rst),
	.din (Y_coordinate),
	.dout (Y_save)
	);

PIPO u2 (
	.clk (clk),
	.rst (rst),
	.din (Z_coordinate),
	.dout (Z_save)
	);
//------------------------------------------------Always block for subtraction logic-------------------------
always @(posedge clk or negedge rst) begin
	if (~rst) begin
//	X_save <= 16'bZ;
//	Y_save <= 16'bZ;
//	Z_save <= 16'bZ;
beat_en <= 1'b0;
	beat_intensity <= 2'b00;		// reset		
end
else if (enable) begin
	/* code */
	if (X_coordinate - X_save > level_1 && X_coordinate - X_save < level_2  || Y_coordinate - Y_save > level_1 && Y_coordinate - Y_save < level_2 || Z_coordinate - Z_save > level_1 && Z_coordinate - Z_save < level_2) begin
		beat_en <= 1'b1;
		//#40 beat_en <= 1'b0;
		beat_intensity <= 2'b01;	
	end
	else if (X_coordinate - X_save > level_2 && X_coordinate - X_save < level_3 || Y_coordinate - Y_save > level_2 && Y_coordinate - Y_save < level_3 || Z_coordinate - Z_save > level_2 && Z_coordinate - Z_save < level_3) begin
		beat_en <= 1'b1;
		//#40 beat_en <= 1'b0;
		beat_intensity <= 2'b10;	
	end
	else if (X_coordinate - X_save > level_3 || Y_coordinate - Y_save > level_3 || Z_coordinate - Z_save > level_3) begin
		beat_en <= 1'b1;
		//#40 beat_en <= 1'b0;
		beat_intensity <= 2'b11;	
	end
	else begin
		beat_en <= 1'b0;
		beat_intensity <= 2'b00;
	end
end

end
endmodule