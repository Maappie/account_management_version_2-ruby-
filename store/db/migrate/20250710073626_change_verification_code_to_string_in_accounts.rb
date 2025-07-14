class ChangeVerificationCodeToStringInAccounts < ActiveRecord::Migration[7.0]
  def up
    change_column :accounts, :verification_code, :string
  end

  def down
    change_column :accounts, :verification_code, :integer
  end
end
