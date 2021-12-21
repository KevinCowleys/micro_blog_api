require 'rails_helper'

describe 'Likes API', type: :request do
  let!(:first_user) { FactoryBot.create(:user, username: 'user1', email: 'user1@fake.com', password: 'Password1') }
  let!(:second_user) { FactoryBot.create(:user, username: 'user2', email: 'user2@fake.com', password: 'Password1') }
  let!(:first_post) { FactoryBot.create(:post, content: 'Hello World!', user_id: first_user.id) }
  let!(:second_post) { FactoryBot.create(:post, content: 'Hello, World!', user_id: second_user.id) }

  describe 'GET /likes/:username' do
    it 'returns all likes by user' do
      FactoryBot.create(:post_like, post_id: first_post.id, user_id: first_user.id)
      get "/api/v1/likes/#{first_user.username}",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body[0]['id']).to eq(first_post.id)
      expect(response_body[0]['user_id']).to eq(first_user.id)
      expect(response_body[0]['content']).to eq(first_post.content)
    end

    it 'doesn\'t return likes by other users' do
      FactoryBot.create(:post_like, post_id: first_post.id, user_id: second_user.id)
      get "/api/v1/likes/#{first_user.username}",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(0)
    end

    it 'can view likes by other users' do
      FactoryBot.create(:post_like, post_id: first_post.id, user_id: second_user.id)
      get "/api/v1/likes/#{second_user.username}",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body[0]['id']).to eq(first_post.id)
      expect(response_body[0]['user_id']).to eq(first_post.user_id)
      expect(response_body[0]['content']).to eq(first_post.content)
    end

    it 'can\'t view likes when blocked by user' do
      FactoryBot.create(:block, blocked_id: first_user.id, blocked_by_id: second_user.id)
      get "/api/v1/likes/#{second_user.username}",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error if username doesn\'t exist' do
      get '/api/v1/likes/does_not_exist',
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when authentication is missing' do
      FactoryBot.create(:post_like, post_id: first_post.id, user_id: first_user.id)
      get "/api/v1/likes/#{first_user.username}"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /like/:id' do
    it 'create a new like' do
      expect do
        post '/api/v1/like/1', params: {},
                               headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }
      end.to change { PostLike.count }.from(0).to(1)

      expect(response).to have_http_status(:created)
      expect(response_body['id']).to eq(1)
      expect(response_body['user_id']).to eq(1)
      expect(response_body['post_id']).to eq(1)
    end

    it 'removes a like if exist' do
      FactoryBot.create(:post_like, post_id: first_post.id, user_id: first_user.id)
      expect do
        post '/api/v1/like/1', params: {},
                               headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }
      end.to change { PostLike.count }.from(1).to(0)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns error if post doesn\'t exist' do
      post '/api/v1/like/99999', params: {},
                                 headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'can\'t like when blocked by poster' do
      FactoryBot.create(:block, blocked_id: first_user.id, blocked_by_id: second_user.id)
      post '/api/v1/like/2',
           headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error when authentication is missing' do
      post '/api/v1/like/1'

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
