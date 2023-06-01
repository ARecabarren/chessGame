require_relative './pieces.rb'

class Board

    @@files_left = {
        'R'=> 'a',
        'N'=> 'b',
        'B'=> 'c',
        'Q'=> 'd',
    }
    @@files_right = {
        'K'=> 'e',
        'B'=> 'f',
        'N'=> 'g',
        'R'=> 'h'
    }
    attr_accessor :cells
    attr_reader :files_left, :files_right
    def initialize
        @cells = {}
    end

    def setup_board
        #Populates pawns
        [2,7].each do |rank|
            'abcdefgh'.split('').each do |file|
                color = rank == 2 ? 'white' : 'black'
                @cells[file + rank.to_s] = Piece.new('pawn', color, file + rank.to_s)
            end
        end

        #Populates left half Rook, Knight, Bishop, Queen
        [1,8].each do |rank|
            color = rank == 1 ? 'white' : 'black'
            @@files_left.each_pair do |key, value|
                @cells[value + rank.to_s] = Piece.new(key, color, value + rank.to_s)
            end
        end
        #Populates right half King, Bishop, Knight, Rook
        [1,8].each do |rank|
            color = rank == 1 ? 'white' : 'black'
            @@files_right.each_pair do |key, value|
                @cells[value + rank.to_s] = Piece.new(key, color, value + rank.to_s)
            end
        end
    end

    def class_variables
        puts "Left files: #{@@files_left}"
        puts "Right files: #{@@files_right}"
    end
end

board = Board.new
board.setup_board
pawns = []
rank = '2'
'abcdefgh'.split('').each do |file|
    piece = board.cells[file + rank]
    pawns << piece.type
end