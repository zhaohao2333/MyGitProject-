module sort (
    input  wire          clk, 
    input  wire          rst_n,
    input  wire    [4:0] int,
    input  wire    [9:0] data
);// sort by intensity

reg [9:0]   data_reg[2:0];
reg [4:0]   int_reg[2:0];
reg [4:0]   int_reg_min1;
reg [4:0]   int_reg_min2;
reg [1:0]   sel1,sel2,sel;
//reg [4:0]   int_reg_min2;


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        int_reg_min1 <= 0;
        sel1 <= 2'b00; 
    end
    else if(int_reg[0] <= int_reg[1]) begin
        int_reg_min1 <= int_reg[0];
        sel1 <= 2'b00; 
    end
    else begin
        int_reg_min1 <= int_reg[1]; 
        sel1 <= 2'b01;        
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        int_reg_min2 <= 0;
        sel2 <= 2'b10;
    end
    else if(int_reg[2] <= int) begin
        int_reg_min2 <= int_reg[2];
        sel2 <= 2'b10;
    end
    else begin
        int_reg_min2 <= int;
        sel2 <= 2'b11;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sel <= 0;
    end
    else if(int_reg_min1 <= int_reg_min2)
        sel <= sel1;
    else
        sel <= sel2;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_reg[0] <= 0;
        data_reg[1] <= 0;
        data_reg[2] <= 0;
    end
    else begin
        case (sel)
            0:
                data_reg[0] <= data;
            1:
                data_reg[1] <= data;
            2:
                data_reg[2] <= data;
            default :
                ;         
        endcase
    end
end
        
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        int_reg[0] <= 0;
        int_reg[1] <= 0;
        int_reg[2] <= 0;
    end
    else begin
        case (sel)
            0:
                int_reg[0] <= int;
            1:
                int_reg[1] <= int;
            2:
                int_reg[2] <= int;
            default :
                ;
        endcase
    end
end

endmodule //sort