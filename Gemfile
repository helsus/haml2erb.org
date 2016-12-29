source 'https://rubygems.org'

gem 'thin'

github 'sinatra/sinatra' do
  gem 'sinatra' # , require: false
  gem 'sinatra-contrib' # , require: false
end

gem 'htmlcompressor', '~> 0.3.1'

gem 'activesupport', '~> 5', require: 'active_support/all'
gem 'actionview', '~> 5', require: 'action_view'

gem 'haml'

group :production do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'ruby-debug-ide'
  gem 'debase'
end
