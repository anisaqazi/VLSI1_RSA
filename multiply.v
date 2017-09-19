module multiplier
#(parameter WIDTH=32)
(
        input clk,
        input [WIDTH-1:0] inp_1,
        input [WIDTH-1:0] inp_2,
        output reg [WIDTH-1:0] out_l,
        output reg [WIDTH-1:0] out_h
);

        // Declare input and output registers
        reg [WIDTH-1:0] inp_1_reg;
        reg [WIDTH-1:0] inp_2_reg;
        wire [2*WIDTH-1:0] mult_out;
        assign mult_out = inp_1_reg * inp_2_reg;
        always @ (posedge clk)
        begin
                inp_1_reg <= inp_1;
                inp_2_reg <= inp_2;
                out_l <= mult_out[WIDTH-1:0];
                out_h <= mult_out[2*WIDTH-1:WIDTH];
        end

endmodule
