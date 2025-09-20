require 'rails_helper'

RSpec.describe FeaturedItemsService, type: :service do
  let(:service) { described_class.new(limit: 4) }
  let(:brand) { create(:brand) }
  let(:category) { create(:category) }

  describe '#call' do
    context 'when no items have promotions' do
      it 'returns empty collection' do
        result = service.call
        expect(result).to be_empty
      end
    end

    context 'when items have direct promotions' do
      let!(:item_with_promotion) { create(:item, name: 'Item with Direct Promotion') }
      let!(:active_promotion) do
        create(:promotion,
               promotionable: item_with_promotion,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
      end

      it 'includes items with direct promotions' do
        result = service.call
        expect(result).to include(item_with_promotion)
      end
    end

    context 'when items have brand promotions' do
      let!(:brand_promotion) do
        create(:promotion,
               promotionable: brand,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
      end
      let!(:item_from_brand) { create(:item, brand: brand, name: 'Item from Brand with Promotion') }

      it 'includes items from brands with active promotions' do
        result = service.call
        expect(result).to include(item_from_brand)
      end
    end

    context 'when items have category promotions' do
      let!(:category_promotion) do
        create(:promotion,
               promotionable: category,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
      end
      let!(:item_from_category) { create(:item, category: category, name: 'Item from Category with Promotion') }

      it 'includes items from categories with active promotions' do
        result = service.call
        expect(result).to include(item_from_category)
      end
    end

    context 'when items have multiple types of promotions' do
      let!(:item_with_multiple_promotions) { create(:item, brand: brand, category: category, name: 'Item with Multiple Promotions') }
      let!(:direct_promotion) do
        create(:promotion,
               promotionable: item_with_multiple_promotions,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
      end
      let!(:brand_promotion) do
        create(:promotion,
               promotionable: brand,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
      end
      let!(:category_promotion) do
        create(:promotion,
               promotionable: category,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
      end

      it 'includes items with multiple promotion types' do
        result = service.call
        expect(result).to include(item_with_multiple_promotions)
      end

      it 'returns distinct items' do
        result = service.call
        expect(result.count).to eq(result.uniq.count)
      end
    end

    context 'when items have expired promotions' do
      let!(:item_with_expired_promotion) { create(:item, name: 'Item with Expired Promotion') }
      let!(:expired_promotion) do
        create(:promotion,
               promotionable: item_with_expired_promotion,
               start_time: 2.days.ago,
               end_time: 1.day.ago)
      end

      it 'excludes items with expired promotions' do
        result = service.call
        expect(result).not_to include(item_with_expired_promotion)
      end
    end

    context 'when items have future promotions' do
      let!(:item_with_future_promotion) { create(:item, name: 'Item with Future Promotion') }
      let!(:future_promotion) do
        create(:promotion,
               promotionable: item_with_future_promotion,
               start_time: 1.day.from_now,
               end_time: 2.days.from_now)
      end

      it 'excludes items with future promotions' do
        result = service.call
        expect(result).not_to include(item_with_future_promotion)
      end
    end

    context 'with custom limit' do
      let(:service_with_limit) { described_class.new(limit: 2) }
      
      before do
        # Create 3 items with active promotions
        3.times do |i|
          item = create(:item, name: "Item #{i}")
          create(:promotion,
                 promotionable: item,
                 start_time: 1.day.ago,
                 end_time: 1.day.from_now)
        end
      end

      it 'respects the custom limit' do
        result = service_with_limit.call
        expect(result.count).to eq(2)
      end
    end

    context 'when there are more items than limit' do
      before do
        # Create 6 items with active promotions
        6.times do |i|
          item = create(:item, name: "Item #{i}")
          create(:promotion,
                 promotionable: item,
                 start_time: 1.day.ago,
                 end_time: 1.day.from_now)
        end
      end

      it 'limits results to specified limit' do
        result = service.call
        expect(result.count).to eq(4)
      end
    end

    it 'includes necessary associations' do
      item = create(:item)
      create(:promotion,
             promotionable: item,
             start_time: 1.day.ago,
             end_time: 1.day.from_now)
      
      result = service.call
      expect(result.first.association(:promotions)).to be_loaded
      expect(result.first.association(:brand)).to be_loaded
      expect(result.first.association(:category)).to be_loaded
    end
  end

  describe 'private methods' do
    describe '#items_with_direct_promotions' do
      it 'returns items with direct active promotions' do
        item = create(:item)
        create(:promotion,
               promotionable: item,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
        
        result = service.send(:items_with_direct_promotions)
        expect(result).to include(item.id)
      end
    end

    describe '#items_from_brands_with_promotions' do
      it 'returns items from brands with active promotions' do
        create(:promotion,
               promotionable: brand,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
        item = create(:item, brand: brand)
        
        result = service.send(:items_from_brands_with_promotions)
        expect(result).to include(item.id)
      end
    end

    describe '#items_from_categories_with_promotions' do
      it 'returns items from categories with active promotions' do
        create(:promotion,
               promotionable: category,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
        item = create(:item, category: category)
        
        result = service.send(:items_from_categories_with_promotions)
        expect(result).to include(item.id)
      end
    end
  end
end
