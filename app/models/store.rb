class Store < Vyapari::ApplicationRecord

  # Constants
  ACTIVE = "active"
  INACTIVE = "inactive"
  CLOSED = "closed"
  
  STATUS_HASH = {"Active" => ACTIVE, "Inactive" => INACTIVE, "Closed" => CLOSED}
  STATUS_HASH_REVERSE = {ACTIVE => "Active", INACTIVE => "Inactive", CLOSED => "Closed"}

  # Constants
  WAREHOUSE = "warehouse"
  POS_STORE = "pos_store"
  
  STORE_TYPES = { 
    WAREHOUSE => "Warehouse", 
    POS_STORE => "POS Store"
  }

  STORE_TYPES_REVERSE = { 
    "Warehouse" => WAREHOUSE, 
    "POS Store" => POS_STORE
  }

  # Validations
  validates :name, presence: true, length: {minimum: 2, maximum: 250}, allow_blank: false
  validates :code, presence: true, uniqueness: true, length: {minimum: 2, maximum: 24}, allow_blank: false
  validates :store_type, :presence => true, :inclusion => {:in => STORE_TYPES.keys, :presence_of => :store_type, :message => "%{value} is not a valid store type" }
  validates :status, :presence=> true, :inclusion => {:in => STATUS_HASH_REVERSE.keys, :presence_of => :status, :message => "%{value} is not a valid status" }
  
  # Associations
  belongs_to :region, optional: true
  belongs_to :country, optional: true
  
  has_many :terminals
  has_many :stock_entries
  has_many :stock_bundles
  
  # ------------------
  # Class Methods
  # ------------------

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> obj.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| joins(:country, :region).where("LOWER(name) LIKE LOWER('%#{query}%') OR 
                                                        LOWER(code) LIKE LOWER('%#{query}%') OR 
                                                        LOWER(store_type) LIKE LOWER('%#{query}%') OR 
                                                        LOWER(regions.name) LIKE LOWER('%#{query}%') OR
                                                        LOWER(countries.name) LIKE LOWER('%#{query}%')")}

  
  scope :warehouse, -> { where(store_type: WAREHOUSE) }
  scope :pos_store, -> { where(store_type: POS_STORE) }

  scope :active, -> { where(status: ACTIVE) }
  scope :inactive, -> { where(status: INACTIVE) }
  scope :close, -> { where(status: CLOSED) }

  scope :active_and_inactive, -> { where(status: [ACTIVE, INACTIVE]) }

  def self.save_row_data(row)

    row.headers.each{ |cell| row[cell] = row[cell].to_s.strip }

    return if row[:name].blank?

    store = Store.find_by_code(row[:code]) || Store.new
    
    store.name = row[:name]
    store.code = row[:code]
    
    store.set_store_type(row[:store_type])
    
    store.region = Region.find_by_code(row[:region]) || Country.find_by_name(row[:country])
    store.country = Country.find_by_code(row[:country]) || Country.find_by_name(row[:country])
    
    # Initializing error hash for displaying all errors altogether
    error_object = Kuppayam::Importer::ErrorHash.new

    if store.valid?
      store.save!
    else
      summary = "Error while saving store: #{store.name}"
      details = "Error! #{store.errors.full_messages.to_sentence}"
      error_object.errors << { summary: summary, details: details }
    end
    return error_object
  end

  # ------------------
  # Instance Methods
  # ------------------

  def display_name
    self.country ? "#{self.code_was}-#{self.name_was}, #{self.country.name}" : "#{self.code_was}-#{self.name_was}"
  end

  def display_store_type
    STORE_TYPES[self.store_type]
  end

  def set_store_type(st)
    if STORE_TYPES.keys.include?(st)
      self.store_type = st
    elsif STORE_TYPES_REVERSE.keys.include?(st)
      self.store_type = STORE_TYPES_REVERSE[st]
    end
  end

  def slug
    self.name.parameterize
  end

  def to_param
    "#{id}-#{slug}"
  end

  def warehouse?
    self.store_type == WAREHOUSE
  end

  def pos_store?
    self.store_type == POS_STORE
  end

  # * Return true if the brand is active, else false.
  # == Examples
  #   >>> brand.active?
  #   => true
  def active?
    (status == ACTIVE)
  end

  # * Return true if the brand is inactive, else false.
  # == Examples
  #   >>> brand.inactive?
  #   => true
  def inactive?
    (status == INACTIVE)
  end

  # * Return true if the brand is closed, else false.
  # == Examples
  #   >>> brand.closed?
  #   => true
  def closed?
    (status == CLOSED)
  end

  # change the status to :active
  # Return the status
  # == Examples
  #   >>> brand.publish!
  #   => "active"
  def activate!
    self.update_attribute(:status, ACTIVE)
  end

  # change the status to :inactive
  # Return the status
  # == Examples
  #   >>> brand.publish!
  #   => "inactive"
  def inactive!
    self.update_attribute(:status, INACTIVE)
  end

  # change the status to :closed
  # Return the status
  # == Examples
  #   >>> brand.publish!
  #   => "closed"
  def close!
    self.update_attribute(:status, CLOSED)
  end

  def can_be_activated?
    inactive? or closed?
  end

  def can_be_inactivated?
    active?
  end

  def can_be_closed?
    active? or inactive?
  end

  def can_be_edited?
    !closed?
  end

  def can_be_deleted?
    if self.terminals.any?
      #self.errors.add(:base, DELETE_MESSAGE) 
      return false
    else
      return true
    end
  end

  def report_heading
    rh = []
    rh << self.company.try(:name) if self.company.name
    rh << self.display_name
    rh.join(", ")
  end

end