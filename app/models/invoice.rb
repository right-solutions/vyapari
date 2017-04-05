class Invoice < Vyapari::ApplicationRecord

  # Constants
  DRAFT = "draft"
  ACTIVE = "active"
  CANCELLED = "cancelled"

  CASH = "cash"
  CREDIT = "credit"
  CREDIT_CARD = "credit_card"
  CHEQUE = "cheque"
  
  STATUS_HASH = {"Draft" => DRAFT, "Active" => ACTIVE, "Cancelled" => CANCELLED}
  STATUS_HASH_REVERSE = {DRAFT => "Draft", ACTIVE => "Active", CANCELLED => "Cancelled"}

  # Call backs
  before_save :calculate_total_amount

  # Validations
  validates :invoice_number, :presence=> true
  validates :invoice_date, :presence=> true

  validates :status, :presence=> true, :inclusion => {:in => STATUS_HASH_REVERSE.keys, :presence_of => :status, :message => "%{value} is not a valid status" }

  # Associations
  belongs_to :terminal
  belongs_to :store
  belongs_to :user
  has_many :line_items
  has_many :stock_entries

  # ------------------
  # Class Methods
  # ------------------

  # Scopes

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> invoice.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda { |query| where("LOWER(invoice_number) LIKE LOWER('%#{query}%') OR LOWER(customer_name) LIKE LOWER('%#{query}%') OR LOWER(customer_address) LIKE LOWER('%#{query}%')")
                        }

  scope :status, lambda { |status| where("LOWER(status)='#{status}'") }
  
  scope :draft, -> { where(status: DRAFT) }
  scope :active, -> { where(status: ACTIVE) }
  scope :cancelled, -> { where(status: CANCELLED) }

  scope :this_month, lambda { where("created_at >= ? AND created_at <= ?", Time.zone.now.beginning_of_month, Time.zone.now.end_of_month) }
  
  # ------------------
  # Instance Methods
  # ------------------

  def initialize
    super
    self.discount = 0.00
    self.adjustment = 0.00
    self.money_taken = 0.00
    self.total_amount = 0.00
  end

  def display_name
    self.invoice_number
  end

  def display_status
    STATUS_HASH_REVERSE[self.status]
  end

  def display_payment_method
    self.payment_method.titleize
  end

  def slug
    self.invoice_number.parameterize
  end

  def generate_temporary_invoice_number
    self.invoice_number = "#{Time.now.to_i}"
  end

  def reset_invoice_number
    self.update_attribute(:invoice_number, "#{INV}-#{self.terminal.code}-#{self.id}") if self.draft?
  end

  def to_param
    "#{id}-#{slug}"
  end

  # * Return true if the invoice is draft, else false.
  # == Examples
  #   >>> invoice.draft?
  #   => true
  def draft?
    (status == DRAFT)
  end

  # change the status to :draft
  # Return the status
  # == Examples
  #   >>> invoice.publish!
  #   => "draft"
  def draft!
    self.update_attribute(:status, DRAFT)
  end

  # * Return true if the invoice is active, else false.
  # == Examples
  #   >>> invoice.active?
  #   => true
  def active?
    (status == ACTIVE)
  end

  # change the status to :active
  # Return the status
  # == Examples
  #   >>> invoice.unpublish!
  #   => "active"
  def activate!
    self.update_attributes(status: ACTIVE)
  end

  # * Return true if the invoice is cancelled, else false.
  # == Examples
  #   >>> invoice.cancelled?
  #   => true
  def cancelled?
    (status == CANCELLED)
  end

  # change the status to :cancelled
  # Return the status
  # == Examples
  #   >>> invoice.remove!
  #   => "cancelled"
  def cancel!
    self.update_attributes(status: CANCELLED, featured: false)
  end

  # * Return true if the invoice is cash, else false.
  # == Examples
  #   >>> invoice.cash?
  #   => true
  def cash?
    (payment_method == CASH)
  end

  # * Return true if the invoice is credit, else false.
  # == Examples
  #   >>> invoice.credit?
  #   => true
  def credit?
    (payment_method == CREDIT)
  end

  # * Return true if the invoice is credit_card, else false.
  # == Examples
  #   >>> invoice.credit_card?
  #   => true
  def credit_card?
    (payment_method == CREDIT_CARD)
  end

  # * Return true if the invoice is cheque, else false.
  # == Examples
  #   >>> invoice.cheque?
  #   => true
  def cheque?
    (payment_method == CHEQUE)
  end

  def can_be_draft?
    active? or cancelled?
  end

  def can_be_active?
    draft? or cancelled?
  end

  def can_be_cancelled?
    draft? or active?
  end

  # TODO

  def can_be_edited?
    true
  end
  
  def can_be_deleted?
    cancelled? && self.line_items.blank?
    #if self.jobs.any?
    #  self.errors.add(:base, DELETE_MESSAGE) 
    #  return false
    #else
    #  return true
    #end
    #return true
  end

  def generate_real_invoice_number!
    self.invoice_number = "INV-#{self.terminal.code}-#{self.id}"
    self.save
  end

  def net_total_amount
    self.total_amount - self.discount
  end

  def balance_to_give
    self.money_taken - self.net_total_amount
  end

  def calculate_total_amount
    self.total_amount = self.line_items.sum("rate * quantity") || 0.0
  end
  
end
