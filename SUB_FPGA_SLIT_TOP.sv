`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/07 11:50:58
// Design Name: 
// Module Name: SLIT_TOP
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


module SLIT_TOP(
                 // GTP
input           RXN_IN,
input           RXP_IN,
input           exclk_P,
input           exclk_N,
output          TXN_OUT,
output          TXP_OUT,     
input           gtrefclk_p,
input           gtrefclk_n,
input [3:0]     COMMUNICATE_BTW_FPGA_RX,
output [3:0]    COMMUNICATE_BTW_FPGA_TX

    );

   wire 					    SystemClk;
   wire 					    SamplingClk;
   //wire 					    ReadClk;
   wire 					    AsynchronousRst;
/*
   wire         RBCP_ACK    ;
   wire         RBCP_JC_ACK ;
   wire         RBCP_GTP_ACK;
   wire [7:0]   RBCP_RD     ;
   wire [7:0]   RBCP_JC_RD  ;
   wire [7:0]   RBCP_GTP_RD ;

   wire RBCP_ACT        ;
   wire [31:0] RBCP_ADDR       ;
   wire [7:0]  RBCP_WD         ;
   wire        RBCP_WE         ;
   wire        RBCP_RE         ;
   wire        RBCP_REG_ACK    ;
   wire [7:0]  RBCP_REG_RD     ;
*/
    wire    gt_pll0outclk;
    wire    gt_pll0outrefclk;
    wire    gt_pll1outclk;
    wire    gt_pll1outrefclk;
    wire    gt_pll0lock;
    wire    gt_pll0refclklost;
    wire    gt_pll1lock;
    wire    gt_pll1refclklost;
    wire    gt_pll1reset;
    wire    gt_pll1pd;
    wire    gtrefclk;
    wire    gtrefclk_bufg;

wire GTP_reset;
wire GTP_TX_reset;
wire GTP_RX_reset;
assign GTP_reset    =   1'b0;
assign GTP_TX_reset =   1'b0;
assign GTP_RX_reset =   1'b0;
wire [15:0] gt_txdata_in;
wire [1:0] gt_txcharisk_in;
wire gt_txusrclk_out;
wire [15:0] gt_rxdata_out;
wire [1:0] gt_rxcharisk_out;
wire gt_rxusrclk_out;
wire [5:0] gt_status;
wire [15:0] error_counter;
wire [15:0] gt_tx_usr_data;  
assign  gt_tx_usr_data  [15:0]  =   16'h0000;
wire [63:0] RX_paralell_data;
//DUMMY SITCP FIFO
wire SiTcpFifoRdEnb;
wire [7:0] SiTcpFifoRdData;
wire SiTcpFifoFull;
wire SiTcpFifoEmpty;
wire SiTcpFifoValid;


    GTP_2p5Gbps_exdes   GTP_2p5Gbps_exdes(
    .reset_in                   (GTP_reset),
    //.gtrefclk_in                (gtrefclk),
    .gtrefclk_in                (gtrefclk_bufg),
    //.gt_pll0outclk              (gt_pll0outclk),
    //.gt_pll0outrefclk           (gt_pll0outrefclk),
    //.gt_pll0lock                (gt_pll0lock),
    //.gt_pll0refclklost          (gt_pll0refclklost),
    .gt_pll1outclk              (gt_pll1outclk),
    .gt_pll1outrefclk           (gt_pll1outrefclk),
    .gt_pll1lock                (gt_pll1lock),
    .gt_pll1refclklost          (gt_pll1refclklost),
    .gt_pll1reset_out           (gt_pll1reset),
    .gt_pll1pd_out              (gt_pll1pd),
    .DRP_CLK_IN                 (SystemClk),
    .GTTX_RESET_IN              (GTP_TX_reset),
    .GTRX_RESET_IN              (GTP_RX_reset),
    .RXN_IN                     (RXN_IN),
    .RXP_IN                     (RXP_IN),
    .TXN_OUT                    (TXN_OUT),
    .TXP_OUT                    (TXP_OUT),
    .gt_txdata_in               (gt_txdata_in),
    .gt_txcharisk_in            (gt_txcharisk_in),
    .gt_txusrclk_out            (gt_txusrclk_out),
    .gt_rxdata_out              (gt_rxdata_out),
    .gt_rxcharisk_out           (gt_rxcharisk_out),
    .gt_rxusrclk_out            (gt_rxusrclk_out),
    .gt_status_out              (gt_status),
    .error_counter              (error_counter)
    );
    
    GTP_TX  GTP_TX(
        .gt_txusrclk_in (gt_txusrclk_out),
        .reset_in       (AsynchronousRst),
        //.gt_tx_usr_data (gt_tx_usr_data),
        .gt_txdata      (gt_txdata_in),
        .gt_txcharisk   (gt_txcharisk_in),
        .SiTcpFifoRdData (SiTcpFifoRdData[7:0]),
        .SiTcpFifoEmpty (SiTcpFifoEmpty),
        .SiTcpFifoRdEnb (SiTcpFifoRdEnb),
        .SiTcpFifoValid (SiTcpFifoValid)
    );
    
    GTP_RX  GTP_RX(
        .gt_rxusrclk_in (gt_rxusrclk_out),
        .reset_in       (GTP_RX_reset),
        .gt_rxdata      (gt_rxdata_out),
        .RX_paralell_data   (RX_paralell_data),
       .gt_rxcharisk   (gt_rxcharisk_out),
       .COMMUNICATE_BTW_FPGA_RX (COMMUNICATE_BTW_FPGA_RX)
    );
    
      gig_ethernet_pcs_pma_1_gt_common #
    (
       .WRAPPER_SIM_GTRESET_SPEEDUP("TRUE")
    )
    core_gt_common_i
  (
      .GTREFCLK0_IN                (gtrefclk),
      .GTREFCLK0_BUFG_IN           (gtrefclk_bufg),
      .PLL0OUTCLK_OUT              (gt_pll0outclk),
      .PLL0OUTREFCLK_OUT           (gt_pll0outrefclk),
      .PLL1OUTCLK_OUT              (gt_pll1outclk), 
      .PLL1OUTREFCLK_OUT           (gt_pll1outrefclk),
      .PLL0LOCK_OUT                (gt_pll0lock),
      .PLL0LOCKDETCLK_IN           (SamplingClk),
      .PLL0REFCLKLOST_OUT          (gt_pll0refclklost),
      //.PLL0RESET_IN                (gt_pll0reset),     
      .PLL1LOCK_OUT                (gt_pll1lock),
      .PLL1LOCKDETCLK_IN           (SamplingClk),
      .PLL1REFCLKLOST_OUT          (gt_pll1refclklost),
      .PLL1PD_IN                   (gt_pll1pd ),
      .PLL1REFCLKSEL_IN            (3'b001),
      .PLL1RESET_IN                (gt_pll1reset)     
  );
/*
    GTP_control     GTP_control(
		.CLK                      (SystemClk          ),   // in   : Clock
		.LOC_ADDR                 (RBCP_ADDR[31:0]    ),
		.LOC_WD                   (RBCP_WD[7:0]       ),
		.LOC_WE                   (RBCP_WE            ),
		.LOC_RE                   (RBCP_RE            ),
		.LOC_ACK                  (RBCP_GTP_ACK       ),
		.LOC_RD                   (RBCP_GTP_RD        ),
		.gt_status                (gt_status          ),
		.error_counter            (error_counter      ),
		.GTP_reset                (GTP_reset          ),
		.GTP_TX_reset             (GTP_TX_reset       ),
		.GTP_RX_reset             (GTP_RX_reset       ),
		.gt_tx_usr_data           (gt_tx_usr_data)
		);
*/
    wire    exclk;
    IBUFDS #(
    .DIFF_TERM("TRUE"),
    .IOSTANDARD("DEFAULT") // Specify the output I/O standard
    ) IBUFDS (
        .I  (exclk_P  ), // Diff_p output (connect directly to top-level port)
        .IB (exclk_N  ), // Diff_n output (connect directly to top-level port)
        .O  (exclk   ) // Buffer input
    );
    wire AsynchronousRst;
    wire    locked;
    assign AsynchronousRst = ~locked;
  sub_fpga_clk instance_name
   (
    // Clock out ports
    .clk150MHz(SystemClk),     // output clk150MHz
    .clk200MHz(SamplingClk),
    // Status and control signals
    .reset(1'b0), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(exclk));      // input clk_in1
// INST_TAG_END ------ End INSTANTIATION Template ---------
    wire    gtrefclk_i;
   IBUFDS_GTE2 ibufds_gtrefclk (
      .I     (gtrefclk_p),
      .IB    (gtrefclk_n),
      .CEB   (1'b0),
      .O     (gtrefclk_i),
      .ODIV2 ()
   );

  assign gtrefclk = gtrefclk_i;

   BUFG  bufg_gtrefclk (
      .I         (gtrefclk_i),
      .O         (gtrefclk_bufg)
   );

wire Fifo_Rst;
wire dummy_prog_full;

DUMMY_SITCP_FIFO DUMMY_SITCP_FIFO (
  .Rst(Fifo_Rst),                  // input wire rst
  .Clk(SystemClk),            // input wire wr_clk
  .gt_txusrclk_in(gt_txusrclk_out),
  //.rd_clk(gt_tx_usr_data),            // input wire rd_clk
  .SiTcpFifoRdEnb(SiTcpFifoRdEnb),              // input wire rd_en
  .SiTcpFifoRdData(SiTcpFifoRdData[7:0]),                // output wire [7 : 0] dout
  //.full(SiTcpFifoFull),                // output wire full
  .SiTcpFifoEmpty(SiTcpFifoEmpty),              // output wire empty
  .SiTcpFifoValid(SiTcpFifoValid),
  .prog_full(COMMUNICATE_BTW_FPGA_RX[3])
  
);

vio_dummy_sitcp_fifo vio_dummy_sitcp_fifo (
  .clk(SystemClk),                // input wire clk
  .probe_out0(Fifo_Rst)  // output wire [0 : 0] probe_out0
);

endmodule
