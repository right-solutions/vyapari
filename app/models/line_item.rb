class LineItem < Vyapari::ApplicationRecord

  # Constants
  DRAFT = "draft"
  SOLD = "sold"
  DAMAGED = "damaged"
  RETURNED = "returned"
  CANCELLED = "cancelled"
  
  STATUS = {"Draft" => DRAFT, "Sold" => SOLD, "Damaged" => DAMAGED, "Returned" => RETURNED, "Cancelled" => CANCELLED}
  STATUS_REVERSE = {DRAFT => "Draft", SOLD => "Sold", DAMAGED => "Damaged", RETURNED => "Returned", CANCELLED => "Cancelled"}

  # Call backs
  before_save :calculate_total_amount

  # Validations
  validates :product, :presence=> true
  validates :quantity, :presence=> true
  validates :rate, :presence=> true

  validates :status, :presence=> true, :inclusion => {:in => STATUS_REVERSE.keys, :presence_of => :status, :message => "%{value} is not a valid status" }

  # Associations
  belongs_to :product, optional: true


  # ------------------
  # Class Methods
  # ------------------

  # Scopes

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> invoice.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda { |query| joins(:product).where("LOWER(products.name) LIKE LOWER('%#{query}%')")}
  scope :status, lambda { |status| where("LOWER(status)='#{status}'") }
  
  scope :draft, -> { where(status: DRAFT) }
  scope :sold, -> { where(status: SOLD) }
  scope :damaged, -> { where(status: DAMAGED) }
  scope :returned, -> { where(status: RETURNED) }

  scope :this_month, lambda { where("created_at >= ? AND created_at <= ?", Time.zone.now.beginning_of_month, Time.zone.now.end_of_month) }
  
  # ------------------
  # Instance Methods
  # ------------------

  def display_name
    if product
      self.product.display_name
    else
      "#{self.id} - No Product"
    end
  end

  # * Return true if the invoice is sold, else false.
  # == Examples
  #   >>> invoice.sold?
  #   => true
  def sold?
    (status == SOLD)
  end

  # change the status to :sold
  # Return the status
  # == Examples
  #   >>> invoice.publish!
  #   => "sold"
  def sold!
    self.update_attribute(:status, SOLD)
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
    self.update_attributes(status: ACTIVE, featured: false)
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

  def can_be_sold?
    active? or cancelled?
  end

  def can_be_active?
    sold? or cancelled?
  end

  def can_be_cancelled?
    sold? or active?
  end

  # change the status to :sold
  # Return the status
  # == Examples
  #   >>> stock_entry.sell!
  #   => "sold"
  def sell!
    self.update_attribute(:status, SOLD)
  end

  # change the status to :damaged
  # Return the status
  # == Examples
  #   >>> stock_entry.mark_as_damaged!
  #   => "damaged"
  def mark_as_damaged!
    self.update_attribute(:status, DAMAGED)
  end

  # change the status to :returned
  # Return the status
  # == Examples
  #   >>> stock_entry.reserve!
  #   => "returned"
  def return!
    self.update_attribute(:status, RETURN)
  end

  # change the status to :draft
  # Return the status
  # == Examples
  #   >>> stock_entry.draft!
  #   => "draft"
  def draft!
    self.update_attribute(:status, DRAFT)
  end

  # * Return true if the stock_entry is sold, else false.
  # == Examples
  #   >>> stock_entry.sold?
  #   => true
  def sold?
    (status == SOLD)
  end

  # * Return true if the stock_entry is damaged, else false.
  # == Examples
  #   >>> stock_entry.damaged?
  #   => true
  def damaged?
    (status == DAMAGED)
  end

  # * Return true if the stock_entry is returned, else false.
  # == Examples
  #   >>> stock_entry.returned?
  #   => true
  def returned?
    (status == RETURNED)
  end

  def calculate_total_amount
    if self.quantity * self.rate
      self.total_amount = self.quantity * self.rate
    else
      self.total_amount = 0.00
    end
  end

  # TODO
  def can_be_edited?
    true
  end
  
  def can_be_deleted?
    true
    #if self.jobs.any?
    #  self.errors.add(:base, DELETE_MESSAGE) 
    #  return false
    #else
    #  return true
    #end
    #return true
  end
  
end
