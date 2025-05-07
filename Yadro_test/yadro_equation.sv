module yadro_equation
#(
    parameter WIDTH = 32
)
(   
    input                        clk,
    input                        rst,
    input                        arg_vld,
    input  signed [WIDTH - 1: 0] a,
    input  signed [WIDTH - 1: 0] b,
    input  signed [WIDTH - 1: 0] c,
    input  signed [WIDTH - 1: 0] d,
    output                       res_vld,
    output signed [WIDTH - 1: 0] res
);

    localparam SUB1_RES_WIDTH = WIDTH;
    localparam MUL1_RES_WIDTH = WIDTH;
    localparam SL_RES_WIDTH   = WIDTH;
    localparam ADD_RES_WIDTH  = WIDTH;
    localparam MUL2_ARG_WIDTH = ADD_RES_WIDTH > SUB1_RES_WIDTH ? ADD_RES_WIDTH : SUB1_RES_WIDTH;
    localparam MUL2_RES_WIDTH = WIDTH;
    localparam SUB2_ARG_WIDTH = MUL2_RES_WIDTH > SL_RES_WIDTH ? MUL2_RES_WIDTH : SL_RES_WIDTH;
    localparam SUB2_RES_WIDTH = WIDTH;
    localparam ASR_RES_WIDTH  = WIDTH;


    logic [SUB1_RES_WIDTH - 1: 0] fifo1_rd;
    logic [SUB1_RES_WIDTH - 1: 0] fifo2_rd;


    logic                         sub1_res_vld;
    logic [SUB1_RES_WIDTH - 1: 0] sub1_res;

    sub #( .ARG_WIDTH(WIDTH), .RES_WIDTH(SUB1_RES_WIDTH) ) sub1 
    (
        .arg_vld (arg_vld     ),
        .a       (a           ),
        .b       (b           ),
        .res_vld (sub1_res_vld),
        .res     (sub1_res    )
    );

    logic                         mul1_res_vld;
    logic [MUL1_RES_WIDTH - 1: 0] mul1_res;

    mul #( .ARG_WIDTH(WIDTH), .RES_WIDTH(MUL1_RES_WIDTH) ) mul1 
    (
        .arg_vld (arg_vld     ),
        .a       (WIDTH'(3)  ), // 'sd3
        .b       (c           ),
        .res_vld (mul1_res_vld),
        .res     (mul1_res    )
    );

    logic                         sl_res_vld;
    logic [SL_RES_WIDTH   - 1: 0] sl_res;

    sl_2 #( .ARG_WIDTH(WIDTH), .RES_WIDTH(SL_RES_WIDTH) ) sl 
    (
        .arg_vld (arg_vld     ),
        .a       (d           ), 
        .res_vld (sl_res_vld  ),
        .res     (sl_res      )
    );


    logic                         mul1_out_vld;
    logic [MUL1_RES_WIDTH - 1: 0] mul1_out;
    register_with_rst #(.WIDTH(1))             r_1_vld  (clk, rst, mul1_res_vld, mul1_out_vld);
    register_with_en #(.WIDTH(MUL1_RES_WIDTH)) r_1_data (clk, mul1_res_vld, mul1_res, mul1_out);


    logic                         add_res_vld;
    logic [SUB1_RES_WIDTH - 1: 0] add_res;

    add #( .ARG_WIDTH(MUL1_RES_WIDTH), .RES_WIDTH(ADD_RES_WIDTH) ) add 
    (
        .arg_vld (mul1_out_vld),
        .a       (WIDTH'(1)  ), // 'sd1
        .b       (mul1_out    ),
        .res_vld (add_res_vld ),
        .res     (add_res     )
    );

    logic                         add_out_vld;
    logic [ADD_RES_WIDTH  - 1: 0] add_out;
    register_with_rst #(.WIDTH(1))            r_2_vld  (clk, rst, add_res_vld, add_out_vld);
    register_with_en #(.WIDTH(ADD_RES_WIDTH)) r_2_data (clk, add_res_vld, add_res, add_out);


    logic                         mul2_res_vld;
    logic [MUL2_RES_WIDTH - 1: 0] mul2_res;

    mul #( .ARG_WIDTH(MUL2_ARG_WIDTH), .RES_WIDTH(MUL2_RES_WIDTH) ) mul2  
    (
        .arg_vld (add_out_vld ),
        .a       (fifo1_rd    ), // 'sd3
        .b       (add_out     ),
        .res_vld (mul2_res_vld),
        .res     (mul2_res    )
    );


    logic                         mul2_out_vld;
    logic [MUL2_RES_WIDTH - 1: 0] mul2_out;
    register_with_rst #(.WIDTH(1))             r_3_vld  (clk, rst, mul2_res_vld, mul2_out_vld);
    register_with_en #(.WIDTH(MUL2_RES_WIDTH)) r_3_data (clk, mul2_res_vld, mul2_res, mul2_out);

    logic                         sub2_res_vld;
    logic [SUB2_RES_WIDTH - 1: 0] sub2_res;

    sub #( .ARG_WIDTH(SUB2_ARG_WIDTH), .RES_WIDTH(SUB2_RES_WIDTH) ) sub2 
    (
        .arg_vld (mul2_out_vld),
        .a       (mul2_out    ),
        .b       (fifo2_rd    ),
        .res_vld (sub2_res_vld),
        .res     (sub2_res    )
    );

    logic                         asr_res_vld;
    logic [SL_RES_WIDTH   - 1: 0] asr_res;

    asr_1 #( .ARG_WIDTH(SUB2_RES_WIDTH), .RES_WIDTH(ASR_RES_WIDTH) ) asr
    (
        .arg_vld (sub2_res_vld),
        .a       (sub2_res    ), 
        .res_vld (asr_res_vld ),
        .res     (asr_res     )
    );

    logic                         asr_out_vld;
    logic [ASR_RES_WIDTH - 1: 0]  asr_out;
    register_with_rst #(.WIDTH(1))            r_4_vld  (clk, rst, asr_res_vld, asr_out_vld);
    register_with_en #(.WIDTH(ASR_RES_WIDTH)) r_4_data (clk, asr_res_vld, asr_res, asr_out);

    fifo #( .WIDTH(SUB1_RES_WIDTH), .DEPTH(2)) fifo1
    (
        .clk     (clk         ),
        .rst     (rst         ),
        .push    (sub1_res_vld),
        .pop     (add_out_vld ),
        .wr_data (sub1_res    ),
        .rd_data (fifo1_rd    )
    );

    fifo #( .WIDTH(SUB1_RES_WIDTH), .DEPTH(3)) fifo2
    (
        .clk     (clk         ),
        .rst     (rst         ),
        .push    (sl_res_vld  ),
        .pop     (mul2_out_vld),
        .wr_data (sl_res      ),
        .rd_data (fifo2_rd    )
    );

    assign res_vld = asr_out_vld;
    assign res     = asr_out;
    
endmodule