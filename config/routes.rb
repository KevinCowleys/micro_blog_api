Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :posts, only: %i[index create destroy]
      resources :conversations do
        resources :messages
      end

      # Like routes
      get 'likes/:username', to: 'likes#index', username: %r{[^/]+}
      post 'like/:post_id', to: 'likes#toggle_like'

      # Save routes
      get 'saves/:username', to: 'saves#index', username: %r{[^/]+}
      post 'save/:post_id', to: 'saves#toggle_save'

      # Follower routes
      get 'following/:username', to: 'followers#show_following', username: %r{[^/]+}
      get 'followers/:username', to: 'followers#show_followers', username: %r{[^/]+}
      post 'follow/:username', to: 'followers#toggle_follow', username: %r{[^/]+}

      # Mute routes
      get 'muted', to: 'mutes#index', as: :settings_mutes
      post 'mute/:username', to: 'mutes#toggle_mute', username: %r{[^/]+}

      # Block routes
      get 'blocked', to: 'blocks#index', as: :settings_blocks
      post 'block/:username', to: 'blocks#toggle_block', username: %r{[^/]+}

      # Authentication routes
      post 'authenticate', to: 'authentication#create'

      # Profile routes
      get ':username', to: 'profile#index', username: %r{[^/]+}
      get 'profile/settings', to: 'profile#settings'
      patch 'profile/settings', to: 'profile#update_settings'
    end
  end
end
