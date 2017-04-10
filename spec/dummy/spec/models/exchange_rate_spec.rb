require 'spec_helper'

RSpec.describe ExchangeRate, type: :model do

  let(:usd_aed) {FactoryGirl.create(:exchange_rate, base_currency: "USD", counter_currency: "AED", value: 3.65)}
  let(:usd_inr) {FactoryGirl.create(:exchange_rate, base_currency: "USD", counter_currency: "INR", value: 65.25)}
  let(:aed_inr) {FactoryGirl.create(:exchange_rate, base_currency: "AED", counter_currency: "INR", value: 18.02)}
  
  context "Factory" do
    it "should validate all the factories" do
      expect(FactoryGirl.build(:exchange_rate).valid?).to be true
    end
  end

  context "Validations" do
    it { should validate_presence_of :base_currency }
    it { should allow_value('USD').for(:base_currency )}
    it { should_not allow_value('A').for(:base_currency )}
    it { should_not allow_value("x"*7).for(:base_currency )}

    it { should validate_presence_of :counter_currency }
    it { should allow_value('AED').for(:counter_currency )}
    it { should_not allow_value('A').for(:counter_currency )}
    it { should_not allow_value("x"*7).for(:counter_currency )}

    it { should validate_presence_of :value }
    it { should validate_numericality_of :value }

    it { should validate_presence_of :effective_date }
  end

  context "Class Methods" do
    it "search" do
      [usd_aed, usd_inr, aed_inr]
      expect(ExchangeRate.search("USD")).to match_array([usd_aed, usd_inr])
      expect(ExchangeRate.search("AED")).to match_array([usd_aed, aed_inr])
      expect(ExchangeRate.search("INR")).to match_array([usd_inr, aed_inr])
    end

    context "Import Methods" do

      it "save_row_data" do
        skip
      end

    end
    
  end

  context "Instance Methods" do

    it "display_name" do
      expect(usd_aed.display_name).to match("USD to AED")
    end

    it "can_be_edited?" do
      skip
    end

    it "can_be_deleted?" do
      skip
    end

  end

end