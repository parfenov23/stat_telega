# config valid only for current version of Capistrano
# require "capistrano-pyenv"
lock '3.17.1'
set :pyenv_python_version, "3.10.8"
set :rvm_ruby_version, '2.3.1'
set :repo_url, 'git@github.com:parfenov23/stat_telega.git'

set :linked_files, fetch(:linked_files, []).push('config/database.yml',
                                                 'config/secrets.yml', 'config/master.key')

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
set :default_env, { path: "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH" }
namespace :deploy do
  after 'deploy:publishing', 'deploy:restart'

  task :set_pyenv do
    on roles(:app) do
      execute "ls ~/.pyenv"
      # execute "export PYENV_ROOT=\"$HOME/.pyenv\""
      # execute "export PATH=\"$PYENV_ROOT/bin:$PATH\""
      # execute "eval \"$(pyenv init --path)\""
      # execute "eval \"$(pyenv init -)\""
      # execute 'exec bash'
      # execute 'll'
      # execute "if command -v pyenv 1>/dev/null 2>&1; then\n eval \"$(pyenv init -)\"\nfi"
      # execute "exec \"$SHELL\""
      # execute 'pyenv versions'
    end
  end

  task :restart do
    invoke 'unicorn:legacy_restart'
  end

  task :start do
    invoke 'unicorn:start'
  end

  task :stop do
    invoke 'unicorn:stop'
  end

  before 'deploy:starting', :some_task do
    execute 'pyenv local 3.10.8'
  end
end

