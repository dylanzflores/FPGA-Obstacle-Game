  module levelLogic(input logic clk, reset, playerDied, userSel,
						  input logic [10:0] game_time, 
						  output logic reset_obj_count, playerDone,
						  output logic shapes[6:0],
						  output logic winScreen, menuScreen);
	
    typedef enum logic [4:0] {menu, menuDelay, S0, S1, S2, S3, S4, S5, S6, fallingSq, pWDelay, playerWins} statetype;
	 statetype state, ns;
	 always_ff @ (posedge clk, posedge reset) begin
	   if(reset)
		  state <= menu;
		else if(playerDied == 1)
		  state <= S0;
		else
		  state <= ns;
    end

    always_comb 
      begin
		  if(game_time == 130 | game_time == 260 | game_time == 390 | game_time == 520 | 
		  game_time == 650 | game_time == 780 | game_time == 910) reset_obj_count = 1;
		  else reset_obj_count = 0;
		  // State for the obstacles spawning
		  case(state)
		  menu: begin 
		    if(userSel) ns = menuDelay;
			  else ns = menu;
		  end
		  menuDelay: begin 
		    if(userSel) ns = S0;
			  else ns = menuDelay;
		  end					
		  S0: begin
		    if(game_time <= 130) ns = S0;
			 else ns = S1;
		  end
		  S1: begin
		    if(game_time <= 260) ns = S1;
			 else ns = S2;
		  end
		  S2: begin
		    if(game_time <= 390) ns = S2;
			  else ns = S3;
		  end
		  S3: begin
		    if(game_time <= 520) ns = S3;
		    else ns = S4;
		  end
		  S4: begin
		    if(game_time <= 650) ns = S4;
			  else ns = S5;
		  end
		  S5: begin
		    if(game_time <= 780) ns = S5;
			  else ns = S6;
		  end
		  S6: begin
		    if(game_time <= 910) ns = S6;
			 else ns = fallingSq;
		  end
		  // 
		  fallingSq: begin
		    if(game_time <= 1300) ns = fallingSq;
			 else ns = pWDelay;
		  end
		  // Win screen duration added at the end of the lvl
		  pWDelay: begin
		    if(userSel) ns = playerWins;
			  else ns = pWDelay;
		  end
		  playerWins: begin
		    if(userSel) ns = menu;
			 else ns = playerWins;
		  end
		  default: ns = menu;
		endcase
	end

	// Configure on when to spawn the obstacles at the given total game time.
	 assign shapes[0] = (state == S0);
	 assign shapes[1] = (state == S1);
	 assign shapes[2] = (state == S2);
	 assign shapes[3] = (state == S3);
	 assign shapes[4] = (state == S4);
	 assign shapes[5] = (state == S5);
	 assign shapes[6] = (state == S6);
	 assign playerDone = (state == fallingSq) | (state == pWDelay) | (state == playerWins);
	 assign menuScreen = (state == menu) | (state == menuDelay);
    assign winScreen = (state == playerWins) | (state == pWDelay);

  endmodule
	