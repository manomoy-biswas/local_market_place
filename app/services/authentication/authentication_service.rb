module Authentication
  class AuthenticationService
    class << self
      def authenticate(email, password)
        user = User.find_by(email: email)
        return nil unless user&.authenticate(password)

        token = JwtService.encode(user_id: user.id)
        { user: user, token: token }
      end

      def authenticate_token(headers)
        token = extract_token(headers)
        return nil unless token

        decoded = JwtService.decode(token)
        User.find_by(id: decoded["user_id"]) if decoded
      end

      private

      def extract_token(headers)
        headers["Authorization"]&.split(" ")&.last
      end
    end
  end
end
