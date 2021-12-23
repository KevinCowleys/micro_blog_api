require 'rails_helper'

describe 'Conversation API', type: :request do
  let!(:first_user) { FactoryBot.create(:user, username: 'user1', email: 'user1@fake.com', password: 'Password1') }
  let!(:second_user) { FactoryBot.create(:user, username: 'user2', email: 'user2@fake.com', password: 'Password1') }
  let!(:third_user) { FactoryBot.create(:user, username: 'user3', email: 'user3@fake.com', password: 'Password1') }
  let!(:jwt) { confirm_and_login_user(first_user) }

  describe 'GET /conversations' do
    let!(:first_conversation) do
      FactoryBot.create(:conversation, sender_id: first_user.id, recipient_id: second_user.id)
    end
    let!(:second_conversation) do
      FactoryBot.create(:conversation, sender_id: second_user.id, recipient_id: third_user.id)
    end

    it 'returns all conversations' do
      get '/api/v1/conversations',
          headers: { 'Authorization' => "Bearer #{jwt}" }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body[0]['sender_id']).to eq(first_user.id)
      expect(response_body[0]['recipient_id']).to eq(second_user.id)
      expect(response_body[0]['sender']['id']).to eq(first_user.id)
      expect(response_body[0]['sender']['name']).to eq(first_user.name)
      expect(response_body[0]['sender']['username']).to eq(first_user.username)
      expect(response_body[0]['recipient']['id']).to eq(second_user.id)
      expect(response_body[0]['recipient']['name']).to eq(second_user.name)
      expect(response_body[0]['recipient']['username']).to eq(second_user.username)
    end

    it 'returns error when authentication is missing' do
      get '/api/v1/conversations'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /conversations' do
    let!(:user) { FactoryBot.create(:user, password: 'Password1') }

    it 'create a new conversation' do
      expect do
        post "/api/v1/conversations?recipient_id=#{second_user.id}", params: {},
                                                                     headers: { 'Authorization' => "Bearer #{jwt}" }
      end.to change { Conversation.count }.from(0).to(1)

      expect(response).to have_http_status(:created)
      expect(response_body['id']).to eq(1)
      expect(response_body['sender_id']).to eq(first_user.id)
      expect(response_body['recipient_id']).to eq(second_user.id)
    end

    it 'returns error when recipient doesn\'t exist' do
      post '/api/v1/conversations?recipient_id=1447', params: {},
                                                      headers: { 'Authorization' => "Bearer #{jwt}" }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when authentication is missing' do
      post '/api/v1/conversations', params: {}

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
