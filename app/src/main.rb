require 'sinatra'
require 'redis'

set :bind, '0.0.0.0'
set :port, 8888

$redis = Redis.new(:host => "my-redis", :port => 6379, :db => 0)

get '/' do
	begin 
		$redis.set("message", "Hello world!")
		message = $redis.get("message")
		message
	rescue Exception => e  
		"<p>#{e.message}</p><p>#{e.backtrace.inspect}</p>"
	end
end