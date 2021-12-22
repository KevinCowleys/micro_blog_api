require 'rails_helper'

describe 'Register API', type: :request do
  let!(:first_user) { FactoryBot.create(:user, username: 'user1', email: 'user1@fake.com', password: 'Password1') }
  let!(:second_user) { FactoryBot.create(:user, username: 'user2', email: 'user2@fake.com', password: 'Password1') }

  describe 'POST /register' do
    it 'creates new user' do
      expect do
        post '/api/v1/register', params: {
          user: {
            name: 'new_user',
            email: 'new_user@fake.com',
            birth_date: Date.today,
            password: 'Password1',
            password_confirm: 'Password1'
          }
        }
      end.to change { User.count }.from(2).to(3)

      expect(response).to have_http_status(:created)
      expect(response_body).to include 'token'
    end

    it 'returns error when name is blank' do
      expect do
        post '/api/v1/register', params: {
          user: {
            name: '',
            email: 'new_user@fake.com',
            birth_date: Date.today,
            password: 'Password1',
            password_confirm: 'Password1'
          }
        }
      end.not_to change { User.count }.from(2)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when email is taken' do
      expect do
        post '/api/v1/register', params: {
          user: {
            name: 'new_user',
            email: 'user1@fake.com',
            birth_date: Date.today,
            password: 'Password1',
            password_confirm: 'Password1'
          }
        }
      end.not_to change { User.count }.from(2)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when email is blank' do
      expect do
        post '/api/v1/register', params: {
          user: {
            user: {
              name: 'new_user',
              email: '',
              birth_date: Date.today,
              password: 'Password1',
              password_confirm: 'Password1'
            }
          }
        }
      end.not_to change { User.count }.from(2)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when email is invalid' do
      expect do
        post '/api/v1/register', params: {
          user: {
            user: {
              name: 'new_user',
              email: 'email.com',
              birth_date: Date.today,
              password: 'Password1',
              password_confirm: 'Password1'
            }
          }
        }
      end.not_to change { User.count }.from(2)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when password is blank' do
      expect do
        post '/api/v1/register', params: {
          user: {
            user: {
              name: 'new_user',
              email: 'new_user@fake.com',
              birth_date: Date.today,
              password: '',
              password_confirm: ''
            }
          }
        }
      end.not_to change { User.count }.from(2)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
