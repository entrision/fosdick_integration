lock '3.4.0'

set :rvm1_ruby_version, '2.2.1@nourish'

set :format, :pretty
set :log_level, :debug
set :pty, true

set :application, 'nourish'
set :repo_url, 'git@github.com:entrision/fosdick_integration.git'
set :deploy_to, '/var/www/nourish'
set :deploy_via, :remote_cache
set :ssh_options, { forward_agent: true }

set :rack_env, :production

set :scm, :git

set :unicorn_conf, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"

namespace :deploy do
  task :restart do
    on roles(:web) do
      execute "if [ -f #{fetch(:unicorn_pid)} ]; then kill -USR2 `cat #{fetch(:unicorn_pid)}`; else cd #{current_path} && bundle exec unicorn -c #{fetch(:unicorn_conf)} -E #{fetch(:rack_env)} -D; fi"
    end
  end

  task :start do
    on roles(:web) do
      execute "cd #{current_path} && bundle exec unicorn -c #{fetch(:unicorn_conf)} -E #{fetch(:rack_env)} -D"
    end
  end

  task :stop do
    on roles(:web) do
      execute "if [ -f #{fetch(:unicorn_pid)} ]; then kill -QUIT `cat #{fetch(:unicorn_pid)}`; fi"
    end
  end
end
