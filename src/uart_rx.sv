module uart_rx #(
    parameter CLOCK_FREQ = 50000000,     // System clock frequency (Hz)
    parameter BAUD_RATE  = 9600          // UART baud rate
)(
    input  logic clk,
    input  logic rst_n,
    input  logic rx,              // Serial input
    output logic [7:0] data_out,  // Received byte
    output logic data_valid       // High for one cycle when byte is ready
);

    localparam integer CYCLES_PER_BIT = CLOCK_FREQ / BAUD_RATE;

    typedef enum logic [2:0] {
        IDLE,
        START,
        DATA,
        STOP,
        DONE
    } state_t;

    state_t state;
    logic [15:0] baud_cnt;
    logic [2:0]  bit_idx;
    logic [7:0]  shift_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            baud_cnt   <= 0;
            bit_idx    <= 0;
            shift_reg  <= 0;
            data_out   <= 0;
            data_valid <= 0;
        end else begin
            case (state)
                IDLE: begin
                    data_valid <= 0;
                    if (!rx) begin
                        state    <= START;
                        baud_cnt <= CYCLES_PER_BIT / 2;
                    end
                end

                START: begin
                    if (baud_cnt == 0) begin
                        state    <= DATA;
                        bit_idx  <= 0;
                        baud_cnt <= CYCLES_PER_BIT - 1;
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end

                DATA: begin
                    if (baud_cnt == 0) begin
                        shift_reg[bit_idx] <= rx;
                        bit_idx <= bit_idx + 1;
                        baud_cnt <= CYCLES_PER_BIT - 1;
                        if (bit_idx == 3'd7)
                            state <= STOP;
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end

                STOP: begin
                    if (baud_cnt == 0) begin
                        state      <= DONE;
                        data_out   <= shift_reg;
                        data_valid <= 1;
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end

                DONE: begin
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule