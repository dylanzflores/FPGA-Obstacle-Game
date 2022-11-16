	module counter_shapes(input logic clk, reset, menuScreen, playerWon, playerLost,
						  output logic [10:0] obj_position_counter, game_time,
						  output logic levelDone);
						  
		always_ff @ (posedge clk, posedge reset) begin
			if(reset) begin
				obj_position_counter <= 0;
				game_time <= 0;
			end
			// Reset level whenever user wins, loses, or goes to the menu screen.
			else if(menuScreen == 1 | playerWon == 1 | playerLost == 1) begin
				obj_position_counter <= 0;
				game_time <= 0;
			end
			else begin
				if(obj_position_counter == 10'd695) begin
					obj_position_counter <= 10'd0;
				end
				else begin
					obj_position_counter <= obj_position_counter + 10;
				end
				// If player beats length of level user wins
				if(game_time == 10'd10000) begin
					game_time <= 0;
					obj_position_counter <= 0;
				end
				else begin
					game_time <= game_time + 1;
				end
			end
		end
	endmodule
	