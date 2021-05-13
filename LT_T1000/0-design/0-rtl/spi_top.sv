`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/03 19:24:49
// Design Name: 
// Module Name: SPI_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SPI_top 
#(parameter MAX_WIDTH=24,IN_WIDTH=8)    // 3*20+15
(   
    // clk and rst
        input  wire                     clk,rst_n,      // internal 250M clk and rst 
    
    // SPI Output Data Interface
        // input  wire  [1:0]              SPI_Onum,       // SPI Output raw Data number, from 0~3
        input  wire  [MAX_WIDTH-1:0]    SPI_Odata,      // SPI Output Data, from core logic [Raw, Peak]
        output logic                    SPI_Odstart,    // SPI Output Data start pulse

    // SPI Reg Interface
        //write
        output logic  [IN_WIDTH-1:0]    SPI_Irreg,      // SPI write reg Data, to core logic
        output logic                    SPI_Irvalid,    // SPI write reg&add valid, to core logic 
        input  wire                     SPI_Irready,    // SPI write reg ready, from core logic 
        //read
        output logic [7:0]              SPI_Iadd,       // SPI register read/write Address, to core logic 
        input  wire  [IN_WIDTH-1:0]     SPI_Oreg,       // SPI register read Data, from core logic
        output logic                    SPI_Orreq,      // SPI register read request, to core logic
        input  wire                     SPI_Orvalid,    // SPI register read valid, from core logic

    // External SPI Interface
        input  wire                     SPI_CS,         
        input  wire                     SPI_CLK,        
        input  wire                     SPI_MOSI,       //CMD[0], 0 for write, 1 for read
        output logic                    SPI_MISO,
        output logic                    MISO_OEN        
);      
        // FSM State parameter definition
        localparam IDLE     =4'h0;
        localparam OUT_DATA =4'h1;
        localparam IN_CMD   =4'h2;
        localparam IN_REG   =4'h4;
        localparam OUT_REG  =4'h8;
        
        // External signal synchronization
        logic [2:0] MOSI_reg;
        logic [2:0] CLK_reg;
        logic [2:0] CS_reg;
        logic SCLK_rise,SCLK_fall;
        logic CS_fall,CS_rise;

        // FSM Declaration
        logic [3:0] cur_state;
        logic [3:0] next_state;

        // SPI output data buffer and valid
        logic [MAX_WIDTH-1:0]  out_buf;
        logic dat_valid;
        
        // SPI input reg  buffer
        logic [7:0] CMD_reg;    // 0 for write, 1 for read
        logic [7:0] DATA_reg;
        logic read_Reg_hs;       // read register handshake
        logic write_Reg_hs;      // write register handshake

        // SCLK counter instantiation, mod = RAW_WIDTH + PEAK_WIDTH
        logic cntdat_rstn,cntdat_en;
        logic [4:0] cnt_data;
        logic cntreg_oen;   // 24 bit at total
        logic cntcmd_oen;   // 16 bit at total
        logic cntdat_oen;   // vary from onum

        // output data width computation
        // logic  [6:0] shift_width;
        
        // OUTPUT DATA Transition Signal
        // logic OUTD_end;      

/*---------------------------------------RTL begins here-------------------------------------*/
//===========================================================================================//

        always_comb begin
             // OUTD_end=!SPI_CS|cntdat_oen;
             read_Reg_hs=SPI_Orreq&SPI_Orvalid;
             write_Reg_hs=SPI_Irvalid&SPI_Irready;
             SPI_Irreg=DATA_reg;
            //  case(SPI_Onum)
            //     2'b1:shift_width=7'd35;
            //     2'd2:shift_width=7'd55;
            //     2'd3:shift_width=7'd75;
            //     default:shift_width=7'd75;
            //     endcase
        end
        
        // SPI singal synchronization
        always_ff@(posedge clk or negedge rst_n)begin 
            if(!rst_n) begin
                MOSI_reg<=3'b0;
                CLK_reg<=3'b0;
                CS_reg<=3'b0;
            end
            else begin
                MOSI_reg<={MOSI_reg[1:0],SPI_MOSI};
                CLK_reg <={CLK_reg[1:0],SPI_CLK};
                CS_reg  <={CS_reg[1:0],SPI_CS};
            end
        end
        
        // state drive
        always_ff@(posedge clk or negedge rst_n)begin
            if(!rst_n)
                cur_state<=IDLE;
            else begin
                cur_state<=next_state;
            end
        end

        // state transition
        always_comb begin
            case(cur_state)
                IDLE: begin
                    // next_state=CS_rise?OUT_DATA:CS_fall?IN_CMD:IDLE;
                    // if(CS_rise)         next_state=OUT_DATA;
                    // else if (CS_fall)   next_state=IN_CMD;
                    if(CS_fall)         next_state=IN_CMD;
                    else                next_state=IDLE;
                end
                OUT_DATA:begin
                    if (CS_rise|cntdat_oen)        next_state=IDLE;
                    // else if (OUTD_end)  next_state=IDLE;
                    else                next_state=OUT_DATA;
                    // next_state=(OUTD_end|CS_fall)?IDLE:OUT_DATA;
                end
                IN_CMD:begin
                    if (CS_rise)        next_state=IDLE;
                    else if(cntcmd_oen)  next_state=(CMD_reg==8'ha2) ? IN_REG :
                                                     (CMD_reg==8'ha3) ? OUT_REG : OUT_DATA;
                    else                next_state=IN_CMD;
                end
                IN_REG:begin
                    if (CS_rise|cntreg_oen)        next_state=IDLE;
                    // else if (cntreg_oen) next_state=IDLE;
                    else                next_state=IN_REG;
                end
                OUT_REG:begin
                    if (CS_rise|cntreg_oen)        next_state=IDLE;
                    // else if (cntreg_oen) next_state=IDLE;
                    else                next_state=OUT_REG;
                end
                default:next_state=IDLE;
            endcase
        end

        // SPI read/write reg buffer drive
        always_ff@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                CMD_reg<=8'b0;
                SPI_Iadd<=8'b0;
                DATA_reg<=8'b0;
            end
            else begin
                if (cur_state==IN_CMD&SCLK_rise) begin
                    if (cnt_data[3]) SPI_Iadd<={SPI_Iadd[6:0],MOSI_reg[2]};
                    else             CMD_reg<={CMD_reg[6:0],MOSI_reg[2]};
                end
                
                if (read_Reg_hs) begin
                    DATA_reg<=SPI_Oreg;
                end
                else if(cur_state==IN_REG&SCLK_rise)begin
                    DATA_reg<={DATA_reg[6:0],MOSI_reg[2]};
                   
                end
                else if(cur_state==OUT_REG&SCLK_rise)begin
                    DATA_reg<=DATA_reg<<1;
                end
            end
        end
        // SPI write/read request signal drive
        always_ff@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                SPI_Orreq<=1'b0;
                SPI_Irvalid<=1'b0;
            end
            else begin
                //read register IN_CMD state=4'h2, 
                if(cntcmd_oen&cur_state[1]&(CMD_reg==8'ha3))begin
                    SPI_Orreq<=1'b1;
                end
                else if(read_Reg_hs) begin
                    SPI_Orreq<=1'b0;
                end
//                if(cntcmd_oen&cur_state==IN_CMD)begin
//                    if(!CMD_reg[0]) begin
//                        SPI_Orreq<=1'b1;
//                    end
//                end
                //else if (read_Reg_hs) SPI_Orreq<=1'b0;
                //write register
                if(cntreg_oen&&cur_state==IN_REG)  SPI_Irvalid<=1'b1;
                else if (write_Reg_hs) SPI_Irvalid<=1'b0;
            end
        end
       
        // SPI output data buffer drive
        always_ff@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                out_buf<='0;
                SPI_Odstart<=1'b0;
            end
            else begin
                // SPI output buf
                if(CS_fall) begin 
                    out_buf<=SPI_Odata;
                    SPI_Odstart<=1'b1;
                end
                else if(SCLK_fall&&(cur_state[0]|cur_state[1])) begin
                    out_buf<=out_buf<<1'b1;
                end
                else if(CS_rise) begin
                    out_buf<='0;
                end
                // self-reset Odstart
                if(SPI_Odstart) SPI_Odstart<=1'b0; 
            end
        end

        //  counter driver
        always_comb begin
            SCLK_rise=CLK_reg[2:1]==2'b01;
            SCLK_fall=CLK_reg[2:1]==2'b10;
            CS_fall=CS_reg[2:1]==2'b10;
            CS_rise=CS_reg[2:1]==2'b01;
            
            // counter data driver 
            cntdat_rstn=!CS_fall&!CS_rise&rst_n;
            cntdat_en=SCLK_rise&(cur_state!=IDLE); 
            
            // counter data reused as counter reg and cmd
            cntreg_oen=cntdat_en&(cnt_data==5'd23);
            cntcmd_oen=cntdat_en&(cnt_data==5'd15);
            cntdat_oen=cntdat_en&(cnt_data==5'd23);
        end

        //  MISO driver
        always_comb begin
            SPI_MISO=cur_state[3]? DATA_reg[7]:
                     cur_state[0]|cur_state[1]? out_buf[MAX_WIDTH-1]:1'b0;
            // MISO_OEN=cur_state==OUT_REG? 1'b0:1'b1;
            MISO_OEN=(cur_state==IDLE)|SPI_CS;
//            case(cur_state) // 
//                OUT_REG:    SPI_MISO=DATA_reg[7];
//                OUT_DATA:   SPI_MISO=out_buf[MAX_WIDTH-1];
//                IDLE:       SPI_MISO=1'b0;
//                default:    SPI_MISO=1'b0;
//            endcase
       end

    counterM #(.cnt_mod(MAX_WIDTH)) cntclk
	(
	.clk(clk),
	.rst_n(cntdat_rstn),
	.cnt_en(cntdat_en),
	.cntout(cnt_data),
	.cout_en()
	);

endmodule 

module counterM #(parameter cnt_mod=10)
	(
	input wire clk,
	input wire rst_n,
	input wire cnt_en,
	output reg [$clog2(cnt_mod)-1:0]cntout,
	output wire cout_en
	);
	assign cout_en=cnt_en&&(cntout==cnt_mod-1'b1);
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
		cntout<=0;
		else if(cnt_en)begin
                if(cntout==cnt_mod-1'b1) begin
                 cntout<=0;
                end
                else cntout<=cntout+1'b1;
		end
	end
endmodule

