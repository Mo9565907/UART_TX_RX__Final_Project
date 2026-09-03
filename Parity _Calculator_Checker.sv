module parity_calculator_checker (
    input  logic       i_clk,
    input  logic       i_rst_n,
    input  logic       i_par_en,
    input  logic       i_par_odd,
    input  logic       check_en,
    input  logic [7:0] i_data,
    input  logic       i_parity_bit,
    output logic       o_parity_err
);

    logic calc_parity;
    logic expected_parity;

    assign calc_parity     = ^i_data;
    assign expected_parity = i_par_odd ? ~calc_parity : calc_parity;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_parity_err <= 1'b0;
        end
        else if (!i_par_en) begin
            o_parity_err <= 1'b0;
        end
        else if (check_en) begin
            o_parity_err <= (expected_parity != i_parity_bit);
        end
    end

endmodule