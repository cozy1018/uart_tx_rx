module uart_tx #(
    parameter CLOCK_FREQ = 50000000,     // System clock frequency (Hz)
    parameter BAUD_RATE  = 9600          // UART baud rate
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] data_in,     // Byte to transmit
    input  logic       transmit,    // High for one cycle to start transmission
    output logic       tx,          // Serial output
    output logic       busy         // High while transmitting
);

    localparam integer CYCLES_PER_BIT = CLOCK_FREQ / BAUD_RATE;

    typedef enum logic [2:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t state;
    logic [15:0] baud_cnt;
    logic [2:0]  bit_idx;
    logic [7:0]  shift_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            baud_cnt  <= 0;
            bit_idx   <= 0;
            shift_reg <= 0;
            tx        <= 1'b1;  // Idle line is HIGH in UART
            busy      <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx   <= 1'b1;
                    busy <= 1'b0;
                    if (transmit) begin
                        shift_reg <= data_in;
                        state     <= START;
                        baud_cnt  <= CYCLES_PER_BIT - 1;
                        busy      <= 1'b1;
                    end
                end

                START: begin
                    tx <= 1'b0;
                    if (baud_cnt == 0) begin
                        state     <= DATA;
                        bit_idx   <= 0;
                        baud_cnt  <= CYCLES_PER_BIT - 1;
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end

                DATA: begin
                    tx <= shift_reg[bit_idx];
                    if (baud_cnt == 0) begin
                        baud_cnt <= CYCLES_PER_BIT - 1;
                        if (bit_idx == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end

                STOP: begin
                    tx <= 1'b1;
                    if (baud_cnt == 0) begin
                        state <= IDLE;
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule