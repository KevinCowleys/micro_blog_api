require 'rails_helper'

describe 'Authentication', type: :request do
  describe 'POST /authenticate' do
    let(:user) { FactoryBot.create(:user, email: 'BookSeller99@fake.com', password: 'Password1') }

    it 'authenticated the client' do
      jwt = confirm_and_login_user(user)
      post '/api/v1/authenticate', params: { email: user.email, password: 'Password1' }

      expect(response).to have_http_status(:created)
      expect(response_body).to eq({
                                    'token' => jwt
                                  })
    end

    it 'returns error when email is missing' do
      post '/api/v1/authenticate', params: { email: '', password: 'Password1' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body).to eq({
                                    'error' => 'param is missing or the value is empty: email'
                                  })
    end

    it 'returns error when password is missing' do
      post '/api/v1/authenticate', params: { email: user.email, password: '' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body).to eq({
                                    'error' => 'param is missing or the value is empty: password'
                                  })
    end

    it 'returns error when password is incorrect' do
      post '/api/v1/authenticate', params: { email: user.email, password: 'incorrect' }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
