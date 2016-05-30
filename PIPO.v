module PIPO (
	din,
	clk,
	rst,
	dout
	);
input [15:0] din;
input clk,rst;
output [159:0] dout;
reg [159:0] din_save;
wire clk,rst;
reg [159:0] dout;
always @(posedge clk or negedge rst) begin
	if(!rst) begin
		dout <= 16'b0;
	end
	else begin
		din_save [15:0] <= din;
		din_save [31:16] <= din_save [15:0];
		din_save [47:31] <= din_save [31:16];
		din_save [63:48] <= din_save [47:31];
		din_save [79:64] <= din_save [63:48];
		din_save [95:80] <= din_save [79:64];
		din_save [111:96] <= din_save [95:80];
		din_save [127:112] <= din_save [111:96];
		din_save [143:128] <= din_save [127:112];
		dout <= din;
	end
end
endmodule