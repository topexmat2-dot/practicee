module universal_shift_register (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [1:0] mode,
    input  wire       d_serial,
    input  wire [7:0] data_in,
    input  wire       load,
    output reg  [7:0] data_out,
    output wire       q_serial
  );

  reg [7:0] shift_reg;

  assign q_serial = shift_reg[0];

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      shift_reg <= 8'b00000000;
    end
    else
    begin
      case (mode)
        2'b00:
        begin // SISO: Serial-In, Serial-Out (Shift Right)
          shift_reg <= {d_serial, shift_reg[7:1]};
        end
        2'b01:
        begin // SIPO: Serial-In, Parallel-Out (Shift Right)
          shift_reg <= {d_serial, shift_reg[7:1]};
        end
        2'b10:
        begin // PISO: Parallel-In, Serial-Out
          if (load)
            shift_reg <= data_in;
          else
            shift_reg <= {1'b0, shift_reg[7:1]};
        end
        2'b11:
        begin // PIPO: Parallel-In, Parallel-Out
          shift_reg <= data_in;
        end
        default:
        begin
          shift_reg <= shift_reg;
        end
      endcase
    end
  end

  always @(*)
  begin
    data_out = shift_reg;
  end

endmodule
