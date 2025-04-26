module yolov3_tiny #(
	parameter SYSTOLIC_SIZE     = 16      ,
	parameter DATA_WIDTH        = 16      ,
	parameter INOUT_WIDTH       = 256     ,
	parameter IFM_RAM_SIZE      = 519168  ,
	parameter WGT_RAM_SIZE      = 8845488 ,
	parameter OFM_RAM_SIZE      = 2378675 ,
	parameter MAX_WGT_FIFO_SIZE = 4608    ,
	parameter RELU_PARAM        = 0       ,
    parameter NUM_LAYER         = 13
) (
	input  clk       ,
	input  rst_n     ,
	input  start_CNN ,
	output done_CNN       
);

    wire start ;
    wire done  ;

    wire [3 : 0] count_layer    ;    
    wire [8 : 0] ifm_size       ;
    wire [10: 0] ifm_channel    ;
    wire [1 : 0] kernel_size    ; 
    wire [10: 0] num_filter     ;
    wire         maxpool_mode   ;
    wire [1 : 0] maxpool_stride ;
    wire         upsample_mode  ;

    wire [$clog2(OFM_RAM_SIZE) - 1 : 0] start_write_addr ;
    wire [$clog2(OFM_RAM_SIZE) - 1 : 0] start_read_addr  ;

TOP #(
    .SYSTOLIC_SIZE     ( SYSTOLIC_SIZE     ) ,
    .DATA_WIDTH        ( DATA_WIDTH        ) ,
    .INOUT_WIDTH       ( INOUT_WIDTH       ) ,
    .IFM_RAM_SIZE      ( IFM_RAM_SIZE      ) ,
    .WGT_RAM_SIZE      ( WGT_RAM_SIZE      ) ,
    .OFM_RAM_SIZE      ( OFM_RAM_SIZE      ) ,
    .MAX_WGT_FIFO_SIZE ( MAX_WGT_FIFO_SIZE ) ,
    .RELU_PARAM        ( RELU_PARAM        )
) single_layer (
    .clk              ( clk              ) ,
    .rst_n            ( rst_n            ) ,
    .start            ( start            ) ,
    .done             ( done             ) ,
    //Layer config
    .count_layer      ( count_layer      ) ,
    .ifm_size         ( ifm_size         ) ,
    .ifm_channel      ( ifm_channel      ) ,
    .kernel_size      ( kernel_size      ) ,
    .num_filter       ( num_filter       ) ,
    .maxpool_mode     ( maxpool_mode     ) ,
    .maxpool_stride   ( maxpool_stride   ) ,
    .upsample_mode    ( upsample_mode    ) ,

    .start_write_addr ( start_write_addr ) ,
    .start_read_addr  ( start_read_addr  )
);

main_controller #(.NUM_LAYER (NUM_LAYER), .OFM_RAM_SIZE (OFM_RAM_SIZE)) main_control (
    .clk              ( clk              ) ,
    .rst_n            ( rst_n            ) ,
    .start_CNN        ( start_CNN        ) ,
    .done_layer       ( done             ) ,
    .start_layer      ( start            ) ,
    .done_CNN         ( done_CNN         ) ,
    //Layer config
    .count_layer      ( count_layer      ) ,
    .ifm_size         ( ifm_size         ) ,
    .ifm_channel      ( ifm_channel      ) ,
    .kernel_size      ( kernel_size      ) ,
    .num_filter       ( num_filter       ) ,
    .maxpool_mode     ( maxpool_mode     ) ,
    .maxpool_stride   ( maxpool_stride   ) ,
    .upsample_mode    ( upsample_mode    ) ,
    
    .start_write_addr ( start_write_addr ) ,
    .start_read_addr  ( start_read_addr  )
);

endmodule