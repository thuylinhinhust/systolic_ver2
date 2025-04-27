module ifm_addr_controller #(
    parameter SYSTOLIC_SIZE = 16     ,
    parameter IFM_RAM_SIZE  = 519168
) (
    input                                     clk           ,
    input                                     rst_n         ,
    input                                     load          ,
    output reg [$clog2(IFM_RAM_SIZE) - 1 : 0] ifm_addr      ,
    output reg                                read_en       ,
    output reg [4 : 0]                        read_ifm_size ,   

    //Layer config
    input      [8 : 0]                        ifm_size      ,
    input      [10: 0]                        ifm_channel   ,
    input      [1 : 0]                        kernel_size   ,
    input      [8 : 0]                        ofm_size
);

    parameter IDLE         = 3'b000 ;
    parameter HOLD         = 3'b001 ;
    parameter NEXT_PIXEL   = 3'b010 ;
    parameter NEXT_LINE    = 3'b011 ;
    parameter NEXT_CHANNEL = 3'b100 ;
    parameter NEXT_TILING  = 3'b101 ;

    reg [2:0] current_state, next_state;
    
    reg [$clog2(IFM_RAM_SIZE) - 1 : 0] base_addr;
    reg [$clog2(IFM_RAM_SIZE) - 1 : 0] start_window_addr;
    
    reg [1 :0] count_pixel_in_row;
    reg [3 :0] count_pixel_in_window;
    reg [12:0] count_pixel_in_channel;

    reg [1 :0] count_line;
    reg [10:0] count_channel;

    reg [8 :0] count_height; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IDLE;
        else        current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            IDLE: if (load) next_state = HOLD;
            HOLD: begin
                if (kernel_size == 1) next_state = NEXT_CHANNEL;
                else                  next_state = NEXT_PIXEL;
            end            
            NEXT_PIXEL: begin
                if      (count_pixel_in_channel == ifm_channel * kernel_size * (kernel_size - 1)) next_state = NEXT_TILING;   
                else if (count_pixel_in_window  == kernel_size * (kernel_size - 1))               next_state = NEXT_CHANNEL;  
                else if (count_pixel_in_row     == kernel_size - 1)                               next_state = NEXT_LINE;
            end 
            NEXT_LINE: next_state = NEXT_PIXEL;
            NEXT_CHANNEL: begin
                if      (kernel_size != 1)                                     next_state = NEXT_PIXEL;
                else if (kernel_size == 1 && count_channel == ifm_channel - 1) next_state = NEXT_TILING;
            end 
            NEXT_TILING: next_state = IDLE;
            default:     next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                    ifm_addr               <= 0                                                                         ;
                    read_en                <= 0                                                                         ;
                    read_ifm_size          <= (ofm_size < SYSTOLIC_SIZE) ? (ifm_size - kernel_size + 1) : SYSTOLIC_SIZE ;
                    base_addr              <= 0                                                                         ;
                    start_window_addr      <= 0                                                                         ;
                    count_pixel_in_row     <= 0                                                                         ;
                    count_pixel_in_window  <= 0                                                                         ;
                    count_pixel_in_channel <= 0                                                                         ;
                    count_line             <= 0                                                                         ;
                    count_channel          <= 0                                                                         ;
                    count_height           <= 0                                                                         ;
        end
        else begin
            case (next_state)
                IDLE: begin
                    ifm_addr               <= start_window_addr ;
                    read_en                <= 0                 ;
                    count_pixel_in_row     <= 0                 ;
                    count_pixel_in_window  <= 0                 ;
                    count_pixel_in_channel <= 0                 ;
                    count_line             <= 0                 ;
                    count_channel          <= 0                 ;
                end 
                HOLD: begin  
                    ifm_addr      <= ifm_addr                                                                                                                                 ;
                    read_en       <= 1                                                                                                                                        ;    
                    read_ifm_size <= ((start_window_addr % ifm_size) + SYSTOLIC_SIZE + kernel_size - 1 > ifm_size) ? (ifm_size - base_addr - kernel_size + 1) : SYSTOLIC_SIZE ;      
                end
                NEXT_PIXEL: begin
                    ifm_addr               <= ifm_addr + 1               ;
                    read_en                <= 1                          ;
                    count_pixel_in_row     <= count_pixel_in_row + 1     ;
                    count_pixel_in_window  <= count_pixel_in_window + 1  ;
                    count_pixel_in_channel <= count_pixel_in_channel + 1 ;
                end
                NEXT_LINE: begin
                    ifm_addr           <= start_window_addr + count_channel * ifm_size * ifm_size + (count_line + 1) * ifm_size ;
                    read_en            <= 1                                                                                     ;
                    count_line         <= count_line + 1                                                                        ;
                    count_pixel_in_row <= 0                                                                                     ;
                end
                NEXT_CHANNEL: begin
                    ifm_addr              <= start_window_addr + (count_channel + 1) * ifm_size * ifm_size ;
                    read_en               <= 1                                                             ;
                    count_channel         <= count_channel + 1                                             ;
                    count_line            <= 0                                                             ; 
                    count_pixel_in_row    <= 0                                                             ;
                    count_pixel_in_window <= 0                                                             ;
                end
                NEXT_TILING: begin
                    read_en           <= 0 ;
                    count_height      <= (count_height == ofm_size - 1) ? 0 : count_height + 1 ;
                    base_addr         <= (start_window_addr + read_ifm_size + kernel_size - 1 == ifm_size * (ifm_size - kernel_size)) ? 0 : ((count_height == ofm_size - 2) ? base_addr + SYSTOLIC_SIZE : base_addr) ;
                    start_window_addr <= (count_height == ofm_size - 1) ? base_addr : start_window_addr + ifm_size ;  
                end
            endcase
        end
    end

endmodule