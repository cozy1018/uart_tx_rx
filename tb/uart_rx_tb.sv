`timescale 1ns/1ps

module uart_rx_tb;

    // Parameters
    parameter CLOCK_FREQ = 50000000;
    parameter BAUD_RATE  = 9600;
    parameter BIT_PERIOD = 1_000_000_000 / BAUD_RATE; // in ns

    // Signals
    reg clk;
    reg rst_n;
    reg rx;
    wire [7:0] data_out;
    wire data_valid;

    // Clock generation (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // DUT
    uart_rx #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .data_out(data_out),
        .data_valid(data_valid)
    );

    // UART Byte Send Task (Verilog style)
    task send_uart_byte;
        input [7:0] b;
        integer i;
        begin
            rx = 0; // Start bit
            #(BIT_PERIOD);

            for (i = 0; i < 8; i = i + 1) begin
                rx = b[i]; // Send LSB first
                #(BIT_PERIOD);
            end

            rx = 1; // Stop bit
            #(BIT_PERIOD);
        end
    endtask

    // Testbench logic
    initial begin
        $dumpfile("sim/uart_rx_tb.vcd");
        $dumpvars(0, uart_rx_tb);

        rx = 1;
        rst_n = 0;
        #100;
        rst_n = 1;
        #100;

        send_uart_byte(8'hA5);
        #100000;
        send_uart_byte(8'h3C);
        #100000;

        $finish;
    end

endmodule