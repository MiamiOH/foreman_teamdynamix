Rails.application.routes.draw do
  constraints(:id => %r{[^\/]+}) do
    resources :hosts do
      member do
        get 'team_dynamix'
      end
    end
  end
end
