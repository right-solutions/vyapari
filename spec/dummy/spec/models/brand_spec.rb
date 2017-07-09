require 'spec_helper'

RSpec.describe Brand, type: :model do

  let(:brand) {FactoryGirl.build(:brand)}
  let(:tata_salt) {FactoryGirl.create(:brand, name: "Tata Salt")}
  let(:lifebuoy) {FactoryGirl.create(:brand, name: "Lifebuoy Soap")}
  let(:lux) {FactoryGirl.create(:brand, name: "Lux Soap")}
  let(:horlicks) {FactoryGirl.create(:brand, name: "Horlicks")}

  let(:published_brand) {FactoryGirl.create(:published_brand, name: "Published Brand")}
  let(:unpublished_brand) {FactoryGirl.create(:unpublished_brand, name: "Un Published Brand")}
  let(:removed_brand) {FactoryGirl.create(:removed_brand, name: "Removed Brand")}

  let(:featured_brand) {FactoryGirl.create(:featured_brand, name: "Featured Brand")}

  context "Factory" do
    it "should validate all the factories" do
      expect(FactoryGirl.build(:brand).valid?).to be true
      
      published_brand = FactoryGirl.build(:published_brand)
      expect(published_brand.valid?).to be true
      expect(published_brand.status).to match("published")

      unpublished_brand = FactoryGirl.build(:unpublished_brand)
      expect(unpublished_brand.valid?).to be true
      expect(unpublished_brand.status).to match("unpublished")

      removed_brand = FactoryGirl.build(:removed_brand)
      expect(removed_brand.valid?).to be true
      expect(removed_brand.status).to match("removed")

      featured_brand = FactoryGirl.build(:featured_brand)
      expect(featured_brand.valid?).to be true
      expect(featured_brand.featured).to be_truthy

      unfeatured_brand = FactoryGirl.build(:unfeatured_brand)
      expect(unfeatured_brand.valid?).to be true
      expect(unfeatured_brand.featured).to be_falsy
    end
  end

  context "Validations" do
    it { should validate_presence_of :name }
    it { should allow_value('Coca Cola').for(:name )}
    it { should_not allow_value('CC').for(:name )}
    it { should_not allow_value("x"*257).for(:name )}

    it { should validate_inclusion_of(:status).in_array(Brand::STATUS.keys)  }
  end

  context "Associations" do
    it { should have_one(:brand_image) }
    it { should have_many(:products) }
  end

  context "Class Methods" do
    it "search" do
      arr = [tata_salt, lifebuoy, horlicks]
      expect(Brand.search("Tata Salt")).to match_array([tata_salt])
      expect(Brand.search("Lifebuoy Soap")).to match_array([lifebuoy])
      expect(Brand.search("Horlicks")).to match_array([horlicks])
      expect(Brand.search("Soap")).to match_array([lifebuoy, lux])
    end

    it "scope unpublished" do
      expect(Brand.unpublished.all).to match_array [tata_salt, lifebuoy, horlicks]
    end

    it "scope published" do
      published_brand
      expect(Brand.published.all).to match_array [published_brand]
    end

    it "scope removed" do
      removed_brand
      expect(Brand.removed.all).to match_array [removed_brand]
    end

    it "scope status" do
      published_brand
      removed_brand
      expect(Brand.status(Brand::UNPUBLISHED)).to match_array [tata_salt, lifebuoy, horlicks]
      expect(Brand.status(Brand::PUBLISHED)).to match_array [published_brand]
      expect(Brand.status(Brand::REMOVED)).to match_array [removed_brand]
    end

    it "scope featured" do
      expect(Brand.featured(false)).to match_array [tata_salt, lifebuoy, horlicks]
      expect(Brand.featured(true)).to match_array [featured_brand]
    end

    context "Import Methods" do

      it "save_row_data" do
        skip
      end

    end
  end

  context "Instance Methods" do

    it "display_name" do
      expect(tata_salt.display_name).to match("Tata Salt")
    end

    it "slug" do
      expect(tata_salt.slug).to match(tata_salt.name.parameterize)
    end

    it "to_param" do
      expect(tata_salt.to_param).to match("#{tata_salt.id}-#{tata_salt.slug}")
    end

    context "Status Methods" do

      let(:b1) {FactoryGirl.build(:published_brand)}
      let(:b2) {FactoryGirl.build(:unpublished_brand)}
      let(:b3) {FactoryGirl.build(:removed_brand)}
      
      it "published?" do
        expect(b1.published?).to be_truthy
        expect(b1.unpublished?).to be_falsy
      end

      it "unpublished?" do
        expect(b2.unpublished?).to be_truthy
        expect(b2.published?).to be_falsy
      end

      it "removed?" do
        expect(b3.removed?).to be_truthy
        expect(b3.published?).to be_falsy
      end

      it "can_be_published?" do
        expect(b1.can_be_published?).to be_falsy
        expect(b2.can_be_published?).to be_truthy
        expect(b3.can_be_published?).to be_truthy
      end

      it "can_be_unpublished?" do
        expect(b1.can_be_unpublished?).to be_truthy
        expect(b2.can_be_unpublished?).to be_falsy
        expect(b3.can_be_unpublished?).to be_truthy
      end

      it "can_be_removed?" do
        expect(b1.can_be_removed?).to be_truthy
        expect(b2.can_be_removed?).to be_truthy
        expect(b3.can_be_removed?).to be_falsy
      end

      it "publish!" do
        b = FactoryGirl.build(:unpublished_brand)
        b.publish!
        expect(b.status).to match "published"

        b = FactoryGirl.build(:published_brand)
        b.publish!
        expect(b.errors[:status].size).to eq(1)
        expect(b.errors[:status]).to include("This brand can't be published. Check if it is already published!")
      end

      it "unpublish!" do
        b = FactoryGirl.build(:published_brand)
        b.unpublish!
        expect(b.status).to match "unpublished"

        b = FactoryGirl.build(:unpublished_brand)
        b.unpublish!
        expect(b.errors[:status].size).to eq(1)
        expect(b.errors[:status]).to include("Cannot unpublish! Brand should be published first.")
      end

      it "remove!" do
        b = FactoryGirl.build(:published_brand)
        b.remove!
        expect(b.status).to match "removed"

        b = FactoryGirl.build(:removed_brand)
        b.remove!
        expect(b.errors[:status].size).to eq(1)
        expect(b.errors[:status]).to include("This brand can't be removed. Either, there are products associated with this brand or it is already removed")
      end

      it "update_status" do
        b = FactoryGirl.build(:unpublished_brand)
        b.update_status!("published")
        expect(b.status).to match "published"

        b = FactoryGirl.build(:published_brand)
        b.update_status!("unpublished")
        expect(b.status).to match "unpublished"

        b = FactoryGirl.build(:published_brand)
        b.update_status!("remove")
        expect(b.status).to match "removed"
      end
    end

    it "can_be_edited?" do
      # published brands should be editable
      b = FactoryGirl.create(:published_brand)
      expect(b.can_be_edited?).to be_truthy

      # unpublished brands should be editable
      b = FactoryGirl.create(:unpublished_brand)
      expect(b.can_be_edited?).to be_truthy

      # removed brands should not be editable
      b = FactoryGirl.create(:removed_brand)
      expect(b.can_be_edited?).to be_falsy
    end

    it "can_be_deleted?" do
      # removed brands without products should be deletable
      b = FactoryGirl.create(:removed_brand)
      expect(b.can_be_deleted?).to be_truthy

      # published brands should not be deletable
      b = FactoryGirl.create(:published_brand)
      expect(b.can_be_deleted?).to be_falsy

      # unpublished brands should not be deletable
      b = FactoryGirl.create(:unpublished_brand)
      expect(b.can_be_deleted?).to be_falsy
      
      # removed brands with products should not be deletable
      b = FactoryGirl.create(:removed_brand)
      p = FactoryGirl.create(:published_product, brand: b)
      expect(b.can_be_deleted?).to be_falsy
    end
  end

end