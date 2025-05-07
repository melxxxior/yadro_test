module register_with_rst
#(
    parameter WIDTH = 32
)
(
    input                      clk,
    input                      rst,
    input        [WIDTH - 1:0] d,
    output logic [WIDTH - 1:0] q
);

    always_ff @ (posedge clk)
        if (rst)
            q <= '0;
        else
            q <= d;

endmodule