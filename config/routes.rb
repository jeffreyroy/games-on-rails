Rails.application.routes.draw do

  root 'games#index'
  get 'games/index'

  # Annuvin
  get 'games/annuvin'
  post 'games/annuvin/click' => 'games#annuvin_click'
  post 'games/annuvin/drop' => 'games#annuvin_drop'


  # Checkers
  get 'games/checkers'
  post 'games/checkers/click' => 'games#checkers_click'
  post 'games/checkers/drop' => 'games#checkers_drop'

  # Chess
  get 'games/chess'
  post 'games/chess/click' => 'games#chess_click'
  post 'games/chess/drop' => 'games#chess_drop'

  # Gomoku
  get 'games/gomoku'
  post 'games/gomoku/drop' => 'games#gomoku_drop'

  # Tic Tac Toe
  get 'games/tictac'
  post 'games/tictac/drop' => 'games#tictac_drop'

  get 'welcome/index'

  # root 'index'

end
