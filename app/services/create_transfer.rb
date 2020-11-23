class CreateTransfer
  def initialize(params = {})
    @params = params
  end

  def run
    @transfer = Transfer.new(@params)

    if @transfer.valid?
      ActiveRecord::Base.transaction do
        source_account = Account.lock.find(@params[:source_id])
        destination_account = Account.lock.find(@params[:destination_id])

        validate_source_balance(source_account)

        @transfer.initial_balance = source_account.balance
        @transfer.save!

        source_account.balance -= @transfer.value
        destination_account.balance += @transfer.value
        source_account.save!
        destination_account.save!
      end

      return { transfer: @transfer } if @errors.empty?

      return { errors: @errors }
    end

    {
      errors: @transfer.errors.messages
    }
  end

  private

  def validate_source_balance(source_account)
    if @transfer.value > source_account.balance
      @errors = { source: ['source account does not have enough balance'] }

      raise ActiveRecord::Rollback
    end

    @errors = {}
  end
end
