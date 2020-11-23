module V1
  class TransfersController < ApplicationController
    def create
      response = CreateTransfer.new(transfer_params).run

      if response.key?(:errors)
        render json: response, status: :unprocessable_entity

        return
      end

      render json: { transfer: response[:transfer].as_json }, status: :created
    end

    private

    def transfer_params
      params.require(:transfer)
            .permit(:source_id, :destination_id, :value)
    end
  end
end
