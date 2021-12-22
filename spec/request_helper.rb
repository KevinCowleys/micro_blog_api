module RequestHelper
  def response_body
    JSON.parse(response.body)
  end

  def confirm_and_login_user(user)
    post '/api/v1/authenticate', params: {email: user.email, password: 'Password1'}
    response_body['token']
  end
end
