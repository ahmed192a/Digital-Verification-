//============================================================================//
//                                                                            //
//      SV Test Bench Counter Game                                            //
//                                                                            //
//      Desc: test bench  multi-mode counter configures using control signal, //
//            with pair of plain binary counters to count the winning and     //
//            losing times.                                                   //
//      Date: April 2022                                                      //
//      Developer: Ahmed Mohamed                                              //
//      Notes:                                                                //
//                                                                            //
//============================================================================//


module Game_State_testbench  #(
    parameter CLOCK = 1,         // clock period
    parameter COUNTER_SIZE = 4   // number of bits in counter
    )(
    //===============
    // Output Ports
    //===============
    output reg clk,                          // clock
    output reg rst_l,                        // reset
    output reg [1:0] control,                // control signal
    output reg [COUNTER_SIZE-1:0] i_value,   // initialization value   
    output reg INIT,                         // initialization signal
    //===============
    // Input Ports
    //===============
    input wire [1:0] who,                    // who is the winner
    input wire los,                          // loser signal when counter is all zeros
    input wire win,                          // winner signal when counter is all ones
    input wire gameover                      // gameover signal when loser or winner counters reaches 15
    );
    //==================
    // Local Variables
    //==================
    int Scenario_NUM;                        // number of scenarios

    //==============================
    // Instantiate the game module
    //==============================
    Game_State g1(      
        .clk(clk),
        .reset(rst_l),
        .control(control),
        .i_value(i_value),
        .INIT(INIT),
        .who(who),
        .los(los),
        .win(win),
        .gameover(gameover)
    );              

    //==============================
    // Create Counter
    //==============================
    always begin
        #CLOCK clk = ~clk;     // create clk works forever
    end

    //==============================
    // Initial Block of Testbench
    //==============================
    initial begin
        Scenario_NUM = 0;            // initialize scenario number
        clk = 1;                    // start the clock


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
        for (int cont = 0; cont < 3; cont = cont + 2) begin
            for (int i_v = 0; i_v < 3; i_v = i_v + 1) begin
                rst_l = 1;                  // reset all registers
                control = cont;             // set control signal
                if(i_v == 2) i_value = 15;  // set initial value to 15
                else i_value = i_v;         // set initial value to 0 or 1
                INIT = 0;                   // release initialization signal
                #1                          // wait for one clock cycle
                rst_l = 0;                  // release reset
                INIT = 1;                   // set initialization signal
                #2                          // wait for two clock cycles
                INIT = 0;                   // release initialization signal
                #481                        // wait for 481 clock cycles
                rst_l = 1;                  // reset all registers
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
        for (int cont = 1; cont < 4; cont = cont + 2) begin
            for (int i_v = 0; i_v < 4; i_v = i_v + 1) begin
                rst_l = 1;                      // reset all registers
                control = cont;                 // set control signal
                if(i_v == 3) i_value = 15;      // set initial value to 15
                else i_value = i_v;             // set initial value to 0, 1, or 2
                INIT = 0;                       // release initialization signal
                #1                              // wait for one clock cycle
                rst_l = 0;                      // release reset
                INIT = 1;                       // set initialization signal
                #2                              // wait for two clock cycles
                INIT = 0;                       // release initialization signal
                #251                            // wait for 251 clock cycles
                rst_l = 1;                      // reset all registers
            end
        end
    end


    //=============================================
    // Dump variables to view them in the waveform
    //=============================================
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars;
        #5000 $finish;
    end

    //=============================================
    // Print Outputs for Each Scenario
    //=============================================
    always@(posedge gameover)begin
        if(who == 2)
            $display("Scenario Num = %0d -------WINNER", Scenario_NUM);
        else
            $display("Scenario Num = %0d -------LOSER", Scenario_NUM);
        Scenario_NUM = Scenario_NUM +1;
  end
endmodule
