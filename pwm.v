`timescale 1ns / 1ps

module pwm (
    input [1:0] address,           // Dia chi thanh ghi (2 bit) trong giao tiep Avalon-MM
    input chipselect,              // Tin hieu chipselect, kich hoat module
    input clk,                     // Tin hieu clock 50 MHz
    input read,                    // Tin hieu doc du lieu
    input reset_n,                 // Tin hieu reset active-low
    input write,                   // Tin hieu ghi du lieu
    input [31:0] writedata,        // Du lieu 32 bit de ghi vao module
    output pwm_out,                // Tin hieu dau ra PWM
    output reg [31:0] readdata     // Du lieu 32 bit doc ra tu module
);

    reg [31:0] DATA;               // Thanh ghi luu chu ky nhiem vu (duty cycle)
    reg [7:0] pwm_cnt;             // Bo dem cho tin hieu PWM
    reg [7:0] duty_cycle;          // Gia tri chu ky nhiem vu 0-100%

    // Giao tiep Avalon-MM: doc/ghi du lieu
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Reset cac thanh ghi ve gia tri mac dinh
            DATA <= 32'b0;
            readdata <= 32'b0;
        end else begin
            readdata <= 32'b0; // Gia tri mac dinh khi doc
            if (chipselect && write && (address == 2'b0)) begin
                // Ghi du lieu vao thanh ghi DATA
                DATA <= writedata[31:0];
            end else if (chipselect && read && (address == 2'b0)) begin
                // Doc du lieu tu thanh ghi DATA
                readdata <= DATA;
            end
        end
    end

    // Tinh hieu chia tan so cho PWM
    wire o_clk_div; // Tin hieu clock da chia tan so
    div_clk div_clk_inst (
        .i_clk_50mhz(clk),         // Clock dau vao 50 MHz
        .o_clk_div(o_clk_div)      // Clock dau ra voi tan so thap hon
    );

    // Cap nhat gia tri duty_cycle dua tren DATA
    always @(posedge o_clk_div or negedge reset_n) begin
        if (!reset_n) begin
            duty_cycle <= 0;       // Reset chu ky nhiem vu ve 0
        end else begin
            // Thay doi chu ky nhiem vu dua tren gia tri DATA
            case (DATA)
                0: duty_cycle <= 0;
                10: duty_cycle <= 10;
                20: duty_cycle <= 20;
                30: duty_cycle <= 30;
                40: duty_cycle <= 40;
                50: duty_cycle <= 50;
                60: duty_cycle <= 60;
                70: duty_cycle <= 70;
                80: duty_cycle <= 80;
                90: duty_cycle <= 90;
                100: duty_cycle <= 100;
                default: duty_cycle <= 0; // Gia tri ngoai pham vi dua ve 0
            endcase
        end
    end

    // Bo dem tao tin hieu PWM
    always @(posedge o_clk_div or negedge reset_n) begin
        if (!reset_n) begin
            pwm_cnt <= 0;          // Reset bo dem ve 0
        end else begin
            if (pwm_cnt == 99) begin
                // Khi bo dem dat gia tri 99, reset ve 0
                pwm_cnt <= 0;
            end else begin
                // Tang bo dem len 1
                pwm_cnt <= pwm_cnt + 1;
            end
        end
    end

    // Tao tin hieu PWM dua tren duty_cycle va pwm_cnt
    assign pwm_out = (pwm_cnt < duty_cycle) ? 1 : 0;

endmodule
