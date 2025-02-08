require "redis"

if Rails.env.development?
  REDIS_CONFIG = {
    host: "localhost",
    port: 6379,
    db: 0,
    timeout: 5
  }
else
  REDIS_CONFIG = {
    url: ENV["REDIS_URL"],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end

begin
  $redis = Redis.new(REDIS_CONFIG)
  $redis.ping
rescue Redis::CannotConnectError => error
  Rails.logger.error "Failed to connect to Redis: #{error}"
  raise "Redis connection failed"
end

def redis_connected?
  $redis.ping == "PONG"
rescue Redis::BaseError
  false
end
