source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
# gem "rails", "~> 7.0.4"
gem "activerecord", "~> 7.0"
gem "activemodel", "~> 7.0"
gem "activejob", "~> 7.0"
gem "activestorage", "~> 7.0"
gem "activesupport", "~> 7.0"
gem "actionview", "~> 7.0"
gem "actioncable", "~> 7.0"
gem "actiontext", "~> 7.0"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "dotenv-rails"
  gem "rspec-rails", "~> 6.0"
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "dockerfile-rails", ">= 1.5"
end

group :test do
  gem "database_cleaner-active_record"
  gem "factory_bot_rails", "~> 6.2"
  gem "faker"
  gem "webmock"
end

gem "slack-ruby-client", "~> 2.0"

gem "zenduty", "~> 1.0"

gem "faraday", "~> 2.7"

gem "httparty", "~> 0.20.0" # needed by zenduty but they somehow didn't specify it...

gem "sentry-ruby"
gem "sentry-rails"


gem "recursive-open-struct", "~> 1.1"

gem "dry-struct", "~> 1.6"

gem "dry-types", "~> 1.7"

gem "dry-monads", "~> 1.6"

gem "dry-container", "~> 0.11.0"

gem "dry-auto_inject", "~> 1.0"

gem "redis", "~> 5.0"