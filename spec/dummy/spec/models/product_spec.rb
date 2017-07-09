require 'spec_helper'

RSpec.describe Product, type: :model do

  let(:mens_wear) {FactoryGirl.create(:product, name: "Mens Wear")}
  let(:lifebuoy) {FactoryGirl.create(:product, name: "Lifebuoy Soap")}
  let(:lux) {FactoryGirl.create(:product, name: "Lux Soap")}

  let(:published_product) {FactoryGirl.create(:published_product, name: "Published Product")}
  let(:unpublished_product) {FactoryGirl.create(:unpublished_product, name: "Un Published Product")}
  let(:removed_product) {FactoryGirl.create(:removed_product, name: "Removed Product")}

  let(:featured_product) {FactoryGirl.create(:featured_product, name: "Featured Product")}

  context "Factory" do
    it "should validate all the factories" do
      expect(FactoryGirl.build(:product).valid?).to be true
      
      published_product = FactoryGirl.build(:published_product)
      expect(published_product.valid?).to be true
      expect(published_product.status).to match("published")

      unpublished_product = FactoryGirl.build(:unpublished_product)
      expect(unpublished_product.valid?).to be true
      expect(unpublished_product.status).to match("unpublished")

      removed_product = FactoryGirl.build(:removed_product)
      expect(removed_product.valid?).to be true
      expect(removed_product.status).to match("removed")

      featured_product = FactoryGirl.build(:featured_product)
      expect(featured_product.valid?).to be true
      expect(featured_product.featured).to be_truthy

      unfeatured_product = FactoryGirl.build(:unfeatured_product)
      expect(unfeatured_product.valid?).to be true
      expect(unfeatured_product.featured).to be_falsy
    end
  end

  context "Validations" do
    it { should validate_presence_of :name }
    it { should allow_value('Coca Cola').for(:name )}
    it { should_not allow_value('CC').for(:name )}
    it { should_not allow_value("x"*257).for(:name )}

    it { should validate_presence_of :ean_sku }
    it { should validate_inclusion_of(:status).in_array(Product::STATUS.keys)  }
    it { should validate_numericality_of(:priority) }
  end

  context "Associations" do
    it { should belong_to(:brand) }
    it { should belong_to(:category) }
    it { should belong_to(:top_category) }
    it { should have_many(:line_items) }
    it { should have_one(:product_image) }
    it { should have_many(:stock_entries) }
  end

  context "Class Methods" do
    it "search" do
      cosmetics = FactoryGirl.create(:category, name: "Cosmetics - Men", one_liner: "Cosmetic Products for Men")
      babel = FactoryGirl.create(:product, ean_sku: "EAN1234", reference_number: "REF. Inv No. 1021", name: "Babel", one_liner: "Unscented Beard Oil", description: "We use organic oils only.", category: cosmetics)
      
      expect(Product.search("Cosmetic Products")).to match_array([babel])
      expect(Product.search("Cosmetics - Men")).to match_array([babel])
      expect(Product.search("EAN1234")).to match_array([babel])
      expect(Product.search("Inv No. 1021")).to match_array([babel])
      expect(Product.search("Babel")).to match_array([babel])
      expect(Product.search("Beard Oil")).to match_array([babel])
      expect(Product.search("organic oils")).to match_array([babel])
    end

    it "scope unpublished" do
      [mens_wear, lifebuoy, lux, published_product, removed_product]
      expect(Product.unpublished.all).to match_array [mens_wear, lifebuoy, lux]
    end

    it "scope published" do
      [mens_wear, lifebuoy, lux, published_product, removed_product]
      expect(Product.published.all).to match_array [published_product]
    end

    it "scope removed" do
      [mens_wear, lifebuoy, lux, published_product, removed_product]
      expect(Product.removed.all).to match_array [removed_product]
    end

    it "scope status" do
      [mens_wear, lifebuoy, lux, published_product, removed_product]
      expect(Product.status(Product::UNPUBLISHED)).to match_array [mens_wear, lifebuoy, lux]
      expect(Product.status(Product::PUBLISHED)).to match_array [published_product]
      expect(Product.status(Product::REMOVED)).to match_array [removed_product]
    end

    it "scope featured" do
      expect(Product.featured(false)).to match_array [mens_wear, lifebuoy, lux]
      expect(Product.featured(true)).to match_array [featured_product]
    end

    context "Import Methods" do

      it "save_row_data" do
        skip
      end

    end
  end

  context "Instance Methods" do

    it "display_name" do
      expect(mens_wear.display_name).to match("Mens Wear")
    end

    it "slug" do
      expect(mens_wear.slug).to match(mens_wear.name.parameterize)
    end

    it "to_param" do
      expect(mens_wear.to_param).to match("#{mens_wear.id}-#{mens_wear.slug}")
    end

    it "publish!" do
      p = FactoryGirl.create(:unpublished_product)
      expect(p.status).to match "unpublished"
      p.publish!
      expect(p.status).to match "published"
    end

    it "unpublish!" do
      p = FactoryGirl.create(:published_product)
      expect(p.status).to match "published"
      p.unpublish!
      expect(p.status).to match "unpublished"
    end

    it "remove!" do
      p = FactoryGirl.create(:published_product)
      expect(p.status).to match "published"
      p.remove!
      expect(p.status).to match "removed"
    end

    it "can_be_published?, can_be_unpublished? & can_be_removed?" do
      p = FactoryGirl.create(:unpublished_product)
      expect(p.can_be_published?).to be_truthy
      expect(p.can_be_unpublished?).to be_falsy
      expect(p.can_be_removed?).to be_truthy

      p.publish!
      expect(p.can_be_published?).to be_falsy
      expect(p.can_be_unpublished?).to be_truthy
      expect(p.can_be_removed?).to be_truthy

      p.remove!
      expect(p.can_be_published?).to be_truthy
      expect(p.can_be_unpublished?).to be_truthy
      expect(p.can_be_removed?).to be_falsy
    end

    it "can_be_edited?" do
      p = FactoryGirl.create(:published_product)
      expect(p.can_be_edited?).to be_truthy

      p = FactoryGirl.create(:unpublished_product)
      expect(p.can_be_edited?).to be_truthy

      p = FactoryGirl.create(:removed_product)
      expect(p.can_be_edited?).to be_falsy
    end

    it "can_be_deleted?" do
      p = FactoryGirl.create(:published_product)
      expect(p.can_be_deleted?).to be_falsy

      p = FactoryGirl.create(:unpublished_product)
      expect(p.can_be_deleted?).to be_falsy

      p = FactoryGirl.create(:removed_product)
      expect(p.can_be_deleted?).to be_truthy

      p = FactoryGirl.create(:removed_product)
      line_item = FactoryGirl.create(:draft_line_item, product: p)
      expect(p.can_be_deleted?).to be_falsy

      p = FactoryGirl.create(:removed_product)
      stock_entry = FactoryGirl.create(:stock_entry, product: p)
      expect(p.can_be_deleted?).to be_falsy
    end
  end

end