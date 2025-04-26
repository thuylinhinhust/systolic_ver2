module main_controller #(
    parameter NUM_LAYER    = 13      ,
    parameter OFM_RAM_SIZE = 2378675  
) (
    input                                     clk              ,
    input                                     rst_n            ,
    input                                     start_CNN        ,
    input                                     done_layer       ,
    output reg                                start_layer      ,
    output reg                                done_CNN         ,

    //Layer config
    output reg [3 : 0]                        count_layer      ,
    output reg [8 : 0]                        ifm_size         ,
    output reg [10: 0]                        ifm_channel      ,
    output reg [1 : 0]                        kernel_size      , 
    output reg [10: 0]                        num_filter       ,
    output reg                                maxpool_mode     ,
    output reg [1 : 0]                        maxpool_stride   ,
    output reg                                upsample_mode    ,

    output reg [$clog2(OFM_RAM_SIZE) - 1 : 0] start_write_addr ,
    output reg [$clog2(OFM_RAM_SIZE) - 1 : 0] start_read_addr
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

    always @(negedge start_CNN or negedge done_layer or negedge rst_n) begin
        if (!rst_n) count_layer = 0               ;
        else        count_layer = count_layer + 1 ;
    end

    always @(count_layer) begin
        case (count_layer)
            4'd1: begin
                ifm_size         = 9'd318      ; //416
                ifm_channel      = 11'd3       ;
                kernel_size      = 2'd3        ;
                num_filter       = 11'd16      ;
                maxpool_mode     = 1           ;
                maxpool_stride   = 2'd2        ;
                upsample_mode    = 0           ;
                start_write_addr = 22'd0       ;
                start_read_addr  = 22'd0       ;
            end 
            4'd2: begin
                ifm_size         = 9'd158      ; //208
                ifm_channel      = 11'd16      ;
                kernel_size      = 2'd3        ;
                num_filter       = 11'd16      ;
                maxpool_mode     = 1           ;
                maxpool_stride   = 2'd2        ;
                upsample_mode    = 0           ;
                start_write_addr = 22'd399424  ; //692224
                start_read_addr  = 22'd0       ;
            end 
            4'd3: begin
                ifm_size         = 9'd78       ;
                ifm_channel      = 11'd16      ;
                kernel_size      = 2'd3        ;
                num_filter       = 11'd16      ;
                maxpool_mode     = 1           ;
                maxpool_stride   = 2'd2        ;
                upsample_mode    = 0           ;
                start_write_addr = 22'd496768  ;
                start_read_addr  = 22'd399424  ;
            end 
            4'd4: begin
                ifm_size         = 9'd38       ;
                ifm_channel      = 11'd16      ;
                kernel_size      = 2'd3        ;
                num_filter       = 11'd16      ;
                maxpool_mode     = 1           ;
                maxpool_stride   = 2'd2        ;
                upsample_mode    = 0           ;
                start_write_addr = 22'd519872  ;
                start_read_addr  = 22'd496768  ;
            end 
            4'd5: begin
                ifm_size         = 9'd18       ;
                ifm_channel      = 11'd16      ;
                kernel_size      = 2'd3        ;
                num_filter       = 11'd16      ;
                maxpool_mode     = 1           ;
                maxpool_stride   = 2'd2        ;
                upsample_mode    = 0           ;
                start_write_addr = 22'd525056  ;
                start_read_addr  = 22'd519872  ;
            end 
            4'd6: begin
                ifm_size         = 9'd8        ;
                ifm_channel      = 11'd16      ;
                kernel_size      = 2'd3        ;
                num_filter       = 11'd16      ;
                maxpool_mode     = 1           ;
                maxpool_stride   = 2'd1        ;
                upsample_mode    = 0           ;
                start_write_addr = 22'd526080  ;
                start_read_addr  = 22'd525056  ;                
            end 
            4'd7: begin
                ifm_size         = 9'd6        ;
                ifm_channel      = 11'd16      ;
                kernel_size      = 2'd3        ;
                num_filter       = 11'd16      ;
                maxpool_mode     = 0           ;
                maxpool_stride   = 2'd0        ;
                upsample_mode    = 0           ;
                start_write_addr = 22'd526656  ;
                start_read_addr  = 22'd526080  ;                       
            end 
            4'd8: begin
                ifm_size         = 9'd4        ;
                ifm_channel      = 11'd16      ;
                kernel_size      = 2'd1        ;
                num_filter       = 11'd16      ;
                maxpool_mode     = 0           ;
                maxpool_stride   = 2'd0        ;
                upsample_mode    = 0           ;
                start_write_addr = 22'd526912  ;
                start_read_addr  = 22'd526656  ;                
            end 
            4'd9: begin
                ifm_size         = 9'd13       ;
                ifm_channel      = 11'd256     ;
                kernel_size      = 2'd3        ;
                num_filter       = 11'd512     ;
                maxpool_mode     = 0           ;
                maxpool_stride   = 2'd0        ;
                upsample_mode    = 0           ;
                start_write_addr = 22'd1644032 ;
                start_read_addr  = 22'd1600768 ;                
            end 
            4'd10: begin
                ifm_size         = 9'd13       ;
                ifm_channel      = 11'd512     ;
                kernel_size      = 2'd1        ;
                num_filter       = 11'd255     ;
                maxpool_mode     = 0           ;
                maxpool_stride   = 2'd0        ;
                upsample_mode    = 0           ;
                start_write_addr = 22'd1730560 ;
                start_read_addr  = 22'd1644032 ;                
            end 
            4'd11: begin
                ifm_size         = 9'd13       ;
                ifm_channel      = 11'd256     ;
                kernel_size      = 2'd1        ;
                num_filter       = 11'd128     ;
                maxpool_mode     = 0           ;
                maxpool_stride   = 2'd0        ;
                upsample_mode    = 1           ;
                start_write_addr = 22'd1773655 ;
                start_read_addr  = 22'd1730560 ;                
            end 
            4'd12: begin
                ifm_size         = 9'd26       ;
                ifm_channel      = 11'd384     ;
                kernel_size      = 2'd3        ;
                num_filter       = 11'd256     ;
                maxpool_mode     = 0           ;
                maxpool_stride   = 2'd0        ;
                upsample_mode    = 0           ;
                start_write_addr = 22'd1860183 ;
                start_read_addr  = 22'd1773655 ;                
            end 
            4'd13: begin
                ifm_size         = 9'd26       ;
                ifm_channel      = 11'd256     ;
                kernel_size      = 2'd1        ;
                num_filter       = 11'd255     ;
                maxpool_mode     = 0           ;
                maxpool_stride   = 2'd0        ;
                upsample_mode    = 0           ;
                start_write_addr = 22'd2033239 ;
                start_read_addr  = 22'd1860183 ;                
            end 
            default: begin
                ifm_size         = 9'd0        ;
                ifm_channel      = 11'd0       ;
                kernel_size      = 2'd0        ;
                num_filter       = 11'd0       ;
                maxpool_mode     = 0           ;
                maxpool_stride   = 2'd0        ;
                upsample_mode    = 0           ;
                start_write_addr = 22'd0       ;
                start_read_addr  = 22'd0       ;                
            end
        endcase
        
    end

endmodule