module yolov3_tiny_tb();

parameter SYSTOLIC_SIZE     = 16      ;
parameter DATA_WIDTH        = 64      ;
parameter INOUT_WIDTH       = 1024    ;
parameter IFM_RAM_SIZE      = 524172  ;
parameter WGT_RAM_SIZE      = 8845488 ;
parameter OFM_RAM_SIZE      = 2378675 ;
parameter MAX_WGT_FIFO_SIZE = 4608    ;
parameter RELU_PARAM        = 0       ;
parameter NUM_LAYER         = 6       ;

localparam OFM_SIZE   = 3   ;
localparam NUM_FILTER = 16  ;

reg  clk       ;
reg  rst_n     ;
reg  start_CNN ;
wire done_CNN  ;

wire ofm_read_en = dut.single_layer.ofm_read_en;
wire write_ofm_en = dut.single_layer.write_out_ofm_en;
wire [$clog2(OFM_RAM_SIZE)  - 1 : 0] ofm_addr_read  = dut.single_layer.ofm_addr_a;
wire [$clog2(OFM_RAM_SIZE)  - 1 : 0] ofm_addr_write = dut.single_layer.ofm_addr_b;

wire [63:0] ofm_data_in_1  = dut.single_layer.ofm_data_in[63:0];
wire [63:0] ofm_data_in_2  = dut.single_layer.ofm_data_in[127:64];
wire [63:0] ofm_data_in_3  = dut.single_layer.ofm_data_in[191:128];
wire [63:0] ofm_data_in_4  = dut.single_layer.ofm_data_in[255:192];
wire [63:0] ofm_data_in_5  = dut.single_layer.ofm_data_in[319:256];
wire [63:0] ofm_data_in_6  = dut.single_layer.ofm_data_in[383:320];
wire [63:0] ofm_data_in_7  = dut.single_layer.ofm_data_in[447:384];
wire [63:0] ofm_data_in_8  = dut.single_layer.ofm_data_in[511:448];
wire [63:0] ofm_data_in_9  = dut.single_layer.ofm_data_in[575:512];
wire [63:0] ofm_data_in_10 = dut.single_layer.ofm_data_in[639:576];
wire [63:0] ofm_data_in_11 = dut.single_layer.ofm_data_in[703:640];
wire [63:0] ofm_data_in_12 = dut.single_layer.ofm_data_in[767:704];
wire [63:0] ofm_data_in_13 = dut.single_layer.ofm_data_in[831:768];
wire [63:0] ofm_data_in_14 = dut.single_layer.ofm_data_in[895:832];
wire [63:0] ofm_data_in_15 = dut.single_layer.ofm_data_in[959:896];
wire [63:0] ofm_data_in_16 = dut.single_layer.ofm_data_in[1023:960];


wire [63:0] ofm_data_out_1  = dut.single_layer.ofm_data_out[63:0];
wire [63:0] ofm_data_out_2  = dut.single_layer.ofm_data_out[127:64];
wire [63:0] ofm_data_out_3  = dut.single_layer.ofm_data_out[191:128];
wire [63:0] ofm_data_out_4  = dut.single_layer.ofm_data_out[255:192];
wire [63:0] ofm_data_out_5  = dut.single_layer.ofm_data_out[319:256];
wire [63:0] ofm_data_out_6  = dut.single_layer.ofm_data_out[383:320];
wire [63:0] ofm_data_out_7  = dut.single_layer.ofm_data_out[447:384];
wire [63:0] ofm_data_out_8  = dut.single_layer.ofm_data_out[511:448];
wire [63:0] ofm_data_out_9  = dut.single_layer.ofm_data_out[575:512];
wire [63:0] ofm_data_out_10 = dut.single_layer.ofm_data_out[639:576];
wire [63:0] ofm_data_out_11 = dut.single_layer.ofm_data_out[703:640];
wire [63:0] ofm_data_out_12 = dut.single_layer.ofm_data_out[767:704];
wire [63:0] ofm_data_out_13 = dut.single_layer.ofm_data_out[831:768];
wire [63:0] ofm_data_out_14 = dut.single_layer.ofm_data_out[895:832];
wire [63:0] ofm_data_out_15 = dut.single_layer.ofm_data_out[959:896];
wire [63:0] ofm_data_out_16 = dut.single_layer.ofm_data_out[1023:960];


yolov3_tiny #(
    .SYSTOLIC_SIZE     ( SYSTOLIC_SIZE     ) ,
    .DATA_WIDTH        ( DATA_WIDTH        ) ,
    .INOUT_WIDTH       ( INOUT_WIDTH       ) ,
    .IFM_RAM_SIZE      ( IFM_RAM_SIZE      ) ,
    .WGT_RAM_SIZE      ( WGT_RAM_SIZE      ) ,
    .OFM_RAM_SIZE      ( OFM_RAM_SIZE      ) ,
    .MAX_WGT_FIFO_SIZE ( MAX_WGT_FIFO_SIZE ) ,
    .RELU_PARAM        ( RELU_PARAM        ) ,
    .NUM_LAYER         ( NUM_LAYER         )
) dut (
    .clk       ( clk       ) ,
    .rst_n     ( rst_n     ) ,
    .start_CNN ( start_CNN ) ,
    .done_CNN  ( done_CNN  ) 
);

//read text files
initial begin
    $readmemb ("./layer1_ifm_bin_c3xh222xw222.txt", dut.single_layer.ifm_dpram.mem);
end

initial begin
    $readmemb ("./weight_bin.txt", dut.single_layer.wgt_dpram.mem);
    //$readmemb ("./layer2_weight_bin_co32xci16xk3xk3.txt", dut.single_layer.wgt_dpram.mem, 8845488'h1B0);
end

reg [DATA_WIDTH - 1 : 0] ofm_golden [OFM_SIZE * OFM_SIZE * NUM_FILTER - 1 : 0];
initial begin
	$readmemb ("./layer6_pooled_bin_c16xh3xw3.txt", ofm_golden);
end

/*
initial begin
    $dumpfile ("yolov3_tiny.VCD");
    $dumpvars (0, yolov3_tiny_tb);
end
*/

//start
always #5 clk = ~clk;

initial begin
    clk   = 0 ;
    rst_n = 0 ;
    start_CNN = 0 ;
    #30 rst_n = 1  ;
    #20 start_CNN = 1  ;
    #20 start_CNN = 0  ;
    #20000000 $finish ; 
end

//write to output text file
integer i, j;
integer file;

initial begin
    wait (done_CNN)
    file = $fopen ("output_matrix.txt", "w");
        for (i = 0; i < OFM_SIZE * NUM_FILTER; i = i + 1) begin
            for (j = 0; j < OFM_SIZE; j = j + 1) begin
                $fwrite (file, "%0d ", $signed(dut.single_layer.ofm_dpram.mem[i * OFM_SIZE + j + 253776]));  
            end
            $fwrite (file, "\n");
            if ( (i + 1) % OFM_SIZE == 0 ) $fwrite (file, "\n");
        end
        $fclose (file);
end

//compare
task compare;
	integer i;
	begin
		for (i = 0; i < OFM_SIZE * OFM_SIZE * NUM_FILTER; i = i + 1) begin
			$display (" matrix ofm RTL : %d", dut.single_layer.ofm_dpram.mem[i + 253776]);
			$display (" matrix golden : %d", ofm_golden[i]);
			if (ofm_golden[i] != dut.single_layer.ofm_dpram.mem[i + 253776]) begin
				$display ("NO PASS in addess %d", i);
				disable compare;
			end
		end
		$display("\n");
		$display("██████╗  █████╗ ███████╗███████╗    ████████╗███████╗███████╗████████╗");
		$display("██╔══██╗██╔══██╗██╔════╝██╔════╝    ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝");
		$display("██████╔╝███████║███████╗███████╗       ██║   █████╗  ███████    ██║   ");
		$display("██╔═══╝ ██╔══██║╚════██║╚════██║       ██║   ██╔══╝       ██    ██║   ");
		$display("██║     ██║  ██║███████║███████║       ██║   ███████╗███████╗   ██║   ");
		$display("╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝       ╚═╝   ╚══════╝╚══════╝   ╚═╝   ");
	end
endtask

always @(posedge done_CNN) begin
	if (done_CNN) begin
		compare();
	end
end

initial begin
	$monitor ("At time : %d - ofm_size = %d - count_layer = %d - counter filter = %d (max = %d) - counter tiling = %d (max = %d)", $time, dut.single_layer.ofm_size_conv, dut.count_layer, dut.single_layer.control.count_filter, dut.single_layer.control.num_load_filter, dut.single_layer.control.count_tiling, dut.single_layer.control.num_tiling);
end

endmodule