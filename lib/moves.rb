module Moves
    def compute_moves(piece)
        list = []
        current_x, current_y = piece.position
        piece.possible_moves.each do |move|
            xstep, ystep = move
            new_x = current_x + xstep
            new_y = current_y + ystep
            list << [new_x, new_y] if valid_move?([new_x, new_y])
        end
    end
    
    def valid_move?(move)
        
    end

    def check_boundaries(move)
        
    end
end