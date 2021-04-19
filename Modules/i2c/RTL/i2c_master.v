module i2c_master (
    input  wire         clk,
    input  wire         rstn,
    inout  wire         sda,
    inout  wire         scl,
    input  wire         i2c_start,
    input  wire         clk1
);
    //----------------------------------------------------------------
    reg     [2:0] count;
    reg     clk_en;
    reg     cnt_en;
    reg     sda_o;
    reg     ld;
    reg     [7:0] n_state, c_state;
    reg     enable, enable_q;
    reg     stop_cnt;
    //----------------------------------------------------------------
    localparam IDLE = 8'b0000_0000;
    localparam START = 8'b0000_0001;
    localparam SEND_ADR = 8'b0000_0010;
    localparam WAIT_ACK = 8'b0000_0011;
    localparam RD_DATA = 8'b0000_0100;
    localparam WR_DATA = 8'b0000_0101;
    localparam WAIT_ACK2 = 8'b0000_0110;
    localparam STOP1 = 8'b0000_0111; 
    localparam STOP = 8'b0000_1000;

    localparam rw = 0; // !
    localparam reg_addr = 8'b1010_0101;
    //----------------------------------------------------------------
    localparam addr = 8'b1100_1001;

    //clk = 100khz
    assign sda = sda_o;
    assign scl = clk_en ? clk1 : 1'b1;

    //
    always @(negedge sda or negedge rstn) begin
        if(!rstn)
            enable <= 0;
        else if (scl & (!enable_q))
            enable <= 1;
        
    end
    
    /* always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            clk_en <= 1'b0;
        end else if((c_state == START)||(c_state == SEND_ADR)) begin //!
            clk_en <= 1'b1; 
        end
    end */
    always @(posedge clk1 or negedge rstn) begin
        if (!rstn) begin
            clk_en <= 1'b0;
            enable_q <= 0;
        end else if(enable & ~enable_q) begin //!
            clk_en <= 1'b1;
        end
        
        // if(clk_en && (c_state == STOP) && (count == 0)) begin
        if(clk_en && (c_state == STOP)) begin
            clk_en <= 1'b0;
            enable_q <= 1;
        end            
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) 
            c_state <= IDLE;
        //else if(state_go)//!
        else
            c_state <= n_state;
    end

    always @( *) begin
        n_state = c_state;
        case (c_state)
            IDLE: begin
                if(i2c_start) begin
                    n_state = START; 
                end
            end
            START: begin
                n_state = SEND_ADR;
            end
            SEND_ADR: begin
                if(count == 0) begin
                    n_state = WAIT_ACK;
                end
            end
            WAIT_ACK: begin
                if(rw)
                    n_state = RD_DATA;
                else if(!rw)
                    n_state = WR_DATA;
            end
            WR_DATA: begin
                if(count == 0) begin
                    n_state = WAIT_ACK2;
                end
            end
            RD_DATA:    ;

            WAIT_ACK2: begin
                n_state = STOP1;
            end
            STOP1: n_state = STOP;

            STOP: ;

        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sda_o <= 1'b1;
            ld <= 1;
            cnt_en <= 0;
        end
        else
            case (c_state)
                IDLE: ;

                START: begin
                    sda_o <= 0;
                    ld <= 1;
                    cnt_en <= 1;
                end
                SEND_ADR: begin
                    ld <= 0;
                    sda_o <= addr[count];
                    if(count == 0) begin
                        cnt_en <= 0;
                        ld <= 1;
                    end                        
                end
                WAIT_ACK: begin
                    sda_o <= 0;
                    ld <= 0;
                    // if(~rw)
                    //     ld <= 1;
                end
                WR_DATA: begin
                    sda_o <= reg_addr[count];
                    cnt_en <= 1;
                    if(count == 0) begin
                        cnt_en <= 0;
                        ld <= 1;
                    end
                end
                RD_DATA: ;

                WAIT_ACK2: begin
                    sda_o <= 0;
                    ld <= 0;
                end

                STOP1: begin
                    sda_o <= 0;
                end

                STOP: begin
                    sda_o <= 1;
                end
            endcase
    end

    always @(posedge clk1 or negedge rstn) begin
        if (!rstn)
            count <= 3'b111;
        else if(ld)
            count <= 3'b111;
        else if((count > 0)&&(cnt_en == 1))
            count <= count - 1;
    end
endmodule //i2c_master