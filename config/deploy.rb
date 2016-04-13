# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'retail_store'
set :deploy_user, 'qingyun'
set :deploy_to, "/home/#{fetch :deploy_user}/retail_store"
set :repo_url, 'git@github.com:cuteali/retail_store.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# namespace :deploy do

#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
#       # Here we can do anything such as:
#       # within release_path do
#       #   execute :rake, 'cache:clear'
#       # end
#     end
#   end

# end
set :unicorn_config, "#{fetch :deploy_to}/config/unicorn.rb"
set :unicorn_pid, "#{fetch :deploy_to}/tmp/pids/unicorn.pid"

namespace :deploy do
  after :finishing, "deploy:cleanup"

  after :publishing, :restart

  desc 'Start application'
  task :start do
    on roles(:app) do
      execute "cd #{fetch :deploy_to} && RAILS_ENV=production bundle exec bin/unicorn -c #{fetch :unicorn_config} -E production -D"
    end
  end

  desc 'Stop application'
  task :stop do
    on roles(:app) do
      execute "if [ -f #{fetch :unicorn_pid} ]; then kill -QUIT `cat #{fetch :unicorn_pid}`; fi"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app) do
      execute "if [ -f #{fetch :unicorn_pid} ]; then kill -s USR2 `cat #{fetch :unicorn_pid}`; fi"
    end
  end
end


# set :unicorn_config, "#{current_path}/config/unicorn.rb"
# set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

# namespace :deploy do
#   task :start, :roles => :app, :except => { :no_release => true } do
#     run "cd #{current_path} && RAILS_ENV=production bundle exec unicorn_rails -c #{unicorn_config} -D"
#   end

#   task :stop, :roles => :app, :except => { :no_release => true } do
#     run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
#   end

#   task :restart, :roles => :app, :except => { :no_release => true } do
#     # 用USR2信号来实现无缝部署重启
#     run "if [ -f #{unicorn_pid} ]; then kill -s USR2 `cat #{unicorn_pid}`; fi"
#   end

#   after :finishing, 'deploy:cleanup'
# end
