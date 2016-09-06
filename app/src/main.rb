require 'sinatra'
require 'redis'

set :bind, '0.0.0.0'
set :port, 8888

redis = Redis.new(:host => ENV["redis_ip"], :port => 6379, :db => 0)

get '/hello' do
	begin
		redis.set("message", "Hello world!")
		message = redis.get("message")
		message
	rescue Exception => e  
		"<p>Oops... #{e.message}</p>"
	end
end