module Authentication
  class PasswordService
    class << self
      def reset_password(user, token, new_password)
        return false unless valid_reset_token?(user, token)

        user.update(
          password: new_password,
          reset_password_token: nil,
          reset_password_sent_at: nil
        )
      end

      def generate_reset_token(user)
        token = SecureRandom.hex(20)
        user.update(
          reset_password_token: token,
          reset_password_sent_at: Time.current
        )
        token
      end

      private

      def valid_reset_token?(user, token)
        user.reset_password_token == token &&
          user.reset_password_sent_at > 2.hours.ago
      end
    end
  end
end
