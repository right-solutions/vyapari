class Brand < Vyapari::ApplicationRecord

  # Constants
  PUBLISHED = "published"
  UNPUBLISHED = "unpublished"
  REMOVED = "removed"
  
  STATUS_REVERSE = {"Published" => PUBLISHED, "Unpublished" => UNPUBLISHED, "Removed" => REMOVED}
  STATUS = {PUBLISHED => "Published", UNPUBLISHED => "Unpublished", REMOVED => "Removed"}

  FEATURED_HASH = {"Featured" => true, "Non Featured" => false}
  FEATURED_HASH_REVERSE = {true => "Featured", false => "Non Featured"}

  # Validations
  validates :name, :presence=> true, uniqueness: true, length: {minimum: 3, maximum: 250}
  validates :status, :presence=> true, :inclusion => {:in => STATUS.keys, :presence_of => :status, :message => "%{value} is not a valid status" }

  # Associations
  has_one :brand_image, :as => :imageable, :dependent => :destroy, :class_name => "Image::BrandImage"
  has_many :products

  # ------------------
  # Class Methods
  # ------------------

  # Scopes

  # return an published record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> brand.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda { |query| where("LOWER(name) LIKE LOWER(?)", "%#{query}%")}
  scope :status, lambda { |status| where("LOWER(status)=?", status) }

  scope :featured, lambda { |val| where(featured: val) }
  
  scope :published, -> { where(status: PUBLISHED) }
  scope :unpublished, -> { where(status: UNPUBLISHED) }
  scope :removed, -> { where(status: REMOVED) }

  scope :this_month, lambda { where("created_at >= ? AND created_at <= ?", Time.zone.now.beginning_of_month, Time.zone.now.end_of_month) }
  
  # Import Methods
  # --------------
  
  def self.save_row_data(row)

    row.headers.each{ |cell| row[cell] = row[cell].to_s.strip }

    return if row[:name].blank?

    brand = Brand.find_by_name(row[:name]) || Brand.new
    
    brand.name = row[:name]
    brand.featured = row[:featured]
    brand.status = row[:status]
    brand.priority = row[:priority]
    
    # Initializing error hash for displaying all errors altogether
    error_object = Kuppayam::Importer::ErrorHash.new

    if brand.valid?
      brand.save!
    else
      summary = "Error while saving brand: #{brand.name}"
      details = "Error! #{brand.errors.full_messages.to_sentence}"
      error_object.errors << { summary: summary, details: details }
    end
    return error_object
  end

  # ------------------
  # Instance Methods
  # ------------------

  def display_name
    self.name
  end

  def slug
    self.name.parameterize
  end

  def to_param
    "#{id}-#{slug}"
  end

  # * Return true if the brand is published, else false.
  # == Examples
  #   >>> brand.published?
  #   => true
  def published?
    (status == PUBLISHED)
  end

  # * Return true if the brand is unpublished, else false.
  # == Examples
  #   >>> brand.unpublished?
  #   => true
  def unpublished?
    (status == UNPUBLISHED)
  end

  # * Return true if the brand is removed, else false.
  # == Examples
  #   >>> brand.removed?
  #   => true
  def removed?
    (status == REMOVED)
  end

  # check if the brand can be published
  # Return the status
  # == Examples
  #   >>> brand.can_be_published?
  #   => true
  def can_be_published?
    unpublished? or removed?
  end

  # check if the brand can be unpublished
  # Return the status
  # == Examples
  #   >>> brand.can_be_unpublished?
  #   => true
  def can_be_unpublished?
    published? or removed?
  end

  # check if the brand can be removed
  # Return the status
  # == Examples
  #   >>> brand.can_be_removed?
  #   => true
  def can_be_removed?
    !removed?
  end

  # change the status of the brand according the status string passed
  # this method will call respective methods and populate errors for changing the status.
  # Return the status
  # == Examples
  #   >>> brand.update_status!("published")
  #   => "published"
  #   >>> brand.update_status!("removed")
  #   => "removed"
  def update_status!(new_status)
    case new_status.to_sym
    when :publish, :published
      publish!
    when :unpublish, :unpublished
      unpublish!
    when :remove, :removed
      remove!
    end
  end

  # change the status to :published
  # Return the status
  # == Examples
  #   >>> brand.publish!
  #   => "published"
  def publish!
    if can_be_published?
      self.update_attribute(:status, PUBLISHED)
    else
      self.errors.add(:status, "This brand can't be published. Check if it is already published!")
    end
  end

  # change the status to :unpublished. This will also unfeature if it is already featured
  # Return the status
  # == Examples
  #   >>> brand.unpublish!
  #   => "unpublished"
  def unpublish!
    if can_be_unpublished?
      self.update_attributes(status: UNPUBLISHED, featured: false)
    else
      self.errors.add(:status, "Cannot unpublish! Brand should be published first.")
    end
  end

  # change the status to :removed. This will also unfeature if it is already featured
  # Return the status
  # == Examples
  #   >>> brand.remove!
  #   => "removed"
  def remove!
    if can_be_removed?
      self.update_attributes(status: REMOVED, featured: false)
    else
      self.errors.add(:status, "This brand can't be removed. Either, there are products associated with this brand or it is already removed")
    end
  end

  def mark_as_featured!
    if can_be_featured?
      self.update_attribute(:featured, true)
    else
      self.errors.add(:featured, "This Brand cannot be featued as it is already featured or is not published")
    end
  end

  def remove_from_featured!
    if can_be_unfeatured?
      self.update_attribute(:featured, false)
    else
      self.errors.add(:featured, "This brand is currently not featured!")
    end
  end

  def can_be_featured?
    !featured? && published?
  end

  def can_be_unfeatured?
    featured?
  end

  def can_be_edited?
    !removed?
  end
  
  def can_be_deleted?
    removed? && self.products.blank?
  end
  
end
