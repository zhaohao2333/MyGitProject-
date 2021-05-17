module reset_best(clk,asyn_resetn,syn_resetn);
input wire clk;
input wire asyn_resetn;
output logic syn_resetn;

reg rst_s1;
reg rst_s2;

always @( posedge clk or negedge asyn_resetn) begin 
if (! asyn_resetn )begin
	rst_s1<=1'b0; rst_s2<=1'b0;
end
else begin
	rst_s1<=1'b1; rst_s2<=rst_s1;
end
end
assign syn_resetn=rst_s2;

endmodule

module CLK_MUX (
    input wire OSC_CLK,     // External Oscillator clk
    input wire PLL_CLK,     // PLL clk
    input wire rstn_osc,    // rst sync with osc
    input wire rstn_pll,    // rst sync with pll
    input wire sel,         // CLK selector, 0 for OSC, 1 for PLL
    output logic OUT_CLK    // Output clk
);
    logic [1:0] ff1;
    logic [1:0] ff2;
    logic clk2;

    // divide 500M PLL_CLK by 2 
    always_ff@(posedge PLL_CLK or negedge rstn_pll)begin
        if(!rstn_pll)begin
            clk2<='0;
        end else begin
            clk2<=~clk2;
        end
    end

    // logic rst_n_osc;
    // logic rst_n_pll;

    //synchronize rst_n to OSC_CLK / PLL_CLK
    // reset_best sync_osc(OSC_CLK,asyn_resetn,rst_n_osc);
    // reset_best 

    always_ff@(posedge OSC_CLK or negedge rstn_osc)begin
        if(!rstn_osc) ff1<=2'b0;
        else begin
            ff1<={ff1[0],~ff2[1]&~sel};
        end
    end

    always_ff@(posedge clk2 or negedge rstn_pll)begin
        if(!rstn_pll) ff2<=2'b0;
        else begin
            ff2<={ff2[0],~ff1[1]&sel};
        end
    end

    assign OUT_CLK=(ff1[1]&OSC_CLK)|(ff2[1]&clk2);

endmodule 

module INPUT_BUF (
    input wire clk,
    input wire rst_n,

    // TDC Interface
    input wire TDC_Ovalid,
    //input wire TDC_Olast,
    input wire [2:0]  TDC_Onum,
    input wire [19:0] TDC_Calib,    // TDC 20bit Calibration
    input wire [18:0] TDC_Odata,
    output logic TDC_Oready,

    // Output to SPI Interface
    input wire SPI_Odstart,
    output logic [23:0] OUT,

    // Intrrupt
    output logic INT,
    output logic read_done,
    input  logic read_en
);
    // TDC Buffer
    logic TDC_full;
    logic [2:0]  readout_cnt;   // readout transition number cnt
    logic [1:0]  out_tag;
    logic [2:0]  onum_cnt;      // current tdc onumber
    logic [2:0]  TDC_cnt;
    logic [18:0] raw_buf1 [5];  // raw data buffer
    logic [18:0] raw_buf2 [5];  // raw data buffer, level 2


    // raw adder delay counter
    logic [5:0] TDC_valid_d; 
    //logic [2:0] adder_valid;
    logic [2:0] adder_cnt;
    //logic [2:0] raw_onum;
    logic signed [19:0]  cal_buf  [5];  // calibrated data buffer
    logic signed [19:0]  adda_buf [5];  // adder input data buffer
    logic signed [19:0]  calib;

    // valid delay driver
    always_ff@(posedge clk or negedge rst_n)begin
        if(!rst_n) begin //adder_cnt<=3'b0; cnt_en<=1'b0; counter_mod<=2'b0; adder_cnt<=3'b0;
           TDC_valid_d <= 0;
        end
        else begin
           TDC_valid_d <= {TDC_valid_d[4:0], TDC_Ovalid};
        end
    end

    // 20 bit fixed point adder for raw
    assign calib = TDC_Calib;
    generate 
       for(genvar i=0; i < 5 ; i++)begin: adder
           assign adda_buf[i] = {1'b0, raw_buf1[i]};
           assign cal_buf[i]  = calib + adda_buf[i];
       end
    endgenerate
    
    // TDC buffer drive
    always_ff@(posedge clk or negedge rst_n)begin
        if(!rst_n)  begin  
            TDC_cnt <= 0; 
            adder_cnt <= 0; 
            onum_cnt <= 0;
            raw_buf1 <= {19'b0,19'b0,19'b0,19'b0,19'b0};
            raw_buf2 <= {19'b0,19'b0,19'b0,19'b0,19'b0};
            //raw_onum <= 0;
        end 
        else begin
                TDC_cnt <= TDC_Ovalid ? TDC_cnt + 1'b1 : 2'b0;
                adder_cnt <= TDC_valid_d[2] ? adder_cnt + 1'b1 : 2'b0;
            if(TDC_Ovalid) begin //raw data drive
                //TDC_cnt<=TDC_cnt+1'b1;
                onum_cnt <= (TDC_Onum == 0) ? 2'b1 : TDC_Onum;
                raw_buf1[TDC_cnt] <= TDC_Odata;
            end
            else if(TDC_valid_d[2]) begin //calib data drive
                raw_buf2[adder_cnt] <= cal_buf[adder_cnt][18:0];
            end
        end
    end

    // ================= Output SPI_Data Control here ====================


    always_ff@(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            TDC_full <= 1'b0; 
            readout_cnt <= 1;
            read_done <= 0;
        end
        else begin 
            if(TDC_valid_d[5:4]==2'b10) begin 
                readout_cnt <= 0;
                TDC_full <= 1'b1;
                read_done <= 0;
            end 
            else if (SPI_Odstart & read_en) begin
                readout_cnt <= readout_cnt + 1'b1;
                if(readout_cnt == onum_cnt - 1'b1) begin
                    TDC_full <= 1'b0;
                    read_done <= 1;
                end
            end
        end
    end

    assign out_tag = 0; // out_tag indicate the current data from TDC1 or TDC2
    //assign out_tag=readout_cnt+1'b1;
    assign OUT= {raw_buf2[readout_cnt], onum_cnt, out_tag};
    assign TDC_Oready=1'b1;
    assign INT = TDC_full;
endmodule

module counterMax #(parameter DW=8)
(
    input wire clk,
    input wire rst_n,
    input wire en,
    input wire [DW-1:0] max,
    output logic [DW-1:0] cnt,
    output logic co
);
    assign co=en&(cnt==max);
    always_ff@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt<='0;
        end else if(en) begin
            if(cnt<max) cnt<=cnt+1'b1;
            else cnt<='0;
        end
    end
endmodule
