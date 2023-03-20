// V2.0 13th September 2014
//
// Copyright 2014 Phil Harman VK6PH
// Copyright 2016 Joe Martin K5SO  (modifications for the Orion MkII PA/filter board)
//
//  HPSDR - High Performance Software Defined Radio
//
//  Alex SPI interface.
//
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA



//---------------------------------------------------
//		Alex SPI interface
//---------------------------------------------------


/*
   ==== Orion MkII PA/filter board (default) ====

	data to send to PA/filter board is in the folowing format:

		Bit 	Function 			I.C. Output
	------ 	------------ 		-----------
				(Rx0 data)
	Bit 00 - YELLOW LED   		U6 - D0 		All are active "High"
	Bit 01 - 13 MHz HPF  		U6 - D1
	Bit 02 - 20 MHz HPF  		U6 - D2
	Bit 03 - 6M Preamp  			U6	- D3		12M/10M/6M LNA
	Bit 04 - 9.5 MHz HPF  		U6 - D4
	Bit 05 - 6.5 MHz HPF  		U6 - D5
	Bit 06 - 1.5 MHz HPF 		U6 - D6	
	Bit 07 - N.C. 					U6 - D7
	Bit 08 - XVTR RX In 			U10 - D0
	Bit 09 - EXT1			 		U10 - D1
	Bit 10 - NC 					U10 - D2
	Bit 11 - RX BYPASS OUT     U10 - D3
	Bit 12 - HPF BYPASS 			U10 - D4
	Bit 13 - NC 					U10 - D5
	Bit 14 - RX MASTER IN SELECT U10 - D6
	Bit 15 - RED LED 				U10 - D7		
	
				(Rx1 data)
	Bit 16 - YELLOW_LED_2		U7 - D0
	Bit 17 - 13MHz HPF_2			U7 - D1
	Bit 18 - 20MHz HPF_2			U7 - D2
	Bit 19 - 6M Preamp_2			U7 - D3      	12M/10M/6M LNA_2
	Bit 20 - 9.5MHz HPF_2		U7 - D4
	Bit 21 - 6.5 MHz HPF_2		U7 - D5
	Bit 22 - 1.5 MHz HPF_2		U7 - D6
	Bit 23 - NC	(100W PA)*		U7 - D7			* NC (100W PA), RX2_GROUND (500W PA)
	Bit 24 - RX2_GROUND (100W PA)* U13 - D0	
	Bit 25 - NC						U13 - D1
	Bit 26 - NC						U13 - D2
	Bit 27 - NC						U13 - D3
	Bit 28 - HPF BYPASS_2		U13 - D4
	Bit 29 - NC						U13 - D5
	Bit 30 - NC						U13 - D6
	Bit 31 - RED LED_2			U13 - D7
	
				(Tx data)
	Bit 32 - N.C. 					U3 - D0 		
	Bit 33 - N.C. 					U3 - D1
	Bit 34 - N.C. (100W)**		U3 - D2			** TRX)STATUS (500W PA)
	Bit 35 - YELLOW LED 			U3 - D3
	Bit 36 - BPF3			 		U3 - D4			30/20M
	Bit 37 - BPF2 					U3 - D5			60/40M
	Bit 38 - BPF1 					U3 - D6			80M
	Bit 39 - BPF0 					U3 - D7			160M
	Bit 40 - ANT #1 				U5 - D0
	Bit 41 - ANT #2 				U5 - D1
	Bit 42 - ANT #3 				U5 - D2
	Bit 43 - T/R Relay 			U5 - D3 			Transmit is high, Rec Low
	Bit 44 - RED LED 				U5 - D4
	Bit 45 - BYPASS(BPF Bypass) U5 - D5
	Bit 46 - BPF5			 		U5 - D6			12/10M
	Bit 47 - BPF4			 		U5 - D7			17/15M
	
	Bit number refers to Alex_data[x]
	
	Alex_data bits are sent to the SPI bus in reverse order, i.e., bit 47 first, bit 46 second, etc
	
	SPI data is sent to Alex whenever data changes.
	On reset all outputs are set off. 

*/


/*
   ==== Anan 100D PA/Filter board (DITHER=0 RAND=1) ====
	
	NOTE: only use RX0
	

	data to send to Alex Rx filters is in the folowing format:
	
		Bit 	Function 		I.C. Output
	------ 	------------ 	-----------
	Bit 00 - YELLOW LED 		U2 - D0 		All are active "High"
	Bit 01 - 13 MHz HPF 		U2 - D1
	Bit 02 - 20 MHz HPF 		U2 - D2
	Bit 03 - 6M Preamp 		U2	- D3
	Bit 04 - 9.5 MHz HPF 	U2 - D4
	Bit 05 - 6.5 MHz HPF 	U2 - D5
	Bit 06 - 1.5 MHz HPF 	U2 - D6	
	Bit 07 - N.C. 				U2 - D7
	Bit 08 - XVTR RX In 		U3 - D0
	Bit 09 - RX 2 In 			U3 - D1
	Bit 10 - RX 1 In 			U3 - D2
	Bit 11 - RX 1 Out 		U3 - D3 		Low = Default Receive Path
	Bit 12 - Bypass 			U3 - D4
	Bit 13 - 20 dB Atten. 	U3 - D5
	Bit 14 - 10 dB Atten. 	U3 - D6
	Bit 15 - RED LED 			U3 - D7		
	
	
	data to send to Alex Tx filters is in the following format:
		Bit 	Function 		I.C. Output
	------ 	------------ 	-----------
	Bit 16 - N.C. 				U2 - D0 		
	Bit 17 - N.C. 				U2 - D1
	Bit 18 - T/R Relay		U2 - D2 		Transmit is high, Rec Low (required by F6ITU Alexandrie/Mentor)
	Bit 19 - YELLOW LED 		U2 - D3
	Bit 20 - 30/20 Meters 	U2 - D4
	Bit 21 - 60/40 Meters 	U2 - D5
	Bit 22 - 80 Meters 		U2 - D6
	Bit 23 - 160 Meters 		U2 - D7
	Bit 24 - ANT #1 			U4 - D0
	Bit 25 - ANT #2 			U4 - D1
	Bit 26 - ANT #3 			U4 - D2
	Bit 27 - T/R Relay 		U4 - D3 		Transmit is high, Rec Low
	Bit 28 - RED LED 			U4 - D4
	Bit 29 - 6 Mtrs(Bypass) U4 - D5
	Bit 30 - 12/10 Meters 	U4 - D6
	Bit 31 - 17/15 Meters 	U4 - D7	
	
	Bit number refers to Alex_data[x]
	
	SPI data is sent to Alex whenever data changes.
	On reset all outputs are set off. 
*/

/*
   === David Fainitski PA/filter board (DITHER=1 RAND=0) ====
	
	NOTE: only use RX0

	Modified by David Fainitski
	for Odyssey-2 TRX project
	2017
	
		Bit 	Function 		I.C. Output
	------ 	------------ 	-----------
	Bit 00 - 160 Meters LPF 		U1 - D0 		
	Bit 01 - 80 Meters  LPF 		U1 - D1
	Bit 02 - 60/40 Meters LPF 		U1 - D2
	Bit 03 - 30/20 Meters LPF 		U1	- D3
	Bit 04 - 17/15 Meters LPF  	U1 - D4
	Bit 05 - 12/10 Meters 	      U1 - D5
	Bit 06 - 1.5 MHz HPF       	U1 - D6	
	Bit 07 - 6.5 MHz HPF 			U1 - D7
	Bit 08 - 9.5 MHz HPF    		U2 - D0
	Bit 09 - 13 MHz HPF 			   U2 - D1
	Bit 10 - 20 MHz HPF 			   U2 - D2
	Bit 11 - Bypass      	   	U2 - D3 	
	Bit 12 - 6M Preamp   			U2 - D4
	Bit 13 - ANT #2            	U2 - D5
	Bit 14 - ANT #3            	U2 - D6
	Bit 15 - T/R Relay      		U2 - D7	
*/


module SPI(
				input reset,
				input  spi_clock,
				input enable,
				input [47:0]Alex_data,
				output reg SPI_data,
				output reg SPI_clock,
				output reg Rx_load_strobe,
				output reg Tx_load_strobe
			);

reg [2:0] spi_state;
reg [5:0] data_count;
reg [47:0] previous_Alex_data;
//reg loop_count; 		// used to send data word twice each time the data word changes


// REMOVE: tentative to convert Orion BPF to Angelia HPF/LPF
/*
assign send_data = {16'b0,
	// TX; if we are in TX we use HPF to select LPF
	Alex_data[43] ? Alex_data[47] : Alex_data[1],
	Alex_data[43] ? Alex_data[46] : Alex_data[2],
	Alex_data[45:40],
	Alex_data[43] ? Alex_data[39] : Alex_data[6],
	Alex_data[43] ? Alex_data[38] : Alex_data[6],
	Alex_data[43] ? Alex_data[37] : Alex_data[5],
	Alex_data[43] ? Alex_data[36] : Alex_data[4],
	Alex_data[35],
	Alex_data[43], // required by F6ITU Alexandrie/Mentor - Puresignal   | Alex_data[34]
	Alex_data[33:32],
	// RX0
	Alex_data[15],
	// 10/20 no way to get attenuators with Orion board type?
	// not used too much anyway; we have step attenuator on radio
	2'b0,
	Alex_data[12:7],
	Alex_data[6] | Alex_data[5], // bit 6 | 5
	Alex_data[4],
	1'b0, // Orion doesn't use 9.5MHz HPF
	Alex_data[3:0]};
*/


always @ (posedge spi_clock)
begin
case (spi_state)
3'd0:	begin
		if (reset | ( enable & (Alex_data != previous_Alex_data))) begin
			previous_Alex_data <= reset ? 48'd0 : Alex_data;
`ifdef ORION_MKII_TYPE
			data_count <= 6'd47;
`elsif ANGELIA_FAINITSKI_TYPE
			data_count <= 6'd15;
`else // default use Angelia 100D type
			data_count <= 6'd31;
`endif
			spi_state <= 3'd1;
		end
		else spi_state <= 3'd0;					// wait for Alex data to change
	end		
3'd1:	begin
		SPI_data <= previous_Alex_data[data_count];	// set up data to send
		spi_state <= 3'd2;
	end
3'd2:	begin
		SPI_clock <= 1'b1;					// set clock high
		spi_state <= 3'd3;
	end
3'd3:	begin
		SPI_clock <= 1'b0;					// set clock low
		spi_state <= 3'd4;
	end
3'd4:	begin
`ifdef ORION_MKII_TYPE
		if (data_count == 6'd32) begin
			Tx_load_strobe <= 1'b1;			// strobe the 16 bits Tx data out in parallel
			spi_state <= 3'd5;
		end
		else
`else
		if (data_count == 6'd16) begin
			Tx_load_strobe <= 1'b1;			// strobe the 16 bits Tx data out in parallel
			spi_state <= 3'd5;
		end
		else
`endif
		if (data_count == 6'd0) begin
			Rx_load_strobe <= 1'b1;			// strobe the 32 bits of Rx1 and Rx0 data out in parallel
			spi_state <= 3'd6;
		end
		else begin
			spi_state  <= 3'd1;  			// go round again
		end
		data_count <= data_count - 6'b1; // decrement Alex_data index pointer
	end
3'd5:	begin
		Tx_load_strobe <= 1'b0;				// reset Tx_load_strobe
		spi_state <= 3'd1;					// now send 32 bits of Rx data (16 bits Rx1 followed by 16 bits Rx0) data out on the SPI bus
	end
3'd6:	begin
	Rx_load_strobe <= 1'b0;				// reset Rx strobe
//	loop_count <= loop_count + 1'b1; // loop_count increments each time the SPI data word is sent after a word change is detected
//	if (loop_count == 1'b1) begin			
//			data_count <= 6'd47;				// set starting bit count to 47
//			spi_state <= 3'd1;			// send data word twice
//		end
//		else begin
			spi_state <= 3'd0;						// reset for next run
//		end
	end
	
endcase
end

endmodule
