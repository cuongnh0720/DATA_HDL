`timescale 1ns/1ps

module tb_pio_inout;

    // Khai bao cac tin hieu cho testbench
    reg clk;                 // Tin hieu clock
    reg reset_n;             // Tin hieu reset active-low
    reg [2:0] address;       // Tin hieu dia chi cho giao tiep Avalon-MM
    reg write;               // Tin hieu ghi du lieu
    reg read;                // Tin hieu doc du lieu
    reg [31:0] writedata;    // Du lieu de ghi vao module
    wire [31:0] readdata;    // Du lieu doc ra tu module
    tri pio_pin;             // Chan hai chieu (inout)

    // Tin hieu noi bo de mo phong chan pio_pin
    reg pio_pin_driver;      // Mo phong tin hieu ben ngoai dieu khien pio_pin
    assign pio_pin = (pio_pin_driver !== 1'bz) ? pio_pin_driver : 1'bz;

    // Ket noi DUT (Device Under Test)
    pio_inout dut (
        .clk(clk),
        .reset_n(reset_n),
        .address(address),
        .write(write),
        .read(read),
        .writedata(writedata),
        .readdata(readdata),
        .pio_pin(pio_pin)
    );

    // Tao xung clock: Chu ky clock la 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Quy trinh kiem tra
    initial begin
        // Khoi tao tin hieu
        reset_n = 0;
        address = 0;
        write = 0;
        read = 0;
        writedata = 32'b0;
        pio_pin_driver = 1'bz; // Khoi tao pio_pin o trang thai khang tro cao

        // Dat lai (reset) module
        #20 reset_n = 1; // Huy reset sau 20ns

        // Test 1: Cai dat huong cua pio_pin thanh dau ra
        address = 3'b000;          // Dia chi cua thanh ghi huong
        writedata = 32'b1;         // Cai dat huong thanh dau ra
        write = 1;
        #10 write = 0;             // Ghi trong mot chu ky clock

        // Test 2: Ghi du lieu logic cao vao pio_pin
        address = 3'b001;          // Dia chi cua thanh ghi du lieu
        writedata = 32'b1;         // Ghi muc logic cao
        write = 1;
        #10 write = 0;             // Ghi trong mot chu ky clock

        // Kiem tra xem pio_pin co xuat muc cao khong
        #10;
        if (pio_pin !== 1)
            $display("Test 2: Loi - pio_pin phai o muc cao khi huong la dau ra va du lieu = 1");

        // Test 3: Chuyen huong pio_pin thanh dau vao
        address = 3'b000;          // Dia chi cua thanh ghi huong
        writedata = 32'b0;         // Cai dat huong thanh dau vao
        write = 1;
        #10 write = 0;             // Ghi trong mot chu ky clock

        // Test 4: Mo phong tin hieu ben ngoai keo pio_pin xuong muc thap
        pio_pin_driver = 1'b0;     // Tin hieu ben ngoai keo chan xuong muc thap
        #10;

        // Doc du lieu tu pio_pin
        address = 3'b001;          // Dia chi cua thanh ghi du lieu
        read = 1;
        #10 read = 0;              // Doc trong mot chu ky clock

        // Kiem tra xem readdata co phan anh dung gia tri ben ngoai hay khong
        if (readdata[0] !== 0)
            $display("Test 4: Loi - readdata phai la 0 khi pio_pin bi keo xuong muc thap");

        // Dua pio_pin tro lai trang thai khang tro cao
        pio_pin_driver = 1'bz;     // Mo phong chan khong bi dieu khien ben ngoai

        // Ket thuc mo phong
        #20 $finish;
    end

endmodule
