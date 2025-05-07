module register_with_en
#(
    parameter WIDTH = 32
)
(
    input                      clk,
    input                      en,
    input        [WIDTH - 1:0] d,
    output logic [WIDTH - 1:0] q
);

    always_ff @ (posedge clk)
        if (en)
            q <= d;

endmodule