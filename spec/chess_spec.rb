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
            blackPawn = board.cells['e7']
            board.update_position(blackPawn, 'e7', 'e2')
            expect(board.king_in_check?(:white)).to be true
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
    end
end