module vga(input  logic clk, game_clk, reset, playerLost, playerWon, menuScreen,
			  input logic [9:0] distance,
			  output logic win, dead,
           output logic vgaclk,          // 25.175 MHz VGA clock 
           output logic hsync, vsync, 
           output logic sync_b, blank_b, // to monitor & DAC 
           output logic [7:0] r, g, b);  // to video DAC 
			  
  logic [9:0] x, y; 
  always_ff @(posedge clk, posedge reset)
    if (reset)
	   vgaclk = 1'b0;
    else
	   vgaclk = ~vgaclk;
		
  // generate monitor timing signals 
  vgaController vgaCont(vgaclk, reset, hsync, vsync, sync_b, blank_b, x, y); 

  // user-defined module to determine pixel color 
  videoGen videoGen1(x, y, clk, distance, reset, game_clk, playerLost, playerWon, menuScreen, r, g, b, win, dead); 

endmodule 

module videoGen(input logic [9:0] x, y, clk, distance,
					 input logic reset, game_clk, playerLost, playerWon, menuScreen,
					 output logic [7:0] r, g, b,
					 output logic win, dead); 

  logic obs[10:0], player, gnd, mb1; 						//Top Left Top Edge  Top Right Bottom Edge
  logic [9:0] player_right_loc, player_bottom_loc;
  logic [7:0] r_red, r_blue, r_green;
  assign player_right_loc = 10'd250;
  assign player_bottom_loc = 10'd400 - distance;
   sqGen mainSq(x, y, 10'd220, 10'd360 - distance, player_right_loc, player_bottom_loc, player); // main player square character
   logic [9:0] counter_black = 0;
	logic [10:0] game_time = 0;
  always_ff @ (posedge game_clk, posedge reset) begin
		if(reset) begin
			counter_black <= 0;
			game_time = 0;
		end
		else begin
			if(counter_black == 10'd620)
				counter_black <= 10'd0;
			else
				counter_black<= counter_black + 10;
			if(game_time == 10'd100) begin
				win <= 1;
				dead <= 0;
				game_time <= 0;
			end
			else if(win == 1) win <= 0;
			else begin
				win <= 0;
				game_time <= game_time + 1;
			end
		end
  end
  sqGen black_square(x, y, 10'd650 - counter_black, 10'd360, 10'd680 - counter_black, 10'd400, obs[0]); 
  sqGen black_square2(x, y, 10'd620- counter_black, 10'd360, 10'd650 - counter_black, 10'd400, obs[1]); 
  //trigen tr(x, y, 10'd650, 10'd360, 10'd680, 10'd400, game_clk, reset, obs[2]); 
   trigen tr(y[8:3], x[2:0], y[2:0], obs[2]); 
  movingBackground b1(x, y, 10'd850, 10'd360, 10'd680, 10'd400, game_clk, reset, mb1);
  sqGen ground(x, y, 10'd20, 10'd400, 10'd700, 10'd500, gnd); // level for player
  // left, top, right, bot
  // Display shapes
  always_ff @(posedge clk) begin		
	/*if(player_right_loc == 10'd620 - counter_black) begin
		//dead <= 1;
	end
	if(menuScreen == 1) begin
		r_red = 8'h00;
		r_green = 8'h00;
		r_blue = 8'h00;
	end
	else if(playerWon == 1) begin
		r_red = 8'h00;
		r_green = 8'hFF;
		r_blue = 8'h00;
	end
	else begin
	*/	
	if(player) begin // player
	   r_red = 8'hFF;
		r_green = 8'h00;
		r_blue = 8'h00;
	 end
	 else if(!player) begin // background
		r_red = 8'h72;
		r_green = 8'h09;
		r_blue = 8'hAA;
	 end
	 
	 // Moving background obstacle appears as a challenge
	if(mb1) begin
		r_red = 8'h0A;
		r_green = 8'h13;
		r_blue = 8'h81;
	end
	
	else if(obs[0]) begin // obstacle 1
		r_red = 8'h00;
		r_green = 8'h00;
		r_blue = 8'h00;
	 end
	 else if(obs[1]) begin // obstacle 2
		r_red = 8'hFF;
		r_green = 8'hFF;
		r_blue = 8'hFF;
	 end
	 else if(obs[2]) begin
		r_red = 8'h0A;
		r_green = 8'h13;
		r_blue = 8'h81;
	end
	 else if(gnd) begin
		r_red = 8'h00;
		r_green = 8'h00;
		r_blue = 8'h00;
	 end
	end
  //end
  
  assign r = r_red;
  assign b = r_blue;
  assign g = r_green;

endmodule

/*module trigen(input  logic [9:0] x, y, left, top, right, bot, 
					input logic clk, reset,
               output logic shape);
  logic [9:0] c = 0;
  
  always_ff @(posedge clk, posedge reset) begin
	if(reset)  
		c = 0;
	else if(c >= top) c <= 0;
	else
		c <= c + 1;
		
  end

	assign shape = x > left & x < right & (y > c + bot) & y < top;//(x > left + changeShape & x < (right - changeShape) ) & (y > changeShape & (y < top));
	

endmodule 
*/
module trigen(input  logic [29:0] ch, 
               input  logic [9:0] xoff, yoff,  
               output logic       trian); 

  logic [30:0] tria[2047:0]; // character generator ROM 
  logic [29:0] line;            // a line read from the ROM 

  // initialize ROM with characters from text file 
  initial $readmemb("triangle.txt", tria); 

  // index into ROM to find line of character 
  assign line = tria[yoff+{ch, 3'b000}];  // subtract 65 because A 
                                                // is entry 0 
  // reverse order of bits 
  assign trian = line[3'd29-xoff]; 
  
endmodule 



module movingBackground(input  logic [9:0] x, y, left, top, right, bot, 
					input logic clk, reset,
               output logic shape);
  logic [9:0] make = 0;
  
  always_ff @(posedge clk, posedge reset) begin
	if(reset) 
		make = 0;
	else if(make >= 10'd450) make <= 0;
	else begin
		make <= make + 1;
	end
  end

	always_comb begin
		if( (x + make) >= left)
			shape = 1;
		else shape = 0;
	end
	

endmodule 

module sqGen(input  logic [9:0] x, y, left, top, right, bot, 
               output logic shape);
  assign shape = (x > left & x < right &  y > top & y < bot); 
endmodule 
	
module vgaController #(parameter HBP     = 10'd48,   // horizontal back porch
                                 HACTIVE = 10'd640,  // number of pixels per line
                                 HFP     = 10'd16,   // horizontal front porch
                                 HSYN    = 10'd96,   // horizontal sync pulse = 96 to move electron gun back to left
                                 HMAX    = HBP + HACTIVE + HFP + HSYN, //48+640+16+96=800: number of horizontal pixels (i.e., clock cycles)
                                 VBP     = 10'd32,   // vertical back porch
                                 VACTIVE = 10'd480,  // number of lines
                                 VFP     = 10'd11,   // vertical front porch
                                 VSYN    = 10'd2,    // vertical sync pulse = 2 to move electron gun back to top
                                 VMAX    = VBP + VACTIVE + VFP  + VSYN) //32+480+11+2=525: number of vertical pixels (i.e., clock cycles)                      

     (input  logic vgaclk, reset,
      output logic hsync, vsync, sync_b, blank_b, 
      output logic [9:0] hcnt, vcnt); 

      // counters for horizontal and vertical positions 
      always @(posedge vgaclk, posedge reset) begin 
        if (reset) begin
          hcnt <= 0;
          vcnt <= 0;
        end
        else  begin
          hcnt++; 
      	   if (hcnt == HMAX) begin 
            hcnt <= 0; 
  	        vcnt++; 
  	        if (vcnt == VMAX) 
  	          vcnt <= 0; 
          end 
        end
      end 
	  
      // compute sync signals (active low)
      assign hsync  = ~( (hcnt >= (HBP + HACTIVE + HFP)) & (hcnt < HMAX) ); 
      assign vsync  = ~( (vcnt >= (VBP + VACTIVE + VFP)) & (vcnt < VMAX) ); 

      // assign sync_b = hsync & vsync; 
      assign sync_b = 1'b0;  // this should be 0 for newer monitors

      // force outputs to black when not writing pixels
      assign blank_b = (hcnt > HBP & hcnt < (HBP + HACTIVE)) & (vcnt > VBP & vcnt < (VBP + VACTIVE)); 
endmodule 
