module ofm_write_addr_controller #(
    parameter SYSTOLIC_SIZE = 16      ,
    parameter OFM_RAM_SIZE  = 2378675
) (
    input                                     clk              , 
    input                                     rst_n            ,
    input                                     start            ,
    input      [$clog2(OFM_RAM_SIZE) - 1 : 0] start_write_addr ,
    input                                     write            ,
    input      [4:0]                          read_wgt_size    ,
    input      [6:0]                          count_filter     , 
    output reg [$clog2(OFM_RAM_SIZE) - 1 : 0] ofm_addr         ,
    output reg [4:0]                          write_ofm_size   ,

    //Layer config
    input      [8:0]                          ofm_size         , 
    input                                     maxpool_mode     ,
    input      [1:0]                          maxpool_stride   ,
    input                                     upsample_mode 
);

    parameter IDLE             = 2'b00 ;
    parameter NEXT_CHANNEL     = 2'b01 ;
    parameter UPDATE_BASE_ADDR = 2'b10 ;

    reg [1:0] current_state, next_state;
    
    reg [$clog2(OFM_RAM_SIZE) - 1 : 0] base_addr             ;
    reg [$clog2(OFM_RAM_SIZE) - 1 : 0] base_addr_rst         ;
    reg [$clog2(OFM_RAM_SIZE) - 1 : 0] start_window_addr     ;
    reg [$clog2(OFM_RAM_SIZE) - 1 : 0] start_window_addr_rst ;

    reg [4:0] count_channel;
    reg [8:0] count_height ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IDLE;
        else        current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            IDLE:         if (write)                              next_state = NEXT_CHANNEL;
            NEXT_CHANNEL: if (count_channel == read_wgt_size - 1) next_state = UPDATE_BASE_ADDR;
            UPDATE_BASE_ADDR: next_state = IDLE; 
            default:          next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                    ofm_addr              <= 0                                                                                                                                                                                                                           ;                    
                    write_ofm_size        <= (upsample_mode == 1) ? ((ofm_size/2 < SYSTOLIC_SIZE) ? ofm_size/2 : SYSTOLIC_SIZE) : ((maxpool_mode == 1) ? ((maxpool_stride == 1) ? ofm_size : ((ofm_size < SYSTOLIC_SIZE/2) ? ofm_size : SYSTOLIC_SIZE/2)) : ((ofm_size < SYSTOLIC_SIZE) ? ofm_size : SYSTOLIC_SIZE)) ;
                    base_addr             <= 0                                                                                                                                                                                                                           ;
                    base_addr_rst         <= 0                                                                                                                                                                                                                           ;
                    start_window_addr     <= 0                                                                                                                                                                                                                           ; 
                    start_window_addr_rst <= 0                                                                                                                                                                                                                           ;
                    count_channel         <= 0                                                                                                                                                                                                                           ;
                    count_height          <= 0                                                                                                                                                                                                                           ; 
        end 
        else begin
            case (next_state)
                IDLE: begin
                    ofm_addr              <= start_window_addr                                                                                                                                                                                                                                        ;
                    write_ofm_size        <= (start) ? ((upsample_mode == 1) ? ((ofm_size/2 < SYSTOLIC_SIZE) ? ofm_size/2 : SYSTOLIC_SIZE) : ((maxpool_mode == 1) ? ((maxpool_stride == 1) ? ofm_size : ((ofm_size < SYSTOLIC_SIZE/2) ? ofm_size : SYSTOLIC_SIZE/2)) : ((ofm_size < SYSTOLIC_SIZE) ? ofm_size : SYSTOLIC_SIZE))) : write_ofm_size ;
                    base_addr_rst         <= (start) ? 0 : base_addr_rst                                                                                                                                                                                                                              ;
                    start_window_addr_rst <= (start) ? 0 : start_window_addr_rst                                                                                                                                                                                                                      ;
                    count_channel         <= 0                                                                                                                                                                                                                                                        ;
                end                            
                NEXT_CHANNEL: begin
                    ofm_addr      <= start_window_addr + (count_channel + 1) * ofm_size * ofm_size ;  
                    count_channel <= count_channel + 1                                             ;
                end
                UPDATE_BASE_ADDR: begin
                    count_height          <= (upsample_mode == 1) ? ((count_height == ofm_size/2 - 1) ? 0 : count_height + 1) : ((count_height == ofm_size - 1) ? 0 : count_height + 1)                                                                                                                                                                                                                                                                                                                                              ;
                    base_addr             <= (upsample_mode == 1) ? (((base_addr_rst + write_ofm_size*2 + ofm_size*3) % (ofm_size * ofm_size) == 0) ? ofm_size * ofm_size * read_wgt_size * count_filter : ((count_height == ofm_size/2 - 2) ? base_addr + write_ofm_size*2 : base_addr)) : (((start_window_addr_rst + write_ofm_size + ofm_size) % (ofm_size * ofm_size) == 0) ? start_write_addr + ofm_size * ofm_size * read_wgt_size * count_filter : ((count_height == ofm_size - 2) ? base_addr + write_ofm_size : base_addr)) ;                                                            
                    base_addr_rst         <= (upsample_mode == 1) ? (((base_addr_rst + write_ofm_size*2 + ofm_size*3) % (ofm_size * ofm_size) == 0) ? ofm_size * ofm_size * read_wgt_size * count_filter : ((count_height == ofm_size/2 - 2) ? base_addr_rst + write_ofm_size*2 : base_addr_rst)) : (((start_window_addr_rst + write_ofm_size + ofm_size) % (ofm_size * ofm_size) == 0) ? ofm_size * ofm_size * read_wgt_size * count_filter : ((count_height == ofm_size - 2) ? base_addr_rst + write_ofm_size : base_addr_rst))    ;
                    start_window_addr     <= (upsample_mode == 1) ? ((count_height == ofm_size/2 - 1) ? base_addr : start_window_addr + ofm_size*2) : ((count_height == ofm_size - 1) ? base_addr : start_window_addr + ofm_size)                                                                                                                                                                                                                                                                                                    ;                            
                    start_window_addr_rst <= (upsample_mode == 1) ? ((count_height == ofm_size/2 - 1) ? base_addr_rst : start_window_addr_rst + ofm_size*2) : ((count_height == ofm_size - 1) ? base_addr_rst : start_window_addr_rst + ofm_size)                                                                                                                                                                                                                                                                                    ;   
                    write_ofm_size        <= (upsample_mode == 1) ? ((base_addr_rst % ofm_size) + write_ofm_size*2 >= ofm_size ? (ofm_size - (base_addr_rst % ofm_size))/2 : ((ofm_size/2 < SYSTOLIC_SIZE) ? ofm_size/2 : SYSTOLIC_SIZE)) : ((base_addr_rst % ofm_size) + write_ofm_size >= ofm_size ? (ofm_size - (base_addr_rst % ofm_size)) : ((maxpool_mode == 1) ? ((maxpool_stride == 1) ? ofm_size : ((ofm_size < SYSTOLIC_SIZE/2) ? ofm_size : SYSTOLIC_SIZE/2)) : ((ofm_size < SYSTOLIC_SIZE) ? ofm_size : SYSTOLIC_SIZE)))                                             ; 
                end
            endcase
        end
    end

endmodule