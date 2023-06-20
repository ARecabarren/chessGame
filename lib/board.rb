require_relative './pieces.rb'
require_relative './UI.rb'
include UI
class Board
  attr_accessor :cells, :current_player
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
    compute_moves(@cells)
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
        position = file + rank.to_s
        piece = Piece.new(:P, color, position, cells)
        cells[position] = piece
        set_en_passant_eligible(piece, position)
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
    piece = cells[from]
    #Things to check before move
    #Move include as legal move in piece.
    #Puts own king in check?
    #Puts enemy king in check?
    #Is move legal?
    #Is move blocked?
    #promote pawn?
    #castling?
    update_en_passant_eligible(piece, from, to)
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
    cells[to] = piece
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
      compute_move(piece, cells)
    end
    compute_pawn_moves(cells)
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
            current_x, current_y = original_position
            break
          end
        end
      when :N, :K
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

  def compute_pawn_moves(cells)
    each_piece(cells) do |cell, piece|
      next unless piece.type == :P
      current_x, current_y = cell_to_coord(piece.position)
      direction = (piece.color == :white ? 1 : -1)
      new_coord = [current_x + direction, current_y]
      if in_boundaries?(new_coord) && cells[coord_to_cell(new_coord)].nil?
        piece.legal_moves << new_coord
        if piece.first_move
          new_coord = [current_x + (2 * direction), current_y ]
          if in_boundaries?(new_coord) && cells[coord_to_cell(new_coord)].nil?
            piece.legal_moves << new_coord
          end
        end
      end
      #Captura diagonal
      [-1, 1].each do |dx|
        new_coord = [current_x + direction, current_y + dx]
        if in_boundaries?(new_coord)
          piece_in_destination = cells[coord_to_cell(new_coord)]
          if !piece_in_destination.nil? && piece_in_destination.color != piece.color
            piece.legal_moves << new_coord
          end
        end
        # En passant
        en_passant_target = coord_to_cell([current_x , current_y + dx])
        if in_boundaries?(new_coord) && cells[en_passant_target].is_a?(Piece) &&
          cells[en_passant_target].type == :P && cells[en_passant_target].color != piece.color &&
          cells[en_passant_target].en_passant_eligible
          piece.legal_moves << new_coord
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
      # compute_moves(temp_cell)
      in_check = king_in_check?(piece.color, temp_cell)
      if in_check 
        pre_legal_moves.delete(move)
      end
      piece.position = original_position
    end
    piece.legal_moves = pre_legal_moves
  end

  def set_en_passant_eligible(piece, position)
    piece.en_passant_eligible = false # Restablecer el estado a falso por defecto
  
    if piece.type == :P && (position[1].to_i - piece.position[1].to_i).abs == 2
      piece.en_passant_eligible = true
    end
  end

  def update_en_passant_eligible(piece, from, to)
    return unless piece.type == :P # Verificar si la pieza es un peón
  
    # Obtener las coordenadas de la posición actual y de destino
    current_x, current_y = cell_to_coord(from)
    new_x, new_y = cell_to_coord(to)
  
    if (new_x - current_x).abs == 2 # La pieza se ha movido dos posiciones hacia adelante
      piece.en_passant_eligible = true
    else
      piece.en_passant_eligible = false
    end
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
legal_moves = board.cells['a2'].legal_moves
show_board(board.cells)