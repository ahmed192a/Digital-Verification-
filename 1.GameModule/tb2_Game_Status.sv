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
    int Senario_NUM;                        // number of senarios

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
        Senario_NUM = 0;            // initialize senario number
        clk = 1;                    // start the clock

    //=====================================================
    // Senario 1:
    // Initialize counter with 0
    // Count up by 1
    //=====================================================
    rst_l = 1;
    control = 0;
    i_value = 0;
    INIT = 0;
    #1
    rst_l = 0;
    INIT = 1;
    #2
    INIT = 0;
    #481
    rst_l = 1;


    //=====================================================
    // Senario 2:
    // Initialize counter with 0
    // Count up by 1
    //=====================================================
    rst_l = 1;
    control = 0;
    i_value = 1;
    INIT = 0;
    #1
    rst_l = 0;
    INIT = 1;
    #2
    INIT = 0;
    #481
    rst_l = 1;

    //=====================================================
    // Senario 3:
    // Initialize counter with 15
    // Count up by 1
    //=====================================================
    rst_l = 1;
    control = 0;
    i_value = 15;
    INIT = 0;
    #1
    rst_l = 0;
    INIT = 1;
    #2
    INIT = 0;
    #481
    rst_l = 1;  


    //=====================================================
    // Senario 4:
    // Initialize counter with 0
    // Count down by 0
    //=====================================================
    rst_l = 1;
    control = 2;
    i_value = 0;
    INIT = 0;
    #1
    rst_l = 0;
    INIT = 1;
    #2
    INIT = 0;
    #481
    rst_l = 1;

    //=====================================================
    // Senario 5:
    // Initialize counter with 1
    // Count down by 1
    //=====================================================
    rst_l = 1;
    control = 2;
    i_value = 1;
    INIT = 0;
    #1
    rst_l = 0;
    INIT = 1;
    #2
    INIT = 0;
    #481
    rst_l = 1;  

    //=====================================================
    // Senario 6:
    // Initialize counter with 15
    // Count down by 1
    //=====================================================
    rst_l = 1;
    control = 2;
    i_value = 15;
    INIT = 0;
    #1
    rst_l = 0;
    INIT = 1;
    #2
    INIT = 0;
    #481
    rst_l = 1; 

    //=====================================================
    // Senario 7:
    // Initialize counter with 0
    // Count up by 2
    //=====================================================
    rst_l = 1;
    control = 1;
    i_value = 0;
    INIT = 0; 
    #1
    rst_l = 0;
    INIT = 1;
    #2
    INIT = 0;
    #251
    rst_l = 1;
    
    //=====================================================
    // Senario 8:
    // Initialize counter with 1
    // Count up by 2
    //=====================================================
    rst_l = 1;
    control = 1;
    i_value = 1;
    INIT = 0; 
    #1
    rst_l = 0;
    INIT = 1;
    #2
    INIT = 0;
    #251
    rst_l = 1;
    
    //=====================================================
    // Senario 9:
    // Initialize counter with 2
    // Count up by 2
    //=====================================================
    rst_l = 1;
    control = 1;
    i_value = 1;
    INIT = 0; 
    #1
    rst_l = 0;
    INIT = 1;
    #2
    INIT = 0;
    #251
    rst_l = 1;

    //=====================================================
    // Senario 10:
    // Initialize counter with 15
    // Count up by 2
    //=====================================================
    rst_l = 1;
    control = 1;
    i_value = 15;
    INIT = 0; 
    #1  
    rst_l = 0;
    INIT = 1;
    #2
    INIT = 0;
    #251
    rst_l = 1;

    //=====================================================
    // Senario 11:
    // Initialize counter with 0
    // Count down by 2
    //=====================================================
    rst_l = 1;
    control = 3;
    i_value = 0;
    INIT = 0; 
    #1
    rst_l = 0;
    INIT = 1;
    #2
    INIT = 0;
    #251
    rst_l = 1;
    
    //=====================================================
    // Senario 12:
    // Initialize counter with 1
    // Count down by 2
    //=====================================================
    rst_l = 1;
    control = 3;
    i_value = 1;
    INIT = 0; 
    #1
    rst_l = 0;
    INIT = 1;
    #2
    INIT = 0;
    #251
    rst_l = 1;
    
    //=====================================================
    // Senario 13:
    // Initialize counter with 2
    // Count down by 2
    //=====================================================
    rst_l = 1;
    control = 3;
    i_value = 1;
    INIT = 0; 
    #1
    rst_l = 0;
    INIT = 1;
    #2
    INIT = 0;
    #251
    rst_l = 1;
    
    //=====================================================
    // Senario 14:
    // Initialize counter with 15
    // Count down by 2
    //=====================================================
    rst_l = 1;
    control = 3;
    i_value = 15;
    INIT = 0; 
    #1
    rst_l = 0;
    INIT = 1;
    #251
    rst_l = 1;
        
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
    // Print Outputs for Each Senario
    //=============================================
    always@(posedge gameover)begin
        if(who == 2)
            $display("Senario Num = %0d -------WINNER", Senario_NUM);
        else
            $display("Senario Num = %0d -------LOSER", Senario_NUM);
        Senario_NUM = Senario_NUM +1;
  end
endmodule
