Rails.application.routes.draw do

  get 'games/index'
  get 'games/annuvin'
  post 'games/annuvin/drag' => 'games#annuvin_drag'

  get 'welcome/index'

  # root 'index'

end
