require 'spec_helper'

RSpec.describe Supplier, type: :model do

  let(:india) {FactoryGirl.create(:country, name: "India", code: "IND")}
  let(:oman) {FactoryGirl.create(:country, name: "Oman", code: "OMN")}
  let(:china) {FactoryGirl.create(:country, name: "China", code: "CHN")}

  let(:mtrpkl) {FactoryGirl.create(:supplier, name: "MTR Pickles", code: "MTRPKL", address: "Kodambakam", city: "Chennai", country: india)}
  let(:ptofri) {FactoryGirl.create(:supplier, name: "Potato Fries", code: "PTOFRI", address: "Madeena Circle", city: "Muscat", country: oman)}
  let(:andphn) {FactoryGirl.create(:supplier, name: "Android Phone", code: "ANDPHN", address: "Xiaping", city: "JunChen", country: china)}

  context "Factory" do
    it "should validate all the factories" do
      expect(FactoryGirl.build(:supplier, country: india).valid?).to be true
    end
  end

  context "Validations" do
    it { should validate_presence_of :name }
    it { should allow_value('ABC Food Products LTD').for(:name )}
    it { should allow_value('AB').for(:name )}
    it { should_not allow_value("X").for(:name )}
    it { should_not allow_value("x"*251).for(:name )}

    it { should validate_presence_of :code }
    it { should allow_value('AB').for(:code )}
    it { should_not allow_value("X").for(:code )}
    it { should_not allow_value("x"*25).for(:code )}

    it { should_not validate_presence_of :address }
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
    it { should belong_to(:country) }
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