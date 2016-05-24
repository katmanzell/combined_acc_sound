`include "macros.vh"
//Works on 50Mhz clock and Active low reset.
//Output will come at every 10 ms on a 50Mhz clock. Period!
module top (
	clk,
	scl,
	sda,
	rst_n,
	X_Accel,
	Y_Accel,
	Z_Accel,
	//X_Gyro,
	//Y_Gyro,
	//Z_Gyro,
	flag
	);
input clk, rst_n; // Active low reset!
output scl;
inout sda;
//output [7: 0] ACC_XH_READ; // stored acceleration X-axis high eight
//output [7: 0] ACC_XL_READ; // store the low eight X-axis acceleration
//output [7: 0] ACC_YH_READ; // stored acceleration Y-axis high eight 
//output [7: 0] ACC_YL_READ; // stored acceleration Y-axis low eight 
//output [7: 0] ACC_ZH_READ; // stored acceleration Z axis high eight 
//output [7: 0] ACC_ZL_READ ; // store the Z-axis acceleration low eight 
//output [7: 0] GYRO_XH_READ; // store the X-axis gyroscope high eight 
//output [7: 0] GYRO_XL_READ; // store low X-axis gyroscope eight 
//output [7: 0] GYRO_YH_READ; // Y-axis gyroscope store high eight 
//output [7: 0] GYRO_YL_READ; // store the Y-axis gyroscope low eight 
//output [7: 0] GYRO_ZH_READ; // store gyroscope Z-axis high eight 
//output [7: 0] GYRO_ZL_READ; // store gyroscope Z-axis low eight
reg [7: 0] ACC_XH_READ; // stored acceleration X-axis high eight
reg [7: 0] ACC_XL_READ; // store the low eight X-axis acceleration
reg [7: 0] ACC_YH_READ; // stored acceleration Y-axis high eight 
reg [7: 0] ACC_YL_READ; // stored acceleration Y-axis low eight 
reg [7: 0] ACC_ZH_READ; // stored acceleration Z axis high eight 
reg [7: 0] ACC_ZL_READ ; // store the Z-axis acceleration low eight 
reg [7: 0] GYRO_XH_READ; // store the X-axis gyroscope high eight 
reg [7: 0] GYRO_XL_READ; // store low X-axis gyroscope eight 
reg [7: 0] GYRO_YH_READ; // Y-axis gyroscope store high eight 
reg [7: 0] GYRO_YL_READ; // store the Y-axis gyroscope low eight 
reg [7: 0] GYRO_ZH_READ; // store gyroscope Z-axis high eight 
reg [7: 0] GYRO_ZL_READ; // store gyroscope Z-axis low eight

output [15:0] X_Accel;
output [15:0] Y_Accel;
output [15:0] Z_Accel;
//output [15:0] X_Gyro;
//output [15:0] Y_Gyro;
//output [15:0] Z_Gyro;
reg signed [15:0] X_Accel;
reg signed [15:0] Y_Accel;
reg signed [15:0] Z_Accel;
//reg signed [15:0] X_Gyro;
//reg signed [15:0] Y_Gyro;
//reg signed [15:0] Z_Gyro;
reg signed [15:0] X_Acc;
reg signed [15:0] Y_Acc;
reg signed [15:0] Z_Acc;
reg signed [15:0] X_Gy;
reg signed [15:0] Y_Gy;
reg signed [15:0] Z_Gy;  
output flag;

reg [2: 0] cnt; // cnt = 0, rising scl; cnt = 1, scl high intermediate; cnt = 2, scl falling; cnt = 3, scl low intermediate 
reg [8: 0] cnt_sum; // generate the desired clock IIC 
reg scl_r; // clock pulse generated 
reg [19: 0] cnt_10ms;
reg flag;

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		// reset
		X_Acc = 16'b0;
		Y_Acc = 16'b0;
		Z_Acc = 16'b0;
		X_Gy = 16'b0;
		Y_Gy = 16'b0;
		Z_Gy = 16'b0;	
	end
	else begin
		X_Acc = {ACC_XH_READ,ACC_XL_READ};
		Y_Acc = {ACC_YH_READ,ACC_YL_READ};
		Z_Acc = {ACC_ZH_READ,ACC_ZL_READ};
		X_Gy = {GYRO_XH_READ,GYRO_XL_READ};
		Y_Gy = {GYRO_YH_READ,GYRO_YL_READ};
		Z_Gy = {GYRO_ZH_READ,GYRO_ZL_READ};
	end
end

always @ (posedge clk or negedge rst_n)
begin
	if (! rst_n) 
		cnt_10ms <= 20'd0;
	else
	cnt_10ms <= cnt_10ms + 1'b1;
end

always @ (posedge clk or negedge rst_n)
begin
	if (! rst_n) 
		cnt_sum <= 0;
	else if (cnt_sum == 9'd499)
		cnt_sum <= 0;
	else
	cnt_sum <= cnt_sum + 1'b1;
end

always @ (posedge clk or negedge rst_n)
begin
	if (! rst_n)
		cnt <= 3'd5;
	else 
	begin
		case (cnt_sum)
			9'd124: cnt <= 3'd1; // High 
			9'd249: cnt <= 3'd2; // falling 
			9'd374: cnt <= 3'd3; // low 
			9'd499 : cnt <= 3'd0; // rising 
			default: cnt <= 3'd5;
		endcase
	end
end

`define SCL_POS (cnt == 3'd0)
`define SCL_HIG (cnt == 3'd1)
`define SCL_NEG (cnt == 3'd2)
`define SCL_LOW (cnt == 3'd3)

always @ (posedge clk or negedge rst_n)
begin
	if (! rst_n)
		scl_r <= 1'b0;
	else if (cnt == 3'd0)
		scl_r <= 1'b1;
	else if (cnt == 3'd2)
		scl_r <= 1'b0;
end

assign scl = scl_r; // scl clock signal 
`define DEVICE_READ 8'hD1 // addressable device, read
`define DEVICE_WRITE 8'hD0 // addressable devices, write 
`define ACC_XH 8'h3B // x-axis high acceleration address 
`define ACC_XL 8'h3C // x-axis acceleration lower address
`define ACC_YH 8'h3D // y-axis acceleration upper address 
`define ACC_YL 8'h3E // y-axis acceleration lower address
`define ACC_ZH 8'h3F // z acceleration axis high-order address 
`define ACC_ZL 8'h40 // z-axis acceleration lower address
`define GYRO_XH 8'h43 // x-axis gyroscope upper address 
`define GYRO_XL 8'h44 // x-axis gyroscope lower address
`define GYRO_YH 8'h45 // y-axis gyroscope upper address 
`define GYRO_YL 8'h46 // y-axis gyroscope lower address
`define GYRO_ZH 8'h47 // z-axis gyroscope upper address 
`define GYRO_ZL 8'h48 // z-axis gyroscope low address	

// Gyroscope initialization register 
`define PWR_MGMT_1 8'h6B
`define SMPLRT_DIV 8'h19
`define CONFIG1 8'h1A
`define GYRO_CONFIG 8'h1B
`define ACC_CONFIG 8'h1C

// Initialize the corresponding register value gyroscope configuration 
`define PWR_MGMT_1_VAL 8'h00
`define SMPLRT_DIV_VAL 8'h07
`define CONFIG1_VAL 8'h06
`define GYRO_CONFIG_VAL 8'h18
`define ACC_CONFIG_VAL 8'h01

parameter IDLE = 4'd0;
parameter START1 = 4'd1; 
parameter ADD1 = 4'd2;
parameter ACK1 = 4'd3;
parameter ADD2 = 4'd4;
parameter ACK2 = 4'd5;
parameter START2 = 4'd6;
parameter ADD3 = 4'd7;
parameter ACK3 = 4'd8;
parameter DATA = 4'd9;
parameter ACK4 = 4'd10;
parameter STOP1 = 4'd11;
parameter STOP2 = 4'd12;
parameter ADD_EXT = 4'd13;
parameter ACK_EXT = 4'd14;

reg [3: 0] state; // status register 
reg sda_r; // output 
reg sda_link; // sda_link = 1, sda output; sda_link = 0, sda high-impedance state 
reg [3: 0] num;
reg [7: 0] db_r;

// reg [7: 0] ACC_XH_READ; // stored acceleration X-axis high eight 
// reg [7: 0] ACC_XL_READ; // stored acceleration X-axis low eight 
// reg [7: 0] ACC_YH_READ; // stored acceleration Y-axis higher octave bit 
// reg [7: 0] ACC_YL_READ; // stored acceleration Y-axis low eight 
// reg [7: 0] ACC_ZH_READ; // stored acceleration Z axis high eight 
// reg [7: 0] ACC_ZL_READ; // store low Z-axis acceleration eight 
// reg [7: 0] GYRO_XH_READ; // store the X-axis gyroscope high eight 
// reg [7: 0] GYRO_XL_READ; // store the X-axis gyroscope low eight 
// reg [7: 0] GYRO_YH_READ; // store gyro Y-axis meter high eight 
// reg [7: 0] GYRO_YL_READ; // store the Y-axis gyroscope low eight 
// reg [7: 0] GYRO_ZH_READ; // store gyroscope Z-axis high eight 
// reg [7: 0] GYRO_ZL_READ; // store gyroscope Z-axis low eight 

reg [4: 0] times; // number of records initial configuration register 

always @ (posedge clk or negedge rst_n)
begin
	if (! rst_n)
	begin
		state <= IDLE;
		sda_r <= 1'b1; // data line pulled 
		sda_link <= 1'b0; // high impedance 
		num <= 4'd0;// Initialize the register 
		ACC_XH_READ <= 8'h00;
		ACC_XL_READ <= 8'h00;
		ACC_YH_READ <= 8'h00;
		ACC_YL_READ <= 8'h00;
		ACC_ZH_READ <= 8'h00;
		ACC_ZL_READ <= 8'h00;
		GYRO_XH_READ <= 8'h00;
		GYRO_XL_READ <= 8'h00;
		GYRO_YH_READ <= 8'h00;
		GYRO_YL_READ <= 8'h00;
		GYRO_ZH_READ <= 8'h00;
		GYRO_ZL_READ <= 8'h00;
		times <= 5'b0;
		flag <= 1'b0;
	end
	else
	case (state)
		IDLE: begin
			times <= times + 1'b1;
			sda_link <= 1'b1; // sda output 
			sda_r <= 1'b1; // pulled sda
			db_r <= `DEVICE_WRITE; // write data to the slave address 
			state = START1;
		end
	    START1: begin // IIC start
	    	if (`SCL_HIG)
				begin// scl high 
					num <= 4'd0;
					sda_link <= 1'b1; // sda output 
					sda_r <= 1'b0; // low sda, generating start signal 
					state <= ADD1;
					flag <= 1'b0;
				end
			else
			state <= START1;
		end
		ADD1: begin // write data 
		if (`SCL_LOW) // scl low begin
			if (num == 4'd8) // When all eight outputs
				begin		
					sda_r <= 1'b1;
					sda_link <= 1'b0; // sda high impedance 
					state <= ACK1;
					num <= 4'd0; // count is cleared 
				end
			else
			begin
				state <= ADD1;
				num <= num + 1'b1;
				sda_r <= db_r [4'd7-num]; // bit output end
			end
			else
			state <= ADD1;
		end
		ACK1: begin // response 
			if (`SCL_NEG)
			begin
				state <= ADD2;
			case (times) // select the next write register address 
				5'd1: db_r <= `PWR_MGMT_1;
				5'd2: db_r <= `SMPLRT_DIV;
				5'd3: db_r <= `CONFIG1;
				5'd4: db_r <= `GYRO_CONFIG;
				5'd5: db_r <= `ACC_CONFIG;
				5'd6: db_r <= `ACC_XH;
				5'd7: db_r <= `ACC_XL;
				5'd8: db_r <= `ACC_YH;
				5'd9: db_r <= `ACC_YL;
				5'd10: db_r <= `ACC_ZH;
				5'd11: db_r <= `ACC_ZL;
				5'd12: db_r <= `GYRO_XH;
				5'd13: db_r <= `GYRO_XL;
				5'd14: db_r <= `GYRO_YH;
				5'd15: db_r <= `GYRO_YL;
				5'd16: db_r <= `GYRO_ZH;
				5'd17: db_r <= `GYRO_ZL;
				default: begin
					db_r <= `PWR_MGMT_1;
					times <= 5'd1;
				end
			endcase
		end
		else
			state <= ACK1; // waits for a response 
		end
		ADD2: begin
		if (`SCL_LOW) // scl low 
		begin
			if (num == 4'd8)
			begin
				num <= 4'd0;
				sda_r <= 1'b1;
				sda_link <= 1'b0;
				state <= ACK2;
			end
			else
			begin
				sda_link <= 1'b1;
				state <= ADD2;
				num <= num + 1'b1;
				sda_r <= db_r [4'd7-num]; // send bit register address 
			end
		end
			else
			state <= ADD2;
		end
		ACK2: begin // response 
			if (`SCL_NEG)
			begin
			case (times) // corresponding to the set value of the register 
				3'd1: db_r <= `PWR_MGMT_1_VAL;
				3'd2: db_r <= `SMPLRT_DIV_VAL;
				3'd3: db_r <= `CONFIG1_VAL;
				3'd4: db_r <= `GYRO_CONFIG_VAL;
				3'd5: db_r <= `ACC_CONFIG_VAL;
				3'd6: db_r <= `DEVICE_READ;
				default: db_r <= `DEVICE_READ;
			endcase
			if (times >= 5'd6)
				state <= START2;
			else
			state <= ADD_EXT;
		end
		else
				state <= ACK2; // waits for a response 
		end
 		ADD_EXT: begin // initialize the setting register 
 			if (`SCL_LOW)
 			begin
 				if (num == 4'd8)
 				begin
 					num <= 4'd0;
 					sda_r <= 1'b1;
					sda_link <= 1'b0; // sda high impedance 
					state <= ACK_EXT;
				end
				else
				begin
					sda_link <= 1'b1;
					state <= ADD_EXT;
					num <= num + 1'b1;
					sda_r <= db_r [4'd7-num]; // bit setting register work 
				end
			end
			else
			state <= ADD_EXT;
		end
		ACK_EXT: begin
			if (`SCL_NEG)
			begin
				sda_r <= 1'b1; // pulled sda
				state <= STOP1;
			end
			else
				state <= ACK_EXT; // waits for a response 
			end
			START2: begin
			if (`SCL_LOW) // scl low 
			begin
				sda_link <= 1'b1; // sda output 
				sda_r <= 1'b1; // pulled sda
				state <= START2;
			end
			else if (`SCL_HIG) // scl high 
			begin
				sda_r <= 1'b0; // low sda, generating start signal 
				state <= ADD3;
			end
			else 
				state <= START2;
		end
		ADD3: begin
		if (`SCL_LOW) // scl-bit low 
		begin
			if (num == 4'd8)
			begin
				num <= 4'd0;
				sda_r <= 1'b1; // pulled sda
				sda_link <= 1'b0; // scl high impedance 
				state <= ACK3;
			end
			else
			begin
				num <= num + 1'b1;
				sda_r <= db_r [4'd7-num]; // bit Write Read register address 
				state <= ADD3;
			end
		end
		else 
			state <= ADD3;
		end
		ACK3: begin
		if (`SCL_NEG)
		begin
			state <= DATA;
			sda_link <= 1'b0; // sda high impedance
		end
		else
			state <= ACK3; // waits for a response 
		end
		DATA: begin
			if (num <= 4'd7)
			begin
				state <= DATA;
				if (`SCL_HIG)
				begin
					num <= num + 1'b1;
					//flag <= 1'b0;
					case (times)
						5'd6: ACC_XH_READ [4'd7-num] <= sda;
						5'd7: ACC_XL_READ [4'd7-num] <= sda;
						5'd8: ACC_YH_READ [4'd7-num] <= sda;
						5'd9: ACC_YL_READ [4'd7-num] <= sda;
						5'd10: ACC_ZH_READ [4'd7-num] <= sda;
						5'd11: ACC_ZL_READ [4'd7-num] <= sda;
						5'd12: GYRO_XH_READ [4'd7-num] <= sda;
						5'd13: GYRO_XL_READ [4'd7-num] <= sda;
						5'd14: GYRO_YH_READ [4'd7-num] <= sda;
						5'd15: GYRO_YL_READ [4'd7-num] <= sda;
						5'd16: GYRO_ZH_READ [4'd7-num] <= sda;
						5'd17: GYRO_ZL_READ [4'd7-num] <= sda;
					default:; // not yet considered, can add code to improve system stability 
				endcase
			end
		end
		else if ((`SCL_LOW) && (num == 4'd8))
		begin
			sda_link <= 1'b1; // sda output 
			num <= 4'd0; // count is cleared 
			state <= ACK4;
		end
		else
			state <= DATA;
		end
		ACK4: begin
		if (times == 5'd17)
			times <= 5'd0;
		if (`SCL_NEG)
		begin
			sda_r <= 1'b1; // pulled sda
			state <= STOP1;
			//flag <= 1'b0;
		end
		else
			state <= ACK4; // waits for a response 
		end
		STOP1: begin
		if (`SCL_LOW) // scl low 
		begin
			sda_link <= 1'b1; // sda output 
			sda_r <= 1'b0; // low sda
			state <= STOP1;
		end
		else if (`SCL_HIG) // sda high 
		begin
			sda_r <= 1'b1; // pulled sda, generates stop signal 
			state <= STOP2;
		end
		else
			state <= STOP1;
		end
		STOP2: begin
		if (`SCL_LOW)
			sda_r <= 1'b1;
		else if (cnt_10ms == 20'hffff0) begin// get a data about 10ms 
			state <= IDLE;
			X_Accel <= X_Acc;
			Y_Accel <= Y_Acc;
			Z_Accel <= Z_Acc;
			//X_Gyro <= X_Gy;
			//Y_Gyro <= Y_Gy;
			//Z_Gyro <= Z_Gy;
			flag <= 1'b1;
		end
		else begin
			state <= STOP2;
		end
	end
	default: state <= IDLE;
	endcase

end
assign sda = sda_link ? sda_r: 1'bz;
endmodule 