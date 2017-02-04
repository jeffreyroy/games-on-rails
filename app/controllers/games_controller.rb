class GamesController < ApplicationController
  attr_accessor :current_game
  def index
  end

  def annuvin
    # Reset game
    game = Annuvin.new
    game.export
  end

  # Respond to player clicking on friendly piece
  def annuvin_click
    p "*"*80
    # Get current state of game
    game = Annuvin.new
    # p game.current_position
    game.import

    # Send piece to model and return list of legal moves
    legal_moves = game.import_click(params["move"])
    p "*"*80
    # Make computer move
    render :json => { moves: legal_moves }
  end

  # Respond to player moving a piece
  def annuvin_drop
    p "*"*80
    # Get current state of game
    game = Annuvin.new
    game.import
    p "Drop parameters:"
    p params
    # Send move to model and return computer move
    # Do we need to parse params as json?
    cont = params["cont"] == "true"
    move_param = params["move"]
    move = game.import_drop(move_param["from"], move_param["to"], cont)
    p "*"*80
    # Make computer move
    cont = game.current_state[:moving_piece] != nil
    render :json => { move: move, cont: cont }
  end

  def gomoku
    # Reset game
    game = Gomoku.new
    game.export
  end

   # Respond to player moving a piece
  def gomoku_drop
    p "*"*80
    # Get current state of game
    game = Gomoku.new
    game.import
    p "Drop parameters:"
    p params
    # Send move to model and return computer move
    # Do we need to parse params as json?
    response = game.import_click(params["move"])
    p "*"*80
    # Make computer move
    render :json => response
  end


  def tictac
    # Reset game
    game = Tictac.new
    game.export
  end

   # Respond to player moving a piece
  def tictac_drop
    p "*"*80
    # Get current state of game
    game = Tictac.new
    game.import
    p "Drop parameters:"
    p params
    # Send move to model and return computer move
    # Do we need to parse params as json?
    response = game.import_click(params["move"])
    p "*"*80
    # Make computer move
    render :json => response
  end

end
