class Piece
    attr_accessor :position
    attr_reader :type, :color
    def initialize(type, color, position)
        @type = type
        @color = color
        @position = position
        @directions = get_directions
        #Need to set @availables_moves
        #Need to adapt directions acording to @type
    end

    def get_directions
        case @type
        when 'R'
            [[0, 1], [1, 0], [0, -1], [-1, 0]]
        when 'N'
            [
                [2,1],[2,-1],[-2,1],[-2,-1],
                [1,2],[1,-2],[-1,2],[-1,-2]
            ]
        when 'B'
            [[1, 1], [1, -1], [-1, -1], [-1, 1]]
        when 'Q'
            [[0, 1], [1, 1], [1, 0], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]
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

    def possible_moves
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