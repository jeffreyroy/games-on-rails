class GamesController < ApplicationController
  attr_accessor :current_game
  def index
  end

  def annuvin
    # Reset game
    game = Annuvin.new
    game.export
  end

  def annuvin_drag
        p "*"*80
    # Get current state of game
    game = Annuvin.new
    p game.current_position
    # game.import

    # Send move to model and get computer move
    move = game.import_drag(params["move"])
    p "*"*80
    # Make computer move
    blurb = "I move #{move}"
    render :json => { blurb: blurb }
  end

end
