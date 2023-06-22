require_relative '../lib/board.rb'
require_relative '../lib/UI.rb'
require_relative '../lib/pieces.rb'
FILES_LEFT = {
    R: 'a',
    N: 'b',
    B: 'c',
    Q: 'd'
}

FILES_RIGHT = {
    K: 'e',
    B: 'f',
    N: 'g',
    R: 'h'
}

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
            expect(pawns.all?([:P,:white])).to be true
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
            expect(pawns.all?([:P,:black])).to be true
        end
        it 'Fills rank 1 with corresponding white pieces' do 
            board = Board.new
            board.setup_board
            result = Array.new
            rank = '1'
            
            FILES_LEFT.each_pair do |piece, file|
                piece_on_board = board.cells[file + rank]
                piece_comparison = piece_on_board.type == piece ? true : false
                color_comparison = piece_on_board.color == :white ? true : false
                result << [piece_comparison, color_comparison]
            end
            FILES_RIGHT.each_pair do |piece, file|
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
            FILES_LEFT.each_pair do |piece, file|
                piece_on_board = board.cells[file + rank]
                piece_comparison = piece_on_board.type == piece ? true : false
                color_comparison = piece_on_board.color == :black ? true : false
                result << [piece_comparison, color_comparison]
            end
            FILES_RIGHT.each_pair do |piece, file|
                piece_on_board = board.cells[file + rank]
                piece_comparison = piece_on_board.type == piece ? true : false
                color_comparison = piece_on_board.color == :black ? true : false
                result << [piece_comparison, color_comparison]
            end
            expect(result.all?([true,true])).to be true
        end
    end
    describe '#compute_move' do
        it 'Get 2 legal moves in initial board setup for Pawns' do
            board = Board.new
            legal_moves = board.cells['a2'].legal_moves
            expect(legal_moves.length).to be 2
        end
        it 'Get 2 legal moves in initial board setup for a knight' do
            board = Board.new
            legal_moves = board.cells['b1'].legal_moves
            expect(legal_moves.length).to be 2
        end
    end
    describe "#find_king" do
        it "returns the position of the player's king" do
          board = Board.new
          board.cells = {}
          board.cells['e1'] = Piece.new(:K, :white, 'e1')
          expect(board.find_king(:white)).to eq("e1")
        end
        it "return the board hash if the king is not on the board" do
          board = Board.new
          board.cells = {}
          expect(board.find_king(:white)).to be board.cells
        end
    end
    
    describe "#no_legal_moves?" do
        context "when there are legal moves available" do
          it "returns false" do
            board = Board.new
            board.cells = {}
            board.cells['e1'] = Piece.new(:K, :white, 'e1')
            board.compute_moves
    
            expect(board.no_legal_moves?(:white)).to be false
          end
        end
        context "when there are no legal moves available" do
            it "returns true" do
              board = Board.new
              board.cells = {}
              board.cells['e1'] = Piece.new(:K, :white, 'e1')
              board.cells['e2'] = Piece.new(:P, :white, 'e2')
      
              expect(board.no_legal_moves?(:white)).to be true
            end
        end
    end

    describe "king_in_check?" do
        it "returns true if the king is in check" do
            board = Board.new
            board.cells = {}
            board.cells['e8'] = Piece.new(:K, :black, 'e8')
            board.cells['e1'] = Piece.new(:R, :white, 'e1')
            board.compute_moves
            expect(board.king_in_check?(:black)).to be true
        end
        it "returns false if the king is not in check" do
            board = Board.new
            expect(board.king_in_check?(:white)).to be false
        end
    end
    describe 'game_state' do
        it 'returns :checkmate if the king is in checkmate' do
            board = Board.new
            board.cells = {}
            board.cells['e1'] = Piece.new(:K, :white, 'e1')
            board.cells['d2'] = Piece.new(:P, :white, 'd2')
            board.cells['e2'] = Piece.new(:P, :white, 'e2')
            board.cells['f2'] = Piece.new(:P, :white, 'f2')
            board.cells['a1'] = Piece.new(:R, :black, 'a1')
            board.cells['h1'] = Piece.new(:R, :black, 'h1')
            board.compute_moves
            show_board(board.cells)
            expect(board.game_state).to be :checkmate
        end
        it 'returns :stalemate if the king is in stalemate' do
            # Situación de empate
            board = Board.new
            board.cells = {
                'e4' => Piece.new(:K, :white, 'e4'),
                'c7' => Piece.new(:Q, :white, 'c7'),
                'a8' => Piece.new(:K, :black, 'a8')
            }
            board.current_player = :black
            board.compute_moves
            expect(board.game_state).to be :stalemate
        end
        it 'return :stalemate if the king is in stalemate' do 
            #Otro stalemate
            board = Board.new
            board.cells = {}
            board.cells['f3'] = Piece.new(:K, :white, 'f3')
            board.cells['b2'] = Piece.new(:R, :black, 'b2')
            board.cells['f4'] = Piece.new(:P, :black, 'f4')
            board.cells['f5'] = Piece.new(:K, :black, 'f5')
            board.current_player = :white
            board.compute_moves
            expect(board.game_state).to be :stalemate
        end
    end
    describe 'castle' do
        let(:board) { Board.new }
        let(:cells) { {} }
        
        before do
            board.cells = cells
        end
        
        describe 'king-side castling' do
            context 'when castling is valid' do
                it 'moves the king and rook correctly' do
                    board.cells['e1'] = Piece.new(:K, :white, 'e1')
                    board.cells['h1'] = Piece.new(:R, :white, 'h1')
                    board.castle('e1', 'g1')
                    
                    expect(board.cells['g1']).to be_instance_of(Piece)
                    expect(board.cells['g1'].type).to eq(:K)
                    expect(board.cells['g1'].color).to eq(:white)
                    expect(board.cells['f1']).to be_instance_of(Piece)
                    expect(board.cells['f1'].type).to eq(:R)
                    expect(board.cells['f1'].color).to eq(:white)
                end
            end
            context 'when castling is invalid' do
                it 'does not perform the castling' do
                    board.cells['e1'] = Piece.new(:K, :white, 'e1')
                    board.cells['h1'] = Piece.new(:R, :white, 'h1')
                    board.cells['g1'] = Piece.new(:N, :white, 'g1')  # Piece blocking the path
                
                    board.castle('e1', 'g1')
                    expect(board.cells['e1']).to be_instance_of(Piece)
                    expect(board.cells['e1'].type).to eq(:K)
                    expect(board.cells['e1'].color).to eq(:white)
                
                    expect(board.cells['h1']).to be_instance_of(Piece)
                    expect(board.cells['h1'].type).to eq(:R)
                    expect(board.cells['h1'].color).to eq(:white)
                end
            end
        end
        
        describe 'queen-side castling' do
            context 'when castling is valid' do
                it 'move the king and rook correctly' do
                    board.cells['e1'] = Piece.new(:K, :white, 'e1')
                    board.cells['a1'] = Piece.new(:R, :white, 'a1')

                    board.castle('e1', 'c1')

                    expect(board.cells['c1']).to be_instance_of(Piece)
                    expect(board.cells['c1'].type).to eq(:K)
                    expect(board.cells['c1'].color).to eq(:white)

                    expect(board.cells['d1']).to be_instance_of(Piece)
                    expect(board.cells['d1'].type).to eq(:R)
                    expect(board.cells['d1'].color).to eq(:white)
                end
            end

            context 'when castling is invalid' do
                it 'does not perform the castling' do
                    board.cells['e1'] = Piece.new(:K, :white, 'e1')
                    board.cells['a1'] = Piece.new(:R, :white, 'a1')
                    board.cells['b1'] = Piece.new(:N, :white, 'b1')  # Piece blocking the path

                    board.castle('e1', 'c1')

                    expect(board.cells['e1']).to be_instance_of(Piece)
                    expect(board.cells['e1'].type).to eq(:K)
                    expect(board.cells['e1'].color).to eq(:white)

                    expect(board.cells['a1']).to be_instance_of(Piece)
                    expect(board.cells['a1'].type).to eq(:R)
                    expect(board.cells['a1'].color).to eq(:white)
                end
            end
        end
    
    end
end

##Lets test castle
