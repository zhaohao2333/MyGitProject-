// efuse driver for SMIC EFUSE Macro Cell S018V3EBCDEFUSE_SISO32B3M
//
// 5/23/2021 by felix
//
// Note and How to use, DO READ CAREFULLY before get into use:
// 1. input clk: 25M osc clk, rst_n: asynchronous rst, valid low, should be synchronously released with clk_osc
// 2. read_start / prog start will start one read/program transition, deassert start signal after ack(see note3)
// 3. read_ack and prog_ack signal will be asserted for one cycle once start signal is accepted
// 4. in prog mode, efuse_din should be valid with start pulse, make sure this signal valid til ack arrives
// 5. it takes "330us" to program, and "41 us" to read, do not send repeated start when the previous one is in-the-flight.


module efuse_driver(
// 25M osc_clk and reset
input wire clk,
input wire rst_n,

// read and program start pulse
input wire read_start,  
output logic read_ack,  // last for one clock cycle
output logic [31:0] dout,
output logic dout_valid,    // valid for one clock cycle

input  wire [31:0] efuse_din,       // valid with start pulse, make sure this data valid until ack
input  wire prog_start,           
output logic prog_ack,              // last for one cycle

// interface with efuse Macro
output logic EFUSE_CS,
output logic EFUSE_PGM,
output logic EFUSE_SCLK,
output logic EFUSE_RW,
input  wire  EFUSE_DOUT
);

localparam IDLE=2'h0;
localparam READ=2'h1;
localparam PROG=2'h2;

logic [1:0] cur_state;
logic [1:0] next_state;

logic [12:0] cnt; //13 bit counter for program/read
logic [1:0] rd_smp;     // read sync reg
logic [1:0] prg_smp;    // prog sync reg
logic [1:0] dout_smp;    // dout sync reg
logic [31:0] prg_dat;   // prog data after sync
logic [31:0] read_dat;  // read data from DOUT
logic prg_en;           // program enable signal
logic cnt_done;         // counter done signal 
logic cs_reg;           // cs driver
logic clk_reg;          // clk driver
/************************** RTL begins here **************************/

// sync reg drive
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rd_smp<='0;
        prg_smp<='0;
        dout_smp<='0;
    end else begin
        rd_smp  <=  {rd_smp[0],read_start};
        prg_smp <=  {prg_smp[0],prog_start};
        dout_smp<=  {dout_smp[0],EFUSE_DOUT};
    end
end

// state drive
always_ff@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        cur_state <= IDLE;
    end else begin
        cur_state <= next_state;
    end
end

// state transition
always_comb begin
    case(cur_state)
        IDLE: next_state =  rd_smp[1] ? READ:
                            prg_smp[1] ? PROG:
                            IDLE;
        READ: next_state = cnt_done ? IDLE : READ;
        PROG: next_state = cnt_done ? IDLE : PROG;
        default : next_state = IDLE;
    endcase
end

// control counter / dat signal ctrl
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt<='0;
        prg_dat<='0;
        read_dat<='0;
        cs_reg<='0;
        clk_reg<='0;
    end else begin
        // counter drive
        if (|cur_state)begin // if cur_state == READ or PROG
            cnt <= cnt +1'b1;
        end else begin
            cnt <='0; 
        end
        // prog reg drive
        if(prg_smp[1]) begin
            prg_dat<=efuse_din;
        end else if(&cnt[7:0]) begin // if cnt=8'1, then shift prg_dat
            prg_dat <= prg_dat>>1;
        end

        // read reg drive
        if(cnt[4:0]==5'b10000 && cur_state == READ)begin
            read_dat <= {EFUSE_DOUT,read_dat[31:1]};
        end

        // cs drive 
        if(cnt[12:0]==13'h2) begin
            cs_reg<=1'b1;
        end else if(cnt==13'h1ffd) begin
            cs_reg<=1'b0;
        end

        // sclk driver 
        if(cnt[7:0]==8'h4) begin
            clk_reg<=1'b1;
        end else if(cnt[7:0]==8'hfa)begin
            clk_reg<=1'b0;
        end

    end
end

// output drive
always_comb begin
    prg_en = prg_dat[0] && ( cnt[7:0] == 8'd4 || cnt[7:0] == 8'd5) ;  // PGM =1 and cnt % 256 == 3,4, hold for 2 cycle
    prog_ack = {cur_state , next_state} == 4'h2; // cur = IDLE, next = PROG, one cycle pulse 
    read_ack = {cur_state , next_state} == 4'h1; // cur = IDLE, next = READ, one cycle pulse
    cnt_done =  cur_state == PROG ? &cnt :  // in prog mode, cnt done after 256 * 32 cycle 
                cur_state == READ ? &cnt[9:0] :'0;        // in read mode, cnt done after 16 * 2 * 32 cycle
    dout = read_dat;
    dout_valid = {cur_state , next_state} == 4'h4; // cur = READ, next=IDLE;

    EFUSE_RW = cur_state[1] ; // current state == PROG, one hot 
    EFUSE_CS = cur_state == PROG ? cs_reg   :// in prog mode,  if cnt > 2, assert CS
               cur_state == READ ? 1'b1             : 0 ;
    EFUSE_SCLK = cur_state == PROG ? clk_reg   :// in prog mode, if cnt % 256 > 4, then assert SCLK
                 cur_state == READ ? ((cnt[4:0]>2)&&(cnt[4:0]<19)) : 0 ;
    EFUSE_PGM  = cur_state == PROG ? prg_en : 0;

end

endmodule 