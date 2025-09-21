require 'rails_helper'

# NOTE: The FeaturedItemsService finds items that have active promotions through:
# 1. Direct item promotions (items with their own promotions)
# 2. Brand promotions (items from brands that have active promotions)
# 3. Category promotions (items from categories that have active promotions)
# The service correctly returns items that qualify through ANY of these paths

RSpec.describe FeaturedItemsService, type: :service do
  let(:service) { described_class.new(limit: 4) }
  let!(:brand) { create(:brand) }
  let!(:category) { create(:category) }

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
      let!(:item_from_brand) { create(:item, brand: brand, category: category, name: 'Item from Brand with Promotion') }

      it 'includes items from brands with active promotions' do
        # Ensure the brand has the promotion
        expect(brand.promotions).to include(brand_promotion)
        # Ensure the item belongs to the brand
        expect(item_from_brand.brand).to eq(brand)
        
        # Test the individual method
        brand_item_ids = service.send(:items_from_brands_with_promotions)
        expect(brand_item_ids).to include(item_from_brand.id)
        
        # Test the full service
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
      let!(:item_from_category) { create(:item, brand: brand, category: category, name: 'Item from Category with Promotion') }

      it 'includes items from categories with active promotions' do
        # Ensure the category has the promotion
        expect(category.promotions).to include(category_promotion)
        # Ensure the item belongs to the category
        expect(item_from_category.category).to eq(category)
        
        # Test the individual method
        category_item_ids = service.send(:items_from_categories_with_promotions)
        expect(category_item_ids).to include(item_from_category.id)
        
        # Test the full service
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
          item = create(:item, name: "Item #{i}", brand: brand, category: category)
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

    context 'when items have both brand and category promotions' do
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
      let!(:item_with_both) { create(:item, brand: brand, category: category, name: 'Item with Both Promotions') }

      it 'includes the item only once (deduplication)' do
        result = service.call
        expect(result).to include(item_with_both)
        
        # The item should appear only once even though it has both brand and category promotions
        item_count = result.select { |item| item.id == item_with_both.id }.count
        expect(item_count).to eq(1)
      end
    end

    context 'when items have expired promotions' do
      let!(:expired_brand_promotion) do
        create(:promotion,
               promotionable: brand,
               start_time: 2.days.ago,
               end_time: 1.day.ago)
      end
      let!(:item_with_expired_promotion) { create(:item, brand: brand, category: category, name: 'Item with Expired Promotion') }

      it 'excludes items with expired brand promotions' do
        result = service.call
        expect(result).not_to include(item_with_expired_promotion)
      end
    end

    context 'when items have future promotions' do
      let!(:future_category_promotion) do
        create(:promotion,
               promotionable: category,
               start_time: 1.day.from_now,
               end_time: 2.days.from_now)
      end
      let!(:item_with_future_promotion) { create(:item, brand: brand, category: category, name: 'Item with Future Promotion') }

      it 'excludes items with future category promotions' do
        result = service.call
        expect(result).not_to include(item_with_future_promotion)
      end
    end

    it 'includes necessary associations' do
      item = create(:item, brand: brand, category: category)
      create(:promotion,
             promotionable: item,
             start_time: 1.day.ago,
             end_time: 1.day.from_now)
      
      result = service.call
      expect(result.first.association(:promotions)).to be_loaded
      expect(result.first.association(:brand)).to be_loaded
      expect(result.first.association(:category)).to be_loaded
    end

    context 'verifying promotion eligibility logic' do
      it 'correctly identifies items eligible through brand promotions' do
        # Create a brand promotion
        brand_promotion = create(:promotion,
               promotionable: brand,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
        
        # Create an item from that brand (no direct promotion)
        item_from_brand = create(:item, brand: brand, category: category, name: 'Item from Brand')
        
        result = service.call
        
        # The item should be included because it's from a brand with active promotion
        expect(result).to include(item_from_brand)
        
        # But the item itself doesn't have direct promotions
        expect(item_from_brand.promotions.active).to be_empty
        
        # However, it's eligible through brand promotion
        expect(brand.promotions.active).to include(brand_promotion)
      end

      it 'correctly identifies items eligible through category promotions' do
        # Create a category promotion
        category_promotion = create(:promotion,
               promotionable: category,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
        
        # Create an item from that category (no direct promotion)
        item_from_category = create(:item, brand: brand, category: category, name: 'Item from Category')
        
        result = service.call
        
        # The item should be included because it's from a category with active promotion
        expect(result).to include(item_from_category)
        
        # But the item itself doesn't have direct promotions
        expect(item_from_category.promotions.active).to be_empty
        
        # However, it's eligible through category promotion
        expect(category.promotions.active).to include(category_promotion)
      end
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
        promotion = create(:promotion,
               promotionable: brand,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
        item = create(:item, brand: brand, category: category)
        
        # Debug: Check associations
        expect(brand.promotions).to include(promotion)
        expect(item.brand).to eq(brand)
        
        # Test the method directly
        result = service.send(:items_from_brands_with_promotions)
        expect(result).to include(item.id)
      end
    end

    describe '#items_from_categories_with_promotions' do
      it 'returns items from categories with active promotions' do
        promotion = create(:promotion,
               promotionable: category,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
        item = create(:item, brand: brand, category: category)
        
        # Debug: Check associations
        expect(category.promotions).to include(promotion)
        expect(item.category).to eq(category)
        
        # Test the method directly
        result = service.send(:items_from_categories_with_promotions)
        expect(result).to include(item.id)
      end
    end
  end
end
