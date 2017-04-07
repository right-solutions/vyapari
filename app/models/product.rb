class Product < Vyapari::ApplicationRecord

  # Constants
  PUBLISHED = "published"
  UNPUBLISHED = "unpublished"
  REMOVED = "removed"
  
  STATUS_HASH = {"Published" => PUBLISHED, "Unpublished" => UNPUBLISHED, "Removed" => REMOVED}
  STATUS_HASH_REVERSE = {PUBLISHED => "Published", UNPUBLISHED => "Unpublished", REMOVED => "Removed"}

  FEATURED_HASH = {"Featured" => true, "Non Featured" => false}
  FEATURED_HASH_REVERSE = {true => "Featured", false => "Non Featured"}

  # Callbacks
  before_validation :update_top_category

	# Validations
  validates :name, presence: true
  validates :ean_sku, presence: true
  
  #validates :description, presence: true
  validates :status, :presence=> true, :inclusion => {:in => STATUS_HASH_REVERSE.keys, :presence_of => :status, :message => "%{value} is not a valid status" }

  # Associations
  has_one :product_image, :as => :imageable, :dependent => :destroy, :class_name => "Image::ProductImage"
  #has_one :brochure, :as => :documentable, :dependent => :destroy, :class_name => "Document::Brochure"
  
  belongs_to :brand
  belongs_to :category
  belongs_to :top_category, class_name: "Category"
  
	# return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> object.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| joins("LEFT JOIN categories on categories.id = products.category_id").
                                 where("LOWER(products.ean_sku) LIKE LOWER('%#{query}%') OR\
                                        LOWER(products.reference_number) LIKE LOWER('%#{query}%') OR\
                                        LOWER(products.name) LIKE LOWER('%#{query}%') OR\
                                        LOWER(products.one_liner) LIKE LOWER('%#{query}%') OR\
                                        LOWER(products.description) LIKE LOWER('%#{query}%') OR\
                                        LOWER(categories.name) LIKE LOWER('%#{query}%') OR\
                                        LOWER(categories.one_liner) LIKE LOWER('%#{query}%')")
                        }

  scope :status, lambda { |status| where("LOWER(status)='#{status}'") }
  scope :featured, lambda { |val| where(featured: val) }

  scope :published, -> { where(status: PUBLISHED) }
  scope :unpublished, -> { where(status: UNPUBLISHED) }
  scope :removed, -> { where(status: REMOVED) }

  def self.save_row_data(row)

    row.headers.each{ |cell| row[cell] = row[cell].to_s.strip }

    return if row[:name].blank?

    product = Product.find_by_name(row[:name]) || Product.new

    product.name = row[:name]
    product.one_liner = row[:one_liner]
    product.description = row[:description]
    product.ean_sku = row[:ean_sku].to_s
    product.reference_number = row[:reference_number]

    product.brand = Brand.find_by_name(row[:brand])
    product.category = Category.find_by_name(row[:category])
    product.top_category = product.category.top_category if product.category

    product.featured = row[:featured]
    product.status = row[:status]
    product.priority = row[:priority]
    
    # Initializing error hash for displaying all errors altogether
    error_object = Kuppayam::Importer::ErrorHash.new

    if product.valid?
      product.save!
    else
      summary = "Error while saving product: #{product.name}"
      details = "Error! #{product.errors.full_messages.to_sentence}"
      error_object.errors << { summary: summary, details: details }
    end
    return error_object
  end

  # ------------------
  # Instance variables
  # ------------------

  def display_name
    "#{self.ean_sku} : #{self.name}"
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
    published? or unpublished? or removed?
  end

  def can_be_edited?
    true
  end

  def can_be_deleted?
    #if self.jobs.any?
    #  self.errors.add(:base, DELETE_MESSAGE) 
    #  return false
    #else
    #  return true
    #end
    return true
  end

  protected

  def update_top_category
    if self.category
      if self.category.parent
        self.top_category = self.category.parent
      else
        self.top_category = self.category
      end
    end
  end

end
