require 'rails_helper'

RSpec.describe JsonWebToken, type: :service do
  let(:payload) { { my_claim: 'value', admin: true } }
  let(:expiration_time) { 15.minutes }
  let(:expected_token) { JWT.encode(payload, secret_key, encryption_algorithm) }
  let(:encryption_algorithm) { 'HS256' }
  let(:secret_key) { Rails.application.secrets.secret_key_base.to_s }

  describe '#encode' do
    let(:response) { described_class.encode(payload: payload, exp: expiration_time) }

    it 'returns a valid JWT' do
      expect(response).to eq(expected_token)
    end

    it 'has a default 24 hours of expiration_time' do
      Timecop.freeze do
        token = described_class.encode(payload: payload)
        payload = JWT.decode(token, secret_key).first.with_indifferent_access
        expiration_time = payload[:exp]
        difference = ((Time.zone.at(expiration_time) - Time.current) / 1.hour).round

        expect(difference).to eq(24)
      end
    end
  end

  describe '#decode' do
    let(:response) { described_class.decode(token: expected_token) }

    it 'returns a hash with payload and headers keys' do
      expect(response).to have_key(:payload)
      expect(response).to have_key(:headers)
    end

    it 'returns the correct payload' do
      payload.each do |key, value|
        expect(response[:payload][key]).to eq(value)
      end
    end

    it 'returns the correct algorithm in the headers' do
      expect(response[:headers][:alg]).to eq(encryption_algorithm)
    end
  end
end
