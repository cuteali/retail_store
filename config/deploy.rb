# config valid only for current version of Capistrano
lock '3.4.1'

set :application, 'retail_store'
set :deploy_user, 'retail_store'
set :deploy_to, "/home/#{fetch :deploy_user}/retail_store"
set :repo_url, 'git@github.com:cuteali/retail_store.git'
set :scm, :git
set :branch, "master"
set :linked_files, %w{config/database.yml config/secrets.yml config/local_env.yml config/unicorn/production.rb}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :unicorn_config, "#{fetch :deploy_to}/shared/config/unicorn.rb"
set :unicorn_pid, "#{fetch :deploy_to}/shared/tmp/pids/unicorn.pid"
set :pty,  false
set :sidekiq_monit_use_sudo, false

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
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'unicorn:legacy_restart'
    end
  end
end
