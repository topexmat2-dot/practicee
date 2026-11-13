module sync_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
  )(
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 wr_en,
    input  wire                 rd_en,
    input  wire [WIDTH-1:0]     din,
    output reg  [WIDTH-1:0]     dout,
    output wire                 full,
    output wire                 empty,
    output wire                 half_full,
    output reg  [$clog2(DEPTH):0] count
  );

  // Local parameters for pointer widths (extra bit for wrap-around detection)
  localparam ADDR_WIDTH = $clog2(DEPTH);

  // Memory array declaration
  reg [WIDTH-1:0] mem [DEPTH-1:0];

  // Read and Write Pointers
  reg [ADDR_WIDTH-1:0] wr_ptr;
  reg [ADDR_WIDTH-1:0] rd_ptr;

  // Flag logic assignments
  assign empty     = (count == 0);
  assign full      = (count == DEPTH);
  assign half_full = (count >= (DEPTH / 2));

  // Write Pointer & Count Logic
  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      wr_ptr <= {ADDR_WIDTH{1'b0}};
    end
    else if (wr_en && !full)
    begin
      mem[wr_ptr] <= din;
      wr_ptr      <= wr_ptr + 1'b1;
    end
  end

  // Read Pointer Logic
  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      rd_ptr <= {ADDR_WIDTH{1'b0}};
      dout   <= {WIDTH{1'b0}};
    end
    else if (rd_en && !empty)
    begin
      dout   <= mem[rd_ptr];
      rd_ptr <= rd_ptr + 1'b1;
    end
  end

  // FIFO Occupancy Counter Logic (Handles simultaneous read and write safely)
  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      count <= {(ADDR_WIDTH+1){1'b0}};
    end
    else
    begin
      case ({wr_en && !full, rd_en && !empty})
        2'b10:
          count <= count + 1'b1; // Write only
        2'b01:
          count <= count - 1'b1; // Read only
        default:
          count <= count;      // Neither or simultaneous read/write
      endcase
    end
  end

endmodule
