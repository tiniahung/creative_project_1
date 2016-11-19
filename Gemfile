source 'https://rubygems.org'

gem 'sinatra'
gem 'json'
gem 'shotgun'
gem 'rack'
gem "rake"
gem 'activerecord'
gem 'sinatra-activerecord' # excellent gem that ports ActiveRecord for Sinatra
gem 'faraday_middleware-parse_oj'
gem 'gemoji'

# to avoid installing postgres use 
# bundle install --without production

group :development, :test do
  gem 'sqlite3'
  gem 'dotenv'
end

group :production do
  gem 'pg'
	gem 'twilio-ruby'

end