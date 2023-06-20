class Piece
  attr_accessor :position, :legal_moves, :en_passant_eligible, :first_move
  attr_reader :type, :color, :directions

  DIRECTIONS = {
    R: [[0, 1], [1, 0], [0, -1], [-1, 0]],
    N: [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]],
    B: [[1, 1], [1, -1], [-1, -1], [-1, 1]],
    Q: [[0, 1], [1, 1], [1, 0], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]],
    K: [[0, 1], [1, 1], [1, 0], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]],
    P: {
      white: [[1, 0], [2, 0]],
      black: [[-1, 0], [-2, 0]]
    }
  }

  def initialize(type, color, position,board_cells = nil)
    @type = type
    @color = color
    @position = position
    @first_move = true
    @directions = set_directions
    @legal_moves = []
    @en_passant_eligible = false
  end

  def set_directions
    directions = DIRECTIONS[@type]
    directions = directions[@color] if directions.is_a?(Hash)
    directions
  end
end



# whitePawn = Piece.new(:P,:white,'a2')
# whiteKnight = Piece.new(:N, :white, 'b1')
# whiteKnight.in_range_moves # [[2, 2], [2, 0], [1, 3]]
