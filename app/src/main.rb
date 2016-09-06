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
		"<p>Still hello world =)... But actually there seems to be an issue when scaling down and up again a redis consuming service"\
		" the new task can't resolve the hostname. I'm not sure if it's a bug in the new swarm mode by docker or on the combination sinatra/redis/docker </p>"\
		"<p>#{e.message}</p>"
	end
end