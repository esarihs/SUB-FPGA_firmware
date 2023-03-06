`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/31 17:22:00
// Design Name: 
// Module Name: GTP_TX
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


module GTP_TX(
    input wire gt_txusrclk_in,
    input wire reset_in,
    //input wire [15:0] gt_tx_usr_data,
    output reg  [15:0] gt_txdata,
    output reg [1:0]  gt_txcharisk,
    output reg SiTcpFifoRdEnb,
    
    input wire SiTcpFifoEmpty,
    input wire [7:0] SiTcpFifoRdData,
    input wire SiTcpFifoValid
    
    );
    
    parameter PAUSE = 5'h0;
    parameter READ1 = 5'h1;
/*
    parameter READ2 = 5'h2;
    parameter READ3 = 5'h3;
    parameter READ4 = 5'h4;
    parameter READ5 = 5'h5;
    parameter READ6 = 5'h6;
*/
    parameter transmit0 = 5'h0;
    parameter transmit1 = 5'h1;
    parameter transmit2 = 5'h2;
    parameter transmit3 = 5'h3;
    parameter transmit4 = 5'h4;
    

    reg [4:0] TX_state;
    reg [3:0] TX_counter;
    reg [23:0] count_event_number;
    reg [9:0] counter_data;
    reg [39:0] gt_txdata_reg;
    reg [39:0] gt_txdata_reg_tmp;
    
    //new
    reg gt_txdata_reg_valid;
    reg [3:0] TX_state2;
    reg [5:0] errorcounter;
    //reg [3:0] DebaState;
 
    always@(posedge gt_txusrclk_in) begin
     if(reset_in) begin
         TX_state <= READ1;
         gt_txdata_reg <= 40'b0;
         gt_txdata_reg_tmp <= 40'b0;
         TX_counter <= 4'b0;
         gt_txdata_reg_valid    <=  1'b0;
     end
     else begin
         case (TX_state)
             PAUSE : begin
                 TX_state <= READ1;
                 TX_counter <= 4'b0;
             end
             READ1 : begin
                if(SiTcpFifoEmpty != 1'b1) begin
                    TX_state <= READ1;
                    SiTcpFifoRdEnb <= 1'b1;
                end
                else begin
                    TX_state <= READ1;
                    SiTcpFifoRdEnb <= 1'b0;
                end
                if(SiTcpFifoValid == 1'b1) begin
                    if(TX_counter == 4'd4) begin
                        TX_counter <= 4'b0;
                        gt_txdata_reg_valid <=  1'b1;
                        //gt_txdata_reg[39:0] <= gt_txdata_reg_tmp[39:0];
                        gt_txdata_reg[39:0] <= {gt_txdata_reg_tmp[31:0],SiTcpFifoRdData};
                    end else begin
                        TX_counter <= TX_counter + 4'b1;
                        gt_txdata_reg_valid   <=  1'b0;
                        gt_txdata_reg_tmp[39:0] <= {gt_txdata_reg_tmp[31:0], SiTcpFifoRdData};
                    end
                end else begin
                    gt_txdata_reg_valid <=  1'b0;
                end
            end
        endcase
    end
end

    //assign gt_txdata = {8'hbc, gt_txdata_reg};
    //output reg [1:0]  gt_txcharisk,

    
always@(posedge gt_txusrclk_in) begin
 if(reset_in) begin
    gt_txcharisk    <= 2'b0  ;
    gt_txdata[15:0] <= 15'b0 ;
    errorcounter <= 5'b0 ;
    TX_state2   <=  transmit0;   
 end else if(gt_txdata_reg_valid==1'b1) begin
    if(TX_state2==transmit0) begin
        TX_state2 <= transmit1;
        gt_txcharisk    <= 2'b1  ;
        gt_txdata[15:0] <= {gt_txdata_reg[39:32], 8'hbc} ;
    end else begin
        errorcounter <= errorcounter + 5'b1; // error detection        
    end
 end else begin
    case (TX_state2)
        transmit0 : begin
             gt_txcharisk    <= 2'b0  ;
             gt_txdata[15:0] <= 15'b0 ;
             errorcounter <= 5'b0 ;
        end
        transmit1 : begin
            TX_state2 <= transmit2;
            gt_txcharisk    <= 2'b0;
            gt_txdata[15:0] <= {gt_txdata_reg[31:24], 8'b0};
        end
        transmit2 : begin
            TX_state2       <= transmit3;
            gt_txcharisk    <= 2'b0;
            gt_txdata[15:0] <= {gt_txdata_reg[23:16], 8'b0};

        end
        transmit3 : begin
            TX_state2       <= transmit4;
            gt_txcharisk    <= 2'b0;
            gt_txdata[15:0] <= {gt_txdata_reg[15:8], 8'b0};

        end
        transmit4 : begin
            TX_state2       <= transmit0;
            gt_txcharisk    <= 2'b0;
            gt_txdata[15:0] <= {gt_txdata_reg[7:0], 8'b0};

        end
    endcase
 end
end

  
vio_TXRXcounter TX_counter_check (
      .clk(gt_txusrclk_in),              // input wire clk
      .probe_in0(TX_counter[0]),  // input wire [0 : 0] probe_in0
      .probe_in1(TX_counter[1]),  // input wire [0 : 0] probe_in1
      .probe_in2(TX_counter[2]),  // input wire [0 : 0] probe_in2
      .probe_in3(TX_counter[3])  // input wire [0 : 0] probe_in3
    );    
    
ila_TXdata TXdata (
        .clk(gt_txusrclk_in), // input wire clk
	    .probe0(TX_state[4:0]), // input wire [3:0]  probe0  
        .probe1(SiTcpFifoEmpty), // input wire [0:0]  probe1 
        .probe2(SiTcpFifoRdEnb), // input wire [0:0]  probe2 
        .probe3(TX_counter[3:0]), // input wire [3:0]  probe3 
        .probe4(SiTcpFifoValid), // input wire [0:0]  probe4 
        .probe5(gt_txdata[15:0]), // input wire [15:0]  probe5 
        .probe6(gt_txdata_reg[39:0]), // input wire [39:0]  probe6 
        .probe7(gt_txdata_reg_tmp[39:0]), // input wire [39:0]  probe7 
        .probe8(gt_txdata_reg_valid), // input wire [0:0]  probe8 
        .probe9(gt_txcharisk[1:0]), // input wire [1:0]  probe9 
        .probe10(errorcounter), // input wire [5:0]  probe10 
        .probe11(TX_state2[3:0]) // input wire [3:0]  probe11
    );    
    

endmodule
