class ApplicationController < ActionController::API
  before_action :authorize_request

  attr_reader :current_account

  private

  def authorize_request
    header = request.headers['Authorization']
    token = header&.split(' ')&.last

    begin
      decoded_token = JsonWebToken.decode(token: token)
      @current_account = Account.find(decoded_token[:payload][:account_id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: { token: ['Could not authenticate account.'] } }, status: :unauthorized
    rescue JWT::ExpiredSignature
      render json: { errors: { token: ['Expired token.'] } }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { errors: { token: ['Invalid token.'] } }, status: :unauthorized
    end
  end
end
