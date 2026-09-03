module uart_rx #(
    parameter DATA_W = 8
)(
    input  logic       i_clk,
    input  logic       i_rst_n,
    input  logic       i_rx,
    input  logic       i_par_en,
    input  logic       i_par_odd,
    output logic [7:0] o_data,
    output logic       o_busy,
    output logic       o_valid,
    output logic       o_frame_err,
    output logic       o_parity_err
);

    logic start_pulse;
    logic shift_en;
    logic load_en;
    logic check_en;
    logic parity_bit;
    logic [7:0] parallel_data;

    edge_detector u_edge_detector (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_rx        (i_rx),
        .start_pulse (start_pulse)
    );

    uart_rx_controller u_uart_rx_controller (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .i_rx         (i_rx),
        .start_pulse  (start_pulse),
        .shift_en     (shift_en),
        .load_en      (load_en),
        .check_en     (check_en),
        .o_busy       (o_busy),
        .o_valid      (o_valid),
        .o_frame_err  (o_frame_err)
    );

    deserializer #(
        .DATA_W(8)
    ) u_deserializer (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_rx          (i_rx),
        .load_en       (load_en),
        .shift_en      (shift_en),
        .o_data        (o_data),
        .parallel_data (parallel_data)
    );

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            parity_bit <= 1'b0;
        end
        else if (check_en) begin
            parity_bit <= i_rx;
        end
    end

    parity_calculator_checker u_parity_checker (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .i_par_en     (i_par_en),
        .i_par_odd    (i_par_odd),
        .check_en     (check_en),
        .i_data       (parallel_data),
        .i_parity_bit (parity_bit),
        .o_parity_err (o_parity_err)
    );

endmodule