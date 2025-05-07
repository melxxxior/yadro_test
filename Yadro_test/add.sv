module add
#(
    parameter ARG_WIDTH = 32,
    parameter RES_WIDTH = ARG_WIDTH + 1
)
(
    input                           arg_vld,
    input  signed [ARG_WIDTH - 1:0] a,
    input  signed [ARG_WIDTH - 1:0] b,
    output                          res_vld,
    output signed [RES_WIDTH - 1:0] res
);

    logic                       overflow;
    logic signed [ARG_WIDTH :0] tmp;

    assign tmp      = a + b;
    assign overflow = tmp[ARG_WIDTH] ^ tmp[ARG_WIDTH-1]; // !=
    assign res      = tmp[RES_WIDTH - 1:0];
    assign res_vld  = arg_vld;
    
endmodule