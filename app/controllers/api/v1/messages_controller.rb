module Api
  module V1
    class MessagesController < ApplicationController
      include ActionController::HttpAuthentication::Token

      MAX_PAGINATION_LIMIT = 100

      before_action :autheticate_user

      def index
        messages = @conversation.messages.limit(limit).offset(params[:offset]).includes(user: [profile_image_attachment: [:blob]]).order(created_at: :desc)
        messages_json = messages.as_json(include: :user)
        messages.each.with_index do |message, index|
          messages_json[index]['user'] = images_attached(message.user)
        end
        render json: messages_json
      end

      def create
        message = @conversation.messages.new(message_params)
        message['user_id'] = @user.id
        if message.save
          render json: message.as_json, status: :created
        else
          render json: message.errors, status: :unprocessable_entity
        end
      end

      private

      def autheticate_user
        token, _options = token_and_options(request)
        user_id = AuthenticationTokenService.decode(token)
        @user = User.find(user_id)
        @conversation = Conversation.where(id: params[:conversation_id],
                                           sender_id: @user.id).or(Conversation.where(
                                                                     id: params[:conversation_id], recipient_id: @user.id
                                                                   )).first

        render status: :unprocessable_entity unless @conversation
      rescue ActiveRecord::RecordNotFound, JWT::DecodeError
        render status: :unauthorized
      end

      def limit
        [
          params.fetch(:limit, MAX_PAGINATION_LIMIT).to_i,
          MAX_PAGINATION_LIMIT
        ].min
      end

      def message_params
        params.require(:message).permit(:content)
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
