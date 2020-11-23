class CreateAccount
  def initialize(params = {})
    @params = params
  end

  def run
    @account = Account.new(@params)

    if @account.valid?
      @account.save

      return {
        account: @account,
        token: generate_token
      }
    end

    {
      errors: @account.errors.messages
    }
  end

  private

  def generate_token
    JsonWebToken.encode(
      payload: {
        account_id: @account.id
      }
    )
  end
end
