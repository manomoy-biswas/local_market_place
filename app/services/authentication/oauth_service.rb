module Authentication
  class OauthService
    class << self

    end
  end
end
module Authentication
  class OauthService
    class << self
      def authenticate_oauth(provider, auth_data)
        user = find_or_create_user(provider, auth_data)
        token = JwtService.encode(user_id: user.id)
        { user: user, token: token }
      end

      private

      def find_or_create_user(provider, auth_data)
        User.find_or_create_by!(email: auth_data["email"]) do |user|
          user.provider = provider
          user.uid = auth_data["id"]
          user.password = SecureRandom.hex(10)
          user.build_profile(
            first_name: auth_data["first_name"],
            last_name: auth_data["last_name"]
          )
        end
      end
    end
  end
end
