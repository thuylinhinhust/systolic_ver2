module Control_Unit #(
    parameter NUM_LAYER      = 13      ,
    parameter OFM_RAM_SIZE_1 = 2205619 ,  
    parameter OFM_RAM_SIZE_2 = 259584 
) (
    input                                       clk                ,
    input                                       rst_n              ,
    input                                       start_CNN          ,
    input                                       done_layer         ,
    output reg                                  start_layer        ,
    output reg                                  done_CNN           ,

    //Layer config
    output reg [3 : 0]                          count_layer        ,
    output reg [8 : 0]                          ifm_size           ,
    output reg [10: 0]                          ifm_channel        ,
    output reg [1 : 0]                          kernel_size        ,   
    output reg [10: 0]                          num_filter         ,
    output reg                                  maxpool_mode       ,
    output reg [1 : 0]                          maxpool_stride     ,
    output reg                                  upsample_mode      ,

    output reg [$clog2(OFM_RAM_SIZE_1) - 1 : 0] start_write_addr_1 ,
    output reg [$clog2(OFM_RAM_SIZE_1) - 1 : 0] start_read_addr_1  ,
    output reg [$clog2(OFM_RAM_SIZE_2) - 1 : 0] start_write_addr_2 ,
    output reg [$clog2(OFM_RAM_SIZE_2) - 1 : 0] start_read_addr_2  
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                start_layer <= 0 ;
                done_CNN    <= 0 ;
        end
        else begin
            if (count_layer < NUM_LAYER) begin
                start_layer <= (start_CNN || done_layer) ;
                done_CNN    <= 0                         ;
            end
            else if (count_layer == NUM_LAYER) begin
                start_layer <= 0          ;
                done_CNN    <= done_layer ;
            end
            else begin
                start_layer <= 0 ;
                done_CNN    <= 0 ;
            end
        end
    end

    reg start_CNN_d;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start_CNN_d <= 0 ;
            count_layer <= 0 ;
        end 
        else begin
            start_CNN_d <= start_CNN ;
            if ((start_CNN_d == 0 && start_CNN == 1) || done_layer == 1) count_layer <= count_layer + 1 ;
        end
    end

    always @(count_layer) begin
        case (count_layer)
            4'd1: begin
                ifm_size           = 9'd418      ; 
                ifm_channel        = 11'd3       ;
                kernel_size        = 2'd3        ;
                num_filter         = 11'd16      ;
                maxpool_mode       = 1           ;
                maxpool_stride     = 2'd2        ;
                upsample_mode      = 0           ;
                start_write_addr_1 = 22'd0       ;
                start_read_addr_1  = 22'd0       ;
                start_write_addr_2 = 22'd0       ;
                start_read_addr_2  = 22'd0       ;
            end 
            4'd2: begin
                ifm_size           = 9'd208      ; 
                ifm_channel        = 11'd16      ;
                kernel_size        = 2'd3        ;
                num_filter         = 11'd32      ;
                maxpool_mode       = 1           ;
                maxpool_stride     = 2'd2        ;
                upsample_mode      = 0           ;
                start_write_addr_1 = 22'd692224  ; 
                start_read_addr_1  = 22'd0       ;
                start_write_addr_2 = 22'd0       ;
                start_read_addr_2  = 22'd0       ;
            end 
            4'd3: begin
                ifm_size           = 9'd104      ;
                ifm_channel        = 11'd32      ;
                kernel_size        = 2'd3        ;
                num_filter         = 11'd64      ;
                maxpool_mode       = 1           ;
                maxpool_stride     = 2'd2        ;
                upsample_mode      = 0           ;
                start_write_addr_1 = 22'd1038336 ;
                start_read_addr_1  = 22'd692224  ;
                start_write_addr_2 = 22'd0       ;
                start_read_addr_2  = 22'd0       ;
            end 
            4'd4: begin
                ifm_size           = 9'd52       ;
                ifm_channel        = 11'd64      ;
                kernel_size        = 2'd3        ;
                num_filter         = 11'd128     ;
                maxpool_mode       = 1           ;
                maxpool_stride     = 2'd2        ;
                upsample_mode      = 0           ;
                start_write_addr_1 = 22'd1211392 ;
                start_read_addr_1  = 22'd1038336 ;
                start_write_addr_2 = 22'd0       ;
                start_read_addr_2  = 22'd0       ;
            end 
            4'd5: begin
                ifm_size           = 9'd26       ;
                ifm_channel        = 11'd128     ;
                kernel_size        = 2'd3        ;
                num_filter         = 11'd256     ;
                maxpool_mode       = 1           ;
                maxpool_stride     = 2'd2        ;
                upsample_mode      = 0           ;
                start_write_addr_1 = 22'd1297920 ;
                start_read_addr_1  = 22'd1211392 ;
                start_write_addr_2 = 22'd86528   ;
                start_read_addr_2  = 22'd0       ;
            end 
            4'd6: begin
                ifm_size           = 9'd13       ;
                ifm_channel        = 11'd256     ;
                kernel_size        = 2'd3        ;
                num_filter         = 11'd512     ;
                maxpool_mode       = 1           ;
                maxpool_stride     = 2'd1        ;
                upsample_mode      = 0           ;
                start_write_addr_1 = 22'd1341184 ;
                start_read_addr_1  = 22'd1297920 ; 
                start_write_addr_2 = 22'd0       ;
                start_read_addr_2  = 22'd0       ;               
            end 
            4'd7: begin
                ifm_size           = 9'd13       ;
                ifm_channel        = 11'd512     ;
                kernel_size        = 2'd3        ;
                num_filter         = 11'd1024    ;
                maxpool_mode       = 0           ;
                maxpool_stride     = 2'd0        ;
                upsample_mode      = 0           ;
                start_write_addr_1 = 22'd1427712 ;
                start_read_addr_1  = 22'd1341184 ;    
                start_write_addr_2 = 22'd0       ;
                start_read_addr_2  = 22'd0       ;            
            end 
            4'd8: begin
                ifm_size           = 9'd13       ;
                ifm_channel        = 11'd1024    ;
                kernel_size        = 2'd1        ;
                num_filter         = 11'd256     ;
                maxpool_mode       = 0           ;
                maxpool_stride     = 2'd0        ;
                upsample_mode      = 0           ;
                start_write_addr_1 = 22'd1600768 ;
                start_read_addr_1  = 22'd1427712 ; 
                start_write_addr_2 = 22'd0       ;
                start_read_addr_2  = 22'd0       ;               
            end 
            4'd9: begin
                ifm_size           = 9'd13       ;
                ifm_channel        = 11'd256     ;
                kernel_size        = 2'd3        ;
                num_filter         = 11'd512     ;
                maxpool_mode       = 0           ;
                maxpool_stride     = 2'd0        ;
                upsample_mode      = 0           ;
                start_write_addr_1 = 22'd1644032 ;
                start_read_addr_1  = 22'd1600768 ;    
                start_write_addr_2 = 22'd0       ;
                start_read_addr_2  = 22'd0       ;            
            end 
            4'd10: begin
                ifm_size           = 9'd13       ;
                ifm_channel        = 11'd512     ;
                kernel_size        = 2'd1        ;
                num_filter         = 11'd255     ;
                maxpool_mode       = 0           ;
                maxpool_stride     = 2'd0        ;
                upsample_mode      = 0           ;
                start_write_addr_1 = 22'd1730560 ;
                start_read_addr_1  = 22'd1644032 ;   
                start_write_addr_2 = 22'd0       ;
                start_read_addr_2  = 22'd0       ;             
            end 
            4'd11: begin
                ifm_size           = 9'd13       ;
                ifm_channel        = 11'd256     ;
                kernel_size        = 2'd1        ;
                num_filter         = 11'd128     ;
                maxpool_mode       = 0           ;
                maxpool_stride     = 2'd0        ;
                upsample_mode      = 1           ;
                start_write_addr_1 = 22'd1773655 ;
                start_read_addr_1  = 22'd1600768 ;  
                start_write_addr_2 = 22'd0       ;
                start_read_addr_2  = 22'd0       ;              
            end 
            4'd12: begin
                ifm_size           = 9'd26       ;
                ifm_channel        = 11'd384     ;
                kernel_size        = 2'd3        ;
                num_filter         = 11'd256     ;
                maxpool_mode       = 0           ;
                maxpool_stride     = 2'd0        ;
                upsample_mode      = 0           ;
                start_write_addr_1 = 22'd1860183 ;
                start_read_addr_1  = 22'd0       ; 
                start_write_addr_2 = 22'd0       ;
                start_read_addr_2  = 22'd0       ;   
            end 
            4'd13: begin
                ifm_size           = 9'd26       ;
                ifm_channel        = 11'd256     ;
                kernel_size        = 2'd1        ;
                num_filter         = 11'd255     ;
                maxpool_mode       = 0           ;
                maxpool_stride     = 2'd0        ;
                upsample_mode      = 0           ;
                start_write_addr_1 = 22'd2033239 ;
                start_read_addr_1  = 22'd1860183 ;       
                start_write_addr_2 = 22'd0       ;
                start_read_addr_2  = 22'd0       ;            
            end 
            default: begin
                ifm_size           = 9'd0        ;
                ifm_channel        = 11'd0       ;
                kernel_size        = 2'd0        ;
                num_filter         = 11'd0       ;
                maxpool_mode       = 0           ;
                maxpool_stride     = 2'd0        ;
                upsample_mode      = 0           ;
                start_write_addr_1 = 22'd0       ;
                start_read_addr_1  = 22'd0       ;    
                start_write_addr_2 = 22'd0       ;
                start_read_addr_2  = 22'd0       ;               
            end
        endcase
    end

endmodule