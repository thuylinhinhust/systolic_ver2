module yolov3_tiny #(
	parameter SYSTOLIC_SIZE     = 16      ,
	parameter DATA_WIDTH        = 16      ,
	parameter INOUT_WIDTH       = 256     ,
	parameter IFM_RAM_SIZE      = 524172  ,
	parameter WGT_RAM_SIZE      = 8845488 ,
	parameter OFM_RAM_SIZE_1    = 2205619 ,
    parameter OFM_RAM_SIZE_2    = 259584  ,
	parameter MAX_WGT_FIFO_SIZE = 4608    ,
	parameter RELU_PARAM        = 0       ,
    parameter NUM_LAYER         = 13
) (
	input                                   clk                ,
	input                                   rst_n              ,
	input                                   start_CNN          ,
	output                                  done_CNN           ,

	output                                  ifm_read_en        ,
	output [$clog2(IFM_RAM_SIZE)   - 1 : 0] ifm_addr_a         ,
	input  [INOUT_WIDTH            - 1 : 0] ifm_data_in        ,

	output                                  wgt_read_en        ,
	output [$clog2(WGT_RAM_SIZE)   - 1 : 0] wgt_addr_a         ,
	input  [INOUT_WIDTH            - 1 : 0] wgt_data_in        ,

	output                                  ofm_read_en_1      ,
	output [$clog2(OFM_RAM_SIZE_1) - 1 : 0] ofm_addr_a_1       ,
	input  [INOUT_WIDTH            - 1 : 0] ofm_data_in_1      ,

	output                                  write_out_ofm_en_1 ,           
	output [$clog2(OFM_RAM_SIZE_1) - 1 : 0] ofm_addr_b_1       ,
	output [INOUT_WIDTH            - 1 : 0] ofm_data_out_1     ,
	output [4 : 0]                          write_ofm_size_1   ,

	output                                  ofm_read_en_2      ,
	output [$clog2(OFM_RAM_SIZE_2) - 1 : 0] ofm_addr_a_2       ,
	input  [INOUT_WIDTH            - 1 : 0] ofm_data_in_2      ,

	output                                  write_out_ofm_en_2 ,           
	output [$clog2(OFM_RAM_SIZE_2) - 1 : 0] ofm_addr_b_2       ,
	output [INOUT_WIDTH            - 1 : 0] ofm_data_out_2     ,
	output [4 : 0]                          write_ofm_size_2   ,
    
    output                                  upsample_mode      ,
	output [8 : 0]                          ofm_size           ,
    output [8 : 0]                          ofm_size_ofm_ram_2
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

    wire [$clog2(OFM_RAM_SIZE_1) - 1 : 0] start_write_addr_1 ;
    wire [$clog2(OFM_RAM_SIZE_1) - 1 : 0] start_read_addr_1  ;
    wire [$clog2(OFM_RAM_SIZE_2) - 1 : 0] start_write_addr_2 ;
    wire [$clog2(OFM_RAM_SIZE_2) - 1 : 0] start_read_addr_2  ;

Functional_Unit #(
    .SYSTOLIC_SIZE     ( SYSTOLIC_SIZE     ) ,
    .DATA_WIDTH        ( DATA_WIDTH        ) ,
    .INOUT_WIDTH       ( INOUT_WIDTH       ) ,
    .IFM_RAM_SIZE      ( IFM_RAM_SIZE      ) ,
    .WGT_RAM_SIZE      ( WGT_RAM_SIZE      ) ,
    .OFM_RAM_SIZE_1    ( OFM_RAM_SIZE_1    ) ,
    .OFM_RAM_SIZE_2    ( OFM_RAM_SIZE_2    ) ,
    .MAX_WGT_FIFO_SIZE ( MAX_WGT_FIFO_SIZE ) ,
    .RELU_PARAM        ( RELU_PARAM        )
) F_U (
    .clk                ( clk                ) ,
    .rst_n              ( rst_n              ) ,
    .start              ( start              ) ,
    .done               ( done               ) ,

    //Layer config
    .count_layer        ( count_layer        ) ,
    .ifm_size           ( ifm_size           ) ,
    .ifm_channel        ( ifm_channel        ) ,
    .kernel_size        ( kernel_size        ) ,
    .num_filter         ( num_filter         ) ,
    .maxpool_mode       ( maxpool_mode       ) ,
    .maxpool_stride     ( maxpool_stride     ) ,
    .upsample_mode      ( upsample_mode      ) ,

    .start_write_addr_1 ( start_write_addr_1 ) ,
    .start_read_addr_1  ( start_read_addr_1  ) ,
    .start_write_addr_2 ( start_write_addr_2 ) ,
    .start_read_addr_2  ( start_read_addr_2  ) ,

    //RAM
    .ifm_read_en        ( ifm_read_en        ) ,
    .ifm_addr_a         ( ifm_addr_a         ) ,
    .ifm_data_in        ( ifm_data_in        ) ,
    
    .wgt_read_en        ( wgt_read_en        ) ,
    .wgt_addr_a         ( wgt_addr_a         ) ,
    .wgt_data_in        ( wgt_data_in        ) ,
    
    .ofm_read_en_1      ( ofm_read_en_1      ) ,
    .ofm_addr_a_1       ( ofm_addr_a_1       ) ,
    .ofm_data_in_1      ( ofm_data_in_1      ) ,
    
    .write_out_ofm_en_1 ( write_out_ofm_en_1 ) ,
    .ofm_addr_b_1       ( ofm_addr_b_1       ) ,
    .ofm_data_out_1     ( ofm_data_out_1     ) ,
    .write_ofm_size_1   ( write_ofm_size_1   ) ,

    .ofm_read_en_2      ( ofm_read_en_2      ) ,
    .ofm_addr_a_2       ( ofm_addr_a_2       ) ,
    .ofm_data_in_2      ( ofm_data_in_2      ) ,
    
    .write_out_ofm_en_2 ( write_out_ofm_en_2 ) ,
    .ofm_addr_b_2       ( ofm_addr_b_2       ) ,
    .ofm_data_out_2     ( ofm_data_out_2     ) ,
    .write_ofm_size_2   ( write_ofm_size_2   ) ,

    .ofm_size           ( ofm_size           ) ,
    .ofm_size_ofm_ram_2 ( ofm_size_ofm_ram_2 ) 
);

Control_Unit #(.NUM_LAYER (NUM_LAYER), .OFM_RAM_SIZE_1 (OFM_RAM_SIZE_1), .OFM_RAM_SIZE_2 (OFM_RAM_SIZE_2)) C_U (
    .clk                ( clk                ) ,
    .rst_n              ( rst_n              ) ,
    .start_CNN          ( start_CNN          ) ,
    .done_layer         ( done               ) ,
    .start_layer        ( start              ) ,
    .done_CNN           ( done_CNN           ) ,

    //Layer config
    .count_layer        ( count_layer        ) ,
    .ifm_size           ( ifm_size           ) ,
    .ifm_channel        ( ifm_channel        ) ,
    .kernel_size        ( kernel_size        ) ,
    .num_filter         ( num_filter         ) ,
    .maxpool_mode       ( maxpool_mode       ) ,
    .maxpool_stride     ( maxpool_stride     ) ,
    .upsample_mode      ( upsample_mode      ) ,
    
    .start_write_addr_1 ( start_write_addr_1 ) ,
    .start_read_addr_1  ( start_read_addr_1  ) ,
    .start_write_addr_2 ( start_write_addr_2 ) ,
    .start_read_addr_2  ( start_read_addr_2  )
);

endmodule