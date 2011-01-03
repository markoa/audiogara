source 'http://rubygems.org'

gem 'rails', '3.0.3'
gem 'pg', :require => 'pg'
gem 'nokogiri'
gem 'will_paginate', "~> 3.0.pre2"
gem 'rufus-scheduler', :require => 'rufus/scheduler'

group :development, :test do
  gem 'mongrel'
  gem 'ruby-debug'
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'autotest'
  gem 'database_cleaner'
  gem 'webrat', '>= 0.7.2'
end

group :production do
  gem "exception_notification", :git => "git://github.com/rails/exception_notification", :require => 'exception_notifier'
end
