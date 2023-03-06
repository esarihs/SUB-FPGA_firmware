`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/19 17:36:44
// Design Name: 
// Module Name: DUMMY_SITCP_FIFO
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


module DUMMY_SITCP_FIFO(
    input   Rst,
    input   Clk, // SystemClk
    input   gt_txusrclk_in,
    input wire SiTcpFifoRdEnb,
    output reg [7:0] SiTcpFifoRdData,
    output reg SiTcpFifoEmpty,
    output reg SiTcpFifoValid,
    input wire prog_full
    );
    
    wire    SiTcpFifoFull;
    wire    SiTcpFifoAlmostFull;
    reg [7:0] SiTcpFifoWrData;
    //assign  SiTcpFifoRdEnb  =   ~SiTcpFifoEmpty;
    reg wr_rst_busy;
    reg rd_rst_busy;
    reg SiTcpFifoWrAck;
    
    parameter PAUSE = 5'h0;
    parameter HEADER1 = 5'h1;
    parameter HEADER2 = 5'h2;
    parameter HEADER3 = 5'h3;
    parameter HEADER4 = 5'h4;
    parameter HEADER5 = 5'h5;
    parameter HEADER6 = 5'h6;
    parameter HEADER7 = 5'h7;
    parameter HEADER8 = 5'h8;
    parameter HEADER9 = 5'h9;
    parameter HEADER10 = 5'ha;
    parameter DATA1 = 5'hb;
    parameter DATA2 = 5'hc;
    parameter DATA3 = 5'hd;
    parameter DATA4 = 5'he;
    parameter DATA5 = 5'hf;
    parameter FOOTER1 = 5'h10;
    parameter FOOTER2 = 5'h11;
    parameter FOOTER3 = 5'h12;
    parameter FOOTER4 = 5'h13;
    parameter FOOTER5 = 5'h14;
    parameter FOOTER6 = 5'h15;
    parameter FOOTER7 = 5'h16;
    parameter FOOTER8 = 5'h17;
    parameter FOOTER9 = 5'h18;
    parameter FOOTER10 = 5'h19;

    reg [23:0] count_event_number;
    reg [23:0] counter_data;
    reg [6:0] PAUSE_counter;
    
    //HEADER
    //parameter FIXED_WORD_HEADER = 2'b10;
    wire [1:0]  FIXED_WORD_HEADER;
    assign FIXED_WORD_HEADER = 2'b10;
    //FIXED_WORD_HEADER[1];
    wire [7:0]  AddressOutsideFrbs;
    assign AddressOutsideFrbs = 8'b10101010;
    wire [1:0]  ModeSelection;
    assign ModeSelection = 2'b00;
    wire  IsEnableZeroSuppression;
    assign IsEnableZeroSuppression = 1'b0;
    wire [16:0]  Empty;
    assign Empty = 17'b0;
    wire  IsEnableTimeWindow;
    assign IsEnableTimeWindow = 1'b0;
    wire [23:0]  EventNumber;
    assign EventNumber = count_event_number;
    wire  IsLastReadfromLargeFifo;
    assign IsLastReadfromLargeFifo = 1'b0;
    wire [23:0]  DataLength;
    assign DataLength = 24'd1000;    
    
    //DATA
    wire [1:0]  FIXED_WORD_DATA;
    assign FIXED_WORD_DATA = 2'b00;
    wire [4:0]  ASIC_ID;
    assign ASIC_ID = 5'b00100;    
    wire [6:0]  Channel_ID;
    assign Channel_ID = 7'b0011100;
    wire [12:0]  Leading_Edge;
    assign Leading_Edge = 13'b1010101010101;
    wire [12:0]  Trailing_Edge;
    assign Trailing_Edge = 13'b0000011100000;  
    
    //FOOTER
    wire [1:0]  FIXED_WORD_FOOTER;
    assign FIXED_WORD_FOOTER = 2'b11;  

        
reg SiTcpFifoWrEnb;

reg [5:0] STATE;
always@(posedge Clk) begin
    if(Rst || wr_rst_busy == 1'b1 || rd_rst_busy == 1'b1) begin
        STATE                   <=  PAUSE;
        SiTcpFifoWrEnb          <=  1'b0;
        SiTcpFifoWrData[7:0]    <=  8'b0;
        count_event_number      <=  24'b0;
        counter_data            <=  24'b0;
        PAUSE_counter           <=  7'b0;
    end else if(SiTcpFifoAlmostFull == 1'b0  && prog_full == 1'b0) begin
        case (STATE)
            PAUSE : begin
                SiTcpFifoWrEnb  <=  1'b0;
                PAUSE_counter <= PAUSE_counter + 7'b1;
                if(PAUSE_counter == 7'd100) begin
                    STATE <= HEADER1;
                end else begin
                    STATE <= PAUSE;
                end           
            end
            HEADER1 : begin
                STATE <= HEADER2;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {FIXED_WORD_HEADER, AddressOutsideFrbs[7:2]}; // dummy data
            end
            HEADER2 : begin
                STATE <= HEADER3;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {AddressOutsideFrbs[1:0], ModeSelection, IsEnableZeroSuppression, Empty[16:14]}; // dummy data
            end
            HEADER3 : begin
                STATE <= HEADER4;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {Empty[13:6]}; // dummy data
            end
            HEADER4 : begin
                STATE <= HEADER5;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {Empty[5:0], IsEnableTimeWindow, EventNumber[23]}; // dummy data
            end
            HEADER5 : begin
                STATE <= HEADER6;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {EventNumber[22:15]}; // dummy data
            end       
            HEADER6 : begin
                STATE <= HEADER7;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {EventNumber[14:7]}; // dummy data
            end
            HEADER7 : begin
                STATE <= HEADER8;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {EventNumber[6:0], IsLastReadfromLargeFifo}; // dummy data
            end                  
            HEADER8 : begin
                STATE <= HEADER9;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {DataLength[23:16]}; // dummy data
            end
            HEADER9 : begin
                STATE <= HEADER10;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {DataLength[15:8]}; // dummy data
            end
            HEADER10 : begin
                STATE <= DATA1;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {DataLength[7:0]}; // dummy data
                counter_data    <=  24'b0;
            end

            DATA1 : begin
                STATE <= DATA2;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {FIXED_WORD_DATA, ASIC_ID, Channel_ID[6]}; // dummy data
                counter_data    <=  counter_data    +   24'b1;
            end
            DATA2 : begin
                STATE <= DATA3;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {Channel_ID[5:0], Leading_Edge[12:11]}; // dummy data
            end
            DATA3 : begin
                STATE <= DATA4;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {Leading_Edge[10:3]}; // dummy data
            end
            DATA4 : begin
                STATE <= DATA5;
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {Leading_Edge[2:0], Trailing_Edge[12:8]}; // dummy data
            end
            DATA5 : begin
                SiTcpFifoWrEnb          <=  1'b1;
                SiTcpFifoWrData[7:0]    <=  {Trailing_Edge[7:0]}; // dummy data
                if( counter_data    ==  24'd1000) begin
                   STATE    <=  FOOTER1;
                end else if( counter_data    <  24'd1000) begin
                   STATE <= DATA1;
                end
            end 
            
             FOOTER1 : begin
                 STATE <= FOOTER2;
                 SiTcpFifoWrEnb          <=  1'b1;
                 SiTcpFifoWrData[7:0]    <=  {FIXED_WORD_FOOTER, AddressOutsideFrbs[7:2]}; // dummy data
             end
             FOOTER2 : begin
                 STATE <= FOOTER3;
                 SiTcpFifoWrEnb          <=  1'b1;
                 SiTcpFifoWrData[7:0]    <=  {AddressOutsideFrbs[1:0], ModeSelection, IsEnableZeroSuppression, Empty[16:14]}; // dummy data
             end
             FOOTER3 : begin
                 STATE <= FOOTER4;
                 SiTcpFifoWrEnb          <=  1'b1;
                 SiTcpFifoWrData[7:0]    <=  {Empty[13:6]}; // dummy data
             end
             FOOTER4 : begin
                 STATE <= FOOTER5;
                 SiTcpFifoWrEnb          <=  1'b1;
                 SiTcpFifoWrData[7:0]    <=  {Empty[5:0], IsEnableTimeWindow, EventNumber[23]}; // dummy data
             end
             FOOTER5 : begin
                 STATE <= FOOTER6;
                 SiTcpFifoWrEnb          <=  1'b1;
                 SiTcpFifoWrData[7:0]    <=  {EventNumber[22:15]}; // dummy data
             end       
             FOOTER6 : begin
                 STATE <= FOOTER7;
                 SiTcpFifoWrEnb          <=  1'b1;
                 SiTcpFifoWrData[7:0]    <=  {EventNumber[14:7]}; // dummy data
             end
             FOOTER7 : begin
                 STATE <= FOOTER8;
                 SiTcpFifoWrEnb          <=  1'b1;
                 SiTcpFifoWrData[7:0]    <=  {EventNumber[6:0], IsLastReadfromLargeFifo}; // dummy data
             end                  
             FOOTER8 : begin
                 STATE <= FOOTER9;
                 SiTcpFifoWrEnb          <=  1'b1;
                 SiTcpFifoWrData[7:0]    <=  {DataLength[23:16]}; // dummy data
             end
             FOOTER9 : begin
                 STATE <= FOOTER10;
                 SiTcpFifoWrEnb          <=  1'b1;
                 SiTcpFifoWrData[7:0]    <=  {DataLength[15:8]}; // dummy data
             end
             FOOTER10 : begin
                 STATE <= HEADER1;
                 SiTcpFifoWrEnb          <=  1'b1;
                 SiTcpFifoWrData[7:0]    <=  {DataLength[7:0]}; // dummy data
                 count_event_number <= count_event_number + 24'b1;
             end
                                                
        endcase
        // ...... dummy data input to SITCP_FIFO
    end else begin
        SiTcpFifoWrEnb          <=  1'b0; 
    end
end



fifo_w8_d32 SITCP_FIFO (
  .rst(Rst),                  // input wire rst
  .wr_clk(Clk),            // input wire wr_clk
  .din(SiTcpFifoWrData[7:0]),                  // input wire [7 : 0] din
  .wr_en(SiTcpFifoWrEnb),              // input wire wr_en
  .rd_clk(gt_txusrclk_in),            // input wire rd_clk
  .rd_en(SiTcpFifoRdEnb),              // input wire rd_en
  .dout(SiTcpFifoRdData[7:0]),                // output wire [7 : 0] dout
  .full(SiTcpFifoFull),                // output wire full
  .almost_full(SiTcpFifoAlmostFull),  // output wire almost_full
  .wr_ack(SiTcpFifoWrAck),            // output wire wr_ack
  .empty(SiTcpFifoEmpty),              // output wire empty
  .valid(SiTcpFifoValid),              // output wire valid
  .wr_rst_busy(wr_rst_busy), //output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy) //output wire rd_rst_busy
);

dummy_sitcp_fifo_ila fifo_ila_150MHzClk (
	.clk(Clk), // input wire clk

   	.probe0(Rst), // input wire [0:0]  probe0  
	.probe1(STATE), // input wire [4:0]  probe1 
	.probe2(SiTcpFifoWrEnb), // input wire [0:0]  probe2 
	.probe3(SiTcpFifoWrData[7:0]), // input wire [7:0]  probe3 
	.probe4(SiTcpFifoRdData[7:0]), // input wire [7:0]  probe4 
	.probe5(counter_data), // input wire [23:0]  probe5
	.probe6(count_event_number), // input wire [23:0]  probe6
	.probe7(SiTcpFifoFull), // input wire [0:0]  probe7 
    .probe8(SiTcpFifoEmpty), // input wire [0:0]  probe8 
    .probe9(SiTcpFifoValid), // input wire [0:0]  probe9 
    .probe10(SiTcpFifoRdEnb), // input wire [0:0]  probe10
    .probe11(gt_txusrclk_in), // input wire [0:0]  probe11 
    .probe12(wr_rst_busy), // input wire [0:0]  probe12 
    .probe13(rd_rst_busy), // input wire [0:0]  probe13
    .probe14(SiTcpFifoAlmostFull), // input wire [0:0]  probe14 
    .probe15(SiTcpFifoWrAck), // input wire [0:0]  probe15
    .probe16(prog_full) // input wire [0:0]  probe16
);

/*
dummy_sitcp_fifo_ila fifo_ila_txusrclk (
	.clk(gt_txusrclk_in), // input wire clk

   	.probe0(Rst), // input wire [0:0]  probe0  
	.probe1(STATE), // input wire [4:0]  probe1 
	.probe2(SiTcpFifoWrEnb), // input wire [0:0]  probe2 
	.probe3(SiTcpFifoWrData[7:0]), // input wire [7:0]  probe3 
	.probe4(SiTcpFifoRdData[7:0]), // input wire [7:0]  probe4 
	.probe5(counter_data), // input wire [23:0]  probe5
	.probe6(count_event_number), // input wire [23:0]  probe6
	.probe7(SiTcpFifoFull), // input wire [0:0]  probe7 
    .probe8(SiTcpFifoEmpty), // input wire [0:0]  probe8 
    .probe9(SiTcpFifoValid), // input wire [0:0]  probe9 
    .probe10(SiTcpFifoRdEnb), // input wire [0:0]  probe10
    .probe11(SiTcpFifoAlmostFull), // input wire [0:0]  probe11 
    .probe12(wr_rst_busy), // input wire [0:0]  probe12 
    .probe13(rd_rst_busy) // input wire [0:0]  probe13
);
*/

endmodule
