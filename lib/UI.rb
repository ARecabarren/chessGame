module UI
  
  def show_board(boardHash)
    board = translateHash(boardHash)
    board.each do |file|
      p file
    end
  end

  def translateHash(boardHash)
    myArray = []
    [8,7,6,5,4,3,2,1].each do |rank|
        fullRank = []
        'abcdefgh'.split('').each do |file|
          if boardHash[file + rank.to_s].nil?
            piece_type = :_
          else
            piece_color = boardHash[file + rank.to_s].color

            # Adapt to make blacks lowercase
            piece_type = if piece_color == :black
              boardHash[file + rank.to_s].type.to_s.downcase.to_sym
            else
              boardHash[file + rank.to_s].type
            end
          end
          

          fullRank.push(piece_type)
        end
        myArray.push(fullRank)
    end
    myArray
  end

end
