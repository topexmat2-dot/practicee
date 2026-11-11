module traffic_light_controller (
    input  wire       clk,
    input  wire       rst_n,
    output reg [2:0]  light_a,
    output reg [2:0]  light_b
  );

 // One-hot state encodings (4 states)
    parameter S1_AG_BR = 4'b0001; // A-Green (4 ticks), B-Red (5 ticks)
    parameter S2_AY_BR = 4'b0010; // A-Yellow (1 tick), B-Red
    parameter S3_AR_BG = 4'b0100; // A-Red (5 ticks), B-Green (4 ticks)
    parameter S4_AR_BY = 4'b1000; // A-Red, B-Yellow (1 tick)

  reg [3:0] state, next_state;
  reg [2:0] timer;

  // State Register & Timer Logic
  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      state <= S1_AG_BR;
      timer <= 3'd0;
    end
    else
    begin
      if (state != next_state)
      begin
        state <= next_state;
        timer <= 3'd0; // Reset timer on transition
      end
      else
      begin
        timer <= timer + 3'd1;
      end
    end
  end

  // Next State Logic & Timing Constraints
  // Green = 4 clock ticks (0 to 3), Yellow = 1 tick (0), Red = 5 ticks total
  always @(*)
  begin
    next_state = state;

    case (state)
      S1_AG_BR:
      begin
        if (timer == 3'd3) // 4 clock cycles
          next_state = S2_AY_BR;
      end
      S2_AY_BR:
      begin
        if (timer == 3'd0) // 1 clock cycle
          next_state = S3_AR_BG;
      end
      S3_AR_BG:
      begin
        if (timer == 3'd3) // 4 clock cycles
          next_state = S4_AR_BY;
      end
      S4_AR_BY:
      begin
        if (timer == 3'd0) // 1 clock cycle
          next_state = S1_AG_BR;
      end
      default:
        next_state = S1_AG_BR;
    endcase
  end

  // Moore Output Logic (Outputs depend exclusively on the current state)
  always @(*)
  begin
    // Format: {Red, Yellow, Green}
    light_a = 3'b000;
    light_b = 3'b000;

    case (state)
      S1_AG_BR:
      begin
        light_a = 3'b001; // Green
        light_b = 3'b100; // Red
      end
      S2_AY_BR:
      begin
        light_a = 3'b010; // Yellow
        light_b = 3'b100; // Red
      end
      S3_AR_BG:
      begin
        light_a = 3'b100; // Red
        light_b = 3'b001; // Green
      end
      S4_AR_BY:
      begin
        light_a = 3'b100; // Red
        light_b = 3'b010; // Yellow
      end
      default:
      begin
        light_a = 3'b100;
        light_b = 3'b100;
      end
    endcase
  end

endmodule
