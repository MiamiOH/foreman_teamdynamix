Rails.application.routes.draw do
  constraints(:id => %r{[^/]+}) do
    resources :hosts do
      member do
        get 'teamdynamix'
      end
    end
  end
end
