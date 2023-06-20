require_relative './pieces.rb'
require_relative './UI.rb'
include UI
class Board
  attr_accessor :cells
  attr_reader :files_left, :files_right

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

  def initialize
    @cells = {}
    @current_player = :white
    setup_board
    compute_moves
  end

  def setup_board
    populate_pawns
    populate_pieces_left
    populate_pieces_right
  end

  def populate_pawns
    [2, 7].each do |rank|
      ('a'..'h').each do |file|
        color = rank == 2 ? :white : :black
        @cells[file + rank.to_s] = Piece.new(:P, color, file + rank.to_s, cells)
      end
    end
  end

  def populate_pieces_left
    [1, 8].each do |rank|
      color = rank == 1 ? :white : :black
      FILES_LEFT.each_pair do |key, value|
        @cells[value + rank.to_s] = Piece.new(key, color, value + rank.to_s, cells)
      end
    end
  end

  def populate_pieces_right
    [1, 8].each do |rank|
      color = rank == 1 ? :white : :black
      FILES_RIGHT.each_pair do |key, value|
        @cells[value + rank.to_s] = Piece.new(key, color, value + rank.to_s, cells)
      end
    end
  end

  def in_boundaries?(move)
    x, y = move
    x_range = 0..7
    y_range = 0..7
    x_range.include?(x) && y_range.include?(y)
  end

  def game_state
    if king_in_check?(@current_player)
      if no_legal_moves?(@current_player)
        return :checkmate
      end
    else
      if no_legal_moves?(@current_player)
        return :stalemate
      end
    end

    :in_game
  end

  def move(from, to)
    #Things to check before move
    #Move include as legal move in piece.
    #Puts own king in check?
    #Puts enemy king in check?
    #Is move legal?
    #Is move blocked?
    #promote pawn?
    #castling?
    #en passant?
    #checkmate?
    #stalemate?
  end

  def update_position(piece, from, to)
    piece.position = to
    cells[to] = cells[from]
    cells[from] = nil 
    compute_moves
    # show_board(cells)
  end

  def temp_move(piece, from, to, cells = @cells)
    piece.position = to
    cells[to] = cells[from]
    cells[from] = nil
    compute_moves(cells)
  end

  def each_piece(cells = @cells)
    cells.each_pair do |cell, piece|
      unless piece.nil? 
        if block_given?
          yield(cell, piece)
        else
          puts cell, piece
        end
      end
    end
  end

  def compute_moves(cells = @cells)
    each_piece(cells) do |cell, piece|
      compute_move(piece)
    end
  end

  def compute_move(piece, cells = @cells)
    piece.legal_moves = []
    original_position = cell_to_coord(piece.position)
    current_x, current_y = cell_to_coord(piece.position)
    piece.directions.each do |direction|
      case piece.type
      when :R, :B, :Q
        loop do
          new_coord = process_direction(direction, current_x, current_y)
          to_cell = cells[coord_to_cell(new_coord)]
  
          if in_boundaries?(new_coord)
            if to_cell.nil?
              piece.legal_moves << new_coord
              current_x, current_y = new_coord
            elsif to_cell.color != piece.color
              piece.legal_moves << new_coord
              current_x, current_y = original_position
              break
            else
              current_x, current_y = original_position
              break
            end
          else
            current_x, current_y = cell_to_coord(piece.position)
            break
          end
        end
      when :N, :K, :P
        new_coord = process_direction(direction, current_x, current_y)
        to_cell = cells[coord_to_cell(new_coord)]
  
        if in_boundaries?(new_coord)
          if to_cell.nil?
            piece.legal_moves << new_coord
          elsif to_cell.color != piece.color
            piece.legal_moves << new_coord
          else
            next
          end
        else
          next
        end
      end
    end


  end

  def process_direction(direction, current_x, current_y)
    xstep, ystep = direction
    new_x = current_x + xstep
    new_y = current_y + ystep
    [new_x,new_y]
  end
  
  def cell_to_coord(fileRank)
    row = fileRank[1].to_i - 1
    col = 0
    'abcdefgh'.split('').each do |file|
      if file == fileRank[0]
        break
      else
        col += 1
      end
    end
    return row, col
  end
  
  def coord_to_cell(coord)
    rank = coord[0] + 1
    files = 'abcdefgh'
    file = files[coord[1]]
    "#{file}#{rank}"
  end

  # private
  def king_in_check?(player, cells = @cells)
    king_position = find_king(player, cells)
    each_piece(cells) do |cell, piece|
      next if piece.color == player
      if piece.legal_moves.include?(cell_to_coord(king_position))
        return true
      end
    end
    false
  end

  def find_king(player,cells = @cells)
    each_piece(cells) do |cell, piece|
      if piece.type == :K && piece.color == player
        return piece.position
      end
    end
  end

  def no_legal_moves?(player)
    each_piece do |_, piece|
      next unless piece.color == player
      test_moves_for_check(piece)
      return false unless piece.legal_moves.empty?
    end
    true 
  end

  def test_moves_for_check(piece)
    pre_legal_moves = piece.legal_moves.dup
    piece.legal_moves.each do |move|
      destination = coord_to_cell(move)
      original_position = piece.position
      piece_in_destination = cells[coord_to_cell(move)]
      temp_cell = cells.dup
      temp_move(piece, original_position, destination,temp_cell)
      in_check = king_in_check?(piece.color, temp_cell)
      if in_check 
        pre_legal_moves.delete(move)
      end
    end
    piece.legal_moves = pre_legal_moves
  end
end


# board = Board.new
# board.cells['c3'] = Piece.new(:R, :white, 'c3')
# board.cells['d4'] = Piece.new(:N, :black, 'd4')
# board.cells['e5'] = Piece.new(:B, :white, 'e5')

# board.compute_moves
# show_board(board.cells)
# whiteKing = Piece.new(:K, :white, 'e4', board)
# p whiteKing.legal_moves
# board.move('b1','c3')
# show_board(board.cells)

# puts board.cells

board = Board.new
board.cells = {}
board.cells['e1'] = Piece.new(:K, :white, 'e1')
board.cells['d2'] = Piece.new(:P, :white, 'd2')
board.cells['e2'] = Piece.new(:P, :white, 'e2')
board.cells['f2'] = Piece.new(:P, :white, 'f2')
board.cells['a1'] = Piece.new(:R, :black, 'a1')
board.cells['h1'] = Piece.new(:R, :black, 'h1')
board.compute_moves
board.game_state
show_board(board.cells)
