Rails.application.routes.draw do

  mount Vyapari::Engine => "/"

  get   '/landing', to: "landing#index",  as: :user_landing

end
