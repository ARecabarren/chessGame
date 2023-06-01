class Piece
    attr_accessor :position
    attr_reader :type, :color
    def initialize(type, color, position)
        @type = type
        @color = color
        @position = position
    end

end


class Knight
    attr_reader :color, :possible_moves
    attr_accessor :position
    def initialize(color, position)
        @position = position
        @color = color
        @possible_moves = [
            [2,1],[2,-1],[-2,1],[-2,-1],
            [1,2],[1,-2],[-1,2],[-1,-2]
        ]
    end
end