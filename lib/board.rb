require_relative './pieces.rb'
require_relative './UI.rb'
include UI
class Board
  attr_accessor :cells
  attr_reader :files_left, :files_right

  def initialize
    @cells = {}
    setup_board
    compute_moves
  end

  def setup_board
    # Populates pawns
    [2, 7].each do |rank|
      'abcdefgh'.split('').each do |file|
        color = rank == 2 ? :white : :black
        @cells[file + rank.to_s] = Piece.new(:P, color, file + rank.to_s, cells)
      end
    end

    # Populates left half Rook, Knight, Bishop, Queen
    [1, 8].each do |rank|
      color = rank == 1 ? :white : :black
      Board.files_left.each_pair do |key, value|
        @cells[value + rank.to_s] = Piece.new(key, color, value + rank.to_s, cells)
      end
    end
    # Populates right half King, Bishop, Knight, Rook
    [1, 8].each do |rank|
      color = rank == 1 ? :white : :black
      Board.files_right.each_pair do |key, value|
        @cells[value + rank.to_s] = Piece.new(key, color, value + rank.to_s, cells)
      end
    end
  end

  def self.files_left
    {
      R: 'a',
      N: 'b',
      B: 'c',
      Q: 'd'
    }
  end

  def self.files_right
    {
      K: 'e',
      B: 'f',
      N: 'g',
      R: 'h'
    }
  end

  def self.in_boundaries?(move)
    x, y = move
    x_range = 0..7
    y_range = 0..7
    x_range.include?(x) && y_range.include?(y)
  end

  def possible_moves(_piece)
    moves = []
    current_x, current_y = @position
    @directions.each do |direction|
      delta_x, delta_y = direction
      new_x = current_x + delta_x
      new_y = current_y + delta_y

      while valid_move?([new_x, new_y])
        moves << [new_x, new_y]
        new_x += delta_x
        new_x += delta_y
      end
    end
    moves
  end

  def move(from, to)
    #Things to check before move
    #Move include as legal move in piece.
    #Puts own king in check
  end

  def update_position(piece, from, to)
    piece.position = to
    cells[to] = cells[from]
    cells[from] = nil 
    show_board(cells)
  end



  def each_piece
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

  def compute_moves
    each_piece do |cell, piece|
      compute_move(piece)
    end
  end

  def compute_move(piece)
    piece.legal_moves = []
      current_x, current_y = cell_to_coord(piece.position)
      case piece.type
      when :R
        piece.directions.each do |direction|
        current_x, current_y = cell_to_coord(piece.position)
          loop do
            new_coord = process_direction(direction, current_x, current_y)
            to_cell = cells[coord_to_cell(new_coord)]
            if in_boundaries?(new_coord)
              if to_cell.nil?
                piece.legal_moves << new_coord
                current_x, current_y = process_direction(direction, current_x, current_y)
              elsif to_cell.color != piece.color
                piece.legal_moves << new_coord
                break
              else
                break
              end
            else
              break
            end
          end
        end
      when :N
        piece.directions.each do |direction|
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
      when :B
        piece.directions.each do |direction|
          current_x, current_y = cell_to_coord(piece.position)
          loop do
            new_coord = process_direction(direction, current_x, current_y)
            to_cell = cells[coord_to_cell(new_coord)]
            if in_boundaries?(new_coord)
              if to_cell.nil?
                piece.legal_moves << new_coord
                current_x, current_y = process_direction(direction, current_x, current_y)
              elsif to_cell.color != piece.color
                piece.legal_moves << new_coord
                break
              else
                break
              end
            else
              break
            end
          end
        end
      when :Q
        piece.directions.each do |direction|
          current_x, current_y = cell_to_coord(piece.position)
          loop do
            new_coord = process_direction(direction, current_x, current_y)
            to_cell = cells[coord_to_cell(new_coord)]
            if in_boundaries?(new_coord)
              if to_cell.nil?
                piece.legal_moves << new_coord
                current_x, current_y = new_coord
              elsif to_cell.color != piece.color
                piece.legal_moves << new_coord
                break
              else
                break
              end
            else
              break
            end
          end
        end
      when :K
        piece.directions.each do |direction|
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
      when :P
        piece.directions.each do |direction|
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
      else
      end
  end
end

# def coordinate_to_key(coordinate)
#   file_index = coordinate[1]
#   rank = coordinate[0]

#   files = 'abcdefgh'
#   file = files[file_index]
#   "#{file}#{rank}"
# end

# def fileRank_to_coord(position)
#   column = position[1]
#   row = 0
#   'abcdefgh'.split('').each do |file|
#     break if position[0] == file
#     row += 1
#   end
#   [row, column]
# end

board = Board.new
# board.cells['c3'] = Piece.new(:R, :white, 'c3')
# board.cells['d4'] = Piece.new(:N, :black, 'd4')
board.cells['e5'] = Piece.new(:B, :white, 'e5')

board.compute_moves
show_board(board.cells)
# whiteKing = Piece.new(:K, :white, 'e4', board)
# p whiteKing.legal_moves
# board.move('b1','c3')
# show_board(board.cells)

# puts board.cells
