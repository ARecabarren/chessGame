require_relative './pieces.rb'
require_relative './UI.rb'
require 'pry-byebug'
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
      puts "#{@current_player.to_s.capitalize} king is in check!"
      if no_legal_moves?(@current_player)
        puts "Checkmate! #{get_opposite_player.to_s.capitalize} wins!"
        return :checkmate
      end
    else
      if no_legal_moves?(@current_player)
        puts "Stalemate!"
        return :stalemate
      end
    end

    :in_game
  end

  def move(from, to)
    piece = cells[from]
    coords_to = cell_to_coord(to)
    if piece.type == :P
      update_en_passant_eligible(piece) if piece.en_passant_eligible
      if piece.legal_moves.include?(coords_to)
        if is_a_en_passant_move?(from,to)
          en_passant(from, to)
        elsif is_pawn_promotion?(from, to, piece)
          promote_pawn(piece, from, to)
          compute_moves(@cells)
        else
          each_piece do |cell, piece|
            next unless piece.is_a?(Piece) && piece.type == :P && piece.color != @current_player
            update_en_passant_eligible(piece) if piece.en_passant_eligible
          end
          en_passant_eligible?(from, to)
          update_position(piece, from, to)
          compute_moves
        end
      else
        return :illegal_move
      end
    elsif piece.type == :K
      castle(from, to)
    elsif piece.legal_moves.include?(coords_to)
      # binding.pry
      update_position(piece, from, to)
    else
      return :illegal_move
    end

    no_legal_moves?(get_opposite_player) if king_in_check?(get_opposite_player)

    
    
    # update_position(piece, from, to) unless piece.position == to || piece.type == :P
  end

  def update_position(piece, from, to)
    piece.position = to
    cells[to] = cells[from]
    cells[from] = nil
    piece.first_move = false if piece.first_move

    compute_moves
    # show_board(cells)
  end

  def get_opposite_player
    @current_player == :white ? :black : :white
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
      next if piece.type == :P
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
      pre_legal_moves.delete(move) if (piece_in_destination.is_a?(Piece) && piece_in_destination.color == piece.color)
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

  def en_passant_eligible?(from, to)
    piece = cells[from]
    return unless piece.type == :P
    rank = piece.position[1]
    file = piece.position[0]
    to_rank = to[1]
    to_file = to[0]
    if piece.first_move && (rank.to_i - to_rank.to_i).abs == 2
      piece.en_passant_eligible = true
    end
  end

  def en_passant(from, to)
    piece = cells[from]
    cell_to = cells[to]
    return unless cell_to.nil?

    piece_position_coord = cell_to_coord(piece.position)
    left_cell_coord = [piece_position_coord[0], piece_position_coord[1] - 1]
    right_cell_coord = [piece_position_coord[0], piece_position_coord[1] + 1]
    left_cell = coord_to_cell(left_cell_coord)
    right_cell = coord_to_cell(right_cell_coord)
    return unless piece.type == :P && cells[left_cell].is_a?(Piece) || cells[right_cell].is_a?(Piece)
    return unless (cells[left_cell].is_a?(Piece) || cells[right_cell].is_a?(Piece))

    # Movimiento diagonal a la izquierda
    if cells[left_cell].is_a?(Piece) && cells[left_cell].type == :P && cells[left_cell].en_passant_eligible && 
      cells[left_cell].color != piece.color && to[0] == left_cell[0]
      cells[left_cell] = nil
      update_position(piece, from, to)
    # Movimiento a la derecha
    elsif cells[right_cell].is_a?(Piece) && cells[right_cell].type == :P && cells[right_cell].en_passant_eligible &&
      cells[right_cell].color != piece.color && to[0] == right_cell[0]
      cells[right_cell] = nil
      update_position(piece, from, to)
    else
      update_en_passant_eligible(cells[left_cell]) if cells[left_cell].is_a?(Piece)
      update_en_passant_eligible(cells[right_cell]) if cells[right_cell].is_a?(Piece)
    end 

  end

  def update_en_passant_eligible(piece)
    if piece.en_passant_eligible
      piece.en_passant_eligible = false
    end
  end

  def is_a_en_passant_move?(from, to)
    piece = cells[from]
    to_as_coord = cell_to_coord(to)
    cell_back_step = piece.color == :white ? [to_as_coord[0] - 1, to_as_coord[1]] : [to_as_coord[0] + 1, to_as_coord[1]]
    cell_back = coord_to_cell(cell_back_step)
    return unless piece.type == :P && cells[cell_back].is_a?(Piece) && cells[cell_back].type == :P && cells[cell_back].en_passant_eligible
    return true
  end


  def castle(from, to)
    piece = cells[from]
    return unless piece.is_a?(Piece) && piece.eligible_for_castle?(@current_player) && cells[to].nil?
    if piece.is_a?(Piece) && piece.type == :K && piece.first_move && piece.color == @current_player
      if kingside_castle?(from, to)
          #Agregar display especifico para cada caso
        return if king_in_check?(piece.color)
        return unless cells['f1'].nil?
        each_piece do |cell, board_piece|
          next if piece.color == board_piece.color
          return if board_piece.legal_moves.include?([0,6])
          return if board_piece.legal_moves.include?([0,7])
        end
    
        kingside_castle(piece)
      elsif queenside_castle?(from, to)
        return if king_in_check?(piece.color)
        return unless cells['b1'].nil?
        return unless cells['d1'].nil?
        each_piece do |cell, board_piece|
          next if piece.color == board_piece.color
          #Agregar display especifico para cada caso
          return if board_piece.legal_moves.include?([0,1])
          return if board_piece.legal_moves.include?([0,2])
          return if board_piece.legal_moves.include?([0,3])
        end
        queenside_castle(piece)
      end
    end
  end

  def kingside_castle?(from, to)
    from_file = from[0]
    to_file = to[0]
    from_rank = from[1].to_i
    to_rank = to[1].to_i
  
    piece = cells[from]
    rook_position = "h#{from_rank}"
    rook = cells[rook_position]

    piece.color == @current_player &&
    piece.type == :K &&
    piece.first_move &&
    rook.is_a?(Piece) &&
    rook.type == :R &&
    rook.first_move &&
    from_file == 'e' &&
    to_file == 'g' &&
    from_rank == to_rank
  end

  def queenside_castle?(from, to)
    from_file = from[0]
    to_file = to[0]
    from_rank = from[1].to_i
    to_rank = to[1].to_i
    
    piece = cells[from]
    rook_position = "a#{from_rank}"
    rook = cells[rook_position]
    
    piece.color == @current_player &&
    piece.type == :K &&
    piece.first_move &&
    rook.is_a?(Piece) &&
    rook.type == :R &&
    rook.first_move &&
    from_file == 'e' &&
    to_file == 'c' &&
    from_rank == to_rank
  end

  def kingside_castle(king)
    rank = king.position[1]
    king_to = "g#{rank}"
    rook_from = "h#{rank}"
    rook_to = "f#{rank}"
  
    update_position(king, king.position, king_to)
    update_position(cells[rook_from], rook_from, rook_to)
  end

  def queenside_castle(king)
    rank = king.position[1]
    king_to = "c#{rank}"
    rook_from = "a#{rank}"
    rook_to = "d#{rank}"
  
    update_position(king, king.position, king_to)
    update_position(cells[rook_from], rook_from, rook_to)
  end

  def is_pawn_promotion?(from, to, current_player)
    piece = cells[from]
    piece.type == :P && to[1] == '8' || to[1] == '1' && piece.color == current_player
  end

  def promote_pawn(from, to, current_player)
    puts "Promote your pawn to (Q)ueen, (R)ook, (B)ishop or (N)ight"
    print "> "
    piece = gets.chomp.upcase
    until %w(Q R B N).include?(piece)
      puts "Invalid selection. Please try again."
      print "> "
      piece = gets.chomp.upcase
    end
    cells[to] = Piece.new(piece.to_sym, current_player, to)
    cells[from] = nil
  end

end

#Moves to test mate pastor
# 1. e2 e4 / e7 e5
# 2. d1 h5 / b8 c6
# 3. f1 c4 / g8 f6
# 4. h5 f7 / e8 f7

# board = Board.new
# board.move('e2', 'e4')
# board.move('e7', 'e5')
# board.move('d1', 'h5')
# board.move('b8', 'c6')
# board.move('f1', 'c4')
# board.move('g8', 'f6')
# board.move('h5', 'f7')
