module uart_tx #(
    parameter DATA_W = 8
)(
    input logic i_clk,
    input logic i_rst_n,
    input logic [7:0] i_data,
    input logic  i_valid,
    input logic i_par_en,
    input logic i_par_odd,
    output logic o_tx,
    output logic o_busy
);

    logic LOAD;
    logic SHIFT_EN;
    logic [3:0] BIT_CNT;
    logic PARITY_CALC_EN;
    logic PARITY_SEL;
    logic [1:0] MUX_SEL;

    logic SERIAL_BIT;
    logic SHIFT_DONE;

    logic PARITY_BIT;
    logic PARTY_DONE;

    logic STOP_BIT;
    logic IDLE_BIT;

    assign STOP_BIT = 1'b1;
    assign IDLE_BIT = 1'b1;

    main_controller #(
        .DATA_WIDTH(8)
    ) main_controller_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_data(i_data),
        .i_valid(i_valid),
        .i_par_en(i_par_en),
        .i_par_odd(i_par_odd),
        .SHIFT_DONE(SHIFT_DONE),
        .PARITY_DONE(PARTY_DONE),
        .LOAD(LOAD),
        .SHIFT_EN(SHIFT_EN),
        .BIT_CNT(BIT_CNT),
        .PARITY_CALC_EN(PARITY_CALC_EN),
        .PARITY_SEL(PARITY_SEL),
        .MUX_SEL(MUX_SEL),
        .o_busy(o_busy)
    );

    Serializer serializer_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .load(LOAD),
        .shift(SHIFT_EN),
        .i_data(i_data),
        .serial_bit(SERIAL_BIT),
        .done(SHIFT_DONE)
    );

    parity_calculator parity_calculator_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_data(i_data),
        .i_par_odd(i_par_odd),
        .i_par_en(PARITY_CALC_EN),
        .PARITY_BIT(PARITY_BIT),
        .PARTY_DONE(PARTY_DONE)
    );

    mux_4x1 mux_4x1_inst (
        .MUX_SEL(MUX_SEL),
        .SERIAL_BIT(SERIAL_BIT),
        .PARITY_BIT(PARITY_BIT),
        .STOP_BIT(STOP_BIT),
        .IDLE_BIT(IDLE_BIT),
        .o_tx(o_tx)
    );

endmodule