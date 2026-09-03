module mux_4x1 (
    input logic [1:0] MUX_SEL,
    input logic SERIAL_BIT,
    input logic PARITY_BIT,
    input logic STOP_BIT,
    input logic IDLE_BIT,
    output logic o_tx
);

    always_ff @(*) begin
        case (MUX_SEL)
            2'b00 : o_tx = SERIAL_BIT;
            2'b01 : o_tx = PARITY_BIT;
            2'b10 : o_tx = STOP_BIT;
            2'b11 : o_tx = IDLE_BIT;
            default : o_tx = 1'b0;
        endcase
    end

endmodule