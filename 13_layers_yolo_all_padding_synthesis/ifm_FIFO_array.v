module ifm_FIFO_array #(
    parameter SYSTOLIC_SIZE     = 16   ,
    parameter DATA_WIDTH        = 16   ,
    parameter INOUT_WIDTH       = 256  ,
    parameter MAX_WGT_FIFO_SIZE = 4608 ,
    parameter NUM_FIFO          = 16
) (
    input                                  clk            , 
    input                                  rst_n          ,

    input                                  rd_clr_1       ,
    input                                  wr_clr_1       ,
    input  [NUM_FIFO              - 1 : 0] rd_en_1        ,
    input                                  wr_en_1        ,

    input                                  rd_clr_2       ,
    input                                  wr_clr_2       , 
    input  [NUM_FIFO              - 1 : 0] rd_en_2        ,
    input                                  wr_en_2        ,

    input                                  ifm_demux      ,
    input                                  ifm_mux        ,
    input  [13: 0]                         count_tiling   ,

    input  [4 : 0]                         read_ifm_size  ,  
    input                                  ofm_read_en    ,   
    
    input  [DATA_WIDTH * NUM_FIFO - 1 : 0] data_in        ,
    output [DATA_WIDTH * NUM_FIFO - 1 : 0] data_out       ,

    input  [3 : 0]                         count_layer    ,
    input  [1 : 0]                         kernel_size    ,
    input  [1 : 0]                         maxpool_stride ,
    input  [8 : 0]                         ofm_size     
);

    wire [4 : 0] num_tiling_per_line = (ofm_size + SYSTOLIC_SIZE - 1) / SYSTOLIC_SIZE ;
    wire [13: 0] num_tiling          = num_tiling_per_line * ofm_size                 ;

    reg [DATA_WIDTH * NUM_FIFO - 1 : 0] ifm_data_in;
    reg [DATA_WIDTH * NUM_FIFO - 1 : 0] ifm_data_in_padding;
    reg [13: 0] count_pixel;

    integer i;
    
    always @(*) begin
        ifm_data_in = {INOUT_WIDTH{1'b0}};
        case (read_ifm_size)
            1 : for (i = 0; i <  1 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            2 : for (i = 0; i <  2 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            3 : for (i = 0; i <  3 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            4 : for (i = 0; i <  4 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            5 : for (i = 0; i <  5 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            6 : for (i = 0; i <  6 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            7 : for (i = 0; i <  7 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            8 : for (i = 0; i <  8 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            9 : for (i = 0; i <  9 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            10: for (i = 0; i < 10 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            11: for (i = 0; i < 11 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            12: for (i = 0; i < 12 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            13: for (i = 0; i < 13 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            14: for (i = 0; i < 14 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            15: for (i = 0; i < 15 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            16: for (i = 0; i < 16 * DATA_WIDTH; i = i + 1) ifm_data_in[i] = data_in[i];
            default: ;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if      (!rst_n)      count_pixel <= 0               ;
        else if (ofm_read_en) count_pixel <= count_pixel + 1 ;
        else                  count_pixel <= 0               ;
    end

    wire [DATA_WIDTH * NUM_FIFO - 1 : 0] shifted_ifm_data_in = ifm_data_in << DATA_WIDTH;

    always @(*) begin
        if (kernel_size == 3 && count_layer > 1) begin
            if (num_tiling_per_line == 1) begin
                if (count_tiling == 1) begin
                    if      (count_pixel % 9 >= 1 && count_pixel % 9 <= 3) ifm_data_in_padding = {INOUT_WIDTH{1'b0}};
                    else if (count_pixel % 9 == 4 || count_pixel % 9 == 7) ifm_data_in_padding = {48'b0,  shifted_ifm_data_in[207:0]};
                    else if (count_pixel % 9 == 6 || count_pixel % 9 == 0) begin
                        ifm_data_in_padding = {INOUT_WIDTH{1'b0}};
                        case (read_ifm_size)
                            1 : ;  //no copy
                            2 : for (i = 0; i <  1 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            3 : for (i = 0; i <  2 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            4 : for (i = 0; i <  3 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            5 : for (i = 0; i <  4 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            6 : for (i = 0; i <  5 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            7 : for (i = 0; i <  6 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            8 : for (i = 0; i <  7 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            9 : for (i = 0; i <  8 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            10: for (i = 0; i <  9 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            11: for (i = 0; i < 10 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            12: for (i = 0; i < 11 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            13: for (i = 0; i < 12 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            14: for (i = 0; i < 13 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            15: for (i = 0; i < 14 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            16: for (i = 0; i < 15 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            default: ;
                        endcase
                    end
                    else ifm_data_in_padding = ifm_data_in;
                end
                else if (count_tiling < ofm_size) begin
                    if      (count_pixel % 9 == 1 || count_pixel % 9 == 4 || count_pixel % 9 == 7) ifm_data_in_padding = {48'b0,  shifted_ifm_data_in[207:0]};
                    else if (count_pixel % 9 == 3 || count_pixel % 9 == 6 || count_pixel % 9 == 0) begin
                        ifm_data_in_padding = {INOUT_WIDTH{1'b0}};
                        case (read_ifm_size)
                            1 : ;  //no copy
                            2 : for (i = 0; i <  1 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            3 : for (i = 0; i <  2 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            4 : for (i = 0; i <  3 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            5 : for (i = 0; i <  4 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            6 : for (i = 0; i <  5 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            7 : for (i = 0; i <  6 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            8 : for (i = 0; i <  7 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            9 : for (i = 0; i <  8 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            10: for (i = 0; i <  9 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            11: for (i = 0; i < 10 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            12: for (i = 0; i < 11 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            13: for (i = 0; i < 12 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            14: for (i = 0; i < 13 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            15: for (i = 0; i < 14 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            16: for (i = 0; i < 15 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            default: ;
                        endcase
                    end
                    else ifm_data_in_padding = ifm_data_in; 
                end
                else begin
                    if      (count_pixel % 9 == 1 || count_pixel % 9 == 4) ifm_data_in_padding = {48'b0,  shifted_ifm_data_in[207:0]};
                    else if (count_pixel % 9 == 3 || count_pixel % 9 == 6) begin
                        ifm_data_in_padding = {INOUT_WIDTH{1'b0}};
                        case (read_ifm_size)
                            1 : ;  //no copy
                            2 : for (i = 0; i <  1 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            3 : for (i = 0; i <  2 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            4 : for (i = 0; i <  3 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            5 : for (i = 0; i <  4 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            6 : for (i = 0; i <  5 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            7 : for (i = 0; i <  6 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            8 : for (i = 0; i <  7 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            9 : for (i = 0; i <  8 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            10: for (i = 0; i <  9 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            11: for (i = 0; i < 10 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            12: for (i = 0; i < 11 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            13: for (i = 0; i < 12 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            14: for (i = 0; i < 13 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            15: for (i = 0; i < 14 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            16: for (i = 0; i < 15 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            default: ;
                        endcase
                    end
                    else if (count_pixel % 9 == 0 || count_pixel % 9 > 6) ifm_data_in_padding = {INOUT_WIDTH{1'b0}};
                    else ifm_data_in_padding = ifm_data_in;  
                end
            end
            else begin
                if (count_tiling == 1) begin
                    if      (count_pixel % 9 >= 1 && count_pixel % 9 <= 3) ifm_data_in_padding = {INOUT_WIDTH{1'b0}} ;
                    else if (count_pixel % 9 == 4 || count_pixel % 9 == 7) ifm_data_in_padding = shifted_ifm_data_in ;   
                    else                                                   ifm_data_in_padding = ifm_data_in         ;
                end
                else if (count_tiling < ofm_size) begin
                    if (count_pixel % 9 == 1 || count_pixel % 9 == 4 || count_pixel % 9 == 7) ifm_data_in_padding = shifted_ifm_data_in;   
                    else                                                                      ifm_data_in_padding = ifm_data_in; 
                end
                else if (count_tiling == ofm_size) begin
                    if      (count_pixel % 9 == 1 || count_pixel % 9 == 4) ifm_data_in_padding = shifted_ifm_data_in ;   
                    else if (count_pixel % 9 == 0 || count_pixel % 9 >  6) ifm_data_in_padding = {INOUT_WIDTH{1'b0}} ;
                    else                                                   ifm_data_in_padding = ifm_data_in         ;  
                end
                else if (count_tiling >= ofm_size * (num_tiling_per_line - 1) + 1) begin
                    if (count_tiling % ofm_size == 1) begin
                        if      (count_pixel % 9 >= 1 && count_pixel % 9 <= 3) ifm_data_in_padding = {INOUT_WIDTH{1'b0}};
                        else if (count_pixel % 9 == 6 || count_pixel % 9 == 0) begin
                        ifm_data_in_padding = {INOUT_WIDTH{1'b0}};
                        case (read_ifm_size)
                            1 : ;  //no copy
                            2 : for (i = 0; i <  1 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            3 : for (i = 0; i <  2 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            4 : for (i = 0; i <  3 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            5 : for (i = 0; i <  4 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            6 : for (i = 0; i <  5 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            7 : for (i = 0; i <  6 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            8 : for (i = 0; i <  7 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            9 : for (i = 0; i <  8 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            10: for (i = 0; i <  9 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            11: for (i = 0; i < 10 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            12: for (i = 0; i < 11 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            13: for (i = 0; i < 12 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            14: for (i = 0; i < 13 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            15: for (i = 0; i < 14 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            16: for (i = 0; i < 15 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            default: ;
                        endcase
                        end
                        else ifm_data_in_padding = ifm_data_in; 
                    end
                    else if (count_tiling % ofm_size == 0) begin
                        if (count_pixel % 9 == 3 || count_pixel % 9 == 6) begin
                        ifm_data_in_padding = {INOUT_WIDTH{1'b0}};
                        case (read_ifm_size)
                            1 : ;  //no copy
                            2 : for (i = 0; i <  1 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            3 : for (i = 0; i <  2 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            4 : for (i = 0; i <  3 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            5 : for (i = 0; i <  4 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            6 : for (i = 0; i <  5 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            7 : for (i = 0; i <  6 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            8 : for (i = 0; i <  7 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            9 : for (i = 0; i <  8 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            10: for (i = 0; i <  9 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            11: for (i = 0; i < 10 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            12: for (i = 0; i < 11 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            13: for (i = 0; i < 12 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            14: for (i = 0; i < 13 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            15: for (i = 0; i < 14 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            16: for (i = 0; i < 15 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            default: ;
                        endcase
                        end
                        else if (count_pixel % 9 == 0 || count_pixel % 9 > 6) ifm_data_in_padding = {INOUT_WIDTH{1'b0}};
                        else ifm_data_in_padding = ifm_data_in; 
                    end
                    else begin
                        if (count_pixel % 9 == 3 || count_pixel % 9 == 6 || count_pixel % 9 == 0) begin
                        ifm_data_in_padding = {INOUT_WIDTH{1'b0}};
                        case (read_ifm_size)
                            1 : ;  //no copy
                            2 : for (i = 0; i <  1 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            3 : for (i = 0; i <  2 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            4 : for (i = 0; i <  3 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            5 : for (i = 0; i <  4 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            6 : for (i = 0; i <  5 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            7 : for (i = 0; i <  6 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            8 : for (i = 0; i <  7 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            9 : for (i = 0; i <  8 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            10: for (i = 0; i <  9 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            11: for (i = 0; i < 10 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            12: for (i = 0; i < 11 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            13: for (i = 0; i < 12 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            14: for (i = 0; i < 13 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            15: for (i = 0; i < 14 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            16: for (i = 0; i < 15 * DATA_WIDTH; i = i + 1) ifm_data_in_padding[i] = ifm_data_in[i];
                            default: ;
                        endcase
                        end
                        else ifm_data_in_padding = ifm_data_in;                
                    end
                end
                else begin
                    if (count_tiling % ofm_size == 1) begin
                        if (count_pixel % 9 >= 1 && count_pixel % 9 <= 3) ifm_data_in_padding = {INOUT_WIDTH{1'b0}} ;
                        else                                              ifm_data_in_padding = ifm_data_in         ; 
                    end
                    else if (count_tiling % ofm_size == 0) begin
                        if (count_pixel % 9 == 0 || count_pixel % 9 > 6) ifm_data_in_padding = {INOUT_WIDTH{1'b0}} ;
                        else                                             ifm_data_in_padding = ifm_data_in         ; 
                    end
                    else ifm_data_in_padding = ifm_data_in;        
                end
            end
        end
        else ifm_data_in_padding = ifm_data_in;    
    end

    genvar j;
    generate
        for (j = 0; j < NUM_FIFO; j = j + 1) begin
            ifm_FIFO #(.DATA_WIDTH (DATA_WIDTH), .MAX_WGT_FIFO_SIZE (MAX_WGT_FIFO_SIZE)) ifm_FIFO_inst (
                .clk       ( clk                                                ) ,
                
                .rd_clr_1  ( rd_clr_1                                           ) ,
                .wr_clr_1  ( wr_clr_1                                           ) ,
                .rd_en_1   ( rd_en_1 [j]                                        ) ,
                .wr_en_1   ( wr_en_1                                            ) ,
                
                .rd_clr_2  ( rd_clr_2                                           ) ,
                .wr_clr_2  ( wr_clr_2                                           ) ,
                .rd_en_2   ( rd_en_2 [j]                                        ) ,
                .wr_en_2   ( wr_en_2                                            ) ,
                
                .ifm_demux ( ifm_demux                                          ) ,
                .ifm_mux   ( ifm_mux                                            ) ,
                
                .data_in   ( ifm_data_in_padding [j * DATA_WIDTH +: DATA_WIDTH] ) ,
                .data_out  ( data_out            [j * DATA_WIDTH +: DATA_WIDTH] )
            );
        end
    endgenerate

endmodule