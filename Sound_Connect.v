module Sound_Connect (
	clk,    // Clock
	rst_n,  // Asynchronous reset active low
	beat,
	beat_int 
);
input clk, rst_n;
output beat;
output [1:0] beat_int;
wire beat;
wire [1:0] beat_int;

wire [15:0] X_Acc;
wire [15:0] Y_Acc;
wire [15:0] Z_Acc;
reg en;
//reg check;
reg clk_scale;
wire check;

Beat_Generator u0 (
	.clk(clk_scale),    // Clock 10 ms
	.enable(en),
	.rst(rst_n),  // Asynchronous reset active low
	.X_coordinate(X_Acc), //16 bit input from accelerometer
	.Y_coordinate(Y_Acc), //16 bit input from accelerometer
	.Z_coordinate(Z_Acc), //16 bit input from accelerometer
	.beat_en(beat), // Output if beat detected
	.beat_intensity(beat_int)	 // Output of the beat intensity detected
);

top u1 (
	.clk(clk),
	.scl(scl),
	.sda(sda),
	.rst_n(rst_n),
	.X_Accel(X_Acc),
	.Y_Accel(Y_Acc),
	.Z_Accel(Z_Acc),
	.flag(check)
	);

scale_clock u2 (
	.clk_50Mhz(clk),
	.rst(rst_n),
	.clk_Hz(clk_scale)
	); //10 ms clock

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		// reset
		//check <= 1'b0;
		en <= 1'b0;
	end
	else if (check == 1'b1) begin
		en <= 1'b1;
	end
	else begin
		en <= 1'b0;	
	end		
end
endmodule