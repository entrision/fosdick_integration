role :app, %w{nourish@104.131.131.191}
role :web, %w{nourish@104.131.131.191}
role :db,  %w{nourish@104.131.131.191}

set :branch, 'master'
set :keep_releases, 10
set :env, :production
