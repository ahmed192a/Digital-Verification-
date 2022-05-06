


module top (output bit clk);
    initial clk = 0;
    initial forever #1 clk = ~clk;
    Game_Interface inter(clk);
    Game_State_testbench u0(inter.tb);
    Game_State u1(inter.dut);


    //=============================================
    // Dump variables to view them in the waveform
    //=============================================
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars;
        #5000 $finish;
    end

endmodule

