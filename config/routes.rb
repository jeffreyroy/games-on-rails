Rails.application.routes.draw do

  get 'games/index'

  # Annuvin
  get 'games/annuvin'
  post 'games/annuvin/click' => 'games#annuvin_click'
  post 'games/annuvin/drop' => 'games#annuvin_drop'

  # Gomoku
  get 'games/gomoku'
  post 'games/gomoku/drop' => 'games#gomoku_drop'

  get 'welcome/index'

  # root 'index'

end
