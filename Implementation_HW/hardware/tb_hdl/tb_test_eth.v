`timescale 1ns / 1ps

`define TOTAL      3500000
`define RESET_TIME 100
`define CLK_PERIOD 10
`define CLK_HALF   5

module tb_test_eth(

    );
    
    reg  clk;
    reg  resetn;
    
    reg  [31:0]         Command0     ;
    wire [31:0]         Status0      ;
    wire [31:0]         Status1      ;
    
    wire                dout_TVALID  ;
    wire [ 63      : 0] dout_TDATA   ;
    wire [(32/8)-1 : 0] dout_TSTRB   ;
    wire                dout_TLAST   ;
    reg                 dout_TREADY  ;

    wire                din_TREADY   ;
    reg  [ 63      : 0] din_TDATA    ;
    reg  [(64/8)-1 : 0] din_TSTRB    ;
    reg                 din_TLAST    ;
    reg                 din_TVALID   ;
    
    reg  [10:0]         eth_write_addr;
    reg  [ 2:0]         processor_sel;
    reg  [ 3:0]         top_mem_sel;
    
    reg  [8:0]          ddr_address;
    reg  [239:0]        ddr_din;
    reg                 ddr_interrupt;
    reg                 ddr_we;
    wire                done;
    wire [239:0]        ddr_dout;
    reg  [7:0]          instruction;
    reg                 modulus_sel;
    
    reg  [3:0]          rdM0;
    reg  [3:0]          rdM1;
    
    reg  [3:0]          wtM0;
    reg  [3:0]          wtM1;
    
    mainbd mainbd_i(
        .s00_axis_aclk(clk),
        .s00_axis_aresetn(resetn),

        .Command0   (Command0),
        .Status0    (Status0),
        .Status1    (Status1),
        
        .M00_AXIS_tdata     (dout_TDATA     ),
        .M00_AXIS_tlast     (dout_TLAST     ),
        .M00_AXIS_tready    (dout_TREADY    ),
        .M00_AXIS_tstrb     (dout_TSTRB     ),
        .M00_AXIS_tvalid    (dout_TVALID    ),
        
        .S00_AXIS_tdata     (din_TDATA      ),
        .S00_AXIS_tlast     (din_TLAST      ),
        .S00_AXIS_tready    (din_TREADY     ),
        .S00_AXIS_tstrb     (din_TSTRB      ),
        .S00_AXIS_tvalid    (din_TVALID     ),

        .ddr_address        (ddr_address    ),
        .ddr_din            (ddr_din        ),
        .ddr_interrupt      (ddr_interrupt  ),
        .ddr_we             (ddr_we         ),
        .done               (done           ),
        .ddr_dout           (ddr_dout       ),
        .instruction        (instruction    ),
        .modulus_sel        (modulus_sel    ),
        .rdM0               (rdM0           ),
        .rdM1               (rdM1           ),
        .wtM0               (wtM0           ),
        .wtM1               (wtM1           )
    );

    // Generate a clk
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end

    initial begin
        // wtM1            = 'b0 ;
        // wtM0            = 'b0 ;
        // rdM0            = 'b0 ;
        // rdM1            = 'b0 ;        
        modulus_sel     = 'b0 ; 

        // instruction     = 'b0 ; // comes from msp

        ddr_address     = 'b0 ;
        ddr_din         = 'b0 ;
        ddr_interrupt   = 'b0 ;
        ddr_we          = 'b0 ;        
    end

    reg [ 2:0] proc;
    reg [11:0] addr;
    reg [11:0] i;
    reg [63:0] expected;
    
    // Test PC -> FPGA
    initial begin      

        resetn        =  1'b0;
        din_TLAST     =  1'b0;
        Command0      = 32'h0;
		i             = 12'd0;	
        expected      = 64'd0;
        dout_TREADY   =  1'b1;
        din_TDATA     =   'b0;
        
        processor_sel  =  3'b0;
        top_mem_sel    =  4'd4;
        eth_write_addr = 11'd0;

        rdM0            = 'b0 ;
        rdM1            = 'b0 ;
        wtM0            = 'b0 ;  
        wtM1            = 'b0 ;
        instruction     = 'b0 ;
        
        #`RESET_TIME

        resetn        =  1'b1;

        #`RESET_TIME
        
       for(proc=0; proc<3'd7; proc=proc+1)
       begin
            
           processor_sel = proc;

           #`CLK_PERIOD;
            
           for(addr=0; addr<12'd2048; addr=addr+128)
           begin

               eth_write_addr = addr[10:0];

               Command0      = {8'h1, 1'b0,processor_sel, top_mem_sel, 5'd0,eth_write_addr} ;
                
               for(i=0; i<12'd128; i=i+1)
               begin
                   din_TVALID   =  1'b1;
                   expected     = {5'b0, processor_sel, 4'b0, top_mem_sel, 5'b0, eth_write_addr+i[10:0], 32'b0};
                   din_TDATA    = expected;
                   din_TLAST    = (i==12'd127);
                   wait(din_TREADY);
                   @(posedge clk);
               end

               din_TDATA    = 'b0;
                
               Command0     = 32'h0;
               din_TLAST    = 1'b0;
                
               #`RESET_TIME;
           end
           #`RESET_TIME;
       end

        rdM0            =  4'd4 ;
        rdM1            =  4'd0 ;  
        wtM0            =  4'd4 ;
        wtM1            =  4'd0 ;    
        
        #`CLK_PERIOD;

        instruction     = 8'd16 ;

        #`CLK_PERIOD;
        #`CLK_PERIOD;  

        wait(done);

        #`CLK_PERIOD;
        #`CLK_PERIOD;        

        instruction     = 8'd0 ;
        rdM0            =  4'd0 ;
        rdM1            =  4'd0 ;  
        wtM0            =  4'd0 ;
        wtM1            =  4'd0 ;    

   
       for(proc=0; proc<3'd7; proc=proc+1)
//        for(proc=3'd6; proc!=3'd7; proc=proc-1)
        begin
            processor_sel = proc;

            #`CLK_PERIOD;
             
            for(addr=0; addr<12'd2048; addr=addr+128)
            begin
                eth_write_addr = addr[10:0];

                Command0      = {8'h2, 1'b0,processor_sel, top_mem_sel, 5'd0,eth_write_addr} ;
                
                dout_TREADY  =  1'b1;
        
                for(i=0; i<12'd128; i=i+1)
                begin
                    expected     = {5'b0, processor_sel, 4'b0, top_mem_sel, 5'b0, eth_write_addr+i[10:0], 32'b0};
                    wait(dout_TVALID);
                    @(posedge clk);
//                    if(expected[59:0]!=dout_TDATA)
//                        $finish;
                end
        
                eth_write_addr = 'b0;
                dout_TREADY  =  1'b0;        
                Command0     = 32'h0;

                #`RESET_TIME;
            end            
            #`RESET_TIME;
        end
        

        $finish;
    end
    
endmodule
