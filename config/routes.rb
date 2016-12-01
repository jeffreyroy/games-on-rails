Rails.application.routes.draw do

  get 'games/index'
  get 'games/annuvin'
  post 'games/annuvin/click' => 'games#annuvin_click'
  post 'games/annuvin/drop' => 'games#annuvin_drop'

  get 'welcome/index'

  # root 'index'

end
