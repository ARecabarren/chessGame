class Piece
    def initialize(type, color, position)

    
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