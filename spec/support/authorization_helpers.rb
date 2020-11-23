module AuthorizationHelpers
  def set_jwt_header(account_id, exp = nil)
    payload = { account_id: account_id }
    token = JsonWebToken.encode(encode_args(payload, exp))

    controller.request.headers['Authorization'] = "Bearer #{token}"
  end

  def encode_args(payload, exp)
    return { payload: payload } if exp.blank?

    { payload: payload, exp: exp }
  end
end
