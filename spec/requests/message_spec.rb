require 'rails_helper'

describe 'Message API', type: :request do
  let!(:first_user) { FactoryBot.create(:user, username: 'user1', email: 'user1@fake.com', password: 'Password1') }
  let!(:second_user) { FactoryBot.create(:user, username: 'user2', email: 'user2@fake.com', password: 'Password1') }
  let!(:third_user) { FactoryBot.create(:user, username: 'user3', email: 'user3@fake.com', password: 'Password1') }

  describe 'GET /conversations/:id/messages' do
    let!(:first_conversation) do
      FactoryBot.create(:conversation, sender_id: first_user.id, recipient_id: second_user.id)
    end
    let!(:second_conversation) do
      FactoryBot.create(:conversation, sender_id: third_user.id, recipient_id: second_user.id)
    end
    let!(:first_message) do
      FactoryBot.create(:message, content: 'Message 1', conversation_id: first_conversation.id, user_id: first_user.id)
    end
    let!(:second_message) do
      FactoryBot.create(:message, content: 'Message 2', conversation_id: second_conversation.id, user_id: third_user.id)
    end

    it 'returns all conversations' do
      get "/api/v1/conversations/#{first_conversation.id}/messages",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body[0]['conversation_id']).to eq(first_message.id)
      expect(response_body[0]['user_id']).to eq(first_message.user_id)
      expect(response_body[0]['content']).to eq(first_message.content)
      expect(response_body[0]['user']['id']).to eq(first_user.id)
      expect(response_body[0]['user']['name']).to eq(first_user.name)
      expect(response_body[0]['user']['username']).to eq(first_user.username)
    end

    it 'returns error when conversation doesn\'t exist and when not conversation member' do
      get "/api/v1/conversations/#{second_conversation.id}/messages",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when authentication is missing' do
      get "/api/v1/conversations/#{first_conversation.id}/messages"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /conversations/:id/messages' do
    it 'create a new conversation' do
      FactoryBot.create(:conversation, sender_id: first_user.id, recipient_id: second_user.id)
      expect do
        post '/api/v1/conversations/1/messages', params: {
          'message': {
            'content': 'New Message'
          }
        },
                                                 headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }
      end.to change { Message.count }.from(0).to(1)

      expect(response).to have_http_status(:created)
      expect(response_body['id']).to eq(1)
      expect(response_body['conversation_id']).to eq(1)
      expect(response_body['user_id']).to eq(first_user.id)
      expect(response_body['content']).to eq('New Message')
    end

    it 'returns error when conversation doesn\'t exist and when not conversation member' do
      FactoryBot.create(:conversation, sender_id: third_user.id, recipient_id: second_user.id)
      post '/api/v1/conversations/1/messages', params: {
        'message': {
          'content': 'New Message'
        }
      },
                                               headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when authentication is missing' do
      FactoryBot.create(:conversation, sender_id: third_user.id, recipient_id: second_user.id)
      post '/api/v1/conversations/1/messages', params: {}

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
