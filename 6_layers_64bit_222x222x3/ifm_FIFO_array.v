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
            5'd1:    ifm_data_in = {960'b0, data_in[63 :0]} ; 	
            5'd2:    ifm_data_in = {896'b0, data_in[127:0]} ;	
            5'd3:    ifm_data_in = {832'b0, data_in[191:0]} ;  
            5'd4:    ifm_data_in = {768'b0, data_in[255:0]} ;  
            5'd5:    ifm_data_in = {704'b0, data_in[319:0]} ;  
            5'd6:    ifm_data_in = {640'b0, data_in[383:0]} ;  
            5'd7:    ifm_data_in = {576'b0, data_in[447:0]} ;  
            5'd8:    ifm_data_in = {512'b0, data_in[511:0]} ;  
            5'd9:    ifm_data_in = {448'b0, data_in[575:0]} ;  
            5'd10:   ifm_data_in = {384'b0, data_in[639:0]} ;  
            5'd11:   ifm_data_in = {320'b0, data_in[703:0]} ;  
            5'd12:   ifm_data_in = {256'b0, data_in[767:0]} ;  
            5'd13:   ifm_data_in = {192'b0, data_in[831:0]} ;  
            5'd14:   ifm_data_in = {128'b0, data_in[895:0]} ;  
            5'd15:   ifm_data_in = { 64'b0, data_in[959:0]} ;  
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