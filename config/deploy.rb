#MVR - needed to give us a terminal
default_run_options[:pty] = true
#MVR - for access to github
ssh_options[:forward_agent] = true
#MVR - log in as root
ssh_options[:keys] = [File.join(ENV["HOME"], ".ec2", "root.pem")]
set :user, "root"
set :application, "rails"
set :repository, "git@github.com:blogcastr/rails.git"
set :deploy_to, "/home/blogcastr/rails"
#MVR - git options
set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache
role :web, "blogcastr.com"
role :app, "blogcastr.com"
role :db,  "blogcastr.com", :primary => true
namespace :deploy do
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
