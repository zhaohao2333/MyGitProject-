module i2c_slave (
    input       scl,
    inout       sda
);

    parameter SLAVE_addr = 7'b001_0000;

    reg [7:0]   mem [3:0];
    reg [7:0]   mem_adr;
    reg [7:0]   mem_data_o;

    reg sta, d_sta;
    reg sto, d_sto;

    //generate shift register
    always @(posedge SCL) begin
        sr <= {sr[6:0], sda};
    end

    //detect my_address
    assign my_addr = (sr[7:1] == SLAVE_addr);

    //generate bit-counter
    always @(posedge scl) begin
        if(ld )
            bit_cnt <= 3'b111;
        else
            bit_cnt <= bit_cnt - 3'b001;        
    end

    //generate access done signal
    assign acc_done = (bit_cnt == 3'b000);

    //detect start condition
    always @(negedge sda) begin
        if(scl) begin
            sta <= 1'b1;
            d_sta <= 1'b0;
            sto <= 1'b0;
        end
        else
            sta <= 1'b0;
    end
    //!multi_driver issue?
    always @(posedge scl) begin
        d_sta <= sta;
    end
    //detect stop condition
    always @(posedge sda) begin
        if(scl) begin
            sta <= 1'b0;
            sto <= 1'b1;
        end
        else
            sto <= 1'b0;
    end
    //generate fsm
    always @(posedge sto or negedge scl) begin
        if(sto || (sta && !d_sta)) begin
            state <= idle;
            sda_o <= 1'b1;
            ld    <= 1'b1;
        end
        else begin
            //initial settings
            sda_o <= 1'b1;
            ld    <= 1'b1;

            case (state)
                idle: begin
                    if (acc_done && my_addr) begin
                    state <= slave_ack;
                    rw    <= sr[0];
                    sda_o <= 1'b0;

                    if(rw) begin
                        mem_do <= mem[mem_adr];
                    end
                end  
                end
                slave_ack:
                begin
                    if (rw) begin
                        state <= data;
                        sda_o <= mem_do[7];
                    end
                    else
                        state <= get_mem_adr;

                    ld <= 1'b1;
                end
                get_mem_adr: begin
                    if(acc_done) begin
                        state <= gma_ack;
                        mem_adr <= sr;
                        sda_o <= !(sr <= 15);
                    end
                end
                gma_ack: begin
                    state <= data;
                    ld    <= 1'b1;
                end
                data: begin
                    if(rw)
                        sda_o <= mem_do[7];

                    if(acc_done) begin
                        state <= data_ack;
                        mem_adr <= mem_adr + 8'h1;
                        sda_o <= (rw && (mem_adr <= 15));
                    end
                end

                data_ack: begin
                    
                end


            endcase
        end
    end








    //slave sda out
    assign sda = sda_o ? 1'bz : 1'b0;

endmodule //i2c_slave