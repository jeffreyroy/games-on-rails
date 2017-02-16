require_relative 'game'
require_relative 'checkers_pieces'

## To complete:
# - Multiple captures by AI

# Classes
class Checkers < Game
  attr_reader :current_state, :active_piece
  attr_accessor :minimax
  ## Constants and initialization

  COLUMNS = "abcdefgh"
  ROWS = "87654321"

  def initialize
    position = Array.new(8) { Array.new(8, ".") }
    player = :human
    pieces = { human: [], computer: [] }
    # State is a hash consisting of the current position and the
    # Player currently to move
    # Initialize empty board
    @current_state = { 
      :position => position,
      :player => player, 
      :pieces => pieces,
      :moving_piece => nil
       }
    # Add pieces to empty board
    init_position
    add_pieces
    # Intialize ai
    initialize_ai(0, 100)
  end

  # Add initial piece setup to board
  def init_position
    position = @current_state[:position]
    position[0] = " o o o o".split("")
    position[1] = "o o o o ".split("")
    position[2] = " o o o o".split("")
    position[3] = ". . . . ".split("")
    position[4] = " . . . .".split("")
    position[5] = "O O O O ".split("")
    position[6] = " O O O O".split("")
    position[7] = "O O O O ".split("")
    @current_state[:position] = position
  end

  def add_pieces
    # Add checkers
    pieces= {
      :human => [ ],
      :computer => [ ]
    }
    @current_state[:position].each_with_index do |row, i|
      row.each_with_index do |space, j|
        case space
        when "o"
          pieces[:computer] << Man.new(self, [i, j], :computer)
        when "O"
          pieces[:human] << Man.new(self, [i, j], :human)
        when "k"
          pieces[:computer] << King.new(self, [i, j], :computer)
        when "K"
          pieces[:human] << King.new(self, [i, j], :human)
        end
      end
    end
    @current_state[:pieces] = pieces
  end

  # Make a move and update the state
  def make_move(move)
    @current_state = next_state(@current_state, move)
    # Save new state to database
    export
    p "Current player is now #{@current_state[:player]}"
  end

  # Placeholders to save and restore current state
  def export
    # Temporarily use first database entry for all saves
    s = CheckersSave.first
    s.position = @current_state[:position].join
    s.human_to_move = @current_state[:player] == :human
    if @current_state[:moving_piece]
      s.moving_piece_row = @current_state[:moving_piece][0]
      s.moving_piece_column = @current_state[:moving_piece][1]
    else
      s.moving_piece_row = -1
      s.moving_piece_column = -1
    end
    s.save
  end

  # Parse string representing position and return array
  def position_string_to_array(string)
    size = Math.sqrt(string.length).to_i
    array = chunk(string, size).map { |row| chunk(row, 1) }
    array
  end

  # Helper function to split string
  def chunk(string, size)
    string.scan(/.{1,#{size}}/)
  end


  def import
    s = CheckersSave.first
    @current_state[:position] = position_string_to_array(s.position)
    add_pieces
    @current_state[:player] = s.human_to_move ? :human : :computer
    if s.moving_piece_row == -1
      @current_state[:moving_piece] = nil
    else
      @current_state[:moving_piece] = [ s.moving_piece_row, s.moving_piece_column ]
    end
    # p s
    # p @current_state
  end


  # Return row at which player's men become kings
  def end_row(player)
    player == :human ? 0 : 7
  end

  def total_value(piece_list)
    # return 0 if piece_list.empty?
    piece_list.reduce(0) { |sum, piece| sum + piece.value }
  end

  # Score position based on value of remaining pieces
  def heuristic_score(state)
    pieces = state[:pieces]
    player = state[:player]
    total_value(pieces[player]) - total_value(pieces[opponent(player)])
  end

  def force_analysis(state)
    !!state[:moving_piece]
  end

  ## Methods to make moves

  # Moved this to piece
  # def inbounds(destination)
  #   row = destination[0]
  #   column = destination[1]
  #   row >= 0 && row <= 7 && column >= 0 && column <= 7
  # end

  # Legal moves for minimax algorithm
  def legal_moves(state)
    position = state[:position]
    player = state[:player]
    piece_list = state[:pieces][player]
    move_list = []
    # Loop over pieces
    piece_list.each do |piece|
      move_list += piece.legal_moves(state)
    end
    move_list
  end

  # Given position and move, return resulting position
  def next_state(state, move)
    position = Marshal.load(Marshal.dump(state[:position]))
    player = state[:player]
    opp = opponent(player)
    # Change this: Don't want to deep copy each piece here!
    pieces = Marshal.load(Marshal.dump(state[:pieces]))
    from = move[0]
    to = move[1]
    moving_piece = nil
    current_piece = pieces[player].find { |piece| piece.location == from }
    if !current_piece
      puts "ERROR--no piece to move!"
    end
    # Check for capture
    if (from[0] - to[0]).abs == 2
      # Remove enemy piece
      captured_location = [0,0]
      captured_location[0] = (from[0] + to[0]) / 2
      captured_location[1] = (from[1] + to[1]) / 2
      pieces[opp].delete_if { |piece| piece.location == captured_location }
      position[captured_location[0]][captured_location[1]] = "."
      moving_piece = to
    end
    # Move piece
    position[from[0]][from[1]] = "."
    # If at end row, turn man into king
    if to[0] == end_row(player)
      pieces[player].delete(current_piece)
      current_piece = King.new(self, from, player)
      pieces[player] << current_piece
    end
    position[to[0]][to[1]] = current_piece.icon
    current_piece.location = to
    # If not in middle of series of captures, switch active player
    next_player = moving_piece ? player : opp
    update_state = { :position => position,
      :player => next_player,
      :pieces => pieces,
      :moving_piece => moving_piece
    }
    # If no more captures, end player's move
    if moving_piece && current_piece.generate_captures(update_state).empty?
      update_state[:moving_piece] = nil
      update_state[:player] = opp
    end
    update_state
  end

  # Interpret algebraic notation as coordinates
  def coordinates(string)
    return nil if string.length != 2
    # interpret letter as column
    column = self.class::COLUMNS.index(string[0])
    row = self.class::ROWS.index(string[1])
    return nil if !column || !row
    [row, column]
  end

  # Translate coordinates into algebraic notation
  def algebraic(coordinates)
    return nil if coordinates.length != 2
    # interpret letter as column
    row = self.class::ROWS[coordinates[0]]
    column = self.class::COLUMNS[coordinates[1]]
    column + row
  end

  # For testing - get piece at location
  def get_piece(location_string)
    location = coordinates(location_string)
    pieces = @current_state[:pieces]
    piece = pieces[:human].find { |piece| piece.location == location }
    if !piece
      piece = pieces[:computer].find { |piece| piece.location == location }
    end
    piece
  end

  # For testing - print legal moves for piece at location
  def print_moves(location_string)
    piece = get_piece(location_string)
    if piece
      p piece.legal_moves(@current_state).map { |move| algebraic(move[1]) }
    else
      "No piece there. "
    end
  end

 # # Get the player's move and make it
 #  def get_move

 #    # Fill this in.  Sample code:
 #    puts
 #    display_position
 #    position = @current_state[:position]
 #    piece_list = @current_state[:pieces][:human]
 #    # print "Your pieces: "
 #    # puts piece_list.map { |piece| "#{piece.icon} at #{piece.location}"}
 #    move = nil
 #    while move == nil
 #      puts
 #      print "Enter move in algebraic notation: "
 #      move_labels = gets.chomp.split("-")
 #      if move_labels.length != 2 || move_labels[0].length != 2 || move_labels[1].length != 2
 #        puts "I don't understand that move."
 #        puts "Please use algebraic notation, e.g. 'e2-e4'."
 #      else
 #        from = coordinates(move_labels[0])
 #        to = coordinates(move_labels[1])
 #        if !from
 #          puts "I don't understand #{move_labels[0]} as a position."
 #        elsif !to
 #          puts "I don't understand #{move_labels[1]} as a position."
 #        else
 #          piece = @current_state[:pieces][:human].find { |p| p.location == from }
 #          if !piece
 #            puts "You have no piece at #{move_labels[0]}"
 #          elsif !piece.legal_moves(@current_state).include?([from, to])
 #            puts "That's not a legal destination."
 #            puts
 #          else
 #            move = [from, to]
 #          end
 #        end
 #      end
 #    end
 #    make_move(move)
 #  end


  # 3.  Methods to respond to user input via controller
  # Import player's click
  def import_click(move_param)
    # Integerize move parameter
    move = move_param.map {|c| c.to_i }
    p "You seem to be moving the piece at #{move}"
    piece = @current_state[:pieces][:human].find { |p| p.location == move }
    if !piece
      p "There is no piece there!"
    end
    # Return list of legal moves
    list = piece.legal_moves(@current_state)
    p "Legal moves for that piece: #{list}"

    list
  end

  # Import player's drop
  def import_drop(from_param, to_param, cont)
    # If computer is not in the middle of a move, make player move
    if !cont
      # Integerize move parameter
      from = from_param.map {|c| c.to_i }
      to = to_param.map {|c| c.to_i }
      p "You seem to be moving to from #{from} to #{to}"
      make_move([from, to])
    end
    p "Current player is now #{@current_state[:player]}"
    # If the player is not in the middle of a move, make computer move
    if @current_state[:player] == :computer
      # Get computer move
      response = best_move(@current_state)
      puts
      p "I respond #{response}"
      make_move(response)
      # p display_position(@current_state)
    else
      # Response to indicate it is still the player's move
      response = [[-1, -1], [-1, -1]]
    end
    # Send move to client
    response
  end


  ## Methods to determine outcome

  # Check whether game is over
  # (ie whether the board is full)
  def done?(state)
    legal_moves(state).empty?
  end

  # Check whether game has been won by player to move
  def won?(state)
    pieces = state[:pieces]
    player = opponent(state[:player])
    pieces[player].empty?
  end

  # Check whether game has been lost by player to move
  def lost?(state)
    pieces = state[:pieces]
    player = state[:player]
    pieces[player].empty?
  end

  # ## Displays

  # # Print the entire board (only works for current position)
  # def display_position
  #   side = " \u2551"
  #   puts " \u2554" + "\u2550" * 16 + "\u2557"
  #   current_position.each do |row|
  #     row_string = row.join(" ")
  #     puts side + row_string + side
  #   end
  #   puts " \u255A" + "\u2550" * 16 + "\u255D"
  # end

  # def display_computer_move(move)
  #   puts "I move #{algebraic(move[0])}-#{algebraic(move[1])}"
  # end

end




