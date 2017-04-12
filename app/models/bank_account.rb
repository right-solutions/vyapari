class BankAccount < Vyapari::ApplicationRecord

  # Validations
  validates :account_number, presence: true
  #validates :email, length: {maximum: 128}, allow_blank: true
  #validates :phone, length: {maximum: 128}, allow_blank: true

  # Associations
  belongs_to :bank_accountable, :polymorphic => true
  
  # ------------------
  # Class Methods
  # ------------------

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> obj.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| joins(:country).where("LOWER(bank_accounts.account_number) LIKE LOWER('%#{query}%') OR
                                        LOWER(bank_accounts.iban) LIKE LOWER('%#{query}%') OR
                                        LOWER(bank_accounts.ifsc_swiftcode) LIKE LOWER('%#{query}%') OR
                                        LOWER(bank_accounts.bank_name) LIKE LOWER('%#{query}%') OR
                                        LOWER(bank_accounts.city) LIKE LOWER('%#{query}%') OR
                                        LOWER(countries.name) LIKE LOWER('%#{query}%')
                        ")}

  # ------------------
  # Instance Methods
  # ------------------

  def display_name
    self.account_number_was
  end

  def can_be_edited?
    true
  end

  def can_be_deleted?
    false
  end

end
