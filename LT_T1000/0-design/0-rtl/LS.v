//Verilog HDL for "Tesla", "Lvshift_1p8to3p3" "functional"


module Lvshift_1p8to3p3 ( A, AGND, AVDD, DGND, DVDD, PD, Y );

  input DGND;
  input A;
  input AGND;
  output Y;
  input PD;
  input DVDD;
  input AVDD;

assign Y =  PD ? 1'b0 : A;

endmodule

//Verilog HDL for "Tesla", "Lvshift_3p3to1p8" "functional"


module Lvshift_3p3to1p8 ( A, DGND, DVDD, Y );

  input DGND;
  input A;
  output Y;
  input DVDD;

assign Y = A;

endmodule
