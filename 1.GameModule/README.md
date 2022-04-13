
# Game Status Module  ![Actions Status](https://img.shields.io/badge/language-systemverilog-orange)
A multi-mode counter. It can count up and down by ones and by twos. <br>
There is a two-bit control bus input indicating which one of the four modes is active.
- 00 count up by 1
- 01 count up by 2
- 10 count down 1
- 11 count down 2 
<br>
It also have an initial value input and a control signal called INIT. 
When INIT is logic 1, parallelly load that initial value into the multi-mode counter.<br>
Whenever the count is equal to all zeros, a signal called LOSER is set to high.
When the count is all ones, a signal called WINNER is set to high. 
In either case, the set signal remains high for only one cycle. <br>
A pair of plain binary counters, count the number of times WINNER and LOSER
goes high. When one of them reaches 15, an output called GAMEOVER is set to high. <br>
If the game is over because LOSER got to 15 first, a two-bit output called WHO is set to
2’b01. If the game is over because WINNER got to 15 first,  WHO is set to 2’b10. <br>
WHO starts at 2’b00 and return to it after each game over. Then synchronously clear all the counters and start over.

## Test Scenarios ![Actions Status](https://img.shields.io/badge/coverage-100-green)
* Control Signal = 0 (Count up by 1)<br>
  * Scenario 1: set initial value to 0
  * Scenario 2: set initial value to 1
  * Scenario 3: set initial value to 15

* Control Signal = 2 (Count down by 1)
  * Scenario 4: set initial value to 0 
  * Scenario 5: set initial value to 1
  * Scenario 6: set initial value to 15
  
* Control Signal = 1 (Count up by 2)
  * Scenario 7: set initial value to 0
  * Scenario 8: set initial value to 1
  * Scenario 9: set initial value to 2
  * Scenario 10: set initial value to 15
  
* Control Signal = 3 (Count down by 2)
  * Scenario 11: set initial value to 0
  * Scenario 12: set initial value to 1
  * Scenario 13: set initial value to 2
  * Scenario 14: set initial value to 15
