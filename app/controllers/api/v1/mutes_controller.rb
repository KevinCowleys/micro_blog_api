module Api
  module V1
    class MutesController < ApplicationController
      include ActionController::HttpAuthentication::Token

      MAX_PAGINATION_LIMIT = 100

      before_action :autheticate_user

      def index
        mutes = Mute.all.limit(limit).offset(params[:offset])
                    .includes(muted: [profile_image_attachment: [:blob]])
                    .where(muted_by_id: @user.id)
        mutes_json = mutes.as_json(include: :muted)
        mutes.each.with_index do |mute, index|
          mutes_json[index]['muted'] = images_attached(mute.muted)
        end
        render json: mutes_json
      end

      def toggle_mute
        @user_being_muted = User.find_by(username: params[:username])
        return render status: :unprocessable_entity unless @user_being_muted && @user_being_muted.id != @user.id

        mute = Mute.where(muted_id: @user_being_muted.id, muted_by_id: @user.id).first_or_initialize

        if mute.id.nil?
          mute.update_attribute(:muted_by_id, @user.id)
          render json: mute.as_json, status: :created
        elsif mute.destroy
          head :no_content
        else
          render json: mute.errors, status: :unprocessable_entity
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
