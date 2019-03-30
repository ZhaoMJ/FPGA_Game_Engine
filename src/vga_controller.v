// Modified from ECE385 code.
module  VGA_controller (input              Reset,       // Active-high reset signal
                        output    reg    VGA_HS, VGA_VS,      // Sync signals. Active low
                        input              VGA_CLK,     // 25 MHz VGA clock input
                        output  [9:0] draw_x, draw_y        // vertical coordinate
                        );

    // 800 pixels per line (including front/back porch)
    // 525 lines per frame (including front/back porch)
    parameter [9:0] H_TOTAL = 10'd799; //800 - 1
    parameter [9:0] V_TOTAL = 10'd524; //525 - 1

    wire VGA_HS_in, VGA_VS_in, VGA_BLANK_N_in;
    reg [9:0] h_counter, v_counter;
    wire [9:0] h_counter_in, v_counter_in;

    reg VGA_BLANK_N;
    wire VGA_SYNC_N;

    assign VGA_SYNC_N = 1'b0;
    assign draw_x = h_counter;
    assign draw_y = v_counter;

    // VGA control signals.
    // VGA_CLK is generated by PLL, so you will have to manually generate it in simulation.
    always @ (posedge VGA_CLK) begin
        if (Reset)
        begin
            VGA_HS <= 1'b1;
            VGA_VS <= 1'b1;
            VGA_BLANK_N <= 1'b0;
            h_counter <= 10'd0;
            v_counter <= 10'd0;
        end else begin
            if (h_counter == 10'd15) begin
                VGA_HS <= 1'b0;
                if (v_counter == 10'd10)
                    VGA_VS <= 1'b0;
                if (v_counter == 10'd12)
                    VGA_VS <= 1'b1;
            end
            if (h_counter == 10'd111)
                VGA_HS <= 1'b1;
            VGA_BLANK_N <= VGA_BLANK_N_in;
            h_counter <= h_counter_in;
            v_counter <= v_counter_in;
        end
    end

    // horizontal and vertical counter
    wire eol_flag = (h_counter == H_TOTAL);
    wire eof_flag = (v_counter == V_TOTAL);
    wire [9:0] incremented_h_counter = h_counter + 10'd1;
    mux2v #(10) h_counter_mux(.out(h_counter_in), .A(incremented_h_counter), .B(10'd0), .sel(eol_flag));

    wire [9:0] incremented_v_counter = v_counter + 10'd1;
    wire [9:0] eof_v_mux_out;
    mux2v #(10) eol_v_mux(.out(v_counter_in), .A(v_counter), .B(eof_v_mux_out), .sel(eol_flag));
    mux2v #(10) eof_v_mux(.out(eof_v_mux_out), .A(incremented_v_counter), .B(10'd0), .sel(eof_flag));
endmodule