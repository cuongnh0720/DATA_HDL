`timescale 1ns / 1ps

module div_clk(
    input i_clk_50mhz, 
	 output o_clk_div
);

parameter integer n = 10000;
reg [31:0]div_cnt;

initial begin
	div_cnt <= 0;
end

always@(posedge i_clk_50mhz) begin
	 if (div_cnt == n-1) begin
		  div_cnt <= 0;
	 end else begin
		  div_cnt <= div_cnt+1;
	 end
end

assign o_clk_div = (div_cnt < (n/2)) ? 1:0;

endmodule
