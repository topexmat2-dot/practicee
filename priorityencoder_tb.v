module priority_encoder_tb;
  reg [7:0] din;
  wire [2:0] dout;
  wire valid;

  priority_encoder_8to3 uut (
                          .din(din),
                          .dout(dout),
                          .valid(valid)
                        );

  initial
  begin
    // Test cases
    $dumpfile("wave.vcd");
    $dumpvars(0, priority_encoder_tb);
    din = 8'b00000000;
    #10;
    din = 8'b00000001;
    #10;
    $display("din = %b, dout = %b, valid = %b", din, dout, valid);
    din = 8'b00000010;
    #10;
    $display("din = %b, dout = %b, valid = %b", din, dout, valid);
    din = 8'b00000100;
    #10;
    $display("din = %b, dout = %b, valid = %b", din, dout, valid);
    din = 8'b00001000;
    #10;
    $display("din = %b, dout = %b, valid = %b", din, dout, valid);
    din = 8'b00010000;
    #10;
    $display("din = %b, dout = %b, valid = %b", din, dout, valid);
    din = 8'b00100000;
    #10;
    $display("din = %b, dout = %b, valid = %b", din, dout, valid);
    din = 8'b01000000;
    #10;
    $display("din = %b, dout = %b, valid = %b", din, dout, valid);
    din = 8'b10000000;
    #10;
    $display("din = %b, dout = %b, valid = %b", din, dout, valid);
    din = 8'b11111111;
    #10;
    $display("din = %b, dout = %b, valid = %b", din, dout, valid);
    $finish;
  end
endmodule
