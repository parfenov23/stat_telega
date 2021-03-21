# config valid only for current version of Capistrano
lock '3.4.0'
set :rvm_ruby_version, '2.3.1'
set :repo_url, 'git@github.com:parfenov23/stat_telega.git'

set :linked_files, fetch(:linked_files, []).push('config/database.yml',
                                                 'config/secrets.yml')

set :linked_dirs, fetch(:linked_dirs, []).push('log',
                                               'tmp/pids',
                                               'tmp/cache',
                                               'tmp/sockets',
                                               'vendor/bundle',
                                               'public/system',
                                               'public/uploads')

set :pty, false
set :keep_releases, 3
set :whenever_roles, [:app]
set :deploy_via, :copy
set :copy_cache, false

namespace :deploy do
  after 'deploy:publishing', 'deploy:restart', 'deploy:ws_sms_pushable_restart'

  task :restart do
    invoke 'unicorn:legacy_restart'
  end

  task :start do
    invoke 'unicorn:start'
  end

  task :stop do
    invoke 'unicorn:stop'
  end
end
