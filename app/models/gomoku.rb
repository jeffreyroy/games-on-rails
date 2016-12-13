# require_relative 'monte_carlo'
require_relative 'minimax'
require_relative 'game'

# Simple implementation of gomoku


# FOR SIMPLICITY Moves are restricted to subset of available moves
# Classes
class Gomoku < Game
  attr_reader :current_state
  attr_accessor :minimax

  # Constants

  SYMBOLS = { :human => "X", :computer => "O" }
  DIRECTIONS = [[1, 0], [0, 1], [1, 1], [-1, 1]]

  ## 1. Methods common to all games, can be redefined if necessary

  # Initialize new game
  def initialize
    reset
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
    @current_state = {
      :position => position,
      :player => player,
      :last_move => last_move,
      :outer_bounds => outer_bounds
       }
  end

  # For testing only:  Let player make computer's move
  # def computer_move
  #   get_move
  # end

  def heuristic_score(state)
    # Get player's best formation
    player = state[:player]
    player_score = longest_row(state, player)

    # Get opponent's best formation
    player = opponent(player)
    opponent_score = longest_row(state, player)
    player_score - opponent_score * 1.1
  end

  ## 2. Game-specific methods to make moves

  # Legal moves for minimax algorithm
  # Returns array containing list of legal moves in given state
  def legal_moves(state)
    position = state[:position]
    outer_bounds = state[:outer_bounds]
    moves = []
    #  Loop through all spaces on grid
    # position.each_with_index do |row, i|
    #   row.each_with_index do |space, j|
    #     if space == "."
    #       moves << [i, j]
    #     end
    #   end
    # end

    # FOR SIMPLICITY require move to be within outer bounds
    # Calculate range of space to check

    row_min = [outer_bounds[:top] - 1, 0].max
    row_max = [outer_bounds[:bottom] + 1, 18].min

    column_min = [outer_bounds[:left] - 1, 0].max
    column_max = [outer_bounds[:right] + 1, 18].min
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
  def next_state(state, move)
    position = state[:position]
    player = state[:player]
    # Need to create new hash for last_move?
    last_move = {}.merge(state[:last_move])
    outer_bounds = {}.merge(state[:outer_bounds])
    # Is this the easiest way to create a new copy of the position?
    next_position = Marshal.load(Marshal.dump(position))
    # Add appropriate symbol to move location
    next_position[move[0]][move[1]] = self.class::SYMBOLS[player]
    # Swap players
    next_player = opponent(player)
    # FOR SIMPLICTY update last move
    last_move[player] = move
    outer_bounds[:top] = move[0] if move[0] < outer_bounds[:top]
    outer_bounds[:bottom] = move[0] if move[0] > outer_bounds[:bottom]
    outer_bounds[:left] = move[1] if move[1] < outer_bounds[:left]
    outer_bounds[:right] = move[1] if move[1] > outer_bounds[:right]
    # Return updated state
    new_state = { :position => next_position,
      :player => next_player,
      :last_move => last_move,
      :outer_bounds => outer_bounds
    }
    new_state
  end

  # Get the player's move and make it
  def get_move
    # Fill this in.  Sample code:
    puts
    display_position(@current_state)
    move = nil
    until move != nil
      puts
      print "Enter your move (x, y): "
      move_string = gets.chomp
      move_array = move_string.split(",")
      if move_array.length != 2
        puts "You must enter two coordinates."
      else
        move = [move_array[1].to_i, move_array[0].to_i]
      end
      if !legal_moves(@current_state).index(move)
        puts "That's not a legal move!"
        move = nil
      end
    end
    make_move(move)
  end

  ## 3. Game-specific methods to determine outcome

  # Check whether game is over
  def done?(state)
    # legal_moves(state).empty?
    # Try to speed up by disregarding possibility of draw
    false
  end

  def inbounds?(row, column)
    row >= 0 && row <= 18 && column >= 0 && column <= 18
  end

  # Helper method to find winning formations
  # Attempts to find five symbols in a row including specified space
  def max_in_a_row(position, row, column, symbol)
    # Make sure starting space includes required symbol
    # print position[row][column]
    return 0 if position[row][column] != symbol
    max = 0
    # Loop over all directions
    self.class::DIRECTIONS.each do |direction|
      check = check_row(position, row, column, symbol, direction)
      max = check if check > max
    end
    return max
  end

  def longest_row(state, player)
    position = state[:position]
    last_move = state[:last_move][player]
    row = last_move[0]
    column = last_move[1]
    symbol = self.class::SYMBOLS[player]
    max_in_a_row(position, row, column, symbol)
  end

  def check_row(position, row, column, symbol, direction)
    row_increment = direction[0]
    column_increment = direction[1]
    total_length = 0
    # From starting space, check forwards and backwards
    [[-1, -1], [1, 1]].each do |multiplier|
      current_row = row
      current_column = column
      # Count number of symbols in a row
      while inbounds?(current_row, current_column) && position[current_row][current_column] == symbol
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
  def won?(state)
    # Fill this in
    player = state[:player]
    longest_row(state, player) >= 5
  end

  # Check whether game has been lost by the player currently on the move
  # in the specified state
  def lost?(state)
    # Fill this in
    player = opponent(state[:player])
    longest_row(state, player) >= 5
  end

  ## 4. Game-specific displays

  # Display the current position
  def display_position(state)
    position = state[:position]
    puts "  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8"
    position.each_with_index do |row, i|
      print i % 10
      print " " + row.join(" ") + " "
      puts i % 10
    end
    puts "  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8"

    last_move = state[:last_move][:computer]
    display_computer_move(last_move)

  end

  # Display the computer's move
  def display_computer_move(move)
    # Fill this in
    puts
    print "Computer just moved to "
    puts "#{move[1]}, #{move[0]}"
    puts
    puts "Your advantage: #{heuristic_score(@current_state)}"

  end

end


# Driver code
game = Gomoku.new
minimax = Minimax.new(game, 1)
# minimax = Montecarlo.new(game, 500, 4)
game.minimax = minimax
done = false
while !done
  game_over = false
  while !game_over
    game.get_move
    if game.lost?(game.current_state)
      puts "You win!!"
      game_over = true
    elsif game.done?(game.current_state)
      puts "Cat's game!"
      game_over = true
    else
      game.computer_move
      if game.lost?(game.current_state)
        puts "I win!" 
        game_over = true
      end
    end
  end

  game.display_position(game.current_state)
  puts
  print "Play again? (y/n)"
  again = gets.chomp.downcase
  if again == "y" 
    game.reset
  else
    done = true
  end
end

puts "Thanks for playing!"