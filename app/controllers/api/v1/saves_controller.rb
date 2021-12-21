module Api
  module V1
    class SavesController < ApplicationController
      include ActionController::HttpAuthentication::Token

      MAX_PAGINATION_LIMIT = 100

      before_action :autheticate_user

      def index
        user = User.find_by(username: params[:username])
        saves = PostSaved.where(user_id: @user.id).order(created_at: :desc).pluck(:post_id)
        if @user.id == user.id
          render json: Post.where(id: [saves]).limit(limit).offset(params[:offset]).order(created_at: :desc).as_json
        else
          render status: :unauthorized
        end
      end

      def toggle_save
        post = Post.find_by(id: params[:post_id])
        return render status: :unprocessable_entity unless post

        is_viewable = !Block.where(
          'blocked_id = ? AND blocked_by_id = ?', @user.id, post.user_id
        ).present?
        return render status: :unauthorized unless is_viewable

        post_save = @user.post_saved.where(post_id: params[:post_id]).first_or_initialize
        if post_save.id.nil?
          post_save.save
          render json: post_save.as_json, status: :created
        elsif post_save.destroy
          head :no_content
        else
          render json: post_save.errors, status: :unprocessable_entity
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
