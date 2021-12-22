module Api
  module V1
    class RegistrationsController < ApplicationController
      def create
        user = User.new(user_params)
        user.username = find_unique(user.name)
        if user.save
          render json: { "token": AuthenticationTokenService.encode(user.id) }, status: :created
        else
          render json: user.errors, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :birth_date, :password, :password_confirmation)
      end

      def find_unique(username)
        test_username = username

        test_username = "#{username}#{SecureRandom.rand(10_000..99_999)}" while User.where(username: test_username).any?

        test_username
      end
    end
  end
end
