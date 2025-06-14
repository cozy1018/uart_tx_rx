`timescale 1ns/1ps

module uart_tx_tb;

    // Parameters
    localparam CLOCK_FREQ = 50_000_000;
    localparam BAUD_RATE  = 9600;

    // Clock and reset
    logic clk;
    logic rst_n;

    // UART signals
    logic [7:0] data_in;
    logic       transmit;
    logic       tx;
    logic       busy;

    // Clock generation: 100MHz
    initial clk = 0;
    always #5 clk = ~clk;

    // DUT instance
    uart_tx #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .transmit(transmit),
        .tx(tx),
        .busy(busy)
    );

    // Test procedure
    initial begin
        $dumpfile("uart_tx_tb.vcd");
        $dumpvars(0, uart_tx_tb);

        // Reset
        rst_n = 0;
        transmit = 0;
        data_in = 8'h00;
        #100;
        rst_n = 1;

        // Wait a few cycles
        #100;

        // Transmit byte 0x55
        data_in = 8'h55;
        transmit = 1;
        #10;
        transmit = 0;

        // Wait for transmission to complete
        wait (busy == 0);

        // Transmit another byte 0xA3
        #1000;
        data_in = 8'hA3;
        transmit = 1;
        #10;
        transmit = 0;

        wait (busy == 0);

        #1000;
        $finish;
    end

endmodule