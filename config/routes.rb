Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'main#index'
  get 'main', to: 'main#index'
  get 'main/:path', to: 'main#show', constraints: { path: /.*/ }
  get '/eddie', to: 'eddie#index'
  post '/eddie', to: 'eddie#create'
end
