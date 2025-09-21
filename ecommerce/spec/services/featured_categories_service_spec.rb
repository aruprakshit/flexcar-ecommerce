require 'rails_helper'

RSpec.describe FeaturedCategoriesService do
  let(:service) { described_class.new(limit: 5) }

  describe '#call' do
    context 'when no categories have promotions' do
      let!(:category_without_promotion) { create(:category, name: 'Books') }

      it 'returns empty collection' do
        result = service.call
        expect(result).to be_empty
      end
    end

    context 'when categories have direct promotions' do
      let!(:category_with_direct_promotion) { create(:category, name: 'Electronics') }
      let!(:category_without_promotion) { create(:category, name: 'Books') }
      
      let!(:active_promotion) do
        create(:promotion,
               promotionable: category_with_direct_promotion,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
      end

      it 'includes categories with direct active promotions' do
        result = service.call
        
        expect(result).to include(category_with_direct_promotion)
        expect(result).not_to include(category_without_promotion)
      end

      it 'excludes categories with inactive promotions' do
        inactive_promotion = create(:promotion,
                                   promotionable: category_without_promotion,
                                   start_time: 2.days.ago,
                                   end_time: 1.day.ago)
        
        result = service.call
        
        expect(result).not_to include(category_without_promotion)
      end
    end

    context 'when categories have items with promotions' do
      let!(:category_with_items_promotion) { create(:category, name: 'Clothing') }
      let!(:category_without_promotion) { create(:category, name: 'Books') }
      
      let!(:item) { create(:item, category: category_with_items_promotion) }
      let!(:item_promotion) do
        create(:promotion,
               promotionable: item,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
      end

      it 'includes categories with items that have active promotions' do
        result = service.call
        
        expect(result).to include(category_with_items_promotion)
        expect(result).not_to include(category_without_promotion)
      end

      it 'excludes categories with items that have inactive promotions' do
        item_promotion.destroy
        
        inactive_item_promotion = create(:promotion,
                                        promotionable: item,
                                        start_time: 2.days.ago,
                                        end_time: 1.day.ago)
        
        result = service.call
        
        expect(result).not_to include(category_with_items_promotion)
      end
    end

    context 'when categories have both direct and item promotions' do
      let!(:category_with_both) { create(:category, name: 'Electronics') }
      let!(:item) { create(:item, category: category_with_both) }
      
      let!(:direct_promotion) do
        create(:promotion,
               promotionable: category_with_both,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
      end
      
      let!(:item_promotion) do
        create(:promotion,
               promotionable: item,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
      end

      it 'includes the category only once (removes duplicates)' do
        result = service.call
        
        expect(result).to include(category_with_both)
        expect(result.select { |cat| cat.id == category_with_both.id }.count).to eq(1)
      end
    end

    context 'when multiple categories have promotions' do
      let!(:category1) { create(:category, name: 'Electronics') }
      let!(:category2) { create(:category, name: 'Clothing') }
      let!(:category3) { create(:category, name: 'Books') }
      
      let!(:promotion1) do
        create(:promotion,
               promotionable: category1,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
      end
      
      let!(:item2) { create(:item, category: category2) }
      let!(:promotion2) do
        create(:promotion,
               promotionable: item2,
               start_time: 1.day.ago,
               end_time: 1.day.from_now)
      end

      it 'returns all categories with active promotions' do
        result = service.call
        
        expect(result).to include(category1, category2)
        expect(result).not_to include(category3)
      end
    end

    context 'limit functionality' do
      let!(:categories) { create_list(:category, 10) }
      
      before do
        categories.each_with_index do |category, index|
          create(:promotion,
                 promotionable: category,
                 start_time: 1.day.ago,
                 end_time: 1.day.from_now)
        end
      end

      it 'limits results to specified limit' do
        service_with_limit = described_class.new(limit: 3)
        result = service_with_limit.call
        
        expect(result.count).to eq(3)
      end

      it 'uses default limit when not specified' do
        service_default = described_class.new
        result = service_default.call
        
        expect(result.count).to eq(5) # default limit
      end
    end

    context 'edge cases' do
      it 'handles categories with no items' do
        category = create(:category, name: 'Empty Category')
        promotion = create(:promotion,
                           promotionable: category,
                           start_time: 1.day.ago,
                           end_time: 1.day.from_now)
        
        result = service.call
        
        expect(result).to include(category)
      end

      it 'handles categories with items but no item promotions' do
        category = create(:category, name: 'Category with Items')
        item = create(:item, category: category)
        promotion = create(:promotion,
                           promotionable: category,
                           start_time: 1.day.ago,
                           end_time: 1.day.from_now)
        
        result = service.call
        
        expect(result).to include(category)
      end

      it 'handles promotions with no end time (ongoing promotions)' do
        category = create(:category, name: 'Ongoing Promotion')
        promotion = create(:promotion,
                           promotionable: category,
                           start_time: 1.day.ago,
                           end_time: nil)
        
        result = service.call
        
        expect(result).to include(category)
      end
    end
  end
end
