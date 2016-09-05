require 'sinatra'
require 'redis'

set :bind, '0.0.0.0'
set :port, 8888

get '/' do
	begin  
		redis = Redis.new(:host => "my-redis", :port => 6379, :db => 0)
		redis.set("message", "Hello world!")
		redis.get("message")
	rescue Exception => e  
		e.backtrace.inspect  
	end
end