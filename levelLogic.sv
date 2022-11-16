	module levelLogic(input logic clk, reset, hit,
					  input logic [10:0] game_time, obj_count,
					  output logic shapes[30:0]);
	
	typedef enum logic [1:0] {S0, S1, S2, S3} statetype;
	statetype state, ns;
  
	always_ff @ (posedge clk, posedge reset) begin
		if(reset)
			state <= S0;
		else if(hit == 1)
			state <= S0;
		else
			state <= ns;
	end

	always_comb 
		case(state)
		S0: begin
				if(game_time <= 10'd80) 
					ns = S0;
				else ns = S1;
		end
		S1: begin
				if(game_time <= 10'd180) 
					ns = S1;
				else ns = S2;
			end
		S2: begin
			ns = S2;
		end
		//S3: begin
		//
		//end
		default: ns = S0;
	endcase

	assign shapes[0] = (state == S0);
	assign shapes[1] = (state == S1);


	endmodule