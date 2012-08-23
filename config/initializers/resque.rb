uri = URI.parse(ENV["REDISTOGO_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)

Resque::Plugins::Status::Hash.expire_in = 600 # 10 min in seconds

require 'process' # ProcessJob