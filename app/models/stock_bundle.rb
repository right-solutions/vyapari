require 'csv'

class StockBundle < ActiveRecord::Base

  # Constants
  PENDING = "pending" # Default Status
  ERRORED = "errored"
  APPROVED = "approved"

  STATUS = {"Pending" => PENDING, "Approved" => APPROVED, "Errored" => ERRORED}
  STATUS_REVERSE = {PENDING => "Pending", APPROVED => "Approved", ERRORED => "Errored"}

  # Validations
  validates :name, :presence=> true, uniqueness: true
  validates :uploaded_date, presence: true
  validates :status, :presence=> true, :inclusion => {:in => STATUS_REVERSE.keys, :presence_of => :status, :message => "%{value} is not a valid status" }
  # validates :file, :presence=> true
  
  # Associations
  has_many :stock_entries
  belongs_to :uploader, class_name: 'User'
  belongs_to :supplier, optional: true
  belongs_to :store

  # Uploader
  mount_uploader :file, File::StockBundleUploader
  mount_uploader :error_file, File::StockBundleUploader

  # ------------------
  # Class Methods
  # ------------------

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> obj.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| joins(:supplier, :store).where("LOWER(suppliers.name) LIKE LOWER('%#{query}%') OR LOWER(stores.name) LIKE LOWER('%#{query}%')")}

  scope :status, lambda { |status| where ("LOWER(stock_bundles.status)='#{status}'") }

  scope :pending, -> { where(status: PENDING) }
  scope :approved, -> { where(status: APPROVED) }
  
  # ------------------
  # Class Methods
  # ------------------

  def parse_stocks

    # For some reasn it throws error for self.error_details unless we reload
    self.reload

    path = "#{Rails.root}/public#{self.file.url}"
    begin
      csv_table = CSV.table(path, {headers: true, converters: nil, header_converters: :symbol})
    rescue CSV::MalformedCSVError => e
      self.error_summary = "The Uploaded File is corrupted."
      self.error_details = "#{e.class}: #{e.message}"
      self.save
      puts self.error_summary.red
      puts self.error_details.red
      return false
    rescue Exception => e
      self.error_summary = "The Uploaded File format is not supported."
      self.error_details = "#{e.class}: #{e.message}"
      puts self.error_summary.red
      puts self.error_details.red
      self.save
      return false
    end

    headers = csv_table.headers

    StockEntry.where(stock_bundle: self.id).destroy_all

    # We need a collection of all the column headings to pass to error hander to reproduce the errors in same format
    columns = [:env_sku, :name, :reference_number, :one_liner, :description, :purchased_price, :landed_price, :selling_price, :retail_price, :brand, :category, :quantity]

    # Initializing the Data Error to store errors for each column
    data_error = Kuppayam::Importer::DataError.new
    data_error.columns = columns
    
    csv_table.each_with_index do |row, i|

      row.headers.each{ |cell| row[cell] = row[cell].to_s.strip }
      
      if row[:ean_sku].blank?
        data_error.add_column_error(:ean_sku, "", "ENV / SKU number is blank", i)
        next
      end

      if row[:quantity].blank?
        data_error.add_column_error(:quantity, "", "Quantity is blank", i)
        next
      end

      product = Product.where("ean_sku = ?", row[:ean_sku]).first || Product.new

      product.ean_sku = row[:ean_sku]
      product.name = row[:name]
      product.reference_number = row[:reference_number]
      product.one_liner = row[:one_liner]
      product.description = row[:description]

      product.purchased_price = row[:purchased_price]
      product.landed_price = row[:landed_price]
      product.selling_price = row[:selling_price]
      product.retail_price = row[:retail_price]

      product.purchased_price = 0.00 if product.purchased_price.blank?
      product.landed_price = 0.00 if product.landed_price.blank?
      product.selling_price = 0.00 if product.selling_price.blank?
      product.retail_price = 0.00 if product.retail_price.blank?

      product.brand = Brand.where("name = ?", row[:brand]).first || product.build_brand(name: row[:brand]) if row[:brand]
      product.category = Category.where("name = ?", row[:category]).first || product.build_category(name: row[:category]) if row[:category]
      
      stock_entry = StockEntry.new()
      
      stock_entry.store = self.store
      stock_entry.product = product
      stock_entry.supplier = self.supplier
      stock_entry.quantity = row[:quantity]
      stock_entry.stock_bundle = self
      stock_entry.status = :pending

      if product.valid? && stock_entry.valid?
        product.save!
        stock_entry.save!
      else
        unless product.valid?
          columns.each do |col_name|
            data_error.add_column_error(col_name, row[col_name], product.errors[col_name], i) if product.errors.has_key?(col_name)
          end
        end
        unless stock_entry.valid?
          columns.each do |col_name|
            data_error.add_column_error(col_name, row[col_name], stock_entry.errors[col_name], i) if stock_entry.errors.has_key?(col_name)
          end
        end
      end

    end

    if data_error.errors.any?
      self.error_summary = "There are few errors in some of the rows in the CSV file. Open the error file to know more."
      # self.error_file = data_error.generate_error_file
    end

    self.save!
    self.stock_entries.update_all(status: :active) if data_error.errors.blank?

    return data_error.errors.blank?
  end

  # ------------------
  # Instance Methods
  # ------------------

  def display_name
    "Stock Bundle - #{self.id} from #{supplier.try(:name)}"
  end

  def display_status
    STATUS_REVERSE[self.status]
  end

  def display_file_name
    if self.file && self.file.file
      self.file.file.filename
    else
      self.display_name
    end
  end

  def original_file_path
    self.file && self.file.file ? self.file.file.path : nil
  end

  def original_error_file_path
    self.error_file && self.error_file.file ? self.error_file.file.path : nil
  end

  # * Return true if the stock_entry is approved, else false.
  # == Examples
  #   >>> stock_entry.pending?
  #   => true
  def pending?
    (status == PENDING)
  end

  # change the status of the stock_entry to :pending
  # Return the status
  # == Examples
  #   >>> stock_entry.mark_as_pending!
  #   => "pending"
  def mark_as_pending!
    self.update_attribute(:status, PENDING)
    self.stock_entries.update_all(status: StockEntry::PENDING)
  end

  # * Return true if the stock_entry is approved, else false.
  # == Examples
  #   >>> stock_entry.approved?
  #   => true
  def approved?
    (status == APPROVED)
  end

  # change the status to :approved
  # Return the status
  # == Examples
  #   >>> stock_entry.approve!
  #   => "approve"
  def approve!
    self.update_attribute(:status, APPROVED)
    self.stock_entries.update_all(status: StockEntry::ACTIVE)
    true
  end

  # * Return true if the stock_entry is errored, else false.
  # == Examples
  #   >>> stock_entry.mark_as_errored?
  #   => true
  def mark_as_errored?
    (status == ERRORED)
  end

  # change the status to :errored
  # Return the status
  # == Examples
  #   >>> stock_entry.mark_as_errored!
  #   => "approve"
  def mark_as_errored!
    self.update_attribute(:status, ERRORED)
    self.stock_entries.update_all(status: StockEntry::PENDING)
    true
  end

  def can_be_deleted?
    true
  end

  def can_be_edited?
    true
  end
  
end
