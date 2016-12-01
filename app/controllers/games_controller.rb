class GamesController < ApplicationController
  attr_accessor :current_game
  def index
  end

  def annuvin
    # Reset game
    game = Annuvin.new
    game.export
  end

  def annuvin_click
        p "*"*80
    # Get current state of game
    game = Annuvin.new
    p game.current_position
    # game.import

    # Send piece to model and return list of legal moves
    legal_moves = game.import_click(params["move"])
    p "*"*80
    # Make computer move
    render :json => { moves: legal_moves }
  end

  def annuvin_drop
    p "*"*80
    # Get current state of game
    game = Annuvin.new
    p game.current_position
    # game.import

    # Send piece to model and return list of legal moves
    move = game.import_drop(params["move"])
    p "*"*80
    # Make computer move
    render :json => { move: move }
  end

end
