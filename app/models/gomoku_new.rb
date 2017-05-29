# require_relative 'monte_carlo'
# require_relative 'minimax'
require_relative 'game_new'

# Simple implementation of gomoku

class GomokuMove

end

class GomokuState
  attr_reader :last_move, :outer_bounds

  def initialize(position, player, last_move, outer_bounds)
    @position = position
    @player = player
    @last_move = last_move
    @outer_bounds = outer_bounds
  end

  def heuristic_score
    # Get player's best formation
    player_score = longest_row(@player)
    # Get opponent's best formation
    opponent_score = longest_row(opponent)
    player_score - opponent_score
  end


  # Use this to force ai to continue to analyse this position
  # even if beyond maximum normal depth (e.g. if part of series
  # of captures)
  def force_analysis
    false
  end

  ## 2. Game-specific methods to make moves

  # Legal moves for minimax algorithm
  # Returns array containing list of legal moves in given state
  def legal_moves
    moves = []

    # FOR SIMPLICITY require move to be within outer bounds
    # Calculate range of space to check

    row_min = [@outer_bounds[:top] - 1, 0].max
    row_max = [@outer_bounds[:bottom] + 1, 18].min

    column_min = [@outer_bounds[:left] - 1, 0].max
    column_max = [@outer_bounds[:right] + 1, 18].min
    (row_min..row_max).each do |i|
      (column_min..column_max).each do |j|
        if position[i][j] == "." # && !moves.index([i, j])
          moves << [i, j]
        end
      end
    end

    moves
  end

  # Given state and move, return resulting state after move is made
  # That means updating the position, and also (usually) switching
  # the player to the opponent
  def next_state(move)
    # Need to create new hash for last_move?
    next_last_move = {}.merge(@last_move)
    next_outer_bounds = {}.merge(@outer_bounds)
    # Is this the easiest way to create a new copy of the position?
    next_position = Marshal.load(Marshal.dump(position))
    # Add appropriate symbol to move location
    next_position[move[0]][move[1]] = self.class::SYMBOLS[player]
    # Swap players
    next_player = opponent
    # FOR SIMPLICTY update last move
    next_last_move[player] = move
    next_outer_bounds[:top] = move[0] if move[0] < next_outer_bounds[:top]
    next_outer_bounds[:bottom] = move[0] if move[0] > next_outer_bounds[:bottom]
    next_outer_bounds[:left] = move[1] if move[1] < next_outer_bounds[:left]
    next_outer_bounds[:right] = move[1] if move[1] > next_outer_bounds[:right]
    # Return updated state
    GomokuState.new(next_position, next_player, next_last_move, next_outer_bounds)
  end


  ## 4. Game-specific methods to determine outcome

  # Check whether game is over
  def done?
    # legal_moves(state).empty?
    # Try to speed up by disregarding possibility of draw
    false
  end

  def inbounds?(row, column)
    row >= 0 && row <= 18 && column >= 0 && column <= 18
  end

  # Helper method to find winning formations
  # Attempts to find five symbols in a row including specified space
  def max_in_a_row(row, column, symbol)
    # Make sure starting space includes required symbol
    # print position[row][column]
    return 0 if @position[row][column] != symbol
    max = 0
    # Loop over all directions
    self.class::DIRECTIONS.each do |direction|
      check = check_row(@position, row, column, symbol, direction)
      max = check if check > max
    end
    return max
  end

  def longest_row(player_to_check)
    move = @last_move[player_to_check]
    row = move[0]
    column = move[1]
    symbol = self.class::SYMBOLS[player_to_check]
    max_in_a_row(@position, row, column, symbol)
  end

  def check_row(row, column, symbol, direction)
    row_increment = direction[0]
    column_increment = direction[1]
    total_length = 0
    # From starting space, check forwards and backwards
    [[-1, -1], [1, 1]].each do |multiplier|
      current_row = row
      current_column = column
      # Count number of symbols in a row
      while inbounds?(current_row, current_column) && @position[current_row][current_column] == symbol
        total_length += 1
        current_row += multiplier[0] * row_increment
        current_column += multiplier[0] * column_increment
      end
    end
    # Return number in a row
    total_length - 1
  end

  # Check whether game has been won by the player currently on the move
  # in the specified state
  def won?
    longest_row(@player) >= 5
  end

  # Check whether game has been lost by the player currently on the move
  # in the specified state
  def lost?(state)
    longest_row(opponent) >= 5
  end

  ## 4. Game-specific displays

  # Display the current position
  def display_position
    # Fill this in
  end

end


# FOR SIMPLICITY Moves are restricted to subset of available moves
# Classes
class NewGomoku < Game
  attr_reader :current_state
  attr_accessor :minimax

  # Constants

  SYMBOLS = { :human => "X", :computer => "O" }
  DIRECTIONS = [[1, 0], [0, 1], [1, 1], [-1, 1]]

  ## 1. Methods common to all games, can be redefined if necessary

  # Initialize new game
  def initialize
    reset
    initialize_ai(0, 100)
  end

  def reset
    player = :human
    # Position = 19 * 19 array, each space initialized to dot
    position = Array.new(19) { Array.new(19, ".") }
    # FOR SIMPLICITY Force computer move to center
    position[9][9] = "O"
    # State is a hash consisting of the current position and the
    # Player currently to move
    # FOR SIMPLICITY add last move by human and computer
    last_move = { :human => [9, 9], :computer => [9, 9] }
    outer_bounds = { :top => 9, :bottom => 9, :left => 9, :right => 9 }
    @current_state = GomokuState.new(position, player, last_move, outer_bounds)
  end

  # Placeholders to save and restore current state
  def export
    # Temporarily use first database entry for all saves
    s = GomokuSave.first
    s.position = @current_state.position.join
    s.human_to_move = @current_state.player == :human
    s.human_last_row = @current_state.last_move[:human][0]
    s.human_last_column = @current_state.last_move[:human][1]
    s.computer_last_row = @current_state.last_move[:computer][0]
    s.computer_last_column = @current_state.last_move[:computer][1]
    s.top = @current_state.outer_bounds[:top]
    s.bottom = @current_state.outer_bounds[:bottom]
    s.left = @current_state.outer_bounds[:left]
    s.right = @current_state.outer_bounds[:right]
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
    s = GomokuSave.first
    position = position_string_to_array(s.position)
    player = s.human_to_move ? :human : :computer
    last_human_move = [s.human_last_row, s.human_last_column]
    last_computer_move = [s.computer_last_row, s.computer_last_column]
    last_move = { human: last_human_move, computer: last_computer_move }
    outer_bounds = { top: s.top, bottom: s.bottom, left: s.left, right: s.right }
    @current_state = GomokuState.new(position, player, last_move, outer_bounds)
    p s
    p @current_state
  end

  # Make a move and update the state
  def make_move(move)
    @current_state = @current_state.next_state(move)
    # Save new state to database
    export
  end

  # For testing only:  Let player make computer's move
  # def computer_move
  #   get_move
  # end



  # 3.  Methods to respond to user input via controller
  # Import player's click
  def import_click(move_param)
    # Integerize move parameter
    move = move_param.map {|c| c.to_i }
    # Make move
    p "You seem to be moving to #{move}"
    make_move(move)
    if @current_state.lost?
      # If computer has lost, return player as winner
      return { move: [-1, -1], winner: "player" }
    else
      # Otherwise, get computer move
      response = @current_state.best_move
      puts
      p "I respond #{response}"
      make_move(response)
      winner = @current_state.lost? ? "computer" : "none"
      # Send move to client
      { move: response, winner: winner }
    end
  end

end

