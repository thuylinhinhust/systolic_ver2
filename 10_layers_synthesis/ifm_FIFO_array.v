module ifm_FIFO_array #(
    parameter DATA_WIDTH        = 16   ,
    parameter MAX_WGT_FIFO_SIZE = 4608 ,
    parameter NUM_FIFO          = 16
) (
    input                                  clk           , 
    input                                  rd_clr_1      ,
    input                                  wr_clr_1      ,
    input  [NUM_FIFO              - 1 : 0] rd_en_1       ,
    input                                  wr_en_1       ,

    input                                  rd_clr_2      ,
    input                                  wr_clr_2      , 
    input  [NUM_FIFO              - 1 : 0] rd_en_2       ,
    input                                  wr_en_2       ,

    input                                  ifm_demux     ,
    input                                  ifm_mux       ,
    input  [4:0]                           read_ifm_size ,     
    input  [DATA_WIDTH * NUM_FIFO - 1 : 0] data_in       ,
    output [DATA_WIDTH * NUM_FIFO - 1 : 0] data_out
);

    reg [DATA_WIDTH * NUM_FIFO - 1 : 0] ifm_data_in ;
    
    always @(read_ifm_size, data_in) begin
        case (read_ifm_size)
            5'd1:    ifm_data_in = {240'b0, data_in[15 :0]} ; 	
            5'd2:    ifm_data_in = {224'b0, data_in[31 :0]} ;	
            5'd3:    ifm_data_in = {208'b0, data_in[47 :0]} ;
            5'd4:    ifm_data_in = {192'b0, data_in[63 :0]} ; 	
            5'd5:    ifm_data_in = {176'b0, data_in[79 :0]} ;	
            5'd6:    ifm_data_in = {160'b0, data_in[95 :0]} ;
            5'd7:    ifm_data_in = {144'b0, data_in[111:0]} ; 	
            5'd8:    ifm_data_in = {128'b0, data_in[127:0]} ;	
            5'd9:    ifm_data_in = {112'b0, data_in[143:0]} ;
            5'd10:   ifm_data_in = {96'b0 , data_in[159:0]} ; 	
            5'd11:   ifm_data_in = {80'b0 , data_in[175:0]} ;	
            5'd12:   ifm_data_in = {64'b0 , data_in[191:0]} ;
            5'd13:   ifm_data_in = {48'b0 , data_in[207:0]} ; 	
            5'd14:   ifm_data_in = {32'b0 , data_in[223:0]} ;	
            5'd15:   ifm_data_in = {16'b0 , data_in[239:0]} ;
            5'd16:   ifm_data_in = data_in ;
            default: ifm_data_in = data_in ;
        endcase
    end
  
    genvar i;
    generate
        for (i = 0; i < NUM_FIFO; i = i + 1) begin
            ifm_FIFO #(.DATA_WIDTH (DATA_WIDTH), .MAX_WGT_FIFO_SIZE (MAX_WGT_FIFO_SIZE)) ifm_FIFO_inst (
                .clk       ( clk                                        ) ,
                .rd_clr_1  ( rd_clr_1                                   ) ,
                .wr_clr_1  ( wr_clr_1                                   ) ,
                .rd_en_1   ( rd_en_1 [i]                                ) ,
                .wr_en_1   ( wr_en_1                                    ) ,
                .rd_clr_2  ( rd_clr_2                                   ) ,
                .wr_clr_2  ( wr_clr_2                                   ) ,
                .rd_en_2   ( rd_en_2 [i]                                ) ,
                .wr_en_2   ( wr_en_2                                    ) ,
                .ifm_demux ( ifm_demux                                  ) ,
                .ifm_mux   ( ifm_mux                                    ) ,
                .data_in   ( ifm_data_in [i * DATA_WIDTH +: DATA_WIDTH] ) ,
                .data_out  ( data_out    [i * DATA_WIDTH +: DATA_WIDTH] )
            );
        end
    endgenerate

endmodule