# require_relative 'monte_carlo'
# require_relative 'minimax'
require_relative 'game'

class Annuvin < Game
  attr_reader :current_state
  attr_accessor :minimax

  # Number of pieces initially on the board
  NUMBER_OF_PIECES = 4

  # Initial board position
  INITIAL_BOARD = ["- - O O O",
                    "- O . . .",
                     ". . . . .",
                      ". . . X -",
                       "X X X - -"]

  # Characters representing pieces for each player
  SYMBOLS = { :human => "X", :computer => "O" }

  # Directions on the hex board, for calculating moves
  DIRECTIONS = { :e =>[0, 1],
                :w =>[0, -1],
                :ne =>[-1, 1],
                :nw =>[-1, 0],
                :se =>[1, 0],
                :sw =>[1, -1] }

  ## 1. Methods common to all games, can be redefined if necessary

  # Initialize new game
  def initialize
    reset
    initialize_ai(0, 100)
  end

  def reset
    player = :human
    position = init_board
    # number of pieces left for each player
    pieces_left = { :human => 4, :computer => 4 }
    # variables required to record partial move
    moving_piece = nil
    moves_left = 0
    # @current_move_list = []
    # State is a hash consisting of the current position and the
    # Player currently to move
    @current_state = {  :position => position,
                        :player => player,
                        :pieces_left => pieces_left,
                        :moving_piece => moving_piece,
                        :moves_left => moves_left,
                        :force_analysis => false }
  end

  # Initialize 3x3 hex board
  def init_board
    board_string = self.class::INITIAL_BOARD
    board = board_string.map do |row|
      row.split(" ")
    end
  end

  # For testing purpose, let player choose computer move
  # def computer_move
  #   get_move
  # end

  # Use this to calculate score of any position beyond
  # the depth of the search tree
  # Default is just to return 0 (even)
  # This should be customized for any game that is too deep to
  # calculate to the end
  def heuristic_score(state)
    player = state[:player]
    pieces_left = state[:pieces_left]
    pieces_left[player] - pieces_left[opponent(player)]
  end


  def force_analysis(state)
    state[:force_analysis]
  end

  ## 2. Game-specific methods to make moves

  # Vector artihmetic
  def add_vector(vector1, vector2)
    vector1.zip(vector2).map { |x,y| x + y }
  end

  def distance(space1, space2)
    ydiff = space1[0] - space2[0]
    xdiff = space1[1] - space2[1]
    ((xdiff + ydiff).abs + xdiff.abs + ydiff.abs) / 2
  end

  # Check whether a space is on the board
  def inbounds?(space)
    # Return false if outside of array
    return false if space[0] < 0 || space[0] > 4
    return false if space[1] < 0 || space[1] > 4
    # Return false if space marked as off limits
    return false if self.class::INITIAL_BOARD[space[0]][space[1]] =="-"
    # Otherwise return true
    true
  end

  # Legal moves for minimax algorithm
  # Returns array containing list of legal moves in given state
  # Move is a hash { :destination, :moves_left }
  def legal_moves(state)
    moves = []
    position = state[:position]
    player = state[:player]
    pieces_left = state[:pieces_left][player]
    moving_piece = state[:moving_piece]
    moves_left = state[:moves_left]
    # If moving piece, add list of additional captures only
    if moving_piece
      # Generate list of captures
      destinations = get_moves(state, moving_piece, moves_left, true)
      moves = destinations.map { |destination| [moving_piece, destination] }
      # Add "pass" move
      moves << [moving_piece, moving_piece]
    else
      moves_left = total_moves(state)
      # Loop through pieces
      pieces = get_pieces(state)
      pieces.each do |piece_location|
        # Add list of moves for this piece
        destinations = get_moves(state, piece_location, moves_left, false)
        moves += destinations.map { |destination| [piece_location, destination] }
      end
    end
    moves
  end

  # Calculate total number of moves available, given number of pieces left
  def total_moves(state)
    player = state[:player]
    return state[:moves_left] if state[:moving_piece]
    self.class::NUMBER_OF_PIECES + 1 - state[:pieces_left][player]
  end

  # Find locations of all of a player's pieces on the board
  def get_pieces(state)
    position = state[:position]
    player = state[:player]
    symbol = self.class::SYMBOLS[player]
    pieces = []
    position.each_with_index do |row, i|
      row.each_with_index do |space, j|
        if space == symbol
          pieces << [i, j]
        end
      end
    end
    pieces
  end

  # Get list of possible moves
  def get_moves(state, start_space, moves_left, capture_only)
    @current_move_list =[]
    destinations(state, start_space, moves_left, capture_only)
    @current_move_list
  end

  # Find possible destinations for a piece
  def destinations(state, start_space, moves_left, capture_only)
    player = state[:player]
    position = state[:position]
    directions = self.class::DIRECTIONS

    # Loop through directions
    directions.each_value do |direction|
      current_space = add_vector(start_space, direction)
      # For testing:  Limit ai to forward moves until captures start
      if player != :computer ||
        direction == [1, 0] || direction == [1, -1] ||
        state[:pieces_left][:computer] < 4
        # Check whether destination is inbounds
        if inbounds?(current_space)
          # p "#{start_space} -> #{current_space}"
          space_contents = position[current_space[0]][current_space[1]]
          # Check whether destination is a legal move
          if space_contents == self.class::SYMBOLS[opponent(player)] || (space_contents == "." && !capture_only)
            # If move not in move list, add it
            if !@current_move_list.include?(current_space)
              @current_move_list << current_space
            end
          end
          # If more moves left, call recursively
          if moves_left > 1
            destinations(state, current_space, moves_left - 1, capture_only)
          end
        end
      end
    end

  end

  # Given state and move, return resulting state after move is made
  # That means updating the position, and also (usually) switching
  # the player to the opponent
  def next_state(state, move)
    # Fill this in.  Sample code:
    position = state[:position]
    # Is this the easiest way to create a new copy of the position?
    next_position = Marshal.load(Marshal.dump(position))

    player = state[:player]
    pieces_left = {}.merge(state[:pieces_left])
    moving_piece = nil
    moves_left = 0
    force = false
    piece = move[0]
    destination = move[1]
    destination_contents = position[destination[0]][destination[1]]
    # Make move on board
    next_position[piece[0]][piece[1]] = "."
    next_position[destination[0]][destination[1]] = self.class::SYMBOLS[player]
    next_player = opponent(player)
    # Check to see whether move is a capture
    if destination_contents == self.class::SYMBOLS[opponent(player)]
      # Make a capture move, allowing for additional moves
      moves_left = total_moves(state) - distance(piece, destination)
      if moves_left > 0
        moving_piece = destination
        next_player = player
        force = true
      end
      pieces_left[opponent(player)] -= 1
    end
    # Create new state
    new_state = { :position => next_position,
      :player => next_player,
      :pieces_left => pieces_left,
      :moving_piece => moving_piece,
      :moves_left => moves_left,
      :force_analysis => force }
    #If capture, check to see whether additional moves can be made
    if moving_piece && get_moves(new_state, moving_piece, moves_left, true).empty?
      # If no more moves, switch to next player
      new_state[:moving_piece] = nil
      new_state[:player] = opponent(player)
    end
    new_state
  end

  # Get the player's move and make it
  def get_move
    # Fill this in.  Sample code:
    display_state(@current_state)
    puts
    display_position(@current_state)
    piece_list = get_pieces(@current_state)
    piece = @current_state[:moving_piece]
    move = nil
    while piece == nil
      print "Your pieces: "
      p piece_list
      puts
      print "Enter piece to move (x, y): "
      piece_string = gets.chomp
      piece = piece_string.split(",").map { |x| x.to_i }
      if piece.length != 2
        puts "You must enter two coordinates. "
        piece = nil
      elsif !piece_list.include?(piece)
        puts "That's not the location of a piece. "
        piece = nil
      end
    end
    puts
    puts "Moving piece at #{piece}."
    moves_left = total_moves(@current_state)
    capture_only = @current_state[:moving_piece] != nil
    puts "Valid move locations: "
    p get_moves(@current_state, piece, moves_left, capture_only)

    while move == nil
      print "Enter location to move: "
      destination_string = gets.chomp
      destination = destination_string.split(",").map { |x| x.to_i }
      move = [piece, destination]
      if destination.length != 2
        puts "You must enter two coordinates. "
        move = nil
      elsif !legal_moves(@current_state).index(move)
        puts "That's not a legal move!"
        move = nil
      end
    end
    make_move(move)
  end

  ## 3. Game-specific methods to determine outcome

  # Check whether game is over
  def done?(state)
    # Fill this in
    false
  end

  # Check whether game has been won by the player currently on the move
  # in the specified state
  def won?(state)
    # Fill this in
    player = state[:player]
    pieces_left = state[:pieces_left]
    pieces_left[opponent(player)] == 0 ||
      pieces_left[opponent(player)] == 1 && pieces_left[player] == 4
  end

  # Check whether game has been lost by the player currently on the move
  # in the specified state
  def lost?(state)
    # Fill this in
    player = state[:player]
    pieces_left = state[:pieces_left]
    pieces_left[player] == 0 ||
      pieces_left[opponent(player)] == 4 && pieces_left[player] == 1
  end

  ## 4. Game-specific displays

  # Display the current position
  def display_position(state)
    position = state[:position]
    player = state[:player]
    count = 0
    position.each do |row|
      print " " * count
      formatted_row = row.map { |space| space == "-" ? " " : space }
      puts formatted_row.join(" ")
      count += 1
    end
  end

  # Display the computer's move
  def display_computer_move(move)
    # Fill this in
    # Example code:
    puts
    puts "I move from #{move[0]} to #{move[1]}. "
  end

  # Display state data for testing
  def display_state(state)
    player = state[:player]
    pieces_left = state[:pieces_left]
    puts
    puts "Player to move: #{player}"
    puts "Pieces for #{player}: #{pieces_left[player]}"
    puts "Pieces for #{opponent(player)}: #{pieces_left[opponent(player)]}"
    puts "Moving piece: #{state[:moving_piece]}"
    puts "Moves left: #{state[:moves_left]}"

  end

end


