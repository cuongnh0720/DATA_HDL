`timescale 1ns / 1ps

module pwm (
	input [1:0] address,
	input chipselect,
	input clk,
	input read,
	input reset_n,
	input write,
	input [31:0] writedata,
	output pwm_out,
	output reg [31:0] readdata
);

reg [31:0] DATA;

always @ (posedge clk or negedge reset_n)
begin
	if ( reset_n == 1'b0 )
	begin
		DATA <= 10'b0;
		readdata <= 32'b0;
	end
	else if ( chipselect && write && (address == 2'b0) )
	begin
		DATA <= writedata[31:0];
		readdata <= 32'b0;
	end
	else if ( chipselect && read && (address == 2'b0) )
	begin
		readdata <= DATA;
		DATA <= DATA;
	end
	else
	begin
		readdata <= 32'b0;
		DATA <= DATA;
	end
end

wire o_clk_div;

div_clk div_clk_inst (
    .i_clk_50mhz  (clk),
    .o_clk_div  (o_clk_div)
);

reg [7:0] pwm_cnt;
reg [7:0] duty_cycle;

initial begin
	pwm_cnt <= 0;
	duty_cycle <= 0;
end

always@(posedge o_clk_div or negedge reset_n) begin
	if (reset_n == 1'b0) begin
		duty_cycle <= 0;
	end else begin	
		if (DATA == 0) begin
			duty_cycle <= 0;
		end else if (DATA == 10) begin
			duty_cycle <= 10;
		end else if (DATA == 20) begin
			duty_cycle <= 20;
		end else if (DATA == 30) begin
			duty_cycle <= 30;
		end else if (DATA == 40) begin
			duty_cycle <= 40;
		end else if (DATA == 50) begin
			duty_cycle <= 50;
		end else if (DATA == 60) begin
			duty_cycle <= 60;
		end else if (DATA == 70) begin
			duty_cycle <= 70;
		end else if (DATA == 80) begin
			duty_cycle <= 80;
		end else if (DATA == 90) begin
			duty_cycle <= 90;
		end else if (DATA == 100) begin
			duty_cycle <= 100;
		end
	end
end
		
always@(posedge o_clk_div or negedge reset_n) begin
	if (reset_n == 1'b0) begin
		pwm_cnt <= 0;
	end else begin
		if (pwm_cnt == 99) begin
			pwm_cnt <= 0;
		end else begin
			pwm_cnt <= pwm_cnt+1;
		end
	end
end  

assign pwm_out = (pwm_cnt < duty_cycle) ? 1:0;

endmodule
