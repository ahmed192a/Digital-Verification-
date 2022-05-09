interface Game_Interface #(
    parameter COUNTER_SIZE = 4
    )(
    input bit clk
    );

    bit [1:0] who, control;
    bit los, win, gameover, reset, INIT;
    bit [COUNTER_SIZE-1:0] i_value;

    clocking cb @(posedge clk);
        default input #0ns output #1ns;
        output reset, control, INIT, i_value;
        input who, los, win, gameover;
    endclocking




    modport dut
    (
        output gameover, who, los, win,
        input clk, reset, control, INIT, i_value
    );
    
    modport tb
    (
        clocking cb,
        output reset
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

