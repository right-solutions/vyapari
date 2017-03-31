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
  before_validation :update_permalink
  before_validation :update_top_category

	# Validations
  validates :name, presence: true
  #validates :description, presence: true
  validates :permalink, presence: true, uniqueness: true
  validates :status, :presence=> true, :inclusion => {:in => STATUS_HASH_REVERSE.keys, :presence_of => :status, :message => "%{value} is not a valid status" }

  # Associations
  has_one :product_image, :as => :imageable, :dependent => :destroy, :class_name => "Image::ProductImage"
  has_one :brochure, :as => :documentable, :dependent => :destroy, :class_name => "Document::Brochure"
  
  belongs_to :brand
  belongs_to :category
  belongs_to :top_category, class_name: "Category"
  
	# return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> object.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| joins("INNER JOIN categories on categories.id = products.category_id").
                                 where("LOWER(products.name) LIKE LOWER('%#{query}%') OR\
                                        LOWER(products.permalink) LIKE LOWER('%#{query}%') OR\
                                        LOWER(products.one_liner) LIKE LOWER('%#{query}%') OR\
                                        LOWER(products.description) LIKE LOWER('%#{query}%') OR\
                                        LOWER(categories.name) LIKE LOWER('%#{query}%') OR\
                                        LOWER(categories.one_liner) LIKE LOWER('%#{query}%') OR\
                                        LOWER(categories.description) LIKE LOWER('%#{query}%')")
                        }

  scope :status, lambda { |status| where("LOWER(status)='#{status}'") }
  scope :featured, lambda { |val| where(featured: val) }

  scope :published, -> { where(status: PUBLISHED) }
  scope :unpublished, -> { where(status: UNPUBLISHED) }
  scope :removed, -> { where(status: REMOVED) }

  # ------------------
  # Instance variables
  # ------------------

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

  # TODO
  def can_be_deleted?
    #if self.jobs.any?
    #  self.errors.add(:base, DELETE_MESSAGE) 
    #  return false
    #else
    #  return true
    #end
    return true
  end

  def default_image_url(size="medium")
    "/assets/defaults/product-#{size}.png"
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

  def update_permalink
    self.permalink = "#{id}-#{name.parameterize}" if self.permalink.blank?
  end

end
