require 'spec_helper'

RSpec.describe Store, type: :model do

  let(:india) {FactoryGirl.create(:country, name: "India", code: "IND")}
  let(:kerala) {FactoryGirl.create(:region, name: "Kerala", code: "KER", country: india)}
  
  let(:comiccon) {FactoryGirl.create(:active_pos_store, name: "Comic Con", code: "STRCCN", region: kerala, country: india)}
  let(:gitex) {FactoryGirl.create(:active_warehouse, name: "Gitex", code: "STRGTX", region: kerala, country: india)}
  let(:airshow) {FactoryGirl.create(:active_ecommerce_store, name: "Air Show", code: "STRAIR", region: kerala, country: india)}

  context "Factory" do
    it "should validate parent factory" do
      s = FactoryGirl.build(:store, region: kerala, country: india)
      expect(s).to be_valid
      expect(s.pos_store?).to be_truthy
    end

    it "should validate pos factories" do
      s = FactoryGirl.build(:active_pos_store, country: india, region: kerala)
      expect(s).to be_valid
      expect(s.pos_store?).to be_truthy
      expect(s.status).to match("active")
      
      s = FactoryGirl.build(:inactive_pos_store, country: india, region: kerala)
      expect(s).to be_valid
      expect(s.pos_store?).to be_truthy
      expect(s.status).to match("inactive")
      
      s = FactoryGirl.build(:closed_pos_store, country: india, region: kerala)
      expect(s).to be_valid
      expect(s.pos_store?).to be_truthy
      expect(s.status).to match("closed")
    end

    it "should validate warehouse factories" do
      s = FactoryGirl.build(:active_warehouse, country: india, region: kerala)
      expect(s).to be_valid
      expect(s.warehouse?).to be_truthy
      expect(s.status).to match("active")

      s = FactoryGirl.build(:inactive_warehouse, country: india, region: kerala)
      expect(s).to be_valid
      expect(s.warehouse?).to be_truthy
      expect(s.status).to match("inactive")

      s = FactoryGirl.build(:closed_warehouse, country: india, region: kerala)
      expect(s).to be_valid
      expect(s.warehouse?).to be_truthy
      expect(s.status).to match("closed")
    end

    it "should validate ecommerce store factories" do
      s = FactoryGirl.build(:active_ecommerce_store, country: india, region: kerala)
      expect(s).to be_valid
      expect(s.ecommerce_store?).to be_truthy
      expect(s.status).to match("active")

      s = FactoryGirl.build(:inactive_ecommerce_store, country: india, region: kerala)
      expect(s).to be_valid
      expect(s.ecommerce_store?).to be_truthy
      expect(s.status).to match("inactive")

      s = FactoryGirl.build(:closed_ecommerce_store, country: india, region: kerala)
      expect(s).to be_valid
      expect(s.ecommerce_store?).to be_truthy
      expect(s.status).to match("closed")
    end
  end

  context "Validations" do
    it { should validate_presence_of :name }
    it { should allow_value('Comic Con 2017, Dubai').for(:name )}
    it { should allow_value('ComicCon').for(:name )}
    it { should_not allow_value("X").for(:name )}
    it { should_not allow_value("x"*251).for(:name )}

    it { should validate_presence_of :code }
    it { should allow_value('CCDXB').for(:code )}
    it { should_not allow_value("X").for(:code )}
    it { should_not allow_value("x"*25).for(:code )}

    it { should validate_presence_of :store_type }
    it { should validate_inclusion_of(:store_type).in_array(Store::STORE_TYPES.keys)  }

    it { should validate_inclusion_of(:status).in_array(Store::STATUS.keys)  }
  end

  context "Associations" do
    it { should belong_to(:region) }
    it { should belong_to(:country) }
    it { should have_many(:terminals) }
    it { should have_many(:invoices) }
    it { should have_many(:stock_entries) }
    it { should have_many(:stock_bundles) }
    it { should have_many(:products).through(:stock_entries) }
  end

  context "Class Methods" do
    it "search" do
      
      [comiccon, gitex, airshow]

      # Search Store Name
      expect(Store.search("Comic Con")).to match_array([comiccon])

      # Search Store Code
      expect(Store.search("STRGTX")).to match_array([gitex])

      # Search Store Region
      expect(Store.search("Kerala")).to match_array([comiccon, gitex, airshow])

      # Search Store Country
      expect(Store.search("India")).to match_array([comiccon, gitex, airshow])

      # Search Store Type
      expect(Store.search("pos_store")).to match_array([comiccon])
      expect(Store.search("warehouse")).to match_array([gitex])
      expect(Store.search("ecommerce_store")).to match_array([airshow])
    end

    context "Import Methods" do

      it "save_row_data" do
        skip
      end

    end
    
  end

  context "Instance Methods" do
  
    context "Other Methods" do

      it "display_name" do
        mtrpkl.name = "Changed"
        expect(mtrpkl.display_name).to match("MTR Pickles")
      end

      it "can_be_edited?" do
        skip
      end

      it "can_be_deleted?" do
        skip
      end
      
    end

  end

end