lock '3.4.0'

set :rvm_ruby_version, '2.2.1@nourish'

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
    run "if [ -f #{unicorn_pid} ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{current_path} && bundle exec unicorn -c #{unicorn_conf} -E #{rack_env} -D; fi"
  end

  task :start do
    run "cd #{current_path} && bundle exec unicorn -c #{unicorn_conf} -E #{rack_env} -D"
  end

  task :stop do
    run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end
end
