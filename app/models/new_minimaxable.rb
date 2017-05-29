module NewMinimaxable

  MAX_DEPTH = 10
  MAX_SCORE = 100

  def initialize_ai
    @score = nil
    # @depth = 0
  end

  # # Find the best move (without random selection)
  # def best_move
  #   best_move_with_score[0]
  # end

  # Find the best move with random selection
  def best_move
    best_score = -9999
    current_moves = legal_moves
    # Return nil if no legal moves
    if current_moves.empty?
      return nil
    end
    # Build list of scores for moves
    move_scores = current_moves.map do |move|
      print "\rConsidering #{move}  "
      score_state = next_state(move)
      move_score = score(0)
      next_player = score_state.player
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
  def best_move_with_score(depth)
    best_player = player
    current_moves = legal_moves
    if current_moves.empty?
      return[nil, 0]
    end
    best_score = -999
    best_move = nil
    # next_player = opponent(player)
    score_array = current_moves.map do |move|
      # Generate resulting state
      score_state = next_state(move)
      # Score resulting position (for opponent)
      move_score = score_state.score(depth)
      next_player = score_state.player
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
    # print best_move
    # print depth
    [best_move, best_score]
  end

  # Returns score of a game state for the player to move
  def score(depth)
    # print depth
    # If state has already been calculated as win or loss,
    # Return score
    if @score != nil
      return @score
    end
    # If @game is over, return appropriate score
    if won?
      best_score = self.class::MAX_SCORE - depth # player won
    elsif lost?
      best_score = -self.class::MAX_SCORE + depth # player lost
    elsif done?
      best_score = 0  # draw
    elsif depth > self.class::MAX_DEPTH && !force_analysis
      # If too deep, use game-specific scoring
      # Default is just to give score of 1 (slightly better than draw)
      # print "."
      best_score = heuristic_score
    else
      # Otherwise find and score best move for opponent
      best_score = best_move_with_score(depth + 1)[1]
    end
    # Add score to master list and return it
    if best_score == self.class::MAX_SCORE || best_score == -self.class::MAX_SCORE
      @score = best_score
    end
    # print best_score
    best_score
  end
end