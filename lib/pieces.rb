class Piece
    attr_accessor :position
    attr_reader :type, :color
    def initialize(type, color, position)
        @type = type
        @color = color
        @position = position
        #Need to set @availables_moves
        #Need to adapt directions acording to @type
    end

    def get_directions
        case @type
        when 'R'
            
        when 'N'
            [
                [2,1],[2,-1],[-2,1],[-2,-1],
                [1,2],[1,-2],[-1,2],[-1,-2]
            ]
        when 'B'

        when 'Q'

        when 'K'
            [
                [0,1],[1,1],[1,0],[-1,1],[-1,0],
                [-1,-1],[0,-1],[1,-1]
            ]
        when 'pawn'

        else
            return
        end
    end

    knight_
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