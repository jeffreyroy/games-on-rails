Rails.application.routes.draw do

  get 'games/index'
  get 'games/annuvin'
  post 'games/annuvin' => 'games#annuvin_move'

  get 'welcome/index'

  # root 'index'

end
