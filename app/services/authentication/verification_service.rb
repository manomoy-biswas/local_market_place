module Authentication
  class VerificationService
    class << self
      def generate_verification_code(user)
        code = SecureRandom.random_number(100000..999999).to_s
        user.update(
          verification_code: code,
          verification_sent_at: Time.current
        )
        code
      end

      def verify_user(user, code)
        return false unless valid_verification_code?(user, code)

        user.update(
          verified_at: Time.current,
          verification_code: nil
        )
      end

      private

      def valid_verification_code?(user, code)
        user.verification_code == code &&
          user.verification_sent_at > 10.minutes.ago
      end
    end
  end
end
