module decoder (
    input  wire [31:0]  decode_in,
    output wire [4 :0]  decode_out        
);


wire     [31:0]  norbuf;
wire     [7 :0]  sel1;
wire     [3 :0]  sel2;
wire     [1 :0]  sel3;


assign norbuf = decode_in ^ {decode_in[0], decode_in[31:1]};
assign decode_out[4] = decode_in[16];

assign sel1 = (norbuf[15:8] == 0) ? norbuf[7:0] : norbuf[15:8];
assign decode_out[3] = (norbuf[15:8] == 0);

assign sel2 = (sel1[7:4] == 0) ? sel1[3:0] : sel1[7:4];
assign decode_out[2] = (sel1[7:4] == 0);

assign sel3 = (sel2[3:2] == 0) ? sel2[1:0] : sel2[3:2];
assign decode_out[1] = (sel2[3:2] == 0);

assign decode_out[0] = (sel3[1] == 0);

endmodule