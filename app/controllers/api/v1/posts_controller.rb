module Api
  module V1
    class PostsController < ApplicationController
      include ActionController::HttpAuthentication::Token

      MAX_PAGINATION_LIMIT = 100

      before_action :autheticate_user_index, only: :index
      before_action :autheticate_user, only: %i[create destroy]

      def index
        if !@user
          render json: Post.all.limit(limit).offset(params[:offset]).order(created_at: :desc).as_json
        else
          blocked_ids = Block.all.where(blocked_by_id: @user.id).pluck(:blocked_id)
          blocked_by_ids = Block.all.where(blocked_id: @user.id).pluck(:blocked_by_id)
          muted_ids = Mute.all.where(muted_by_id: @user.id).pluck(:muted_id)
          avoid_posts = (blocked_ids + blocked_by_ids + muted_ids).uniq
          render json: Post.all.where.not(user_id: avoid_posts).limit(limit).offset(params[:offset]).order(created_at: :desc).as_json
        end
      end

      def create
        post = @user.posts.new(post_params)
        if post.save
          render json: post.as_json, status: :created
        else
          render json: post.errors, status: :unprocessable_entity
        end
      end

      def destroy
        post = @user.posts.find_by(id: params[:id])
        return render status: :unprocessable_entity unless post && @user.id == post.user_id

        if post.destroy
          head :no_content
        else
          render json: post.errors, status: :unprocessable_entity
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

      def limit
        [
          params.fetch(:limit, MAX_PAGINATION_LIMIT).to_i,
          MAX_PAGINATION_LIMIT
        ].min
      end

      def post_params
        params.require(:post).permit(:content)
      end
    end
  end
end
