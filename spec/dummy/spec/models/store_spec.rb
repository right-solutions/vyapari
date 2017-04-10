require 'spec_helper'

RSpec.describe Supplier, type: :model do

  let(:india) {FactoryGirl.create(:country, name: "India", code: "IND")}
  let(:kerala) {FactoryGirl.create(:region, name: "Kerala", code: "KER", country: ind)}
  
  let(:comiccon) {FactoryGirl.create(:store, name: "Comic Con", code: "STRCCN", region: kerala, country: india)}
  let(:gitex) {FactoryGirl.create(:store, name: "Gitex", code: "STRGTX", region: kerala, country: india)}
  let(:airshow) {FactoryGirl.create(:store, name: "Air Show", code: "STRAIR", region: kerala, country: india)}

  context "Factory" do
    it "should validate all the factories" do
      expect(FactoryGirl.build(:store, region: kerala, country: india).valid?).to be true
      expect(FactoryGirl.build(:active_pos_store, country: india, region: kerala)
      expect(FactoryGirl.build(:inactive_pos_store, country: india, region: kerala)
      expect(FactoryGirl.build(:closed_pos_store, country: india, region: kerala)
      expect(FactoryGirl.build(:active_warehouse, country: india, region: kerala)
      expect(FactoryGirl.build(:inactive_warehouse, country: india, region: kerala)
      expect(FactoryGirl.build(:closed_warehouse, country: india, region: kerala)
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

    it { should_not validate_presence_of :store_type }
    it { should allow_value("#Building No, Street No").for(:address )}
    it { should_not allow_value("ABCDE").for(:address )}
    it { should_not allow_value("x"*1025).for(:address )}

    it { should_not validate_presence_of :city }
    it { should allow_value("City").for(:city )}
    it { should_not allow_value("X").for(:city )}
    it { should_not allow_value("x"*57).for(:city )}

    it { should validate_presence_of :country }
  end

  context "Associations" do
    it { should belong_to(:region) }
    it { should belong_to(:country) }
    it { should have_many(:terminals)
    it { should have_many(:stock_entries)
    it { should have_many(:stock_bundles)
    it { should have_many(:products).through(:stock_entries) }
  end

  context "Class Methods" do
    it "search" do
      # Search Supplier Name
      expect(Supplier.search("MTR Pickles")).to match_array([mtrpkl])
      expect(Supplier.search("Potato Fries")).to match_array([ptofri])
      expect(Supplier.search("Android Phone")).to match_array([andphn])

      # Search Supplier Code
      expect(Supplier.search("MTRPKL")).to match_array([mtrpkl])
      expect(Supplier.search("PTOFRI")).to match_array([ptofri])
      expect(Supplier.search("ANDPHN")).to match_array([andphn])

      # Search Address
      expect(Supplier.search("Kodambakam")).to match_array([mtrpkl])
      expect(Supplier.search("Madeena Circle")).to match_array([ptofri])
      expect(Supplier.search("Xiaping")).to match_array([andphn])

      # Search City
      expect(Supplier.search("Chennai")).to match_array([mtrpkl])
      expect(Supplier.search("Muscat")).to match_array([ptofri])
      expect(Supplier.search("JunChen")).to match_array([andphn])

      # Search City
      expect(Supplier.search("India")).to match_array([mtrpkl])
      expect(Supplier.search("Oman")).to match_array([ptofri])
      expect(Supplier.search("China")).to match_array([andphn])
    end

    context "Import Methods" do

      it "save_row_data" do
        skip
      end

    end
    
  end

  context "Instance Methods" do

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