#MVR - tty and ssh settings
default_run_options[:pty] = true
ssh_options[:keys] = [File.join("..", "keys", "deploy")]
ssh_options[:forward_agent] = true

set :application, "rails"
set :user, "deploy"
set :use_sudo, false

#MVR - git options
set :scm, :git
set :repository, "git@github.com:mrushton/blogcastr_rails.git"
set :branch, "master"
set :deploy_via, :remote_cache

role :app, "rails.blogcastr.com"
role :web, "rails.blogcastr.com"
role :db,  "rails.blogcastr.com", :primary => true

#MVR - deploy tasks
namespace :deploy do
  task :start do
  end 
  task :stop do
  end 
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
end
