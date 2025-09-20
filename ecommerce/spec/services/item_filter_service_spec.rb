require 'rails_helper'

RSpec.describe ItemFilterService, type: :service do
  let!(:category1) { create(:category, name: 'Test Category Electronics') }
  let!(:category2) { create(:category, name: 'Test Category Clothing') }
  let!(:brand1) { create(:brand, name: 'Test Brand Apple') }
  let!(:brand2) { create(:brand, name: 'Test Brand Sony') }
  
  let!(:item1) { create(:item, name: 'Test Item iPhone', price: 999.99, category: category1, brand: brand1) }
  let!(:item2) { create(:item, name: 'Test Item Sony Headphones', price: 299.99, category: category1, brand: brand2) }
  let!(:item3) { create(:item, name: 'Test Item T-Shirt', price: 29.99, category: category2, brand: brand1) }
  let!(:item4) { create(:item, name: 'Test Item Laptop', price: 1299.99, category: category1, brand: brand1) }

  describe '#call' do
    context 'when no filters are applied' do
      it 'returns all items ordered by name' do
        service = ItemFilterService.new({})
        result = service.call

        expect(result.map(&:name)).to eq(['Test Item Laptop', 'Test Item Sony Headphones', 'Test Item T-Shirt', 'Test Item iPhone'])
      end
    end

    context 'when filtering by category' do
      it 'returns only items from the specified category' do
        service = ItemFilterService.new({ category_id: category1.id })
        result = service.call

        expect(result.map(&:name)).to eq(['Test Item Laptop', 'Test Item Sony Headphones', 'Test Item iPhone'])
        expect(result.all? { |item| item.category == category1 }).to be true
      end
    end

    context 'when filtering by brand' do
      it 'returns only items from the specified brand' do
        service = ItemFilterService.new({ brand_id: brand1.id })
        result = service.call

        expect(result.map(&:name)).to eq(['Test Item Laptop', 'Test Item T-Shirt', 'Test Item iPhone'])
        expect(result.all? { |item| item.brand == brand1 }).to be true
      end
    end

    context 'when filtering by both category and brand' do
      it 'returns items matching both filters' do
        service = ItemFilterService.new({ category_id: category1.id, brand_id: brand1.id })
        result = service.call

        expect(result.map(&:name)).to eq(['Test Item Laptop', 'Test Item iPhone'])
        expect(result.all? { |item| item.category == category1 && item.brand == brand1 }).to be true
      end
    end

    context 'when sorting by price ascending' do
      it 'returns items ordered by price low to high' do
        service = ItemFilterService.new({ sort: 'price_asc' })
        result = service.call

        expect(result.map(&:price)).to eq([29.99, 299.99, 999.99, 1299.99])
      end
    end

    context 'when sorting by price descending' do
      it 'returns items ordered by price high to low' do
        service = ItemFilterService.new({ sort: 'price_desc' })
        result = service.call

        expect(result.map(&:price)).to eq([1299.99, 999.99, 299.99, 29.99])
      end
    end

    context 'when sorting by category' do
      it 'returns items ordered by category name' do
        service = ItemFilterService.new({ sort: 'category' })
        result = service.call

        expect(result.map(&:category).map(&:name)).to eq(['Test Category Clothing', 'Test Category Electronics', 'Test Category Electronics', 'Test Category Electronics'])
      end
    end

    context 'when sorting by brand' do
      it 'returns items ordered by brand name' do
        service = ItemFilterService.new({ sort: 'brand' })
        result = service.call

        expect(result.map(&:brand).map(&:name)).to eq(['Test Brand Apple', 'Test Brand Apple', 'Test Brand Apple', 'Test Brand Sony'])
      end
    end

    context 'when combining filters and sorting' do
      it 'applies filters first, then sorting' do
        service = ItemFilterService.new({ 
          category_id: category1.id, 
          sort: 'price_asc' 
        })
        result = service.call

        expect(result.map(&:name)).to eq(['Test Item Sony Headphones', 'Test Item iPhone', 'Test Item Laptop'])
        expect(result.all? { |item| item.category == category1 }).to be true
      end
    end

    context 'when pagination is applied' do
      it 'returns paginated results' do
        service = ItemFilterService.new({ page: 1 })
        result = service.call

        expect(result).to respond_to(:current_page)
        expect(result).to respond_to(:per)
      end
    end
  end
end
