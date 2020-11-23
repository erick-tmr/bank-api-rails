class JsonWebToken
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s
  ALGORITHM = 'HS256'.freeze

  def self.encode(opts = {})
    payload = opts.fetch(:payload)
    expiration_time = opts.fetch(:exp, 24.hours.from_now)
    payload[:exp] = expiration_time.to_i

    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(opts = {})
    token = opts.fetch(:token)
    verify_valid = true
    decoded_token = JWT.decode(token, SECRET_KEY, verify_valid, algorithm: ALGORITHM)
    payload = decoded_token.first
    headers = decoded_token.last

    {
      payload: payload,
      headers: headers
    }.with_indifferent_access
  end
end
