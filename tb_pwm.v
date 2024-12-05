`timescale 1ns / 1ps

module tb_pwm;

    // Khai bao tin hieu
    reg [1:0] address;           // Dia chi thanh ghi
    reg chipselect;              // Tin hieu chipselect
    reg clk;                     // Tin hieu clock
    reg read;                    // Tin hieu doc du lieu
    reg reset_n;                 // Tin hieu reset active-low
    reg write;                   // Tin hieu ghi du lieu
    reg [31:0] writedata;        // Du lieu ghi vao module
    wire pwm_out;                // Tin hieu dau ra PWM
    wire [31:0] readdata;        // Du lieu doc ra tu module

    // Khoi tao DUT (Device Under Test)
    pwm dut (
        .address(address),
        .chipselect(chipselect),
        .clk(clk),
        .read(read),
        .reset_n(reset_n),
        .write(write),
        .writedata(writedata),
        .pwm_out(pwm_out),
        .readdata(readdata)
    );

    // Tao clock 50 MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // Chu ky clock la 20ns (50 MHz)
    end

    // Test sequence
    initial begin
        // Khoi tao tin hieu
        reset_n = 0;               // Reset module
        chipselect = 0;
        address = 0;
        read = 0;
        write = 0;
        writedata = 32'b0;

        // Reset module
        #50 reset_n = 1;           // Huy reset sau 50ns
        chipselect = 1;            // Kich hoat module
        address = 2'b00;           // Dia chi thanh ghi DATA

        // Ghi duty cycle = 70%
        writedata = 32'd70;
        write = 1;
        #20 write = 0;             // Ket thuc ghi

        // Doc gia tri duty cycle de xac nhan
        read = 1;
        #20 read = 0;
        if (readdata !== writedata)
            $display("FAILED: Duty cycle doc ra (%d) khong dung", readdata);
        else
            $display("PASSED: Duty cycle doc ra dung (%d)", readdata);

        // Quan sat PWM trong 10 µs
        $display("Observing PWM signal with duty cycle = 70%%...");
        #10000; // Quan sat trong 10 µs

        // Ket thuc mo phong
        $display("Testbench completed.");
        #100 $finish;
    end

    // Ghi log thay doi tin hieu pwm_out
    initial begin
