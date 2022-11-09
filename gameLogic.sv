module gameLogic(input logic clk, reset, userSel, win, dead,
				 output logic winScreen, loseScreen, menuScreen);
				 
  typedef enum logic [1:0] {S0, S1, S2, S3} statetype;
  statetype state, ns;
  
  always @ (posedge clk) begin
    if(reset)
	  state <= S0;
	else
	  state <= ns;
  end

  always_comb
    case(state)
	  S0: begin 
			if(userSel) ns = S1;
			else ns = S0;
		  end
	  S1: begin
			 if(win == 1 & dead == 0)
			   ns = S2;
			else if(dead == 1 & win == 0)
				ns = S3;
			else
				ns = S1;
		  end
	  S2: begin
			if(userSel) ns = S0;
			else ns = S2;
		  end
	  S3: ns = S0; 
	  default: ns = ns;
	endcase
	
	assign menuScreen = (state == S0);
	assign winScreen = (state == S2);
	assign loseScreen = (state == S3);
endmodule