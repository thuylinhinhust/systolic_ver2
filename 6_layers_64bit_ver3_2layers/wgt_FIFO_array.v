module wgt_FIFO_array #(
    parameter DATA_WIDTH        = 16   ,
    parameter MAX_WGT_FIFO_SIZE = 4608 ,
    parameter NUM_FIFO          = 16
) (
    input                                  clk           ,
    input                                  rd_clr        ,
    input                                  wr_clr        ,
    input  [NUM_FIFO              - 1 : 0] rd_en         ,
    input                                  wr_en         ,
    input  [4:0]                           read_wgt_size ,
    input  [DATA_WIDTH * NUM_FIFO - 1 : 0] data_in       ,
    output [DATA_WIDTH * NUM_FIFO - 1 : 0] data_out
);

    reg [DATA_WIDTH * NUM_FIFO - 1 : 0] wgt_data_in ;    

    always @(read_wgt_size, data_in) begin
        case (read_wgt_size)
            5'd1:    wgt_data_in = {960'b0, data_in[63 :0]} ; 	
            5'd2:    wgt_data_in = {896'b0, data_in[127:0]} ;	
            5'd3:    wgt_data_in = {832'b0, data_in[191:0]} ;  
            5'd4:    wgt_data_in = {768'b0, data_in[255:0]} ;  
            5'd5:    wgt_data_in = {704'b0, data_in[319:0]} ;  
            5'd6:    wgt_data_in = {640'b0, data_in[383:0]} ;  
            5'd7:    wgt_data_in = {576'b0, data_in[447:0]} ;  
            5'd8:    wgt_data_in = {512'b0, data_in[511:0]} ;  
            5'd9:    wgt_data_in = {448'b0, data_in[575:0]} ;  
            5'd10:   wgt_data_in = {384'b0, data_in[639:0]} ;  
            5'd11:   wgt_data_in = {320'b0, data_in[703:0]} ;  
            5'd12:   wgt_data_in = {256'b0, data_in[767:0]} ;  
            5'd13:   wgt_data_in = {192'b0, data_in[831:0]} ;  
            5'd14:   wgt_data_in = {128'b0, data_in[895:0]} ;  
            5'd15:   wgt_data_in = { 64'b0, data_in[959:0]} ;  
            5'd16:   wgt_data_in = data_in ;
            default: wgt_data_in = data_in ;
        endcase
    end

    genvar i;
    generate
        for (i = 0; i < NUM_FIFO; i = i + 1) begin
            FIFO #(.DATA_WIDTH (DATA_WIDTH), .FIFO_SIZE (MAX_WGT_FIFO_SIZE)) wgt_FIFO_inst (
                .clk           ( clk                                        ) ,
                .rd_clr        ( rd_clr                                     ) ,
                .wr_clr        ( wr_clr                                     ) ,
                .rd_inc        ( 1'b1                                       ) ,
                .wr_inc        ( 1'b1                                       ) ,
                .rd_en         ( rd_en [i]                                  ) ,
                .wr_en         ( wr_en                                      ) ,
                .data_in_fifo  ( wgt_data_in [i * DATA_WIDTH +: DATA_WIDTH] ) ,
                .data_out_fifo ( data_out    [i * DATA_WIDTH +: DATA_WIDTH] )
            );
        end
    endgenerate

endmodule