Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Flash Demo Routes
  get "flash_demo", to: "flash_demo#index", as: "flash_demo"

  post "flash_demo/success", to: "flash_demo#success", as: "flash_demo_success"
  post "flash_demo/error", to: "flash_demo#error", as: "flash_demo_error"
  post "flash_demo/warning", to: "flash_demo#warning", as: "flash_demo_warning"
  post "flash_demo/info", to: "flash_demo#info", as: "flash_demo_info"
  post "flash_demo/notice", to: "flash_demo#notice", as: "flash_demo_notice"
  post "flash_demo/alert", to: "flash_demo#alert", as: "flash_demo_alert"
  post "flash_demo/multiple", to: "flash_demo#multiple", as: "flash_demo_multiple"
  post "flash_demo/custom_duration", to: "flash_demo#custom_duration", as: "flash_demo_custom_duration"
  post "flash_demo/quick_dismiss", to: "flash_demo#quick_dismiss", as: "flash_demo_quick_dismiss"
  post "flash_demo/long_message", to: "flash_demo#long_message", as: "flash_demo_long_message"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

end
