require 'sidekiq'
require 'sidekiq-status'
require 'sidekiq/web'

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
  if Rails.env.production?
    config.redis = { :url => 'redis://139.196.166.7/0' }
  else
    config.redis = { :url => 'redis://localhost:6379/0' }
  end
end

Sidekiq.configure_server do |config|
  if Rails.env.production?
    config.redis = { :url => 'redis://139.196.166.7/0' }
  else
    config.redis = { :url => 'redis://localhost:6379/0' }
  end

  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
  end
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end

  ::ActiveRecord::Base.configurations[Rails.env]['pool'] = 30
  ::ActiveRecord::Base.establish_connection
end
