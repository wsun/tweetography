ENV["REDISTOGO_URL"] ||= "redis://wsun:79a8d238c907b40b29dd5fdf994df4cb@tetra.redistogo.com:9844/"

uri = URI.parse(ENV["REDISTOGO_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)

Resque::Plugins::Status::Hash.expire_in = 600 # 10 min in seconds

require 'test' # TestJob
require 'process' # ProcessJob