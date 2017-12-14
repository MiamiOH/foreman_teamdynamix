Rails.application.routes.draw do
  constraints(:id => %r{[^\/]+}) do
    resources :hosts do
      member do
        get 'new_action'
      end
    end
  end
end
