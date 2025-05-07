module tb;

    localparam WIDTH = 32;

    logic                clk;
    logic                rst;

    logic                arg_vld;
    logic  signed [WIDTH - 1:0] a, b, c, d;

    logic  signed               res_vld;
    logic  signed [WIDTH - 1:0] res;

    logic  signed [WIDTH - 1:0] res_expected;

    yadro_equation #(.WIDTH(WIDTH)) dut (.*);
    
    initial
    begin
        clk = '1;

        forever
        begin
            # 5
            clk = ~ clk;
        end
    end

    task reset ();

        rst <= 'x;
        repeat (3) @ (posedge clk);
        rst <= '1;
        repeat (3) @ (posedge clk);
        rst <= '0;

    endtask

    int test_num = 0;
    int file_in;
    int errors = 0;
    int args_cnt;

    logic  signed [WIDTH - 1:0] a_tmp, b_tmp, c_tmp, d_tmp;
    logic  signed [WIDTH - 1:0] res_expected_tmp;

    initial begin
        arg_vld <= '0;
        reset ();
        
        file_in = $fopen("test_vectors.txt", "r");
        if (!file_in) begin
            $display("Error: Cannot open file 'test_vectors.txt'!");
            $finish;
        end

        while (!$feof(file_in)) begin
            // $display("Test #%d", test_num);
            test_num++;
            args_cnt = $fscanf(file_in, "%d %d %d %d %d", a_tmp, b_tmp, c_tmp, d_tmp, res_expected_tmp);
            if (args_cnt != 5) begin
                $display("Error fscanf #args: %3d (expected %3d)", args_cnt, 5);
                // $finish;
            end
            else begin
            a       <= a_tmp;
            b       <= b_tmp;
            c       <= c_tmp;
            d       <= d_tmp;
            arg_vld <= '1;

            res_expected <= res_expected_tmp;

            @ (posedge clk);
            arg_vld <= '0;
            end 
        end

        $fclose(file_in);
        $display("Tests completed. Errors: %0d", errors);

        repeat (3) @ (posedge clk);
        $finish;
    end

    //-------------------------------------------------------------------------

    int cycle = 0;

    always @ (posedge clk)
    begin
        $write (" cycle  %5d --", cycle);
        cycle <= cycle + 1'b1;

        if (rst)
            $write (" rst");
        else
            $write ("    ");

        if (arg_vld)
            $write (" arg %12d %12d %12d %12d", a, b, c, d);
        else
            $write ("                                     ");

        if (res_vld)
            $write (" res %12d", res);

        $display;
    end
    //-------------------------------------------------------------------------
    logic [WIDTH - 1:0] queue [$];

    logic was_reset = 0;

    always @ (posedge clk)
    begin
        if (rst)
        begin
            queue = {};
            was_reset = 1;
        end
        else if (was_reset)
        begin
            if (arg_vld)
            begin
                queue.push_back (res_expected);
                // $display (" push_back: expected result %0d", res_expected);
            end

            if (res_vld)
            begin
                if (queue.size () == 0)
                begin
                    $display (" FAIL: unexpected result %0d", res);
                    // $finish;
                end
                else
                begin
                    // `ifdef __ICARUS__
                        // Some version of Icarus has a bug, and this is a workaround
                        // res_expected = queue [0];
                        // queue.delete (0);
                    // `else
                        res_expected = queue.pop_front ();
                    // `endif

                    if (res !== res_expected)
                    begin
                        $display (" FAIL: res mismatch. Expected %0d, actual %0d",
                            res_expected, res);
                        // $finish;
                    end
                end
            end
        end
    end


    initial begin
        $dumpfile ("dump.vcd");
        $dumpvars ();
        #1;
    end

    initial
    begin
        repeat (1000) @ (posedge clk);
        $display ("TIMEOUT REACHED!");
        $finish;
    end


endmodule