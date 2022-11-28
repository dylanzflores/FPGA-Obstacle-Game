	module levelLogic(input logic clk, reset, playerDied, userSel,
					  input logic [15:0] game_time, 
					  output logic reset_obj_count,
					  output logic shapes[19:0],
					  output logic winScreen, menuScreen);
	
	typedef enum logic [4:0] {menu, S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12,
	S13, S14, S15, S16, S17, S18, S19, pWDelay, playerWins} statetype;
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
			case(state)
			menu: begin 
						if(userSel) ns = S0;
						else ns = menu;
					end
			S0: begin
					if(game_time <= 125) ns = S0;
					else ns = S1;
			end
			S1: begin
					if(game_time <= 250) 
						ns = S1;
					else ns = S2;
			end
			S2: begin
					if(game_time <= 375) 
						ns = S2;
					else ns = S3;
				end
			S3: begin
					if(game_time <= 500) 
						ns = S3;
					else ns = S4;
				end
			S4: begin
					if(game_time <= 625) 
						ns = S4;
					else ns = pWDelay;
				end
			S5: begin
					if(game_time <= 750)
						ns = S5;
					else ns = pWDelay;
				end
			S6: begin
					if(game_time <= 875) 
						ns = S6;
					else ns = S7;
				end
			S7: begin
					if(game_time <= 1000) 
						ns = S7;
					else ns = S8;
				end
			S8: begin
					if(game_time <= 1125) 
						ns = S8;
					else ns = S9;
				end
			S9: begin
					if(game_time <= 950) 
						ns = S9;
					else ns = S19;
				end
			S19: begin
					if(game_time <= 1045) 
						ns = S19;
					else ns = pWDelay;
				end
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
		
		if(game_time == 125 | game_time == 250 | game_time == 375 | game_time == 500 | 
		game_time == 625 | game_time == 750 | game_time == 875 | game_time == 1000 |
		game_time == 1025 | game_time == 950 | game_time == 1045) reset_obj_count = 1;
		else reset_obj_count = 0;
	end

	
	assign shapes[0] = (state == S0);
	assign shapes[1] = (state == S1);
	assign shapes[2] = (state == S2);
	assign shapes[3] = (state == S3);
	assign shapes[4] = (state == S4);
	assign shapes[5] = (state == S5);
	assign shapes[6] = (state == S6);
	assign shapes[7] = (state == S7);
	assign shapes[8] = (state == S8);
	assign shapes[9] = (state == S9);
	assign shapes[10] = (state == S10);
	assign shapes[11] = (state == S11);
	assign shapes[12] = (state == S12);
	assign shapes[13] = (state == S13);
	assign shapes[14] = (state == S14);
	assign shapes[15] = (state == S15);
	assign shapes[16] = (state == S16);
	assign shapes[17] = (state == S17);
	assign shapes[18] = (state == S18);
	assign shapes[19] = (state == S19);
	
	assign menuScreen = (state == menu);
	assign winScreen = (state == playerWins) | (state == pWDelay);

	endmodule
	