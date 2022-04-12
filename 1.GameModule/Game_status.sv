//============================================================================//
//                                                                            //
//      SV Counter Game                                                       //
//                                                                            //
//      Desc: multi-mode counter configures using control signal, with pair   //
//           of plain binary counters to count the winning and losing times.  //
//      Date: April 2022                                                      //
//      Developer: Ahmed Mohamed                                              //
//      Notes:                                                                //
//                                                                            //
//============================================================================//



//==============================================================================
// Module Counter:
//      4 bit Muliti-mode counter module
//      With Control signal to change the mode
//          00 count up by 1
//          01 count down by 1
//          10 count up by 2
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
    input [1:0] control             // control     (0: count up by 1, 1: count down by 1, 2: count up by 2, 3: count down by 2)
    );

  always @(posedge clk) begin
    if (reset) begin
      count_reg = 0;                            // reset counter
    end else begin
        //==============================
        // Initialization
        //==============================
        if (Init) begin
            count_reg = load;                    // initialize counter
        end 
        //==============================
        // Counting
        //==============================
        else begin
            case(control)                         // Check the Control signal
            2'b00: count_reg = count_reg + 1;     //  00 count up by 1
            2'b01: count_reg = count_reg + 2;     //  01 count up by 2
            2'b10: count_reg = count_reg - 1;     //  10 count down by 1
            2'b11: count_reg = count_reg - 2;     //  11 count down by 2
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
    //===============
    // Output Ports
    //===============
    output reg [1:0] who,               // who is the winner
    output reg los,                     // loser signal when counter is all zeros
    output reg win,                     // winner signal when counter is all ones
    output reg gameover,                // gameover signal when loser or winner counters reaches 15
    //===============
    // Input Ports
    //===============
    input clk,                          // clock
    input reset,                        // reset
    input [1:0] control,                // control signal
    input INIT,                         // initialization signal
    input [COUNTER_SIZE-1:0] i_value    // initialization value
    );

    //==============================
    // Signals
    //==============================
    wire start_over = reset | gameover; // start over signal     (1: start over and reset all reg and modules, 0: normal operation)

    //==============================
    // Local registers
    //==============================
    reg [COUNTER_SIZE-1:0] count_reg;   // counter register (read-only)
    reg [3:0]wins, losses;              // winner and loser counters   

    //==============================
    // Instantiate Counter module
    //==============================
    counter c1(.clk(clk), .reset(start_over), .Init(INIT), .load(i_value), .control(control), .count_reg(count_reg));



    always@(posedge clk) begin
        // Reset Block
        if (start_over) begin       
            who = 0;                    // reset Who register
            los = 0;                    // release Loser signal
            win = 0;                    // release Winner signal
            gameover <= 0;              // release Gameover signal
            wins = 0;                   // reset Winner counter
            losses = 0;                 // reset Loser counter
        end 
        //==============================
        // Initialization
        //==============================
        else if(INIT) begin
            who = 0;                    // reset Who register
            los = 0;                    // release Loser signal
            win = 0;                    // release Winner signal
            wins = 0;                   // reset Winner counter
            losses = 0;                 // reset Loser counter
        end
        // Normal Operation
        else begin
            if (count_reg == 15) begin
                win = 1;                // set Winner signal
                los = 0;                // release Loser signal
                wins = wins + 1;        // increment winner counter
            end else if(count_reg == 0) begin
                win = 0;                // release Winner signal
                los = 1;                // set Loser signal
                losses = losses + 1;    // increment loser counter
            end
            else begin
                win = 0;                // release Winner signal
                los = 0;                // release Loser signal
            end

            if (losses == 15) begin
                who = 1;                // Who with 01 to indicates Loser 
                gameover <= 1;          // set Gameover signal
            end
            if (wins == 15) begin
                who = 2;                // Who with 10 to indicates Winner
                gameover <= 1;          // set Gameover signal
            end
        end
    end
endmodule


