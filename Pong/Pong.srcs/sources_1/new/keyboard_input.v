//use keyboard as input 
//input port keyboard_clk => F4
//input port keyboard_clk => B2

module keyboard_input (
    input clk,
    input keyboard_clk, // get data at negedge
    input keyboard_data, // keyboard data => get at negedge
    output reg player_1_up,
    output reg player_1_down,
    output reg player_2_up,
    output reg player_2_down,
    output reg start
);
    
    wire keyboard_clk_de;
    wire keyboard_data_de;
    reg [7:0] datacur = 8'd0;//current data
    reg [7:0] dataold = 8'd0;//old data
    reg [3:0] count = 8'd0;//count for 8 bit data
    reg end_input_data = 1'd0;//after input 8 bit
    reg [31:0] keydata = 32'd0; // store data

    debouncer debounce(
        .clk(clk),
        .kclk(keyboard_clk),
        .kdata(keyboard_data),
        .kclk_de(keyboard_clk_de),
        .kdata_de(keyboard_data_de)
    );
    
    always@(negedge keyboard_clk_de)begin //read 8 bit data
    case(count)
    4'd0:;//Start bit
    4'd1:
        datacur[0]<=keyboard_data_de;
    4'd2:
        datacur[1]<=keyboard_data_de;
    4'd3:
        datacur[2]<=keyboard_data_de;
    4'd4:
        datacur[3]<=keyboard_data_de;
    4'd5:
        datacur[4]<=keyboard_data_de;
    4'd6:
        datacur[5]<=keyboard_data_de;
    4'd7:
        datacur[6]<=keyboard_data_de;
    4'd8:
        datacur[7]<=keyboard_data_de;
    4'd9:
        end_input_data<=1'b1;//8 bit end
    4'd10:
        end_input_data<=1'b0;
    
    endcase
        if(count<=4'd9) 
            count<=count+4'd1;
        else if(count==4'd10) 
            count<=4'd0;
    end

    always @(posedge end_input_data)begin//when 8 bit end
    if (dataold!=datacur)begin
        keydata[31:24]<=keydata[23:16];
        keydata[23:16]<=keydata[15:8];
        keydata[15:8]<=dataold;
        keydata[7:0]<=datacur;
        dataold<=datacur;// current data move to old data
    end
    end
    always@(*)begin
        if(keydata[15:8] != 8'hF0)
        begin
            case (keydata[7:0])
                8'h1C://press s
                begin
                    player_1_up<=1'b1;
                    player_1_down<=1'b0;
                    player_2_up<=1'b0;
                    player_2_down<=1'b0;
                    start<=1'b0;
                end
                8'h1B://press s
                begin  
                    player_1_up<=1'b0;
                    player_1_down<=1'b1;
                    player_2_up<=1'b0;
                    player_2_down<=1'b0;
                    start<=1'b0;
                end
                8'h4B://press l
                begin
                    player_1_up<=1'b0;
                    player_1_down<=1'b0;
                    player_2_up<=1'b1;
                    player_2_down<=1'b0;
                    start<=1'b0;
                end
                8'h4C://press ;
                begin
                    player_1_up<=1'b0;
                    player_1_down<=1'b0;
                    player_2_up<=1'b0;
                    player_2_down<=1'b1;
                    start<=1'b0;
                end
                8'h29://press space
                begin
                    player_1_up<=1'b0;
                    player_1_down<=1'b0;
                    player_2_up<=1'b0;
                    player_2_down<=1'b0;
                    start<=1'b1;
                end
                default:
                begin
                    player_1_up<=1'b0;
                    player_1_down<=1'b0;
                    player_2_up<=1'b0;
                    player_2_down<=1'b0;
                    start<=1'b0;
                end 
            endcase
        end
        else
        begin
            player_1_up<=1'b0;
            player_1_down<=1'b0;
            player_2_up<=1'b0;
            player_2_down<=1'b0;
            start<=1'b0;
        end
    end
endmodule