class GamesController < ApplicationController
  attr_accessor :current_game
  def index
  end

  def annuvin
    current_game = Annuvin.new
    @blurb = current_game.get_pieces(current_game.current_state).join(" ")
  end

  def annuvin_move
    @blurb = current_game.get_pieces(current_game.current_state).join(" ")
    render :json => @blurb
  end

end
