module Api
  module V1
    class LikesController < ApplicationController
      include ActionController::HttpAuthentication::Token

      MAX_PAGINATION_LIMIT = 100

      before_action :autheticate_user

      def index
        user = User.find_by(username: params[:username])
        return render status: :unprocessable_entity unless user

        likes = PostLike.where(user_id: user.id).order(created_at: :desc).pluck(:post_id)
        if @user.id == user.id
          render json: Post.where(id: [likes]).limit(limit).offset(params[:offset]).order(created_at: :desc).as_json
        else
          is_viewable = !Block.where(
            'blocked_id = ? AND blocked_by_id = ?', @user.id, user.id
          ).present?
          if is_viewable
            render json: Post.where(id: [likes]).limit(limit).offset(params[:offset]).order(created_at: :desc).as_json
          else
            render status: :unauthorized
          end
        end
      end

      def toggle_like
        post = Post.find_by(id: params[:post_id])
        return render status: :unprocessable_entity unless post

        is_viewable = !Block.where(
          'blocked_id = ? AND blocked_by_id = ?', @user.id, post.user_id
        ).present?
        return render status: :unauthorized unless is_viewable

        post_like = @user.post_likes.where(post_id: params[:post_id]).first_or_initialize
        if post_like.id.nil?
          post_like.save
          render json: post_like.as_json, status: :created
        elsif post_like.destroy
          head :no_content
        else
          render json: post_like.errors, status: :unprocessable_entity
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

      def limit
        [
          params.fetch(:limit, MAX_PAGINATION_LIMIT).to_i,
          MAX_PAGINATION_LIMIT
        ].min
      end
    end
  end
end
