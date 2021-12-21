module Api
  module V1
    class ConversationsController < ApplicationController
      include ActionController::HttpAuthentication::Token

      MAX_PAGINATION_LIMIT = 100

      before_action :autheticate_user

      def index
        conversations = Conversation.limit(limit).offset(params[:offset]).includes(sender: [profile_image_attachment: [:blob]],
                                                                                   recipient: [profile_image_attachment: [:blob]]).where(sender_id: @user.id).or(Conversation.limit(limit).offset(params[:offset]).includes(sender: [profile_image_attachment: [:blob]],
                                                                                                                                                                                                                            recipient: [profile_image_attachment: [:blob]]).where(recipient_id: @user.id)).order(updated_at: :desc)
        conversations_json = conversations.as_json(include: %i[sender recipient])
        conversations.each.with_index do |convo, index|
          conversations_json[index]['sender'] = images_attached(convo.sender)
          conversations_json[index]['recipient'] = images_attached(convo.recipient)
        end
        render json: conversations_json
      end

      def create
        @conversation = Conversation.between(@user.id, params[:recipient_id])
        render json: @conversation = if @conversation.present?
                                       @conversation.first
                                     else
                                       Conversation.create!(sender_id: @user.id, recipient_id: params[:recipient_id])
                                     end, status: :created
      rescue ActiveRecord::RecordInvalid
        render status: :unprocessable_entity
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
