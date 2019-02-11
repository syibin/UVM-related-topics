module spi_master#(
	parameter DATA_WIDTH = 16
)(clk, reset_n, enable, cpol, cpha, clk_div, tx_data, miso, sclk, ss_n, mosi, busy, rx_data);

//Parameters
parameter READY = 2'b01, EXECUTE = 2'b10;

//Port declarations
input clk;
input reset_n;
input enable;
input cpol;
input cpha;
input [3:0] clk_div;
input [(DATA_WIDTH-1):0] tx_data;
input miso;
output reg ss_n;
output reg sclk;
output reg mosi;
output reg busy;
output reg [(DATA_WIDTH-1):0] rx_data;

//Inside Variables
reg [1:0] state;
reg [3:0] clk_ratio; //Current divider
reg [(DATA_WIDTH-1):0] counter; //Counter to trigger SCLK
reg [31:0] toggle_counter;
reg assert_data; //1 tx sclk, 0 rx sclk toggle
reg [(DATA_WIDTH-1):0] rx_buffer;
reg [(DATA_WIDTH-1):0] tx_buffer;
reg [(DATA_WIDTH*2):0] rx_last_bit;

//Logic
always @(posedge clk or negedge reset_n) begin

	if(reset_n == 0) begin //Reset
		busy <= 1;
		ss_n <= 1;
		mosi <= 0;
		rx_data <= 0;
		state <= READY;
	end

	else begin
		case(state)
		READY: begin
			busy <= 0;
			ss_n <= 1;
			mosi <= 0;
			
			if(enable) begin
				busy <= 1;
				
				if(clk_div == 0) begin	//If 0, set to max, which is 1
					clk_ratio <= 1;
					counter <= 1;
				end
				else begin
					clk_ratio <= clk_div;
					counter <= clk_div;
				end
				
				sclk <= cpol;				//Clock polarity
				assert_data <= ~cpha;	//Clock phase
				tx_buffer <= tx_data;
				toggle_counter <= 0;
				rx_last_bit <= DATA_WIDTH*2 + cpha - 1; //Data width * 2 + phase -1
				state <= EXECUTE;
			end
			else begin
				state <= READY; 			//Remain in READY state
			end
		end
		
		EXECUTE: begin 
			busy <= 1;
			ss_n <= 0;
			
			if(counter == clk_ratio) begin	//Ratio is met
				counter <= 0;						//Reset counter
				assert_data = ~assert_data;
				
				if(toggle_counter == (DATA_WIDTH*2 + 1)) begin
					toggle_counter <= 0;			//Reset toggle counter
				end
				else begin
					toggle_counter <= toggle_counter + 1;
				end
				
				//Toggle clock for spi
				if((toggle_counter <= DATA_WIDTH*2) && (ss_n == 0)) begin
					sclk <= ~sclk;
				end
				
				//Shift in the received bit
				if((assert_data == 0) && (toggle_counter < rx_last_bit +1) && (ss_n == 0)) begin
                    //rx_buffer <= rx_buffer[DATA_WIDTH-2 : 0] & miso;
					rx_buffer <= (rx_buffer << 1) | miso;
				end
				
				//Shift out the next tx bit
				if((assert_data == 1) && (toggle_counter < rx_last_bit)) begin
					mosi <= tx_buffer[DATA_WIDTH-1];
					tx_buffer <= (tx_buffer << 1);
				end
				
				//EOT
				if(toggle_counter == DATA_WIDTH*2 + 1) begin
					busy <= 0;
					ss_n <= 1;
					mosi <= 0;
					rx_data <= rx_buffer;
					state <= READY;
				end
				else begin
					state <= EXECUTE;
				end	
			end
			else begin //Clock to sclk ratio not met
				counter <= counter + 1'b1;
				state <= EXECUTE;
			end
		end
		endcase

	end
end

endmodule