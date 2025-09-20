require 'rails_helper'

RSpec.describe ItemSortingService, type: :service do
  let!(:category) { create(:category, name: 'Test Category A') }
  let!(:brand1) { create(:brand, name: 'Test Brand Apple') }
  let!(:brand2) { create(:brand, name: 'Test Brand Sony') }
  
  let!(:item1) { create(:item, name: 'Test Item AirPods', price: 249.99, category: category, brand: brand1) }
  let!(:item2) { create(:item, name: 'Test Item Sony Headphones', price: 329.99, category: category, brand: brand2) }
  let!(:item3) { create(:item, name: 'Test Item Bose Speakers', price: 199.99, category: category, brand: brand1) }
  
  let(:items_collection) { category.items }

  describe '#sorted_collection' do
    context 'when sorting by name ascending' do
      it 'returns items sorted alphabetically A-Z' do
        service = ItemSortingService.new(items_collection, 'name_asc')
        result = service.sorted_collection

        expect(result.map(&:name)).to eq(['Test Item AirPods', 'Test Item Bose Speakers', 'Test Item Sony Headphones'])
      end
    end

    context 'when sorting by name descending' do
      it 'returns items sorted alphabetically Z-A' do
        service = ItemSortingService.new(items_collection, 'name_desc')
        result = service.sorted_collection

        expect(result.map(&:name)).to eq(['Test Item Sony Headphones', 'Test Item Bose Speakers', 'Test Item AirPods'])
      end
    end

    context 'when sorting by price ascending' do
      it 'returns items sorted by price low to high' do
        service = ItemSortingService.new(items_collection, 'price_asc')
        result = service.sorted_collection

        expect(result.map(&:price)).to eq([199.99, 249.99, 329.99])
      end
    end

    context 'when sorting by price descending' do
      it 'returns items sorted by price high to low' do
        service = ItemSortingService.new(items_collection, 'price_desc')
        result = service.sorted_collection

        expect(result.map(&:price)).to eq([329.99, 249.99, 199.99])
      end
    end

    context 'when sorting by brand ascending' do
      it 'returns items sorted by brand name A-Z' do
        service = ItemSortingService.new(items_collection, 'brand_asc')
        result = service.sorted_collection

        expect(result.map(&:brand).map(&:name)).to eq(['Test Brand Apple', 'Test Brand Apple', 'Test Brand Sony'])
      end
    end

    context 'when sorting by brand descending' do
      it 'returns items sorted by brand name Z-A' do
        service = ItemSortingService.new(items_collection, 'brand_desc')
        result = service.sorted_collection

        expect(result.map(&:brand).map(&:name)).to eq(['Test Brand Sony', 'Test Brand Apple', 'Test Brand Apple'])
      end
    end

    context 'when no sort option is provided' do
      it 'defaults to name ascending' do
        service = ItemSortingService.new(items_collection)
        result = service.sorted_collection

        expect(result.map(&:name)).to eq(['Test Item AirPods', 'Test Item Bose Speakers', 'Test Item Sony Headphones'])
      end
    end

    context 'when invalid sort option is provided' do
      it 'defaults to name ascending' do
        service = ItemSortingService.new(items_collection, 'invalid_sort')
        result = service.sorted_collection

        expect(result.map(&:name)).to eq(['Test Item AirPods', 'Test Item Bose Speakers', 'Test Item Sony Headphones'])
      end
    end
  end

  describe 'edge cases' do
    context 'when collection is empty' do
      let(:empty_category) { create(:category, name: 'Test Category Empty') }
      let(:empty_collection) { empty_category.items }

      it 'returns empty collection for any sort option' do
        service = ItemSortingService.new(empty_collection, 'name_asc')
        result = service.sorted_collection

        expect(result).to be_empty
      end
    end

    context 'when items have same prices' do
      let!(:item_same_price1) { create(:item, name: 'Test Item A', price: 100.00, category: category, brand: brand1) }
      let!(:item_same_price2) { create(:item, name: 'Test Item B', price: 100.00, category: category, brand: brand2) }

      it 'maintains consistent ordering for price sorting with ties' do
        service = ItemSortingService.new(items_collection, 'price_asc')
        result = service.sorted_collection
        
        # Items with same price should maintain consistent ordering
        same_price_items = result.select { |item| item.price == 100.00 }
        expect(same_price_items.map(&:name)).to eq(['Test Item A', 'Test Item B'])
      end
    end
  end
end
