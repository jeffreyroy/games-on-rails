class Tictac < Game

  attr_reader :current_state
  attr_accessor :minimax


    ## Constants and initialization

  BOARD_TRANS = [[6, 1, 8], [7, 5, 3], [2, 9, 4]]
  BOARD_REV_TRANS = [0, [0, 1], [2, 0], [1, 2], [2, 2], [1, 1], [0, 0], [1, 0], [0, 2], [2, 1]]
  MARKERS = ["   ", " O ", " X "]

  def initialize
    position = [3, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    player = :human
    # State is a hash consisting of the current position and the
    # Player currently to move
    @current_state = { :position => position, :player => player }
    initialize_ai(9, 100)
  end

  def number(player)
    (player == :human) ? 2 : 1
  end

    # Placeholders to save and restore current state
  def export
    # Temporarily use first database entry for all saves
    s = TictacSave.first
    s.position = @current_state[:position].join
    s.human_to_move = @current_state[:player] == :human
    s.save
  end

  # Parse string representing position and return array
  def position_string_to_array(string)
    string.split("").map { |n| n.to_i }
  end

  def import
    s = TictacSave.first
    @current_state[:position] = position_string_to_array(s.position)
    @current_state[:player] = s.human_to_move ? :human : :computer
    p s
    p @current_state
  end

  # Make a move and update the state
  def make_move(move)
    @current_state = next_state(@current_state, move)
    # Save new state to database
    export
  end


  ## 2. Methods to make moves

  # Legal moves for minimax algorithm
  def legal_moves(state)
    position = state[:position]
    move_list = []
    position.each_with_index do |square, index|
      if square == 0
        move_list << index
      end
    end
    move_list
  end

  # Given position and move, return resulting position
  # Move expressed as number of square 1-9
  def next_state(state, move)
    position = state[:position]
    player = state[:player]
    result = Array.new(position)
    # array_square = self.class::BOARD_TRANS[move]
    result[move] = number(player)
    next_player = opponent(player)
    { :position => result, :player => next_player }
  end

  # Get the player's move
  def get_move
    puts
    display_position
    array_square = 0
    until array_square > 0
      puts
      print "Enter your move (1-9): "
      player_move = gets.chomp.to_i
      array_square = self.class::BOARD_TRANS[player_move]

      if !legal_moves(@current_state).index(array_square)
        puts "That's not a legal move!"
        # minimax.show_scores
        array_square = 0
      end
    end
    make_move(array_square)
  end

  ## 3. Methods to input moves via web interface

  # Import player's click
  def import_click(move_param)
    # Integerize move parameter
    move = move_param.to_i
    # Make move
    puts "You seem to be moving to #{move}"
    if !legal_moves(@current_state).index(move)
      puts "That's not a legal move!"
    end
    make_move(move)
    if lost?(@current_state)
      # If computer has lost, return player as winner
      return { move: 0, winner: "player" }
    elsif done?(@current_state)
      return { move: 0, winner: "cat" }
    else
      # Otherwise, get computer move
      response = best_move(@current_state)
      puts
      p "I respond #{response}"
      make_move(response)
      winner = lost?(@current_state) ? "computer" : "none"
      # Send move to client
      { move: response, winner: winner }
    end
  end


  ## 4. Methods to determine outcome

  # Check whether game is over
  # (ie whether the board is full)
  def done?(state)
    position = state[:position]
    position.index(0) == nil
  end

  # check row using magic square
  # value: 1 = computer, 2 = player
  def check_row(position, a, b, value)
    c = 15 - a - b
    # Squares are out of bounds (should not ever happen)
    if a < 1 || a > 9  || b < 1 || b > 9
      puts "Out of bounds error while checking row #{a} #{b}!"
      return false
    # Third space is not legal
    elsif c < 1 || c > 9 || c == a || c == b || a == b
      return false
    # Check whether third space has the value we're looking
    elsif position[a] == value && position[b] == value && position[c] == value
      return true
    else
      return false
    end
  end

  # Checks all straight lines on board to try to find a formation
  # Line must contain two cells with firstValue and one with secondValue
  # a, b, c are board spaces in magic square notation
  # checkMove returns cell with value if formation is found
  # otherwise returns nil
  def check_move(position, value)
    move = nil
    (1..9).each do |a|
      (1..9).each do |b|
        if check_row(position, a, b, value)
          move = 15 - a - b
        end
      end
    end
    move
  end

  # Check whether game has been won by a player
  def won?(state)
    position = state[:position]
    player = state[:player]
    n = number(player)
    check_move(position, n) ? true : false
  end

  def lost?(state)
    position = state[:position]
    player = opponent(state[:player])
    won?( { :position => position, :player => player } )
  end

  # ## Displays

  # # Get marker on square on the board (1-9)
  # def marker(num)
  #   square_code = current_position[self.class::BOARD_TRANS[num]]
  #   self.class::MARKERS[square_code]
  # end

end
