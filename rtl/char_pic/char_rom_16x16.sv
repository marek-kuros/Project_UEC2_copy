module char_rom_16x16(
    input  logic [7:0] char_xy,
    input  logic [3:0] char_line,
    output logic [10:0] char_code
);

typedef bit [7:0] array_byte;

logic [3:0] x_pos;
logic [3:0] y_pos;

array_byte [15:0][15:0] array_of_letters = '{
                        '{"W", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"A", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"S", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"D", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"F", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"G", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"H", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"J", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"K", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"K", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"L", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"Z", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"X", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"C", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"V", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"},
                        '{"B", "E", "L", "L", "I", "T", "W", "O", "R", "K", "S", "A", "B", "C", "D", "E"}
                    };
always_comb begin
    x_pos = char_xy[7:4];
    y_pos = char_xy[3:0];
end

logic [10:4] value;

always_comb begin
    value = array_of_letters[15 - x_pos][15 - y_pos];
    char_code[10:0] = {value, char_line};
end

endmodule