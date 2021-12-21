require 'rails_helper'

describe 'Posts API', type: :request do
  let!(:first_user) { FactoryBot.create(:user, username: 'user1', email: 'user1@fake.com', password: 'Password1') }
  let!(:second_user) { FactoryBot.create(:user, username: 'user2', email: 'user2@fake.com', password: 'Password1') }

  describe 'GET /posts' do
    let!(:first_post) { FactoryBot.create(:post, content: 'Hello World!', user_id: first_user.id) }
    let!(:second_post) { FactoryBot.create(:post, content: 'Hello, World!', user_id: second_user.id) }

    it 'returns all posts' do
      get '/api/v1/posts'

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(2)
      expect(response_body).to eq(
        [
          {
            'id' => 2,
            'user_id' => 2,
            'content' => 'Hello, World!',
            'created_at' => second_post.created_at.iso8601(3).to_s,
            'updated_at' => second_post.updated_at.iso8601(3).to_s
          },
          {
            'id' => 1,
            'user_id' => 1,
            'content' => 'Hello World!',
            'created_at' => first_post.created_at.iso8601(3).to_s,
            'updated_at' => first_post.updated_at.iso8601(3).to_s
          }
        ]
      )
    end

    it 'returns all posts with blocks filtered' do
      FactoryBot.create(:block, blocked_id: second_user.id, blocked_by_id: first_user.id)
      get '/api/v1/posts',
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body[0]['id']).to eq(1)
      expect(response_body[0]['user_id']).to eq(1)
      expect(response_body[0]['content']).to eq('Hello World!')
    end

    it 'returns all posts with mutes filtered' do
      FactoryBot.create(:mute, muted_id: second_user.id, muted_by_id: first_user.id)
      get '/api/v1/posts',
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body[0]['id']).to eq(1)
      expect(response_body[0]['user_id']).to eq(1)
      expect(response_body[0]['content']).to eq('Hello World!')
    end

    it 'returns a subset of posts based on pagination' do
      get '/api/v1/posts', params: { limit: 1 }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body[0]['id']).to eq(2)
      expect(response_body[0]['user_id']).to eq(2)
      expect(response_body[0]['content']).to eq('Hello, World!')
    end

    it 'returns a subset of posts based on limit and offset' do
      get '/api/v1/posts', params: { limit: 1, offset: 1 }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body[0]['id']).to eq(1)
      expect(response_body[0]['user_id']).to eq(1)
      expect(response_body[0]['content']).to eq('Hello World!')
    end
  end

  describe 'POST /posts' do
    let!(:user) { FactoryBot.create(:user, password: 'Password1') }

    it 'create a new post' do
      expect do
        post '/api/v1/posts', params: {
          post: { content: 'New Post Test' }
        }, headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }
      end.to change { Post.count }.from(0).to(1)

      expect(response).to have_http_status(:created)
      expect(response_body['id']).to eq(1)
      expect(response_body['user_id']).to eq(1)
      expect(response_body['content']).to eq('New Post Test')
    end

    it 'errors without post content' do
      post '/api/v1/posts', params: {
        post: { content: '' }
      }, headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when authentication is missing' do
      post '/api/v1/posts', params: {
        post: { content: 'New Post Test' }
      }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /posts/:id' do
    let!(:post) { FactoryBot.create(:post, content: 'New Post', user_id: first_user.id) }
    let!(:post_two) { FactoryBot.create(:post, content: 'New post', user_id: second_user.id) }

    it 'deletes a post' do
      expect do
        delete "/api/v1/posts/#{post.id}",
               headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }
      end.to change { Post.count }.from(2).to(1)

      expect(response).to have_http_status(:no_content)
    end

    it 'errors when trying to delete someone else\'s post' do
      FactoryBot.create(:post, content: 'New post', user_id: second_user.id)
      delete "/api/v1/posts/#{post_two.id}",
             headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'errors when trying to delete post that doesn\'t exist' do
      delete '/api/v1/posts/1447',
             headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when authentication is missing' do
      delete "/api/v1/posts/#{post.id}", params: {}

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
