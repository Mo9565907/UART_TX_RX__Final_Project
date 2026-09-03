module parity_calculator (
    input  logic       i_clk,
    input  logic       i_rst_n,
    input  logic [7:0] i_data,
    input  logic       i_par_odd,
    input  logic       i_par_en,
    output logic       PARITY_BIT,
    output logic       PARTY_DONE
);

    logic parity_result;

    assign parity_result = (i_par_odd == 1'b0) ? ^i_data : ~(^i_data);

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            PARITY_BIT <= 1'b0;
            PARTY_DONE <= 1'b0;
        end
        else begin
            if (i_par_en) begin
                PARITY_BIT <= parity_result;
                PARTY_DONE <= 1'b1;
            end
            else begin
                PARTY_DONE <= 1'b0;
            end
        end
    end

endmodule