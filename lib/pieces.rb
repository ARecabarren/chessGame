# require_relative './board.rb'

class Piece
  attr_accessor :position, :in_range_moves
  attr_reader :type, :color, :directions

  def initialize(type, color, position)
    @type = type
    @color = color
    @position = position
    @first_move = true
    set_directions
    compute_moves
  end

  def set_directions
    @directions = case @type
      when :R
        [[0, 1], [1, 0], [0, -1], [-1, 0]]
      when :N
        [
          [2, 1], [2, -1], [-2, 1], [-2, -1],
          [1, 2], [1, -2], [-1, 2], [-1, -2]
        ]
      when :B
        [[1, 1], [1, -1], [-1, -1], [-1, 1]]
      when :Q
        [[0, 1], [1, 1], [1, 0], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]
      when :K
        [
          [0, 1], [1, 1], [1, 0], [-1, 1], [-1, 0],
          [-1, -1], [0, -1], [1, -1]
        ]
      when :P
        if @color == :white
          if @first_move
            [[-1, 0], [-2, 0]]
          else
            [[-1, 0]]
          end
        else
          if @first_move
            [[1, 0], [2, 0]]
          else
            [[1, 0]]
          end
        end
      else
        []
      end
  end
  # knight example
  def compute_moves
    @in_range_moves = []
    current_x, current_y = cell_to_coord(self.position)
    case type
    when :R
      
    when :N
      self.directions.each do |direction|
        xstep, ystep = direction
        new_x = current_x + xstep
        new_y = current_y + ystep
        new_coord = [new_x,new_y]
        in_range_moves << new_coord if in_boundaries?(new_coord)
      end
    when :B

    when :Q

    when :K

    when :P
      
    else
      
    end
  end
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

def in_boundaries?(coord)
  x, y = coord
  x.between?(0,7) && y.between?(0,7) 
end

# whitePawn = Piece.new(:P,:white,'a2')
whiteKnight = Piece.new(:N, :white, 'b1')
whiteKnight.in_range_moves # [[2, 2], [2, 0], [1, 3]]