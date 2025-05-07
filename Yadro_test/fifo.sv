module fifo
# (
    parameter WIDTH = 32, DEPTH = 2
)
(
    input                clk,
    input                rst,
    input                push,
    input                pop,
    input  [WIDTH - 1:0] wr_data,
    output [WIDTH - 1:0] rd_data
    // output               empty,
    // output               full
);



    localparam PTR_WIDTH = $clog2(DEPTH);
    localparam max_ptr   = PTR_WIDTH' (DEPTH - 1);

    logic [WIDTH - 1:0]      data_arr [DEPTH - 1: 0];
    logic [PTR_WIDTH - 1: 0] write_ptr;
    logic [PTR_WIDTH - 1: 0] read_ptr;
    logic                    mod_2;

    // assign empty     = (write_ptr == read_ptr) & (~mod_2);
    // assign full      = (write_ptr == read_ptr) & (mod_2);
    assign rd_data = data_arr[read_ptr];

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            write_ptr <= '0;
        else if (push)
            write_ptr <= write_ptr == max_ptr ? '0 : write_ptr + 1'b1;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            read_ptr <= '0;
        else if (pop)
            read_ptr <= read_ptr == max_ptr ? '0 : read_ptr + 1'b1;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            mod_2 <= '0;
        else 
            mod_2 <= mod_2 ^ (push & (write_ptr == max_ptr)) ^ (pop & (read_ptr == max_ptr));

    always_ff @ (posedge clk)
        if (push) 
            data_arr[write_ptr] <= wr_data;

endmodule