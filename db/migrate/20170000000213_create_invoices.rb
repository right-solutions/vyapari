class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      
      t.string :invoice_number
      t.datetime :invoice_date

      t.string :customer_name
      t.string :customer_address

      t.integer :discount
      t.decimal :tax
      t.decimal :total_amount

      t.text :notes

      # CASH, CREDIT CARD, CHEQUE or CREDIT
      t.string :payment_method, :null => false, :default=>"cash", :limit=>16

      # If Cash
      t.decimal :adjustment
      t.decimal :money_taken

      # If Cheque
      t.string :cheque_number

      # If Credit Card
      t.string :credit_card_number

      t.string :status, :null => false, :default=>"draft", :limit=>16

      t.references :terminal, index: true
      t.references :store, index: true
      t.references :user, index: true
      
      t.timestamps null: false
    end

    add_index :invoices, :invoice_number, :unique => true

    create_table :line_items do |t|
      
      t.references :product, index: true
      t.integer :quantity
      t.decimal :rate
      t.decimal :discount
      t.decimal :tax
      t.decimal :total_amount

      t.references :invoice, index: true

      t.string :status, :null => false, :default=>"draft", :limit=>16
      
      t.timestamps null: false
    end

  end
end
