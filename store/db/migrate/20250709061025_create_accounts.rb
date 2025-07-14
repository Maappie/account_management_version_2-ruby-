class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :email
      t.string :password
      t.integer :verification_code
      t.boolean :verified, default: false
      t.string :roles, default: "user"

      t.timestamps
    end
  end
end
