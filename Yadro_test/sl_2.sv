module sl_2
#(
    parameter ARG_WIDTH = 32,
    parameter RES_WIDTH = ARG_WIDTH
)
(
    input                           arg_vld,
    input  signed [ARG_WIDTH - 1:0] a,
    output                          res_vld,
    output signed [RES_WIDTH - 1:0] res
);

    logic                          overflow;
    logic signed [ARG_WIDTH + 1:0] tmp; // ARG_WIDTH + 2 bit for shift

    assign tmp      = a << 2;
    assign overflow = | tmp[ARG_WIDTH + 1 : ARG_WIDTH]; // !=
    assign res      = tmp[RES_WIDTH - 1:0];
    assign res_vld  = arg_vld;
    
endmodule