interface Game_Interface #(
    parameter COUNTER_SIZE = 4
    )(
    input bit clk
    );

    logic [1:0] who, control;
    logic los, win, gameover, reset, INIT;
    logic [COUNTER_SIZE-1:0] i_value;

    // clocking cb @(posedge clk);
    //     output who;
    //     output los;
    //     output win;
    // endclocking

    modport dut(
        output gameover,
        output who,
        output los,
        output win,
        input clk,
        input reset,
        input control,
        input INIT,
        input i_value
        );
    
    modport tb
    (
        output reset,
        output control,
        output INIT,
        output i_value,
        input who,
        input los,
        input win,
        input gameover
    );
    
endinterface



//==============================================================================
// Module Counter:
//      4 bit Muliti-mode counter module
//      With Control signal to change the mode
//          00 count up by 1
//          01 count up by 2
//          10 count down by 1
//          11 count down by 2   
//  Input: clk, reset, Init, load, control
//  Output: count_reg
//==============================================================================
module counter(
    //===============
    // Output Ports
    //===============
    output reg [3:0] count_reg,      // Counter register 
    //===============
    // Input Ports
    //===============
    input clk,                      // clock
    input reset,                    // reset    
    input Init,                     // initialize   (1: initialize, 0: normal operation) 
    input [3:0] load,               // load value  (for counter initialization) 
    input [1:0] control             // control     (0: count up by 1, 1: count up by 2, 2: count down by 1, 3: count down by 2)
    );

  always @(posedge clk) begin
    if (reset) begin
      count_reg <= 0;                            // reset counter
    end else begin
        //==============================
        // Initialization
        //==============================
        if (Init) begin
            count_reg <= load;                    // initialize counter
        end 
        //==============================
        // Counting
        //==============================
        else begin
            case(control)                         // Check the Control signal
            2'b00: count_reg <= count_reg + 1;     //  00 count up by 1
            2'b01: count_reg <= count_reg + 2;     //  01 count up by 2
            2'b10: count_reg <= count_reg - 1;     //  10 count down by 1
            2'b11: count_reg <= count_reg - 2;     //  11 count down by 2
            endcase
        end
    end
  end
endmodule


//==============================================================================
// Module Game_State:
//  Input: clk, reset, Init, i_value, control
//  Output: who,los, win, gameover
//==============================================================================
module Game_State#(
    //==============================
    // Top level block parameters
    //==============================
    parameter COUNTER_SIZE = 4          // number of bits in counter
    )(
    Game_Interface.dut Signals
    );

    //==============================
    // Signals
    //==============================
    wire start_over = Signals.reset | Signals.gameover; // start over signal     (1: start over and reset all reg and modules, 0: normal operation)
  	bit start_over;
//
    //==============================
    // Local registers
    //==============================
    reg [COUNTER_SIZE-1:0] count_reg;   // counter register (read-only)
    reg [3:0]wins, losses;              // winner and loser counters   

    //==============================
    // Instantiate Counter module
    //==============================
    counter c1(.clk(Signals.clk), .reset(start_over), .Init(Signals.INIT), .load(Signals.i_value), .control(Signals.control), .count_reg(count_reg));



    always@(posedge Signals.clk) begin
        // Reset Block
      	//start_over = Signals.reset | Signals.gameover;
        if (start_over) begin       
            Signals.who <= 0;                    // reset Who register
            Signals.los <= 0;                    // release Loser signal
            Signals.win <= 0;                    // release Winner signal
            Signals.gameover <= 0;              // release Gameover signal
            wins = 0;                   // reset Winner counter
            losses = 0;                 // reset Loser counter
        end 
        //==============================
        // Initialization
        //==============================
        else if(Signals.INIT) begin
            Signals.who <= 0;                    // reset Who register
            Signals.los <= 0;                    // release Loser signal
            Signals.win <= 0;                    // release Winner signal
            wins = 0;                   // reset Winner counter
            losses = 0;                 // reset Loser counter
            Signals.gameover <= 0;              // release Gameover signal
        end
        // Normal Operation
        else begin
            if (count_reg == 15) begin
                Signals.win <= 1;                // set Winner signal
                Signals.los <= 0;                // release Loser signal
                wins = wins + 1;        // increment winner counter
            end else if(count_reg == 0) begin
                Signals.win <= 0;                // release Winner signal
                Signals.los <= 1;                // set Loser signal
                losses = losses + 1;    // increment loser counter
            end
            else begin
                Signals.win <= 0;                // release Winner signal
                Signals.los <= 0;                // release Loser signal
            end

            if (losses == 15) begin
                Signals.who <= 1;                // Who with 01 to indicates Loser 
                Signals.gameover <= 1;          // set Gameover signal
            end
            if (wins == 15) begin
                Signals.who <= 2;                // Who with 10 to indicates Winner
                Signals.gameover <= 1;          // set Gameover signal
            end
        end
    end
endmodule


program Game_State_testbench  #(
    parameter CLOCK = 1,         // clock period
    parameter COUNTER_SIZE = 4   // number of bits in counter
    )(
    Game_Interface.tb Signals
    );
    //==================
    // Local Variables
    //==================
    int Scenario_NUM;                        // number of scenarios


    //==============================
    // Initial Block of Testbench
    //==============================
    initial begin
        Scenario_NUM = 0;            // initialize scenario number


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
                Signals.reset = 1;                  // reset all registers
                Signals.control = cont;             // set control signal
                if(i_v == 2) Signals.i_value = 15;  // set initial value to 15
                else Signals.i_value = i_v;         // set initial value to 0 or 1
                Signals.INIT = 0;                   // release initialization signal
                #1                                  // wait for one clock cycle
                Signals.reset = 0;                  // release reset
                Signals.INIT = 1;                   // set initialization signal
                #2                                  // wait for two clock cycles
                Signals.INIT = 0;                   // release initialization signal
                #481                                // wait for 481 clock cycles
                Signals.reset = 1;                  // reset all registers
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
                Signals.reset = 1;                      // reset all registers
                Signals.control = cont;                 // set control signal
                if(i_v == 3) Signals.i_value = 15;      // set initial value to 15
                else Signals.i_value = i_v;             // set initial value to 0, 1, or 2
                Signals.INIT = 0;                       // release initialization signal
                #1                                      // wait for one clock cycle
                Signals.reset = 0;                      // release reset
                Signals.INIT = 1;                       // set initialization signal
                #2                                      // wait for two clock cycles
                Signals.INIT = 0;                       // release initialization signal
                #251                                    // wait for 251 clock cycles
                Signals.reset = 1;                      // reset all registers
            end
        end
        #20;
    end




    // //=============================================
    // // Print Outputs for Each Scenario
    // //=============================================
    // always@(posedge gameover)begin
    //     if(who == 2)
    //         $display("Scenario Num = %0d -------WINNER", Scenario_NUM);
    //     else
    //         $display("Scenario Num = %0d -------LOSER", Scenario_NUM);
    //     Scenario_NUM = Scenario_NUM +1;
    // end
endprogram

          
