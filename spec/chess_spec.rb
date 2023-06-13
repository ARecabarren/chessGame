require_relative '../lib/board.rb'
require_relative '../lib/moves.rb'
require_relative '../lib/pieces.rb'
# 
# describe Board do
    # describe '#initialize' do
        # it 'Contains an bidimensional array o board matrix' do 
            # board = Board.new
            # array = board.instance_variable_get(:@cells)
            # expect(array).to eql(
                # [['','','','','','','',''],
                # ['','','','','','','',''],
                # ['','','','','','','',''],
                # ['','','','','','','',''],
                # ['','','','','','','',''],
                # ['','','','','','','',''],
                # ['','','','','','','',''],
                # ['','','','','','','','']
            # ])
        # end
    # end
# 
    # describe '#setup_board'
# end
# 
# describe Moves do
    # include Moves
    # describe '#in_boundaries?' do
        # it 'return true if the move is inside the board' do
            # move = [0,0]
            # move1 = [7,7]
            # move2 = [5,5]
            # expect(in_boundaries?(move)).to be true
            # expect(in_boundaries?(move1)).to be true
            # expect(in_boundaries?(move2)).to be true
        # end
        # it 'return false if the move is offside the board' do
            # move = [8,8]
            # move1 = [-1,4]
            # move2 = [-2,-5]
            # expect(in_boundaries?(move)).to be false
            # expect(in_boundaries?(move1)).to be false
            # expect(in_boundaries?(move2)).to be false
        # end
    # end
# 
    # describe '#same_color?' do
        # it 'return true if the piece in the target has the same color' do
            # whiteKnight = Knight.new('white', [0,0])
            # white
        # end
    # end
# 
# end

describe Board do
    describe '#setup_board' do
        it 'Fills rank 2 with white pawns' do
            board = Board.new
            board.setup_board
            pawns = []
            rank = '2'
            'abcdefgh'.split('').each do |file|
                piece = board.cells[file + rank]
                pawns << [piece.type, piece.color]
            end
            expect(pawns.all?(['P',:white])).to be true
        end
        it 'Fills rank 7 with black pawns' do
            board = Board.new
            board.setup_board
            pawns = []
            rank = '7'
            'abcdefgh'.split('').each do |file|
                piece = board.cells[file + rank]
                pawns << [piece.type, piece.color]
            end
            expect(pawns.all?(['P',:black])).to be true
        end
        it 'Fills rank 1 with corresponding white pieces' do 
            board = Board.new
            board.setup_board
            result = Array.new
            rank = '1'
            
            Board.files_left.each_pair do |piece, file|
                piece_on_board = board.cells[file + rank]
                piece_comparison = piece_on_board.type == piece ? true : false
                color_comparison = piece_on_board.color == :white ? true : false
                result << [piece_comparison, color_comparison]
            end
            Board.files_right.each_pair do |piece, file|
                piece_on_board = board.cells[file + rank]
                piece_comparison = piece_on_board.type == piece ? true : false
                color_comparison = piece_on_board.color == :white ? true : false
                result << [piece_comparison, color_comparison]
            end
            expect(result.all?([true,true])).to be true
        end
        it 'Fills rank 7 with corresponding black pieces' do
            board = Board.new
            board.setup_board
            result = Array.new
            rank = '8'
            Board.files_left.each_pair do |piece, file|
                piece_on_board = board.cells[file + rank]
                piece_comparison = piece_on_board.type == piece ? true : false
                color_comparison = piece_on_board.color == :black ? true : false
                result << [piece_comparison, color_comparison]
            end
            Board.files_right.each_pair do |piece, file|
                piece_on_board = board.cells[file + rank]
                piece_comparison = piece_on_board.type == piece ? true : false
                color_comparison = piece_on_board.color == :black ? true : false
                result << [piece_comparison, color_comparison]
            end
            expect(result.all?([true,true])).to be true

        end
    end
end