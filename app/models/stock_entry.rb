class StockEntry < Vyapari::ApplicationRecord

  # Constants
  ACTIVE = "active"
  SOLD = "sold"
  DAMAGED = "damaged"
  RECEIVED = "received"
  RETURNED = "returned"
  RESERVED = "reserved"
  PENDING = "pending"
  
  STATUS_HASH = {"Active" => ACTIVE, "Sold" => SOLD, "Damaged" => DAMAGED, "Received" => RECEIVED, "Reserved" => RESERVED, "Pending" => PENDING, "Returned" => RETURNED}
  STATUS_HASH_REVERSE = {ACTIVE => "Active", SOLD => "Sold", DAMAGED => "Damaged", RECEIVED => "Received", RESERVED => "Reserved", PENDING => "Pending", RETURNED => "Returned"}

  # Validations
  validates :store, presence: true
  validates :product, presence: true
  validates :quantity, presence: true, numericality: true
  validates :status, :presence=> true, :inclusion => {:in => STATUS_HASH_REVERSE.keys, :presence_of => :status, :message => "%{value} is not a valid status" }
  
  # Associations
  belongs_to :store
  belongs_to :product
  belongs_to :supplier, optional: true
  belongs_to :stock_bundle, optional: true
  belongs_to :invoice, optional: true
  
  # ------------------
  # Class Methods
  # ------------------

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> obj.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| joins("LEFT JOIN `stores` ON `stores`.`id` = `stock_entries`.`store_id` LEFT JOIN `products` ON `products`.`id` = `stock_entries`.`product_id` LEFT JOIN `suppliers` ON `suppliers`.`id` = `stock_entries`.`supplier_id`").where("LOWER(products.name) LIKE LOWER('%#{query}%') OR 
                                                        LOWER(suppliers.name) LIKE LOWER('%#{query}%') OR 
                                                        LOWER(products.ean_sku) LIKE LOWER('%#{query}%') OR 
                                                        LOWER(products.one_liner) LIKE LOWER('%#{query}%') OR
                                                        LOWER(products.description) LIKE LOWER('%#{query}%') OR
                                                        LOWER(stores.name) LIKE LOWER('%#{query}%')")}

  
  scope :active, -> { where(status: ACTIVE) }
  scope :sold, -> { where(status: SOLD) }
  scope :damaged, -> { where(status: DAMAGED) }
  scope :returned, -> { where(status: RETURNED) }
  scope :received, -> { where(status: RECEIVED) }
  scope :reserved, -> { where(status: RESERVED) }
  scope :in_stock, -> { where(status: [ACTIVE, RECEIVED, RETURNED]) }

  scope :this_month, lambda { where("created_at >= ? AND created_at <= ?", Time.zone.now.beginning_of_month, Time.zone.now.end_of_month) }
  scope :today, lambda { where('DATE(created_at) = ?', Date.current.in_time_zone)}

  def self.save_row_data(row)

    row.headers.each{ |cell| row[cell] = row[cell].to_s.strip }

    return if row[:ean_sku].blank?

    # Initializing error hash for displaying all errors altogether
    error_object = Kuppayam::Importer::ErrorHash.new

    store = Store.find_by_code(row[:stock])
    unless store
      summary = "Store doesn't exist."
      details = "Error! The store with code #{row[:store]} doesn't exists in the database"
      error_object.errors << { summary: summary, details: details }
      return
    end

    product = Product.find_by_ean_sku(row[:ean_sku]) || Product.new

    product.name = row[:name]
    product.code = row[:code]
    
    if product.valid?
      product.save!
    else
      summary = "Error while saving product: #{product.name}"
      details = "Error! #{product.errors.full_messages.to_sentence}"
      error_object.errors << { summary: summary, details: details }
    end


    stock_entry.store = store
    stock_entry.product = product
    stock_entry.quantity = row[:quantity]
    
    stock_entry.set_stock_entry_type(row[:stock_entry_type])
    
    stock_entry.region = Region.find_by_code(row[:region]) || Country.find_by_name(row[:country])
    stock_entry.country = Country.find_by_code(row[:country]) || Country.find_by_name(row[:country])
    
    if stock_entry.valid?
      stock_entry.save!
    else
      summary = "Error while saving stock_entry: #{stock_entry.name}"
      details = "Error! #{stock_entry.errors.full_messages.to_sentence}"
      error_object.errors << { summary: summary, details: details }
    end
    return error_object
  end

  # ------------------
  # Instance Methods
  # ------------------

  def display_name
    "Stock from #{self.supplier.try(:name)}"
  end

  def display_store_type
    STATUS_HASH[self.status]
  end

  def display_status
    STATUS_HASH_REVERSE[self.status]
  end

  def slug
    if self.product
      self.product.name.parameterize
    else
      self.id
    end
  end

  def to_param
    "#{id}-#{slug}"
  end

  # change the status to :active
  # Return the status
  # == Examples
  #   >>> stock_entry.activate!
  #   => "active"
  def activate!
    self.update_attribute(:status, ACTIVE)
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

  # change the status to :received
  # Return the status
  # == Examples
  #   >>> stock_entry.mark_as_received!
  #   => "received"
  def mark_as_received!
    self.update_attribute(:status, RECEIVED)
  end

  # change the status to :reserved
  # Return the status
  # == Examples
  #   >>> stock_entry.reserve!
  #   => "reserved"
  def reserve!
    self.update_attribute(:status, RESERVED)
  end

  # change the status to :returned
  # Return the status
  # == Examples
  #   >>> stock_entry.reserve!
  #   => "returned"
  def return!
    self.update_attribute(:status, RETURN)
  end

  # change the status to :pending
  # Return the status
  # == Examples
  #   >>> stock_entry.mark_as_pending!
  #   => "pending"
  def mark_as_pending!
    self.update_attribute(:status, PENDING)
  end

  # * Return true if the stock_entry is active, else false.
  # == Examples
  #   >>> stock_entry.active?
  #   => true
  def active?
    (status == ACTIVE)
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

  # * Return true if the stock_entry is received, else false.
  # == Examples
  #   >>> stock_entry.received?
  #   => true
  def received?
    (status == RECEIVED)
  end

  # * Return true if the stock_entry is returned, else false.
  # == Examples
  #   >>> stock_entry.returned?
  #   => true
  def returned?
    (status == RETURNED)
  end

  # * Return true if the stock_entry is reserved, else false.
  # == Examples
  #   >>> stock_entry.reserved?
  #   => true
  def reserved?
    (status == RESERVED)
  end

  # * Return true if the stock_entry is pending, else false.
  # == Examples
  #   >>> stock_entry.pending?
  #   => true
  def pending?
    (status == PENDING)
  end

  def can_be_edited?
    true
  end

  def can_be_deleted?
    # if self.products.any?
    #   #self.errors.add(:base, DELETE_MESSAGE) 
    #   return false
    # else
    #   return true
    # end
    return true
  end

  def report_heading
    rh = []
    rh << self.company.try(:name) if self.company.name
    rh << self.display_name
    rh.join(", ")
  end

end
