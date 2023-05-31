require 'pieces.rb'
class Board
    attr_accessor :cells
    def initialize
        @cells = {}
        # @cells = Array.new(8){ Array.new(8){""} }
    end

    def setup_board
        'abcdefgh'.split('').each do |chr|
            '12345678'.split('').each do |numb|
                if numb == '2'
                    @cells[chr+numb] = Piece.new('pawn', 'white', chr+numb) 
                elsif numb == '6'
                    @cells[chr+numb] = Piece.new('pawn', 'black', chr+numb)
                end
                 
            end
        end
    end
end