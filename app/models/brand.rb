class Brand < Vyapari::ApplicationRecord

  # Constants
  PUBLISHED = "published"
  UNPUBLISHED = "unpublished"
  REMOVED = "removed"
  
  STATUS_HASH = {"Published" => PUBLISHED, "Unpublished" => UNPUBLISHED, "Removed" => REMOVED}
  STATUS_HASH_REVERSE = {PUBLISHED => "Published", UNPUBLISHED => "Unpublished", REMOVED => "Removed"}

  FEATURED_HASH = {"Featured" => true, "Non Featured" => false}
  FEATURED_HASH_REVERSE = {true => "Featured", false => "Non Featured"}

  # Validations
  validates :name, :presence=> true, uniqueness: true
  validates :status, :presence=> true, :inclusion => {:in => STATUS_HASH_REVERSE.keys, :presence_of => :status, :message => "%{value} is not a valid status" }

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
  scope :search, lambda { |query| where("LOWER(name) LIKE LOWER('%#{query}%')")
                        }

  scope :status, lambda { |status| where("LOWER(status)='#{status}'") }
  scope :featured, lambda { |val| where(featured: val) }

  scope :published, -> { where(status: PUBLISHED) }
  scope :unpublished, -> { where(status: UNPUBLISHED) }
  scope :removed, -> { where(status: REMOVED) }

  scope :this_month, lambda { where("created_at >= ? AND created_at <= ?", Time.zone.now.beginning_of_month, Time.zone.now.end_of_month) }
  
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

  # change the status to :published
  # Return the status
  # == Examples
  #   >>> brand.publish!
  #   => "published"
  def publish!
    self.update_attribute(:status, PUBLISHED)
  end

  # * Return true if the brand is unpublished, else false.
  # == Examples
  #   >>> brand.unpublished?
  #   => true
  def unpublished?
    (status == UNPUBLISHED)
  end

  # change the status to :unpublished
  # Return the status
  # == Examples
  #   >>> brand.unpublish!
  #   => "unpublished"
  def unpublish!
    self.update_attributes(status: UNPUBLISHED, featured: false)
  end

  # * Return true if the brand is removed, else false.
  # == Examples
  #   >>> brand.removed?
  #   => true
  def removed?
    (status == REMOVED)
  end

  # change the status to :removed
  # Return the status
  # == Examples
  #   >>> brand.remove!
  #   => "removed"
  def remove!
    self.update_attributes(status: REMOVED, featured: false)
  end

  def can_be_published?
    unpublished? or removed?
  end

  def can_be_unpublished?
    published? or removed?
  end

  def can_be_removed?
    published? or unpublished?
  end

  # TODO

  def can_be_edited?
    true
  end
  
  def can_be_deleted?
    removed? && self.products.blank?
    #if self.jobs.any?
    #  self.errors.add(:base, DELETE_MESSAGE) 
    #  return false
    #else
    #  return true
    #end
    #return true
  end
  
end
