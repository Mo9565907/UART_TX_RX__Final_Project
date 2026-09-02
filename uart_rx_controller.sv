module uart_rx_controller (
    input  logic       i_clk,
    input  logic           i_rst_n,
    input  logic       i_rx,
    input  logic     start_pulse,
    output logic      shift_en,
    output logic     load_en,
    output logic    check_en,
    output logic     o_busy,
    output logic    o_valid,
    output logic      o_frame_err
);

    localparam BAUD_CNT_MAX = 50_000_000 / 115_200;
    localparam HALF_BAUD    = BAUD_CNT_MAX / 2;

    localparam IDLE   = 3'b000,
               START  = 3'b001,
               DATA   = 3'b010,
               PARITY = 3'b011,
               STOP   = 3'b100;

    logic [2:0]  state, next_state;
    logic [15:0] baud_counter;
    logic [2:0]  bit_counter;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            next_state   <= IDLE;
            baud_counter <= 0;
            bit_counter  <= 0;
            shift_en     <= 1'b0;
            load_en      <= 1'b0;
            check_en     <= 1'b0;
            o_busy         <= 1'b0;
            o_valid        <= 1'b0;
            o_frame_err    <= 1'b0;
        end else begin
            shift_en  <= 1'b0;
            load_en   <= 1'b0;
            check_en  <= 1'b0;
            o_valid     <= 1'b0;

            case (state)
                IDLE: begin
                    o_busy <= 1'b0;
                    o_frame_err <= 1'b0;
                    baud_counter <= 0;
                    bit_counter <= 0;
                    if (start_pulse) begin
                        next_state <= START;
                        busy <= 1'b1;
                    end
                end

                START: begin
                    if (baud_counter == BAUD_CNT_MAX - 1) begin
                        baud_counter <= 0;
                        next_state <= DATA;
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

                DATA: begin
                    if (baud_counter == HALF_BAUD - 1) begin
                        shift_en <= 1'b1;
                    end
                    if (baud_counter == BAUD_CNT_MAX - 1) begin
                        baud_counter <= 0;
                        bit_counter <= bit_counter + 1;
                        if (bit_counter == 7) begin
                            next_state <= PARITY;
                        end
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

                PARITY: begin
                    if (baud_counter == HALF_BAUD - 1) begin
                        check_en <= 1'b1;
                    end
                    if (baud_counter == BAUD_CNT_MAX - 1) begin
                        baud_counter <= 0;
                        next_state <= STOP;
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

                STOP: begin
                    if (baud_counter == HALF_BAUD - 1) begin
                        load_en <= 1'b1;
                        if (i_rx == 1'b0) begin
                            o_frame_err <= 1'b1;
                        end
                    end
                    if (baud_counter == BAUD_CNT_MAX - 1) begin
                        baud_counter <= 0;
                        o_valid <= 1'b1;
                        o_busy <= 1'b0;
                        next_state <= IDLE;
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

                default: next_state <= IDLE;
            endcase
        end
    end

endmodule