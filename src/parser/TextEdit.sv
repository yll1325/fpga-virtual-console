`include "DataType.svh"

module TextEdit(
	input                   clk, rst,
	input                   commandReady,
	input  CommandsType     commandType,
	input  Terminal_t       term,
	input  Param_t          param,
	input  TextRamResult_t  ramRes,
	output TextRamRequest_t ramReq
);

enum {
	Idle, 
	input_ReadRam0, input_ReadRam1, input_WriteRam
} status;

logic [15:0] data;
logic [7:0] row, col;
logic char_printable;

assign char_printable = param.Pchar >= 8'h30;

always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
	end else begin
		unique case(status)
			Idle:
			begin
				if(commandReady)
				begin
					unique case(commandType)
						INPUT:
						begin
							if(char_printable)
							begin
								status = input_ReadRam0;
								data = { 4'b0, 9'b0, 9'h1ff, 2'b0, param.Pchar };
								row = term.cursor.x;
								col = term.cursor.y;
							end
						end
						default:
							status = Idle;
					endcase
				end
			end
			input_ReadRam0:
				status = input_ReadRam1;
			input_ReadRam1:
				status = input_WriteRam;
			input_WriteRam:
				status = Idle;
			default:
				status = Idle;
		endcase
	end
end

// setup write info
logic [`TEXT_RAM_LINE_WIDTH - 1:0] next_line, cur_line;
assign cur_line = ramRes;
genvar i;
generate
	for(i = 0; i < `CONSOLE_COLUMNS; i = i + 1)
	begin: gen_for
		logic [`TEXT_RAM_CHAR_WIDTH - 1:0] next_char, cur_char;
		assign cur_char = cur_line[`TEXT_RAM_CHAR_WIDTH * i +: `TEXT_RAM_CHAR_WIDTH];

		assign next_line[`TEXT_RAM_CHAR_WIDTH * i +: `TEXT_RAM_CHAR_WIDTH] = (i == col) ? data : cur_char;
	end
endgenerate

always @(posedge clk)
begin
	unique case(status)
		input_ReadRam0:  // setup read request
		begin
			ramReq.address <= row;
			ramReq.wren <= 1'b0;
		end
		input_WriteRam:  // setup write request
		begin
			ramReq.address <= row;
			ramReq.wren <= 1'b1;
			ramReq.data <= next_line;
		end
		Idle:  // clear write request
		begin
			ramReq.wren <= 1'b0;
		end
	endcase
end

endmodule
