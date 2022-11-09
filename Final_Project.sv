// Mesa
module Final_Project(input logic CLOCK_50, SW[1:0], KEY[0],
							output logic       VGA_CLK, 
							output logic       VGA_HS,
							output logic       VGA_VS,
							output logic       VGA_SYNC_N,
							output logic       VGA_BLANK_N,
							output logic [7:0] VGA_R,
							output logic [7:0] VGA_G,
							output logic [7:0] VGA_B);
  // SW[0] = reset, SW[1] = switch clockspeed enable, KEY[0] = player control to jump						
 logic game_clk, jump;
 logic victoryScreen, loseScreen, menuScreen, playerDeath, win;
 logic [9:0] distance = 0;
 jump_logic j(game_clk, SW[0], ~KEY[0], distance);
 
 gameLogic fsm1(CLOCK_50, SW[0], ~KEY[0], win, playerDeath, victoryScreen, loseScreen, menuScreen); // game FSM
 slowClkHz hz24 (CLOCK_50, SW[0], game_clk);
 vga vgaDev(CLOCK_50, game_clk, SW[0], loseScreen, victoryScreen, menuScreen, distance, win, playerDeath, VGA_CLK, VGA_HS, VGA_VS, VGA_SYNC_N, VGA_BLANK_N,
			 VGA_R, VGA_G, VGA_B);   
endmodule