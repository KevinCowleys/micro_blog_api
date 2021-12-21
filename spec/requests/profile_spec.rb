require 'rails_helper'

describe 'Profile API', type: :request do
  let!(:first_user) { FactoryBot.create(:user, username: 'user1', email: 'user1@fake.com', password: 'Password1') }
  let!(:second_user) { FactoryBot.create(:user, username: 'user2', email: 'user2@fake.com', password: 'Password1') }

  describe 'GET /:username' do
    it 'returns user profile' do
      get "/api/v1/#{first_user.username}",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to be > 0
      expect(response_body.size).to be <= 12
      expect(response_body['id']).to eq(first_user.id)
      expect(response_body['username']).to eq(first_user.username)
      expect(response_body['name']).to eq(first_user.name)
      expect(response_body['location']).to eq(first_user.location)
      expect(response_body['gender']).to eq(first_user.gender)
      expect(response_body['website']).to eq(first_user.website)
      expect(response_body['bio']).to eq(first_user.bio)
      expect(response_body).not_to include 'password_digest'
      expect(response_body).not_to include 'email'
    end

    it 'returns user profile without authentication' do
      get "/api/v1/#{first_user.username}"

      expect(response).to have_http_status(:success)
      expect(response_body.size).to be > 0
      expect(response_body.size).to be <= 12
      expect(response_body['id']).to eq(first_user.id)
      expect(response_body['username']).to eq(first_user.username)
      expect(response_body['name']).to eq(first_user.name)
      expect(response_body['location']).to eq(first_user.location)
      expect(response_body['gender']).to eq(first_user.gender)
      expect(response_body['website']).to eq(first_user.website)
      expect(response_body['bio']).to eq(first_user.bio)
      expect(response_body).not_to include 'password_digest'
      expect(response_body).not_to include 'email'
    end

    it 'errors when trying to view when blocked' do
      FactoryBot.create(:block, blocked_id: first_user.id, blocked_by_id: second_user.id)
      get "/api/v1/#{second_user.username}",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'errors when user doesn\'t exist' do
      get '/api/v1/username_does_not_exist',
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET /profile/settings' do
    it 'returns logged in user settings' do
      get '/api/v1/profile/settings',
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to be > 0
      expect(response_body.size).to be <= 13
      expect(response_body['id']).to eq(first_user.id)
      expect(response_body['username']).to eq(first_user.username)
      expect(response_body['name']).to eq(first_user.name)
      expect(response_body['location']).to eq(first_user.location)
      expect(response_body['gender']).to eq(first_user.gender)
      expect(response_body['website']).to eq(first_user.website)
      expect(response_body['email']).to eq(first_user.email)
      expect(response_body['bio']).to eq(first_user.bio)
      expect(response_body).not_to include 'password_digest'
    end

    it 'returns error when authentication is missing' do
      get '/api/v1/profile/settings'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /profile/settings' do
    it 'updates user settings' do
      patch '/api/v1/profile/settings', params: {
        user: {
          username: first_user.username,
          name: first_user.name,
          location: first_user.location,
          gender: first_user.gender,
          website: first_user.website,
          email: first_user.email,
          bio: first_user.bio
        }
      }, headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:no_content)
    end

    it 'returns error when authentication is missing' do
      patch '/api/v1/profile/settings'

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
