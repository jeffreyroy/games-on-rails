# require_relative 'minimax'
require_relative 'game'
require_relative 'chess_pieces'
# require 'pry'

## To do:
# Check and Checkmate (temporarily disabled for speed)
# Pawn promotion (done)
# Castling (done, except for legality check)
# En passant
# Opening book
# Put next_state into pieces rather than game?
# Refactor using classes for states and moves

# Classes
class Chess < Game
  attr_reader :current_state
  attr_accessor :minimax

  ## Constants and initialization

  COLUMNS = "abcdefgh"
  ROWS = "87654321"
  SETUP = "rnbqkbnr" + "pppppppp" + "." * 32 + "PPPPPPPP" + "RNBQKBNR"

  def initialize
    position = position_string_to_array(self.class::SETUP)
    player = :human
    pieces= {
      :human => [ ],
      :computer => [ ]
    }
    # Initialize empty board
    @current_state = {
      :position => position,
      :player => player,
      :pieces => pieces,
      :check => false,
      :force_analysis => false
    }
    add_pieces
    # Intialize ai
    initialize_ai(0, 1000)
    @max_force_depth = 3
    display_position
  end

  def add_pieces
    # Add pieces
    pieces= {
      :human => [ ],
      :computer => [ ]
    }
    @current_state[:position].each_with_index do |row, i|
      row.each_with_index do |space, j|
        case space
        when "k"
          pieces[:computer] << ChessKing.new(self, [i, j], :computer)
        when "K"
          pieces[:human] << ChessKing.new(self, [i, j], :human)
        when "q"
          pieces[:computer] << Queen.new(self, [i, j], :computer)
        when "Q"
          pieces[:human] << Queen.new(self, [i, j], :human)
        when "r"
          pieces[:computer] << Rook.new(self, [i, j], :computer)
        when "R"
          pieces[:human] << Rook.new(self, [i, j], :human)
        when "b"
          pieces[:computer] << Bishop.new(self, [i, j], :computer)
        when "B"
          pieces[:human] << Bishop.new(self, [i, j], :human)
        when "n"
          pieces[:computer] << Knight.new(self, [i, j], :computer)
        when "N"
          pieces[:human] << Knight.new(self, [i, j], :human)
        when "p"
          pieces[:computer] << Pawn.new(self, [i, j], :computer)
        when "P"
          pieces[:human] << Pawn.new(self, [i, j], :human)

        end
      end
    end
    @current_state[:pieces] = pieces
  end

  # Add piece icons to board
  def add_icons
    [:human, :computer].each do |player|
      @current_state[:pieces][player].each do |piece|
        row = piece.location[0]
        column = piece.location[1]
        @current_state[:position][row][column] = piece.icon
      end
    end
  end


  # Placeholders to save and restore current state
  def export
    # Temporarily use first database entry for all saves
    s = ChessSave.first
    s.position = @current_state[:position].join
    s.human_to_move = @current_state[:player] == :human
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
    s = ChessSave.first
    @current_state[:position] = position_string_to_array(s.position)
    add_pieces
    @current_state[:player] = s.human_to_move ? :human : :computer
  end

  # Make a move and update the state
  def make_move(move)
    @current_state = next_state(@current_state, move)
    # Save new state to database
    export
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

  # Return row at which player's pawns promote
  def end_row(player)
    player == :human ? 0 : 7
  end

  def force_analysis(state)
    state[:force_analysis] && @depth < @max_force_depth
  end

  ## Methods to make moves

  # Find a player's king
  def get_king(state, player)
    pieces = state[:pieces][player]
    pieces.find { |piece| piece.class == ChessKing }
  end

  # Test whether opponent is in check
  def check?(state)
    player = state[:player]
    king = get_king(state, opponent(player))
    # Look for a move that can capture the king
    checking_move = king && pre_check_legal_moves(state).find {
      |move| move[1] == king.location
    }
    !!checking_move
  end

  # Check whether a destination is on the board
  def inbounds(destination)
    row = destination[0]
    column = destination[1]
    row >= 0 && row <= 7 && column >= 0 && column <= 7
  end

  # Generate list of moves, not taking account of whether
  # Player is left in check
  def pre_check_legal_moves(state)
    player = state[:player]
    piece_list = state[:pieces][player]
    move_list = []
    # Loop over pieces
    piece_list.each do |piece|
      move_list += piece.legal_moves(state)
    end
    move_list
  end

  # Get list of legal moves in given state
  # for minimax algorithm
  def legal_moves(state)
    move_list = pre_check_legal_moves(state)
    # # Eliminate moves which leave player in check
    # # move_list.delete_if { |move| check?(next_state(state, move)) }
    # move_list.each do |move| 
    #   if check?(next_state(state, move))
    #     print "."
    #     move_list.delete(move)
    #   end
    # end
    move_list
  end

  # Given state and move, return resulting state
  def next_state(state, move)
    # Deep copy position (is this the easiest way?)
    position = Marshal.load(Marshal.dump(state[:position]))
    player = state[:player]
    opp = opponent(player)
    pieces = Marshal.load(Marshal.dump(state[:pieces]))
    from = move[0]
    to = move[1]
    force_analysis = false
    check = false
    moving_piece = pieces[player].find { |piece| piece.location == from }
    if !moving_piece
      puts "ERROR--no piece to move!"
    end
    # Check for capture
    if position[to[0]][to[1]] != "."
      # Remove enemy piece
      pieces[opp].delete_if { |piece| piece.location == to }
      # Force AI to continue analysis
      force_analysis = true
    end
    # Check for promotion
    if moving_piece.class == Pawn && to[0] == end_row(player)
      # Replace pawn with queen
      # (Underpromotion not yet implemented)
      pieces[player].delete(moving_piece)
      moving_piece = Queen.new(self, to, player)
      pieces[player] << moving_piece
    end
    # Move piece
    position[from[0]][from[1]] = "."
    position[to[0]][to[1]] = moving_piece.icon
    moving_piece.location = to
    # Complete castling by moving rook
    if moving_piece.class == ChessKing && (from[1] - to[1]).abs == 2
      rook_column = to[1] == 6 ? 7 : 0
      castling_rook = pieces[player].find { |piece| piece.location == [from[0], rook_column] }
      if castling_rook
        rook_dest = to[1] == 6 ? 5 : 3
        position[from[0]][rook_column] = "."
        position[to[0]][rook_dest] = castling_rook.icon
        castling_rook.location = [to[0], rook_dest]
      else
        puts "Castling error -- can't find rook!"
      end
    end
    # Switch active player
    next_player = opp
    # # Create new state for testing whether king is in check
    # new_position_state = {
    #   :position => position,
    #   :player => player,
    #   :pieces => pieces,
    #   :check => false,
    #   :force_analysis => false
    # }
    # # Test whether opponent's king is now in check
    # check = check?(new_position_state)
    # force_analysis = true if check
    # Return new state
    {
      :position => position,
      :player => next_player,
      :pieces => pieces,
      :check => check,
      :force_analysis => force_analysis
    }
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


  # 3.  Methods to respond to user input via controller
  # Import player's click
  def import_click(move_param)
    # Integerize move parameter
    move = move_param.map {|c| c.to_i }
    p "You seem to be moving the piece at #{move}"
    piece = @current_state[:pieces][:human].find { |p| p.location == move }
    if !piece
      p "There is no piece there:"
      display_position
      p @current_state[:pieces][:human]
    end
    # Return list of legal moves
    list = piece.legal_moves(@current_state)
    p "Legal moves for that piece: #{list}"

    list
  end

  # Import player's drop
  def import_drop(from_param, to_param)
    # Make player move
    # Integerize move parameter
    from = from_param.map {|c| c.to_i }
    to = to_param.map {|c| c.to_i }
    p "You seem to be moving to from #{from} to #{to}"
    make_move([from, to])
    p "Current player is now #{@current_state[:player]}"

    display_position
    # Make computer move
    response = best_move(@current_state)
    puts
    p "I respond #{response}"
    make_move(response)
    # p display_position(@current_state)
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
    # pieces[player].empty?
    king = pieces[player].find { |piece| piece.class == ChessKing }
    !king
  end

  # Check whether game has been lost by player to move
  def lost?(state)
    pieces = state[:pieces]
    player = state[:player]
    # pieces[player].empty?
    king = pieces[player].find { |piece| piece.class == ChessKing }
    !king
  end


  ## Displays

  # Print the entire board (only works for current position)
  def display_position
    side = " \u2551"
    puts " \u2554" + "\u2550" * 16 + "\u2557"
    current_position.each do |row|
      row_string = row.join(" ")
      puts side + row_string + side
    end
    puts " \u255A" + "\u2550" * 16 + "\u255D"
    if @current_state[:check]
      puts
      puts "Check!"
    end
  end

end


