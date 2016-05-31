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
reg [15:0] old_X, old_Y, old_Z;

always @(posedge clk or negedge rst) begin
	if (~rst) begin
		// reset
		beat_en <= 1'b0;
		beat_intensity <= 2'b00;
	end
	else begin 
		case (X_coordinate[15])//0110000110101000
		1'b1: begin
			if (X_coordinate[14] == 1'b1 && old_X[14] == 1'b0) begin
				if(X_coordinate[13] == 1'b1 && old_X[13] == 1'b0) begin
					beat_en <= 1'b1;
					beat_intensity[0] <= 1'b0;
				end	
			end
		end
		1'b0: begin
			if (X_coordinate[14] == 1'b0 && old_X[14] == 1'b1) begin
				if(X_coordinate[13] == 1'b0 && old_X[13] == 1'b1) begin
					beat_en <= 1'b1;
					beat_intensity[0] <= 1'b0;
				end	
			end
		end
		default : begin
			beat_en <= 1'b0;
			beat_intensity <= 2'b00;
		end
		endcase
		case (Y_coordinate[15])
		1'b1: begin
			if (Y_coordinate[14] == 1'b1 && old_Y[14] == 1'b0) begin
				if(Y_coordinate[13] == 1'b1 && old_Y[13] == 1'b0) begin
					beat_en <= 1'b1;
					beat_intensity[0] <= 1'b1;
				end
			end
		end
		1'b0: begin
			if (Y_coordinate[14] == 1'b0 && old_Y[14] == 1'b1) begin
				if(Y_coordinate[13] == 1'b0 && old_Y[13] == 1'b1) begin
					beat_en <= 1'b1;
					beat_intensity[0] <= 1'b1;
				end
			end
		end
		default : begin
			beat_en <= 1'b0;
			beat_intensity <= 2'b00;
		end
		endcase
		case (Z_coordinate[15])
		1'b1: begin
			if (Z_coordinate[14] == 1'b1 && old_Z[14] == 1'b0) begin
				if(Z_coordinate[13] == 1'b1 && old_Z[13] == 1'b0) begin
					beat_en <= 1'b1;
					beat_intensity <= 2'b11;
				end
			end
		end
		1'b0: begin
			if (Z_coordinate[14] == 1'b0 && old_Z[14] == 1'b1) begin
				if(Z_coordinate[13] == 1'b0 && old_Z[13] == 1'b1) begin
					beat_en <= 1'b1;
					beat_intensity[0] <= 2'b11;
				end
			end
		end
		default : begin
			beat_en <= 1'b0;
			beat_intensity <= 2'b00;
		end
		endcase
		end
		old_Y <= Y_coordinate;
		old_X <= X_coordinate;
		old_Z <= Z_coordinate;
		beat_intensity[1] <= 1'b0;
		//beat_en <= 1'b0;		
	end
always @(posedge clk) begin
	if (beat_en == 1'b1) begin
	beat_en <= 1'b0;
end
end
endmodule