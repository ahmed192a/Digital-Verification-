


module top (output bit clk);
    initial clk = 1;
    always #1 clk = ~clk;
    Game_Interface inter(.clk(clk));
    Game_State_testbench u0(.Signals(inter.tb));
    Game_State u1(.Signals(inter.dut));
    //=============================================
    // Dump variables to view them in the waveform
    //=============================================
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars;
        #5000 $finish;
    end
endmodule



program Game_State_testbench (
    Game_Interface.tb Signals
    );
    // wire who ,gameover;
    assign who = Signals.cb.who;
    assign los = Signals.cb.los;
    assign win = Signals.cb.win;
    assign gameover = Signals.cb.gameover;
    int cont;
    int i_v ;
    //==============================
    // Initial Block of Testbench
    //==============================
    initial begin
        //===========================================
        // For Control Signal = 0 (Count up by 1)
        // Scenario 1: set initial value to 0
        // Scenario 2: set initial value to 1
        // Scenario 3: set initial value to 15
        //===========================================
        // For Control Signal = 2 (Count down by 1)
        // Scenario 4: set initial value to 0
        // Scenario 5: set initial value to 1
        // Scenario 6: set initial value to 15
        //===========================================
        for ( cont = 0; cont < 3; cont = cont + 2) begin
            for ( i_v = 0; i_v < 3; i_v = i_v + 1) begin
                $display("\n\n Senario: Control = %0d, initail value = %0d",cont,i_v);

                Signals.cb.reset <= 1;                   // reset all registers
                Signals.cb.control <= cont;              // set control signal
                if(i_v == 2) Signals.cb.i_value <= 15;   // set initial value to 15
                else Signals.cb.i_value <= i_v;          // set initial value to 0 or 1
                Signals.cb.INIT <= 0;                    // release initialization signal
                #2                                      // wait for one clock cycle
                Signals.cb.reset <= 0;                   // release reset
                Signals.cb.INIT <= 1;                    // set initialization signal
                #2                                      // wait for two clock cycles
                Signals.cb.INIT <= 0;                    // release initialization signal
                #482                                    // wait for 481 clock cycles
                Signals.cb.reset <= 1;                   // reset all registers
            end
        end
        //===========================================
        // For Control Signal = 1 (Count up by 2)
        // Scenario 7: set initial value to 0
        // Scenario 8: set initial value to 1
        // Scenario 9: set initial value to 2
        // Scenario 10: set initial value to 15
        //===========================================
        // For Control Signal = 3 (Count down by 2)
        // Scenario 11: set initial value to 0
        // Scenario 12: set initial value to 1
        // Scenario 13: set initial value to 2
        // Scenario 14: set initial value to 15
        //===========================================
        for ( cont = 1; cont < 4; cont = cont + 2) begin
            for ( i_v = 0; i_v < 4; i_v = i_v + 1) begin
                $display("\n\n Senario: Control = %0d, initail value = %0d",cont,i_v);

                Signals.cb.reset <= 1;                       // reset all registers
                Signals.cb.control <= cont;                  // set control signal
                if(i_v == 3) Signals.cb.i_value <= 15;       // set initial value to 15
                else Signals.cb.i_value <= i_v;              // set initial value to 0, 1, or 2
                Signals.cb.INIT <= 0;                        // release initialization signal
                #2                                           // wait for one clock cycle
                Signals.cb.reset <= 0;                       // release reset
                Signals.cb.INIT <= 1;                        // set initialization signal
                #2                                           // wait for two clock cycles
                Signals.cb.INIT <= 0;                        // release initialization signal
                #252                                         // wait for 251 clock cycles
                Signals.cb.reset <= 1;                       // reset all registers
            end
        end
        #20;
    end
    //===========================
    // Properties
    //===========================
    property signals_cleared;
      @(Signals.cb) disable iff(!($fell(Signals.reset) )) (who==0 || los ==0 || gameover ==0 || win ==0);
    endproperty

    property winner_checker;
      @(Signals.cb)
      if($fell(Signals.reset)) ##[113:241] gameover ==1;
    endproperty

    //===========================
    // Asserions
    //===========================
    assert_winner_checker: assert property(winner_checker)$display("[%0t] ----- Assertion GameOver passed", $time);
    assert_signals_cleared: assert property (signals_cleared) $display("[%0t] ----- Assertion Reseting_signals passed", $time);
endprogram

          
