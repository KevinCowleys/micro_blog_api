module Api
  module V1
    class BlocksController < ApplicationController
      include ActionController::HttpAuthentication::Token

      MAX_PAGINATION_LIMIT = 100

      before_action :autheticate_user

      def index
        blocks = Block.all.limit(limit).offset(params[:offset])
                      .includes(blocked: [profile_image_attachment: [:blob]])
                      .where(blocked_by_id: @user.id)
        blocks_json = blocks.as_json(include: :blocked)
        blocks.each.with_index do |block, index|
          blocks_json[index]['blocked'] = images_attached(block.blocked)
        end
        render json: blocks_json
      end

      def toggle_block
        @user_being_blocked = User.find_by(username: params[:username])
        return render status: :unprocessable_entity unless @user_being_blocked && @user_being_blocked.id != @user.id

        block = Block.where(blocked_id: @user_being_blocked.id, blocked_by_id: @user.id).first_or_initialize

        if block.id.nil?
          block.update_attribute(:blocked_by_id, @user.id)
          render json: block.as_json, status: :created
        elsif block.destroy
          head :no_content
        else
          render json: block.errors, status: :unprocessable_entity
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
