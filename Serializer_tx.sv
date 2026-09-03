module Serializer ( 
    input  logic       i_clk, 
    input  logic       i_rst_n, 
    input  logic       load, 
    input  logic       shift, 
    input  logic [7:0] i_data, 
    output logic       serial_bit, 
    output logic       done 
); 
 
    logic [7:0] shift_reg; 
    logic [2:0] bit_counter; 
 
    always_ff @(posedge i_clk or negedge i_rst_n) begin 
        if (!i_rst_n) begin 
            shift_reg   <= 8'b0; 
            serial_bit  <= 1'b0; 
            bit_counter <= 3'b0; 
            done        <= 1'b0; 
        end 
        else begin 
            if (load) begin 
                shift_reg   <= i_data; 
                bit_counter <= 3'b0; 
                done        <= 1'b0; 
                serial_bit  <= i_data[0]; 
            end 
            else if (shift) begin 
                serial_bit <= shift_reg[0]; 
                shift_reg  <= {1'b0, shift_reg[7:1]}; 
                 
                if (bit_counter == 3'd7) begin 
                    done        <= 1'b1; 
                    bit_counter <= bit_counter; 
                end 
                else begin 
                    bit_counter <= bit_counter + 1'b1; 
                    done        <= 1'b0; 
                end 
            end 
            else begin 
                done <= 1'b0; 
            end 
        end 
    end 
 
endmodule