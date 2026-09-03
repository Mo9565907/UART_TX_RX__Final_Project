module deserializer #(
    parameter DATA_W = 8
)(
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_rx,
    input  logic              load_en,
    input  logic              shift_en,
    output logic [DATA_W-1:0] o_data,
    output logic [DATA_W-1:0] parallel_data
);

    logic [DATA_W-1:0] shift_reg;
    logic [DATA_W-1:0] out_reg;

    assign o_data        = out_reg;
    assign parallel_data = out_reg;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            shift_reg <= '0;
            out_reg   <= '0;
        end
        else begin
            if (shift_en) begin
                shift_reg <= {i_rx, shift_reg[DATA_W-1:1]};
            end

            if (load_en) begin
                out_reg <= shift_reg;
            end
        end
    end

endmodule