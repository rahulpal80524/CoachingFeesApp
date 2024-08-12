Rails.application.routes.draw do
  resources :students do
    member do
      post :pay_installment
    end
  end

  root 'students#new'
end
