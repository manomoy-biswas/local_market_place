class Authentication::JwtBlacklist
  class << self
    def add(user_id:, token:, exp:)
      $redis.setex(
        "blacklisted_token:#{token}",
        exp.to_i,
        user_id
      )
    end

    def blacklisted?(token)
      $redis.exists?("blacklisted_token:#{token}")
    end
  end
end
