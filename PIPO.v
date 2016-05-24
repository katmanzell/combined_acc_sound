module PIPO (
	din,
	clk,
	rst,
	dout
	);
input [15:0] din;
input clk,rst;
output [15:0] dout;
wire [15:0] din;
wire clk,rst;
reg [15:0] dout;
always @(posedge clk or negedge rst) begin
	if(!rst) begin
		dout <= 16'b0;
	end
	else begin
		dout <= din;
	end
end
endmodule