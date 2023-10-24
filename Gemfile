source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.3.1'

gem 'rails', '= 5.2.4.5'
gem 'pg', '>= 0.18', '< 2.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
# gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'slim', '~> 2.0.0'
gem 'nokogiri'
# gem 'mechanize'
# gem 'public_suffix', '4.0.7'
# gem 'regexp_parser', '1.8.2'
# gem 'ruby_dep', '1.5.0'

# gem 'rubyzip', '>= 1.2.1'
# gem 'zip-zip'
# gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: 'c8ac844'
# gem 'caxlsx_rails'
# gem 'github_webhook', '~> 1.1'
# gem 'aws-sdk-s3'
# gem 'pycall', '1.4.2'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-byebug'
  gem 'pry-rails'
end
gem 'unicorn'
gem 'whenever', :require => false

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'
  gem 'capistrano3-unicorn'
  gem 'capistrano-secrets-yml'
  gem 'puma'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
end

# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
#
# gem "sidekiq", "~> 5.2"
# gem "sidekiq-cron"