module Api
  module V1
    class ProfileController < ApplicationController
      include ActionController::HttpAuthentication::Token

      before_action :autheticate_user_index, only: :index
      before_action :autheticate_user, only: %i[settings update_settings]

      def index
        user = User.select(:id, :username, :name, :location, :gender, :birth_date, :website, :bio, :created_at)
                   .includes(profile_image_attachment: [:blob], profile_banner_attachment: [:blob])
                   .find_by(username: params[:username])
        return render status: :unprocessable_entity unless user

        user_json = images_attached(user)
        if !@user || @user.id == user.id
          render json: user_json
        else
          is_viewable = !Block.where('blocked_id = ? AND blocked_by_id = ?', @user.id, user.id).present?
          return render status: :unauthorized unless is_viewable

          render json: user_json.merge({
                                         'is_following' => Follower.where(
                                           'follower_id = ? AND following_id = ?', @user.id, user.id
                                         ).present?,
                                         'is_followed_by' => Follower.where(
                                           'follower_id = ? AND following_id = ?', user.id, @user.id
                                         ).present?,
                                         'is_blocked' => Block.where(
                                           'blocked_id = ? AND blocked_by_id = ?', user.id, @user.id
                                         ).present?,
                                         'is_muted' => Mute.where(
                                           'muted_id = ? AND muted_by_id = ?', user.id, @user.id
                                         ).present?
                                       })
        end
      end

      def settings
        user = User.select(:id, :name, :username, :bio, :location, :gender, :website, :email,
                           :created_at).find_by(id: @user.id)
        user_json = images_attached(user)
        render json: user_json
      end

      def update_settings
        user = User.find_by(id: @user.id)
        if user.update(user_params)
          render json: user.as_json, status: :no_content
        else
          render json: user.errors, status: :unprocessable_entity
        end
      end

      private

      def autheticate_user
        token, _options = token_and_options(request)
        user_id = AuthenticationTokenService.decode(token)
        @user = User.find(user_id)
      rescue ActiveRecord::RecordNotFound, JWT::DecodeError
        render status: :unauthorized
      end

      def autheticate_user_index
        token, _options = token_and_options(request)
        user_id = AuthenticationTokenService.decode(token)
        @user = User.find(user_id)
      rescue ActiveRecord::RecordNotFound, JWT::DecodeError
        @user = nil
      end

      def images_attached(user)
        user_json = user.as_json
        if user.profile_image.attached?
          user_json = user_json.merge({
                                        'profile_image' => url_for(user.profile_image)
                                      })
        end
        if user.profile_banner.attached?
          user_json = user_json.merge({
                                        'profile_banner' => url_for(user.profile_banner)
                                      })
        end
        user_json
      end

      def user_params
        params.require(:user).permit(:name, :username, :bio, :location, :gender, :website, :email, :profile_image,
                                     :profile_banner)
      end
    end
  end
end
