module UI
  
  def self.show_board(board_hash)
    board = translate_hash(board_hash)
    board.each { |rank| puts rank.join(' ') }
    puts "\n"
  end

  def self.display_empty_cell_message
    puts 'The choosen cell is empty'
  end

  def self.display_current_player(current_player)
    puts "#{current_player.to_s.capitalize}'s turn\n\n"
  end
    
  def display_same_color_piece
    puts "\nSame color piece in destination\n\n"
  end

  def self.display_welcome_message
    puts "\nWelcome to Chess!\n\n"
  end

  def self.display_menu
    puts "1. New Game"
    puts "2. Load Game"
    puts "3. Exit"
    print "> "
  end

  def self.display_game_menu
    puts "1. Move"
    puts "2. Save"
    puts "3. Exit"
    print "> "
  end

  def self.get_move
    puts "Enter your move as 'a2 a4' (from to), 'save' or 'exit'"
    print "> "
    input = gets.chomp
    case input
    when 'save'
      display_save_menu
      input = gets.chomp
      save_game(input)
      nil
    when 'exit'
      puts "Goodbye!"
      exit
    else
      return input if UI.valid_move_input?(input)
      return :invalid_move
    end
  end

  def self.valid_move_input?(input)
    input.match?(/^[a-h][1-8]\s[a-h][1-8]$/)
  end

  def self.save_game(filename)
    File.open("./saves/#{filename}.yml", 'w') { |file| file.write(YAML.dump(self)) }
  end

  def self.get_input
    input = gets.chomp
    until valid_input?(input)
      UI.display_invalid_input_message
      input = gets.chomp
    end
    input
  end

  def self.valid_input?(input)
    input.match?(/^[1-3]$/)
  end

  def self.display_move_menu
    puts "Enter the coordinates of the piece you want to move"
    puts "Enter the coordinates of the destination"
  end

  def self.display_save_menu
    puts "Enter the name of the save file"
    print "> "
  end

  def self.display_out_of_boundaries_message
    puts "Out of boundaries"
  end

  def self.display_same_color_piece_message
    puts "Same color piece in destination"
  end

  def self.display_no_piece_message
    puts "No piece in origin"
  end

  def self.display_wrong_piece_color_message
    puts "You can move only your pieces"
  end

  def self.display_load_menu
    puts "Enter the name of the save file"
  end

  def self.display_checkmate_message
    puts "Checkmate!"
  end

  def self.display_check_message
    puts "Check!"
  end

  def self.display_stalemate_message
    puts "Stalemate!"
  end

  def self.display_invalid_move_message
    puts "Invalid move"
    puts
  end

  def self.display_invalid_input_message
    puts "Invalid input"
  end

  def self.translate_hash(board_hash)
    translated_board = []
    [8, 7, 6, 5, 4, 3, 2, 1].each do |rank|
        full_rank = []
        ('a'..'h').each do |file|
          piece = board_hash[file + rank.to_s]
          
          piece_type = piece.nil? ? :_ : translate_piece_type(piece)
          
          full_rank.push(piece_type)
        end
        translated_board.push(full_rank)
    end
    translated_board
  end

  def self.translate_piece_type(piece)
    piece_color = piece.color
    piece_type = piece.type

    if piece_color == :black
      piece_type = piece_type.to_s.downcase.to_sym
    end

    piece_type
  end

end
