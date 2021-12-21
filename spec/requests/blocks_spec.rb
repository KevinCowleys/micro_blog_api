require 'rails_helper'

describe 'Blocks API', type: :request do
  let!(:first_user) { FactoryBot.create(:user, username: 'user1', email: 'user1@fake.com', password: 'Password1') }
  let!(:second_user) { FactoryBot.create(:user, username: 'user2', email: 'user2@fake.com', password: 'Password1') }
  let!(:first_post) { FactoryBot.create(:post, content: 'Hello World!', user_id: first_user.id) }
  let!(:second_post) { FactoryBot.create(:post, content: 'Hello, World!', user_id: second_user.id) }

  describe 'GET /blocked' do
    it 'returns all blocked by user' do
      FactoryBot.create(:block, blocked_id: second_user.id, blocked_by_id: first_user.id)
      get '/api/v1/blocked',
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body[0]['id']).to eq(1)
      expect(response_body[0]['blocked_id']).to eq(second_user.id)
      expect(response_body[0]['blocked_by_id']).to eq(first_user.id)
      expect(response_body[0]['blocked']['id']).to eq(second_user.id)
      expect(response_body[0]['blocked']['name']).to eq(second_user.name)
      expect(response_body[0]['blocked']['username']).to eq(second_user.username)
    end

    it 'returns error when authentication is missing' do
      FactoryBot.create(:block, blocked_id: first_user.id, blocked_by_id: second_user.id)
      get "/api/v1/saves/#{first_user.username}"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /block/:username' do
    it 'create a new block' do
      expect do
        post "/api/v1/block/#{second_user.username}", params: {},
                                                      headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }
      end.to change { Block.count }.from(0).to(1)

      expect(response).to have_http_status(:created)
      expect(response_body['id']).to eq(1)
      expect(response_body['blocked_id']).to eq(second_user.id)
      expect(response_body['blocked_by_id']).to eq(first_user.id)
    end

    it 'returns error when blocking yourself' do
      post "/api/v1/block/#{first_user.username}", params: {},
                                                   headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when user doesn\'t exist' do
      post '/api/v1/block/does_not_exist', params: {},
                                           headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when authentication is missing' do
      post "/api/v1/block/#{second_user.username}"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
