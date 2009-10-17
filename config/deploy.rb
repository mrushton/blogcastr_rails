#MVR - tty and ssh settings
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ec2", "root.pem")]

set :application, "blogcastr"
set :user, "deploy"
set :use_sudo, false

#MVR - git options
set :scm, :git
set :repository, "git@github.com:blogcastr/blogcastr.git"
set :branch, "master"
set :deploy_via, :remote_cache

role :web, "blogcastr.com"
role :app, "blogcastr.com"
role :db,  "blogcastr.com", :primary => true

#MVR - need to set the permissions on the tmp directory so Passenger can remove the restart file
after "deploy:finalize_update", :update_tmp_permissions
task :update_tmp_permissions do
  run "chmod g+w #{File.join(release_path, 'tmp')}"
end

namespace :deploy do
  task :start do
  end 
  task :stop do
  end 
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
    #MVR - give apache permission to delete file
    run "chmod g+w #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
end
