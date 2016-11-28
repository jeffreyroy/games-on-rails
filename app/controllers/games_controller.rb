class GamesController < ApplicationController
  attr_accessor :currentGame
  def index
  end

  def annuvin
    currentGame = Annuvin.new
    @blurb = "Welcome to Annuvin!"
  end
end
