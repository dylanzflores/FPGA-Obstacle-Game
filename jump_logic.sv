	module jump_logic(input  logic clk, reset, en,
					output logic [9:0] out);
	logic stop;
	jumpDelay j(clk, reset, enCount, out, stop);
	jumpFSM jf(clk, reset, en, stop, enCount);
		
	endmodule
	
	module jumpDelay(input logic clk, reset, enCount,
						output logic [9:0] out,
						output logic stop);
	logic done = 0;
	
	always_ff @ (posedge clk, posedge reset) begin
		if(reset) begin
			out <= 10'd0;
			stop <= 1'b0;
		end
		else if(enCount == 1 & ~reset) begin
				if(done == 0) begin
					out <= out + 10;
					stop <= 0;
					if(out == 100) done = 1;
					else done = 0;
				end
				else if(done == 1) begin
					out <= out - 10;
					if(out == 0) begin
						stop = 1;
						done = 0;
					end
					else begin
						stop = 0;
						done = 1;
					end
				end
			end
		else out <= 0;
		end
	endmodule
	
	module jumpFSM(input logic clk, reset, en, stop,
						output logic enCount);
		typedef enum logic {S0, S1} statetype;
		statetype state, ns;
		
		always_ff @ (posedge clk, posedge reset) begin
			if(reset) state <= S0;
			else state <= ns;
		end
		
		always_comb
		case(state)
		S0: begin
					if(en) ns = S1; // jump
					else ns = S0; // not jumping
				end
		S1: begin
					if(stop == 1) ns = S0;
					else ns = S1;
				end
		default: ns = S0;
		endcase
		
		assign enCount = (state == S1);
	endmodule
