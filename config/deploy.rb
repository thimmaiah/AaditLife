# Load DSL and Setup Up Stages
lock "3.10.1"

 
# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:
 
set :rails_env, fetch(:stage)

set :ssh_options, {
  user: 'ubuntu',
  keys: ['/home/thimmaiah/.ssh/AaditLife.pem'],
  forward_agent: true,
  auth_methods: ["publickey"]
}

set :application, "AaditLife"
set :user, "ubuntu"
set :repo_url, "git@github.com:thimmaiah/AaditLife.git"
set :branch, 'master'

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'volumes', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')
#set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/ubuntu/AaditLife"
on :start do    
  `ssh-add`
end

set :puma_daemonize,  true
set :puma_threads,    [4, 16]
set :puma_workers,    4
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to true if using ActiveRecord



## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
set :log_level,     :debug
set :keep_releases, 5

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

#  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # invoke 'puma:restart'
    end
  end

  desc "Uploads .env remote servers."
  task :upload_env do
    on roles(:app) do
      rails_env = fetch(:rails_env)
      puts "Uploading .env files to #{release_path} #{rails_env}"
      upload!("/home/thimmaiah/work/AaditLife/.env", "#{release_path}", recursive: false)
      upload!("/home/thimmaiah/work/AaditLife/.env.local", "#{release_path}", recursive: false)
      upload!("/home/thimmaiah/work/AaditLife/.env.staging", "#{release_path}", recursive: false) if rails_env == :staging
      upload!("/home/thimmaiah/work/AaditLife/.env.production", "#{release_path}", recursive: false) if rails_env == :production      
    end
  end

  desc "Uploads dev apk remote servers."
  task :upload_dev_apk do
    on roles(:app) do
      upload!("/home/thimmaiah/work/angular/AaditLifeUI/platforms/android/build/outputs/apk/android-debug.apk", "#{current_path}/public", recursive: true)
    end
  end

  desc "Uploads dev ipa remote servers."
  task :upload_dev_ipa do
    on roles(:app) do
      upload!("/Users/NehaiMac/work/AaditLifeUI/platforms/ios/build/device/Care Connect.ipa", "#{current_path}/public", recursive: true)
    end
  end

  before :starting,     :check_revision
  after  :updated,      "deploy:upload_env"
  #before :finishing,    :upload_angular
  #before :finishing,    :upload_dev_apk
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end