	module levelLogic(input logic clk, reset, hit, userSel,
					  input logic [10:0] game_time, obj_count,
					  output logic shapes[30:0],
					  output logic winScreen, loseScreen, menuScreen);
	
	typedef enum logic [3:0] {menu, S0, S1, S2, S3, playerWins} statetype;
	statetype state, ns;
  
	always_ff @ (posedge clk, posedge reset) begin
		if(reset)
			state <= menu;
		else if(hit == 1)
			state <= S0;
		else
			state <= ns;
	end

	always_comb 
		case(state)
		menu: begin 
					if(userSel) ns = S0;
					else ns = menu;
				end
		S0: begin
				if(game_time <= 10'd80) 
					ns = S0;
				else ns = S1;
		end
		S1: begin
				if(game_time <= 10'd180) 
					ns = S1;
				else ns = playerWins;
			end
		playerWins: begin
			if(userSel) ns = menu;
			else ns = playerWins;
		end
		
		//S3: begin
		//
		//end
		default: ns = menu;
	endcase

	assign shapes[0] = (state == S0);
	assign shapes[1] = (state == S1);

	assign menuScreen = (state == menu);
	assign winScreen = (state == playerWins);

	endmodule