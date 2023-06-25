require_relative './lib/pieces.rb'
require_relative './lib/board.rb'
require_relative './lib/UI.rb'
require 'json'
class ChessGame
    def initialize()
        @board = Board.new
    end

    def play
        UI.display_welcome_message
        UI.display_menu
        input = UI.get_input
        case input
        when '1'
            while (state = @board.game_state) == :in_game
                puts
                UI.show_board(@board.cells)
                UI.display_current_player(@board.current_player)
                input = UI.get_move
                if input == 'save'
                    save_game
                    puts "Game saved!"
                    exit
                
                elsif valid_move?(input)
                    puts
                    from, to = input.split(' ')
                    until @board.move(from, to) != :illegal_move
                        UI.display_invalid_move_message
                        input = UI.get_move
                        if input == 'save'
                            save_game
                            puts "Game saved!"
                            exit
                        
                        elsif valid_move?(input)
                            from, to = input.split(' ')
                            if @board.move(from, to) != :illegal_move
                                break
                            end 
                        end
                    end
                    switch_players         
                end
            end
            puts 
        when '2'
            @board.current_player, @board.cells = load_game
            @board.compute_moves
            run_game
        when '3'
            puts "Goodbye!"
            exit
        end
    end 

    def switch_players
        current_player = @board.current_player
        @board.current_player = (current_player == :white) ? :black : :white
    end

    def valid_move?(input)
        return false if input == :invalid_move
        from, to = input.split(' ')
        unless piece_selected?(from)
            UI.display_empty_cell_message
            return false
        end
        unless right_player?(from, to)
            UI.display_wrong_piece_color_message
            UI.display_current_player(@board.current_player)
            return false
        end
        unless in_boundaries?(from, to)
            UI.display_out_of_boundaries_message
            return false
        end
        true
    end

    def piece_selected?(from)
        # Check if piece in from is not nil
        @board.cells[from] != nil
        
    end

    def right_player?(from, to)
        # Check if piece  in from equals current plater
        @board.cells[from].color == @board.current_player
    end

    def in_boundaries?(from, to)
        from_coords = ChessGame.cell_to_coord(from)
        to_coords = ChessGame.cell_to_coord(to)
        # Check if from and to are in boundaries
        @board.in_boundaries?(from_coords) && @board.in_boundaries?(to_coords)
    end

    def self.cell_to_coord(fileRank)
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
      
    def self.coord_to_cell(coord)
        rank = coord[0] + 1
        files = 'abcdefgh'
        file = files[coord[1]]
        "#{file}#{rank}"
    end

    def save_game
        UI.display_save_menu
        filename = gets.chomp
        game_data = {:current_player => @board.current_player}
        game_data[:cells] = {}
        @board.cells.each do |cell, piece|
            next if piece == nil
            game_data[:cells][cell] = {:type => piece.type, :color => piece.color, :position => piece.position, :first_move => piece.first_move,
            :legal_moves => piece.legal_moves, :en_passant_eligible => piece.en_passant_eligible}
        end
        write_file(game_data, filename)
    end
    def write_file(game_data, filename)
        # As json
        filename = "./saves/#{filename}.json"
        File.open(filename, 'w') do |file|
            file.puts game_data.to_json
        end
    end
        
    def load_game
        puts "Choose a game by its number"
        display_saves
        game_to_load = gets.chomp.to_i
        game_data = read_file(game_to_load)
        # binding.pry
        [game_data['current_player'].to_sym,game_data['cells']]
    end

    def display_saves
        saves_array = Dir.glob("./saves/*.json")
        saves_array.each_with_index do |save, index|
            puts "#{index}. #{save}"
        end
    end

    def read_file(game_to_load)
        games_array = Dir.glob("./saves/*.json")
        filename = games_array[game_to_load]
        game_data = File.read("#{filename}")

        game_data = JSON.parse(game_data)
        game_data['cells'].transform_values! do |piece_data|
            next if piece_data == nil
            Piece.new(piece_data['type'].to_sym, piece_data['color'].to_sym, piece_data['position'], piece_data['first_move'],
            piece_data['legal_moves'], piece_data['en_passant_eligible'])
        end
        game_data
    end

    def run_game
        # binding.pry
        while (state = @board.game_state) == :in_game
            puts
            UI.show_board(@board.cells)
            UI.display_current_player(@board.current_player)
            input = UI.get_move
            if input == 'save'
                save_game
                puts "Game saved!"
                exit
            
            elsif valid_move?(input)
                puts
                from, to = input.split(' ')
                until @board.move(from, to) != :illegal_move
                    UI.display_invalid_move_message
                    input = UI.get_move
                    if input == 'save'
                        save_game
                        puts "Game saved!"
                        exit
                    
                    elsif valid_move?(input)
                        from, to = input.split(' ')
                        if @board.move(from, to) != :illegal_move
                            break
                        end 
                    end
                end
                switch_players         
            end
        end
    end
end

game = ChessGame.new
game.play