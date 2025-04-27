module PE #(
	parameter DATA_WIDTH = 16
) (
	input                           clk          ,
	input                           rst_n        ,
	input                           reset_pe     ,
	input                           write_out_en ,
	input      [DATA_WIDTH - 1 : 0] top_in       ,
	input      [DATA_WIDTH - 1 : 0] left_in      ,
	input      [DATA_WIDTH - 1 : 0] mac_in       ,
	output reg [DATA_WIDTH - 1 : 0] bottom_out   ,
	output reg [DATA_WIDTH - 1 : 0] right_out    ,
	output reg [DATA_WIDTH - 1 : 0] mac_out
);

	reg  [DATA_WIDTH - 1 : 0] result ;
	wire [DATA_WIDTH - 1 : 0] mult   ;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			result     <= {DATA_WIDTH{1'b0}} ;
			bottom_out <= {DATA_WIDTH{1'b0}} ;
			right_out  <= {DATA_WIDTH{1'b0}} ;
			mac_out    <= {DATA_WIDTH{1'b0}} ;
		end
		else begin
			result     <= (reset_pe) ? {DATA_WIDTH{1'b0}} : (mult + result) ;  
			bottom_out <= top_in                                            ;
			right_out  <= left_in                                           ;
			mac_out    <= (write_out_en) ? mac_in : result                  ;
		end
	end

	assign mult = $signed(top_in) * $signed(left_in) ;

endmodule