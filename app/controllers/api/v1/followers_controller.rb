module Api
  module V1
    class FollowersController < ApplicationController
      include ActionController::HttpAuthentication::Token

      MAX_PAGINATION_LIMIT = 100

      before_action :autheticate_user

      def toggle_follow
        @user_being_followed = User.find_by(username: params[:username])
        return render status: :unprocessable_entity unless @user_being_followed && @user_being_followed.id != @user.id

        follow = Follower.where(following_id: @user_being_followed.id, follower_id: @user.id).first_or_initialize

        is_viewable = !Block.where(
          'blocked_id = ? AND blocked_by_id = ?', @user.id, @user_being_followed.id
        ).present?
        return render status: :unauthorized unless is_viewable

        if follow.id.nil?
          follow.update_attribute(:follower_id, @user.id)
          render json: follow.as_json, status: :created
        elsif follow.destroy
          head :no_content
        else
          render json: follow.errors, status: :unprocessable_entity
        end
      end

      def show_following
        @user_visited = User.find_by(username: params[:username])
        return render status: :unprocessable_entity unless @user_visited

        is_viewable = !Block.where(
          'blocked_id = ? AND blocked_by_id = ?', @user.id, @user_visited.id
        ).present?
        return render status: :unauthorized unless is_viewable

        following = Follower.all.limit(limit).offset(params[:offset])
                            .includes(following: [profile_image_attachment: [:blob]])
                            .where(follower_id: @user_visited.id)
        following_json = following.as_json(include: :following)
        following.each.with_index do |follower, index|
          following_json[index]['following'] = images_attached(follower.following)
        end
        render json: following_json
      end

      def show_followers
        @user_visited = User.find_by(username: params[:username])
        return render status: :unprocessable_entity unless @user_visited

        is_viewable = !Block.where(
          'blocked_id = ? AND blocked_by_id = ?', @user.id, @user_visited.id
        ).present?
        return render status: :unauthorized unless is_viewable

        followers = Follower.all.limit(limit).offset(params[:offset])
                            .includes(follower: [profile_image_attachment: [:blob]])
                            .where(following_id: @user_visited.id)
        followers_json = followers.as_json(include: :follower)
        followers.each.with_index do |follower, index|
          followers_json[index]['follower'] = images_attached(follower.follower)
        end
        render json: followers_json
      end

      private

      def autheticate_user
        token, _options = token_and_options(request)
        user_id = AuthenticationTokenService.decode(token)
        @user = User.find(user_id)
      rescue ActiveRecord::RecordNotFound, JWT::DecodeError
        render status: :unauthorized
      end

      def limit
        [
          params.fetch(:limit, MAX_PAGINATION_LIMIT).to_i,
          MAX_PAGINATION_LIMIT
        ].min
      end

      def images_attached(user)
        user_json = user.as_json
        if user.profile_image.attached?
          user_json = user_json.merge({
                                        'profile_image' => url_for(user.profile_image)
                                      })
        end
        user_json
      end
    end
  end
end
