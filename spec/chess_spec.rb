require_relative '../lib/board.rb'
require_relative '../lib/moves.rb'
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
        it 'Fills rank 1 with white pawns' do
            board = Board.new
            board.setup_board
            row = []
            rank = 1.to_s
            'abcdefgh'.split.each do |chr|
                row << board.cells[chr+rank].class
            end
            expect(row.all?(Piece)).to be true
        end
    end
end