`timescale 1 ns / 1 ps

module interfacer #
(
    parameter integer STREAM_DATA_WIDTH        = 64,
    parameter integer STREAM_ADDR_WIDTH        = 11,
    parameter integer STREAM_NUMBER_OF_WORDS   = 2048,

    parameter integer REG_DATA_WIDTH           = 32,
    parameter integer REG_ADDR_WIDTH           = 6
)
(
    // Users to add ports here
    output wire         poly_interrupt_eth, 
    output wire [10:0]  poly_address_eth, 
    output wire [59:0]  poly_dinb_eth,
    output wire         poly_web_eth  ,
    input  wire [59:0]  poly_doutb_eth,
    output wire         poly_select_all,
    output wire [  7:0] poly_instruction, 
    output wire [  2:0] poly_processor_sel,
    output wire [  3:0] poly_top_mem_sel,
    output wire         poly_modulus_sel,
    output wire [  3:0] poly_rdM0, 
    output wire [  3:0] poly_rdM1, 
    output wire [  3:0] poly_wtM0, 
    output wire [  3:0] poly_wtM1, 
    input  wire         poly_done,
    
    // User ports ends
    
    // Ports of Axi Slave Bus Interface S00_AXI
    input wire  s00_axi_aclk,
    input wire  s00_axi_aresetn,
    input wire [REG_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire  s00_axi_awvalid,
    output wire  s00_axi_awready,
    input wire [REG_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(REG_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire  s00_axi_wvalid,
    output wire  s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire  s00_axi_bvalid,
    input wire  s00_axi_bready,
    input wire [REG_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire  s00_axi_arvalid,
    output wire  s00_axi_arready,
    output wire [REG_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire  s00_axi_rvalid,
    input wire  s00_axi_rready,

    // Ports of Axi Slave Bus Interface S00_AXIS
    input wire  s00_axis_aclk,
    input wire  s00_axis_aresetn,
    output wire  s00_axis_tready,
    input wire [STREAM_DATA_WIDTH-1 : 0] s00_axis_tdata,
    input wire [(STREAM_DATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
    input wire  s00_axis_tlast,
    input wire  s00_axis_tvalid,

    // Ports of Axi Master Bus Interface M00_AXIS
    input wire  m00_axis_aclk,
    input wire  m00_axis_aresetn,
    output wire  m00_axis_tvalid,
    output wire [STREAM_DATA_WIDTH-1 : 0] m00_axis_tdata,
    output wire [(STREAM_DATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
    output wire  m00_axis_tlast,
    input wire  m00_axis_tready
);

wire [31:0] reg_to_stream_command;
wire [31:0] stream_to_reg_status;

streamer # (
    .DATA_WIDTH         (STREAM_DATA_WIDTH         ),
    .ADDR_WIDTH         (STREAM_ADDR_WIDTH         ),
    .NUMBER_OF_WORDS    (STREAM_NUMBER_OF_WORDS    )
) 
streamer_inst (
    
    .Command0           (reg_to_stream_command ),
    .Status0            (stream_to_reg_status  ),

    .dout_ACLK          (m00_axis_aclk      ),
    .dout_ARESETN       (m00_axis_aresetn   ),
    .dout_TVALID        (m00_axis_tvalid    ),
    .dout_TDATA         (m00_axis_tdata     ),
    .dout_TSTRB         (m00_axis_tstrb     ),
    .dout_TLAST         (m00_axis_tlast     ),
    .dout_TREADY        (m00_axis_tready    ),

    .din_ACLK           (s00_axis_aclk      ),
    .din_ARESETN        (s00_axis_aresetn   ),
    .din_TREADY         (s00_axis_tready    ),
    .din_TDATA          (s00_axis_tdata     ),
    .din_TSTRB          (s00_axis_tstrb     ),
    .din_TLAST          (s00_axis_tlast     ),
    .din_TVALID         (s00_axis_tvalid    ),
    
    .eth_proc_sel       (poly_processor_sel ),
    .eth_mem_sel        (poly_top_mem_sel   ),
    .eth_intr           (poly_interrupt_eth ),
    .eth_addr           (poly_address_eth   ), 
    .eth_to_proc_data   (poly_dinb_eth      ),
    .eth_to_proc_we     (poly_web_eth       ),        
    .eth_from_proc_data (poly_doutb_eth     ),
    .eth_to_all_proc_en (poly_select_all    )
    );

registers # ( 
    .C_S_AXI_DATA_WIDTH ( REG_DATA_WIDTH    ),
    .C_S_AXI_ADDR_WIDTH ( REG_ADDR_WIDTH    )
) registers_inst (
    
    // Address 0
    .str_command	    ( reg_to_stream_command	),

    // Address 1
    .str_status			( stream_to_reg_status	),

    // Address 2
    .poly_instruction   ( poly_instruction  ),
    .poly_rdM0		    ( poly_rdM0     	),
    .poly_rdM1		    ( poly_rdM1     	),
    .poly_wtM0		    ( poly_wtM0     	),
    .poly_wtM1		    ( poly_wtM1     	),
    .poly_modulus	    ( poly_modulus_sel	),

    // Address 3
    .poly_done		    ( poly_done		    ),

    .S_AXI_ACLK         ( s00_axi_aclk      ),
    .S_AXI_ARESETN      ( s00_axi_aresetn   ),
    .S_AXI_AWADDR       ( s00_axi_awaddr    ),
    .S_AXI_AWPROT       ( s00_axi_awprot    ),
    .S_AXI_AWVALID      ( s00_axi_awvalid   ),
    .S_AXI_AWREADY      ( s00_axi_awready   ),
    .S_AXI_WDATA        ( s00_axi_wdata     ),
    .S_AXI_WSTRB        ( s00_axi_wstrb     ),
    .S_AXI_WVALID       ( s00_axi_wvalid    ),
    .S_AXI_WREADY       ( s00_axi_wready    ),
    .S_AXI_BRESP        ( s00_axi_bresp     ),
    .S_AXI_BVALID       ( s00_axi_bvalid    ),
    .S_AXI_BREADY       ( s00_axi_bready    ),
    .S_AXI_ARADDR       ( s00_axi_araddr    ),
    .S_AXI_ARPROT       ( s00_axi_arprot    ),
    .S_AXI_ARVALID      ( s00_axi_arvalid   ),
    .S_AXI_ARREADY      ( s00_axi_arready   ),
    .S_AXI_RDATA        ( s00_axi_rdata     ),
    .S_AXI_RRESP        ( s00_axi_rresp     ),
    .S_AXI_RVALID       ( s00_axi_rvalid    ),
    .S_AXI_RREADY       ( s00_axi_rready    )
);

endmodule