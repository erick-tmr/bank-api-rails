module V1
  class AccountsController < ApplicationController
    skip_before_action :authorize_request, only: [:create]

    def create
      response = CreateAccount.new(account_params).run

      if response.key?(:errors)
        render json: response, status: :unprocessable_entity

        return
      end

      render json: { account: response[:account].as_json, token: response[:token] }, status: :created
    end

    def show
      account = Account.find_by(id: params[:id])

      if account.present?
        render json: { account: account.as_json }

        return
      end

      render json: { errors: { account: ["Account with id #{params[:id]} does not exists"] } }, status: :not_found
    end

    private

    def account_params
      params.require(:account)
            .permit(:balance, :id, :name)
    end
  end
end
