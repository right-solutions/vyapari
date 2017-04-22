class Terminal < Vyapari::ApplicationRecord

  # Constants
  ACTIVE = "active"
  INACTIVE = "inactive"
  CLOSED = "closed"
  
  STATUS = {"Active" => ACTIVE, "Inactive" => INACTIVE, "Closed" => CLOSED}
  STATUS_REVERSE = {ACTIVE => "Active", INACTIVE => "Inactive", CLOSED => "Closed"}

  # Validations
  validates :name, presence: true, length: {minimum: 2, maximum: 250}, allow_blank: false
  validates :code, presence: true, uniqueness: true, length: {minimum: 2, maximum: 24}, allow_blank: false
  validates :status, :presence=> true, :inclusion => {:in => STATUS_REVERSE.keys, :presence_of => :status, :message => "%{value} is not a valid status" }
  
  # Associations
  belongs_to :store
  has_many :invoices
  
  # ------------------
  # Class Methods
  # ------------------

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> obj.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| where("LOWER(name) LIKE LOWER('%#{query}%') OR 
                                        LOWER(code) LIKE LOWER('%#{query}%')")}

  
  scope :active, -> { where(status: ACTIVE) }
  scope :inactive, -> { where(status: INACTIVE) }
  scope :close, -> { where(status: CLOSED) }

  scope :active_and_inactive, -> { where(status: [ACTIVE, INACTIVE]) }
  
  def self.save_row_data(row)

    row.headers.each{ |cell| row[cell] = row[cell].to_s.strip }

    return if row[:name].blank?

    terminal = Terminal.find_by_code(row[:code]) || Terminal.new
    
    terminal.name = row[:name]
    terminal.code = row[:code]
    
    terminal.store = Store.find_by_code(row[:store])

    # Initializing error hash for displaying all errors altogether
    error_object = Kuppayam::Importer::ErrorHash.new

    if terminal.valid?
      terminal.save!
    else
      summary = "Error while saving terminal: #{terminal.name}"
      details = "Error! #{terminal.errors.full_messages.to_sentence}"
      error_object.errors << { summary: summary, details: details }
    end

    return error_object
  end

  # ------------------
  # Instance Methods
  # ------------------

  def display_name
    "#{self.code_was}-#{self.name_was}"
  end

  def slug
    self.name.parameterize
  end

  def to_param
    "#{id}-#{slug}"
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
    if self.invoices.any?
      #self.errors.add(:base, DELETE_MESSAGE) 
      return false
    else
      return true
    end
  end

end
