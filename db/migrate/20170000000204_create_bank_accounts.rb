class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table(:bank_accounts) do |t|

      t.string :account_number, limit: 256
      t.string :iban, limit: 56
      t.string :ifsc_swiftcode, limit: 56
      t.string :bank_name, limit: 256
      t.string :branch_name, limit: 56
      t.string :city, limit: 56
      t.references :country

      t.integer :bank_accountable_id
      t.string  :bank_accountable_type
      
      t.timestamps
    end

    add_index(:bank_accounts, [ :bank_accountable_id, :bank_accountable_type ], :name => 'indx_bank_accountable_id_and_type')
  end
end
