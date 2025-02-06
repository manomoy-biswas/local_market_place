module Authentication
  class JwtService
    ALGORITHM = "HS256"
    class << self
      def encode(payload, exp = 24.hours.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload, secret_key, ALGORITHM)
      end

      def decode(token)
        JWT.decode(token, secret_key, true, algorithm: ALGORITHM).first
      rescue JWT::DecodeError
        nil
      end

      private

      def secret_key
        Rails.application.credentials.secret_key_base
      end
    end
  end
end
