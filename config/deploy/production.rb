set :stage, :production

server '139.196.166.7', user: 'qingyun', roles: %w{web app db}

set :rails_env, :production

set :unicorn_worker_count, 8

set :enable_ssl, false
