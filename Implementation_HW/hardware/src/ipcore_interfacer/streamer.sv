`timescale 1ns / 1ps

module streamer#( 
		parameter integer DATA_WIDTH	    = 64,
		parameter integer ADDR_WIDTH	    = 11,
		parameter integer NUMBER_OF_WORDS	= 128
    )
    ( 
        input  wire [31:0]                 Command0, 
        output wire [31:0]                 Status0, 
         
        // output wire [31:0]                 AckH, 
        // output wire [31:0]                 AckL, 
 
        // PORTS FOR DATA OUT
		input  wire                        dout_ACLK,
		input  wire                        dout_ARESETN,
		output wire                        dout_TVALID,
		output wire [ DATA_WIDTH-1    : 0] dout_TDATA,
		output wire [(DATA_WIDTH/8)-1 : 0] dout_TSTRB,
		output wire                        dout_TLAST,
		input  wire                        dout_TREADY,

        // PORTS FOR DATA IN
        input  wire                        din_ACLK,
		input  wire                        din_ARESETN,
		output wire                        din_TREADY,
		input  wire [ DATA_WIDTH-1    : 0] din_TDATA,
		input  wire [(DATA_WIDTH/8)-1 : 0] din_TSTRB,
		input  wire                        din_TLAST,
		input  wire                        din_TVALID,

        output wire                        eth_intr, 
        output wire [10:0]                 eth_addr,
        output wire [59:0]                 eth_to_proc_data,
        output wire                        eth_to_proc_we  ,
        input  wire [59:0]                 eth_from_proc_data,
        output wire [ 2:0]                 eth_proc_sel,
        output wire [ 3:0]                 eth_mem_sel,
        output wire                        eth_to_all_proc_en

    );
    
    reg          done_write;
    reg          done_read;
    reg  [ 2:0]  processor;
    reg          all_proc_en;

    assign eth_proc_sel       = processor;
    assign eth_mem_sel        = 4'd4;
    assign eth_to_all_proc_en = all_proc_en;


    wire [ 7:0]  command;

    assign command            = Command0[31:24];


    wire wrActive; // if 1 then write is active
    wire rdActive; // if 1 then read  is active

    // ////////////////////////////////////////////
    // //
    // // Acknowledgement

    // reg  [63:0] Acknowledgement;

    // assign AckH = Acknowledgement[63:32];
    // assign AckL = Acknowledgement[31: 0];

    // always@(posedge din_ACLK) 
	// begin
    //     if (s_din_next_state == s_din_wait_data) 
    //         Acknowledgement <= 64'h0;
    //     else if (din_TVALID & din_TREADY)
    //         Acknowledgement <= Acknowledgement ^ din_TDATA;
    // end

    ////////////////////////////////////////////
    //
    // Receive data from PC and write to BRAM

    typedef enum 
    {  
            s_din_wait_command,
            s_din_wait_data   ,
            s_din_read_data   ,
            s_din_wait_release
    }       
    s_din_states_t;
    
    s_din_states_t  s_din_state;
    s_din_states_t  s_din_next_state;


    // Implement Write-Address Counter
    reg [31:0] wAddrCounter;

    always@(posedge din_ACLK) 
	begin
        if(!din_ARESETN) 
            wAddrCounter <= 0;
        else if (s_din_state == s_din_wait_command & (command == 8'h1|| command == 8'h3))
            wAddrCounter <= {16'b0, Command0[15:0]};
        else if ((s_din_state == s_din_read_data) && din_TVALID)
            wAddrCounter <= wAddrCounter + 1;
    end

    assign eth_to_proc_data = {4'b0,din_TDATA[59:0]};
    assign eth_to_proc_we   = (s_din_state == s_din_read_data) && din_TVALID;
    assign din_TREADY       = (s_din_state == s_din_read_data);

    assign wrActive         = (s_din_state != s_din_wait_command);

    always@(*) 
	begin
        case (s_din_state)
            s_din_wait_command: begin
                if (command == 8'h1 || command == 8'h3) s_din_next_state <= s_din_wait_data;
                else                                    s_din_next_state <= s_din_wait_command;
            end

            s_din_wait_data: begin
                if (din_TVALID)                         s_din_next_state <= s_din_read_data;
                else                                    s_din_next_state <= s_din_wait_data;
            end

            s_din_read_data: begin
                if (din_TLAST)                          s_din_next_state <= s_din_wait_release;
                else                                    s_din_next_state <= s_din_read_data;
            end

            s_din_wait_release: begin
                if (command == 8'h0)                    s_din_next_state <= s_din_wait_command;
                else                                    s_din_next_state <= s_din_wait_release;
            end

            default: begin
                s_din_next_state <= s_din_wait_command;
            end
        endcase        
    end

    always@(posedge din_ACLK) 
	begin
        if (!din_ARESETN)   begin
            s_din_state <= s_din_wait_command;
            done_write <= 1'b1;
        end    
        else begin                
            s_din_state <= s_din_next_state;

            if      (s_din_state == s_din_wait_command && (command == 8'h1 || command == 8'h3))
                done_write <= 1'b0;
            else if (s_din_state == s_din_read_data && din_TLAST) 
                done_write <= 1'b1;
        end
    end
    
    ////////////////////////////////////////////
    //
    // Read data from BRAM and send to PC
    
    typedef enum
    {  
            s_dout_wait_command,
            s_dout_wait_ready  ,
            s_dout_write_data  ,
            s_dout_wait_release
    }       
    s_dout_states_t;
    
    s_dout_states_t  s_dout_state;
    s_dout_states_t  s_dout_next_state;

    // Implement Read-Address Counter
    wire [31:0] rAddress_next;
    reg  [31:0] rAddress;
    reg  [31:0] word_couter;
    
    always@(posedge dout_ACLK) 
	begin
        if(!dout_ARESETN) begin
            rAddress    <= 32'b0;
            word_couter <= 32'b0;            
        end
        else if (s_dout_state == s_dout_wait_command && (command == 8'h2 || command == 8'h4)) begin
            rAddress    <= {16'b0, Command0[15:0]};
            word_couter <= 32'b0;            
        end
        else if (s_dout_state != s_dout_wait_command) begin
            rAddress    <= rAddress_next;  
            word_couter <= word_couter+1;
        end
    end

    assign rAddress_next  = (dout_TREADY && dout_TVALID) ?  rAddress + 1 :
                                                            rAddress     ;

    assign dout_TSTRB  = {(DATA_WIDTH/8){1'b1}};
    assign dout_TDATA  = {4'b0, eth_from_proc_data};
    
    assign dout_TLAST  = dout_TVALID && ( (command == 8'h2 && word_couter == NUMBER_OF_WORDS) ||
                                          (command == 8'h4 && word_couter == 32'd12288      ) ) ;
    assign dout_TVALID = (s_dout_state == s_dout_write_data);

    assign rdActive    = (s_dout_state != s_dout_wait_command);

    always@(*) 
	begin
        case (s_dout_state)
            s_dout_wait_command: begin
                if (command == 8'h2 || command == 8'h4) s_dout_next_state <= s_dout_wait_ready;                        
                else                                    s_dout_next_state <= s_dout_wait_command;
            end

            s_dout_wait_ready: begin                    
                if (dout_TREADY)        s_dout_next_state <= s_dout_write_data;
                else                    s_dout_next_state <= s_dout_wait_ready;                    
            end

            s_dout_write_data: begin
                if (!dout_TREADY)                                                   s_dout_next_state <= s_dout_wait_ready;
                else if ( (command == 8'h2 && word_couter == NUMBER_OF_WORDS) ||
                          (command == 8'h4 && word_couter == 32'd12288      )  )    s_dout_next_state <= s_dout_wait_release;
                else                                                                s_dout_next_state <= s_dout_write_data;
            end

            s_dout_wait_release: begin

                if (command == 8'h0)    s_dout_next_state <= s_dout_wait_command;
                else                    s_dout_next_state <= s_dout_wait_release;
            end
            
            default: begin
                s_dout_next_state <= s_dout_wait_command;
            end

        endcase
    end 

    assign eth_addr = (wrActive) ?  wAddrCounter[ADDR_WIDTH-1:0] : 
                                    rAddress_next[ADDR_WIDTH-1:0];    

    always@(posedge dout_ACLK) 
	begin
        if (!dout_ARESETN) begin
            s_dout_state <= s_dout_wait_command;
            done_read     <= 1'b1;
        end
        else begin

            s_dout_state <= s_dout_next_state;

            if ((s_dout_state == s_dout_wait_command && (command == 8'h2 || command == 8'h4)) ||
                (s_din_state  == s_din_wait_command  && (command == 8'h1 || command == 8'h3)) )
            begin
                processor     <= Command0[22:20];
                all_proc_en   <= Command0[16];
            end
            else begin
                all_proc_en   <= all_proc_en;

                if      (command == 8'h3 && wAddrCounter[10:0] == 11'h7FF) 
                    processor <= processor + 1;
                else if (command == 8'h4 && rAddress_next[10:0]  == 11'h7FF)
                    processor <= processor + 1;
                else
                    processor <= processor;
            end

            if      (s_dout_state == s_dout_wait_command && ( command == 8'h2 ||
                                                              command == 8'h4 )
                    )
                done_read     <= 1'b0; 
            else if (s_dout_state == s_dout_write_data   && ((command == 8'h2 && word_couter == NUMBER_OF_WORDS) ||
                                                             (command == 8'h4 && word_couter == 32'd12288      ) )
                    )
                done_read     <= 1'b1;

        end
    end

    assign Status0          = {15'b0, done_read, 15'b0, done_write};

    assign eth_intr = (s_dout_next_state !=  s_dout_wait_command) | (s_din_state != s_din_wait_command);

endmodule