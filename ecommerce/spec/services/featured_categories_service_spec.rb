require 'rails_helper'

RSpec.describe FeaturedCategoriesService do
  let(:service) { described_class.new(limit: 5) }

  describe '#call' do
    let!(:category_with_direct_promotion) { create(:category, name: 'Electronics') }
    let!(:category_with_items_promotion) { create(:category, name: 'Clothing') }
    let!(:category_without_promotion) { create(:category, name: 'Books') }
    
    let!(:active_promotion) do
      create(:promotion,
             promotionable: category_with_direct_promotion,
             start_time: 1.day.ago,
             end_time: 1.day.from_now)
    end
    
    let!(:item) { create(:item, category: category_with_items_promotion) }
    let!(:item_promotion) do
      create(:promotion,
             promotionable: item,
             start_time: 1.day.ago,
             end_time: 1.day.from_now)
    end
    
    let!(:inactive_promotion) do
      create(:promotion,
             promotionable: category_without_promotion,
             start_time: 1.day.ago,
             end_time: 1.day.ago)
    end

    it 'returns categories with active promotions' do
      result = service.call
      
      expect(result).to include(category_with_direct_promotion)
      expect(result).to include(category_with_items_promotion)
      expect(result).not_to include(category_without_promotion)
    end

    it 'limits results to specified limit' do
      service_with_limit = described_class.new(limit: 2)
      result = service_with_limit.call
      
      expect(result.count).to eq(2)
    end

    it 'includes promotions for eager loading' do
      result = service.call
      
      expect(result.first.association(:promotions)).to be_loaded
    end
  end
end
