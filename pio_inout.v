module pio_inout (
    input               clk,        // Tin hieu clock
    input               reset_n,    // Tin hieu reset active-low (muc thap de reset)
    input       [2:0]   address,    // Dia chi Avalon-MM
    input               write,      // Tin hieu ghi du lieu Avalon-MM
    input               read,       // Tin hieu doc du lieu Avalon-MM
    input       [31:0]  writedata,  // Du lieu ghi vao module (32 bit)
    output reg  [31:0]  readdata,   // Du lieu doc ra tu module (32 bit)
    inout               pio_pin     // Chan inout (PIO, chan ngo vao ra)
);

    // Cac thanh ghi noi bo
    reg io_dir;          // Thanh ghi huong: 1 = output (dau ra), 0 = input (dau vao)
    reg io_data_out;     // Thanh ghi du lieu xuat ra (dung khi la dau ra)
    wire io_data_in;     // Day tin hieu doc du lieu vao (dung khi la dau vao)

    // Dieu khien chan inout pio_pin
    assign pio_pin = (io_dir) ? io_data_out : 1'bz; // Logic ba trang thai (tri-state)
    assign io_data_in = pio_pin;                   // Doc du lieu tu chan pio_pin

    // Logic xu ly Avalon-MM (Doc/Ghi)
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Gia tri reset
            io_dir      <= 1'b0;    // Mac dinh huong: dau vao
            io_data_out <= 1'b0;    // Gia tri dau ra mac dinh: 0
            readdata    <= 32'b0;   // Gia tri doc mac dinh: 0
        end else begin
            // Xu ly tin hieu ghi
            if (write) begin
                case (address)
                    3'b000: io_dir      <= writedata[0]; // Ghi huong: 0 = input, 1 = output
                    3'b001: io_data_out <= writedata[0]; // Ghi du lieu: 0 = thap, 1 = cao
                endcase
            end
            // Xu ly tin hieu doc
            if (read) begin
                case (address)
                    3'b000: readdata <= {31'b0, io_dir};        // Doc huong: 1 bit
                    3'b001: readdata <= {31'b0, io_data_in};    // Doc du lieu dau vao: 1 bit
                endcase
            end
        end
    end

endmodule
