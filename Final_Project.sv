module Final_Project(input logic CLOCK_50, SW[1:0], KEY[1:0],
                                inout  logic [4:0] GPIO,
                                output logic       VGA_CLK, 
                                output logic       VGA_HS,
                                output logic       VGA_VS,
                                output logic       VGA_SYNC_N,
                                output logic       VGA_BLANK_N,
                                output logic [7:0] VGA_R,
                                output logic [7:0] VGA_G,
                                 output logic [7:0] VGA_B);
        // SW[0] = reset, SW[1] = switch clockspeed enable, KEY[0] = player control to jump                        
        logic game_clk, jump, reset_obj_count, fallingSq;
        logic victoryScreen, menuScreen, playerDeath;
        logic [9:0] distance;
        logic [9:0] obj_position_counter;
        logic [10:0] game_time;
        logic shapes[6:0];
        assign GPIO[1] = GPIO[0];
        assign GPIO[2] = GPIO[0];
        
        levelLogic lm(CLOCK_50, SW[0], playerDeath, ~KEY[0], game_time, reset_obj_count, fallingSq, shapes, victoryScreen, menuScreen);
        counter_shapes c1(game_clk, reset, menuScreen, victoryScreen, playerDeath, reset_obj_count, obj_position_counter, game_time);
        slowClkHz hz24 (CLOCK_50, SW[0], game_clk);
        jump_logic j(game_clk, SW[0], ~KEY[0], fallingSq, distance);
        vga vgaDev(CLOCK_50, game_clk, SW[0], victoryScreen, menuScreen, shapes, distance, obj_position_counter, playerDeath, GPIO[4], VGA_CLK, VGA_HS, VGA_VS, VGA_SYNC_N, VGA_BLANK_N,
                    VGA_R, VGA_G, VGA_B);     
    endmodule