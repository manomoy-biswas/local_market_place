module Authentication
  class JwtService
    ALGORITHM = "HS256"
    class << self
      def encode(payload, exp = 2.hour.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload, secret_key, ALGORITHM)
      end

      def decode(token)
        JWT.decode(token, secret_key, true, algorithm: ALGORITHM, verify_expiration: true).first
      rescue JWT::ExpiredSignature
        raise TokenExpiredError, "Token has expired"
      rescue JWT::DecodeError
        raise TokenInvalidError, "Token is invalid"
      end

      private

      def secret_key
        Figaro.env.jwt_secret_key
      end
    end
  end
end
