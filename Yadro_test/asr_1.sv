module asr_1
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

    assign res      = a >>> 1;
    assign res_vld  = arg_vld;
    
endmodule