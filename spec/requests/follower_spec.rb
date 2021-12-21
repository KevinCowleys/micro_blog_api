require 'rails_helper'

describe 'Follower API', type: :request do
  let!(:first_user) { FactoryBot.create(:user, username: 'user1', email: 'user1@fake.com', password: 'Password1') }
  let!(:second_user) { FactoryBot.create(:user, username: 'user2', email: 'user2@fake.com', password: 'Password1') }
  let!(:third_user) { FactoryBot.create(:user, username: 'user3', email: 'user3@fake.com', password: 'Password1') }

  describe 'GET /:username' do
    let!(:first_follow) { FactoryBot.create(:follower, following_id: first_user.id, follower_id: third_user.id) }
    let!(:second_follow) { FactoryBot.create(:follower, following_id: third_user.id, follower_id: first_user.id) }

    it 'returns list of followers' do
      get "/api/v1/followers/#{first_user.username}",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:success)
      expect(response_body[0]['id']).to eq(1)
      expect(response_body[0]['following_id']).to eq(first_user.id)
      expect(response_body[0]['follower_id']).to eq(third_user.id)
    end

    it 'returns error when blocked by user' do
      FactoryBot.create(:block, blocked_id: first_user.id, blocked_by_id: second_user.id)
      get "/api/v1/following/#{second_user.username}",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error when authentication is missing for followers' do
      get "/api/v1/followers/#{first_user.username}"

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error when username doesn\'t exist for followers' do
      get '/api/v1/followers/bad_username',
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns list of people that are followed by user' do
      get "/api/v1/following/#{first_user.username}",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:success)
      expect(response_body[0]['id']).to eq(2)
      expect(response_body[0]['following_id']).to eq(third_user.id)
      expect(response_body[0]['follower_id']).to eq(first_user.id)
    end

    it 'returns error when blocked by user' do
      FactoryBot.create(:block, blocked_id: first_user.id, blocked_by_id: second_user.id)
      get "/api/v1/following/#{second_user.username}",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error when authentication is missing for following' do
      get "/api/v1/following/#{first_user.username}"

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error when username doesn\'t exist for following' do
      get '/api/v1/following/bad_username',
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST /:username' do
    it 'creates a new follow' do
      expect do
        post "/api/v1/follow/#{second_user.username}",
             headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }
      end.to change { Follower.count }.from(0).to(1)

      expect(response).to have_http_status(:success)
      expect(response_body['id']).to eq(1)
      expect(response_body['following_id']).to eq(second_user.id)
      expect(response_body['follower_id']).to eq(first_user.id)
    end

    it 'removes a follow if exist' do
      FactoryBot.create(:follower, following_id: second_user.id, follower_id: first_user.id)
      expect do
        post "/api/v1/follow/#{second_user.username}",
             headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }
      end.to change { Follower.count }.from(1).to(0)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns error if blocked' do
      FactoryBot.create(:block, blocked_id: first_user.id, blocked_by_id: second_user.id)
      post "/api/v1/follow/#{second_user.username}",
           headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error when following yourself' do
      post "/api/v1/follow/#{first_user.username}",
           headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when user doesn\'t exist' do
      post '/api/v1/follow/bad_username',
           headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when authentication is missing' do
      post "/api/v1/follow/#{second_user.username}"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
