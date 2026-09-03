module edge_detector (
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic i_rx,
    output logic start_pulse
);

    logic sync_1;
    logic sync_2;
    logic i_rx_d1;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            sync_1  <= 1'b1;
            sync_2  <= 1'b1;
            i_rx_d1 <= 1'b1;
        end else begin
            sync_1  <= i_rx;
            sync_2  <= sync_1;
            i_rx_d1 <= sync_2;
        end
    end

    assign start_pulse = ~sync_2 & i_rx_d1;

endmodule