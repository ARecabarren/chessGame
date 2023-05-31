require_relative '../lib/board.rb'
require_relative '../lib/moves.rb'

describe Board do
    describe '#initialize' do
        it 'Contains an bidimensional array o board matrix' do 
            board = Board.new
            array = board.instance_variable_get(:@cells)
            expect(array).to eql(
                [['','','','','','','',''],
                ['','','','','','','',''],
                ['','','','','','','',''],
                ['','','','','','','',''],
                ['','','','','','','',''],
                ['','','','','','','',''],
                ['','','','','','','',''],
                ['','','','','','','','']
            ])

        end
    end
end

describe Moves do
    include Moves
    describe '#in_boundaries?' do
        it 'return true if the move is inside the board' do
            move = [0,0]
            expect(in_boundaries?(move)).to be true
        end
    end
end
