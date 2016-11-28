module Minimaxable
  attr_accessor :max_depth, :max_score

  def initialize_ai(max_depth = 10, max_score = 100)
    @state_scores = {}
    @depth = 0
    @max_depth = max_depth
    @max_score = max_score
  end

  # # Find the best move (without random selection)
  # def best_move(state)
  #   best_move_with_score(state)[0]
  # end

  # Find the best move with random selection
  def best_move(state)
    player = state[:player]
    best_score = -9999
    legal_moves = legal_moves(state)
    # Return nil if no legal moves
    if legal_moves.empty?
      return nil
    end
    # Build list of scores for moves
    move_scores = legal_moves.map do |move|
      print "\rConsidering #{move}  "
      score_state = next_state(state, move)
      move_score = score(score_state)
      next_player = score_state[:player]
      # If alternating moves, use negative of opponent's score
      if next_player != player
        move_score = -move_score
      end
      best_score = move_score if move_score > best_score
      { :move => move, :score => move_score }
    end
    # p move_scores
    # Pick best move
    # Choose randomly if more than one
    best_moves = move_scores.select { |move_score| move_score[:score] == best_score }
    best_moves.sample[:move]
  end

  # Recursive minimax algorithm divided into two parts
  # First part picks best move for a player
  # Second part assigns score to move

  # Pick best move for player to move
  # State is the state of the game expressed as a hash
  # { :position => <current position>, :player => <player to move> }
  def best_move_with_score(state)
    position = state[:position]
    player = state[:player]
    best_player = player
    legal_moves = legal_moves(state)
    if legal_moves.empty?
      return[nil, 0]
    end
    best_score = -999
    best_move = nil
    # next_player = opponent(player)
    score_array = legal_moves.map do |move|
      # Generate resulting state
      score_state = next_state(state, move)
      # Score resulting position (for opponent)
      move_score = score(score_state)
      next_player = score_state[:player]
      # If alternating moves, use negative of opponent's score
      if next_player != player
        move_score = -move_score
      end
      # # For testing: Immediately return move that leads to win
      # if move_score >= 50
      #   return [move, move_score]
      # end
      # Check whether this move is best so far
      if move_score > best_score
        best_move = move
        best_score = move_score
        best_player = next_player
      end
    end
    # Return best move
    # print best_score
    [best_move, best_score]
  end

  # For testing
  # Show all states with calculated scores
  def show_scores
    puts "Showing scores: "
    @state_scores.each_pair do |state, score|
      position = state[:position]
      player = state[:player]
      puts
      p position
      puts "Player to move: #{player}"
      puts "Score: #{score}"
    end
  end

  # Returns score of a game state for the player to move
  def score(state)
    position = state[:position]
    # If state has already been calculated as win or loss,
    # Return score
    if @state_scores.has_key?(state)
      return @state_scores[state]
    end
    # If @game is over, return appropriate score
    if won?(state)
      best_score = @max_score - @depth # player won
    elsif lost?(state)
      best_score = -@max_score + @depth # player lost
    elsif done?(state)
      best_score = 0  # draw
    elsif @depth > @max_depth && !force_analysis(state)
      # If too deep, use game-specific scoring
      # Default is just to give score of 1 (slightly better than draw)
      # print "."
      best_score = heuristic_score(state)
    else
      # Otherwise find and score best move for opponent
      # print @depth
      @depth += 1
      best_score = best_move_with_score(state)[1]
      @depth -= 1
    end
    # Add score to master list and return it
    if best_score == @max_score || best_score == -@max_score
      @state_scores[state] = best_score
    end
    best_score
  end
end