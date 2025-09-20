require 'rails_helper'

RSpec.describe SortingService, type: :service do
  describe 'Brand context' do
    let!(:brand_with_3_items) { create(:brand, name: 'Test Brand C') }
    let!(:brand_with_1_item) { create(:brand, name: 'Test Brand A') }
    let!(:brand_with_5_items) { create(:brand, name: 'Test Brand B') }
    let!(:brand_with_no_items) { create(:brand, name: 'Test Brand D') }

    before do
      # Create items for brands to establish different product counts
      create_list(:item, 3, brand: brand_with_3_items)
      create(:item, brand: brand_with_1_item)
      create_list(:item, 5, brand: brand_with_5_items)
      # brand_with_no_items has no items
    end

    describe '#sorted_collection' do
      context 'when sorting by name ascending' do
        it 'returns brands sorted alphabetically A-Z' do
          service = SortingService.new(Brand, 'name_asc')
          result = service.sorted_collection
          test_brands = result.select { |brand| brand.name.start_with?('Test Brand') }

          expect(test_brands.map(&:name)).to eq(['Test Brand A', 'Test Brand B', 'Test Brand C', 'Test Brand D'])
        end
      end

      context 'when sorting by name descending' do
        it 'returns brands sorted alphabetically Z-A' do
          service = SortingService.new(Brand, 'name_desc')
          result = service.sorted_collection
          test_brands = result.select { |brand| brand.name.start_with?('Test Brand') }

          expect(test_brands.map(&:name)).to eq(['Test Brand D', 'Test Brand C', 'Test Brand B', 'Test Brand A'])
        end
      end

      context 'when sorting by products ascending (few to many)' do
        it 'returns brands sorted by product count ascending' do
          service = SortingService.new(Brand, 'products_asc')
          result = service.sorted_collection
          test_brands = result.select { |brand| brand.name.start_with?('Test Brand') }

          expect(test_brands.map(&:name)).to eq(['Test Brand D', 'Test Brand A', 'Test Brand C', 'Test Brand B'])
          expect(test_brands.map { |brand| brand.items.count }).to eq([0, 1, 3, 5])
        end
      end

      context 'when sorting by products descending (many to few)' do
        it 'returns brands sorted by product count descending' do
          service = SortingService.new(Brand, 'products_desc')
          result = service.sorted_collection
          test_brands = result.select { |brand| brand.name.start_with?('Test Brand') }

          expect(test_brands.map(&:name)).to eq(['Test Brand B', 'Test Brand C', 'Test Brand A', 'Test Brand D'])
          expect(test_brands.map { |brand| brand.items.count }).to eq([5, 3, 1, 0])
        end
      end

      context 'when no sort option is provided' do
        it 'defaults to name ascending' do
          service = SortingService.new(Brand)
          result = service.sorted_collection
          test_brands = result.select { |brand| brand.name.start_with?('Test Brand') }

          expect(test_brands.map(&:name)).to eq(['Test Brand A', 'Test Brand B', 'Test Brand C', 'Test Brand D'])
        end
      end

      context 'when invalid sort option is provided' do
        it 'defaults to name ascending' do
          service = SortingService.new(Brand, 'invalid_sort')
          result = service.sorted_collection
          test_brands = result.select { |brand| brand.name.start_with?('Test Brand') }

          expect(test_brands.map(&:name)).to eq(['Test Brand A', 'Test Brand B', 'Test Brand C', 'Test Brand D'])
        end
      end
    end
  end

  describe 'Category context' do
    let!(:category_with_2_items) { create(:category, name: 'Test Category C') }
    let!(:category_with_4_items) { create(:category, name: 'Test Category A') }
    let!(:category_with_1_item) { create(:category, name: 'Test Category B') }
    let!(:category_with_no_items) { create(:category, name: 'Test Category D') }

    before do
      # Create items for categories to establish different product counts
      create_list(:item, 2, category: category_with_2_items)
      create_list(:item, 4, category: category_with_4_items)
      create(:item, category: category_with_1_item)
    end

    describe '#sorted_collection' do
      context 'when sorting by name ascending' do
        it 'returns categories sorted alphabetically A-Z' do
          service = SortingService.new(Category, 'name_asc')
          result = service.sorted_collection
          test_categories = result.select { |category| category.name.start_with?('Test Category') }

          expect(test_categories.map(&:name)).to eq(['Test Category A', 'Test Category B', 'Test Category C', 'Test Category D'])
        end
      end

      context 'when sorting by name descending' do
        it 'returns categories sorted alphabetically Z-A' do
          service = SortingService.new(Category, 'name_desc')
          result = service.sorted_collection
          test_categories = result.select { |category| category.name.start_with?('Test Category') }

          expect(test_categories.map(&:name)).to eq(['Test Category D', 'Test Category C', 'Test Category B', 'Test Category A'])
        end
      end

      context 'when sorting by products ascending (few to many)' do
        it 'returns categories sorted by product count ascending' do
          service = SortingService.new(Category, 'products_asc')
          result = service.sorted_collection
          test_categories = result.select { |category| category.name.start_with?('Test Category') }

          expect(test_categories.map(&:name)).to eq(['Test Category D', 'Test Category B', 'Test Category C', 'Test Category A'])
          expect(test_categories.map { |category| category.items.count }).to eq([0, 1, 2, 4])
        end
      end

      context 'when sorting by products descending (many to few)' do
        it 'returns categories sorted by product count descending' do
          service = SortingService.new(Category, 'products_desc')
          result = service.sorted_collection
          test_categories = result.select { |category| category.name.start_with?('Test Category') }

          expect(test_categories.map(&:name)).to eq(['Test Category A', 'Test Category C', 'Test Category B', 'Test Category D'])
          expect(test_categories.map { |category| category.items.count }).to eq([4, 2, 1, 0])
        end
      end

      context 'when no sort option is provided' do
        it 'defaults to name ascending' do
          service = SortingService.new(Category)
          result = service.sorted_collection
          test_categories = result.select { |category| category.name.start_with?('Test Category') }

          expect(test_categories.map(&:name)).to eq(['Test Category A', 'Test Category B', 'Test Category C', 'Test Category D'])
        end
      end

      context 'when invalid sort option is provided' do
        it 'defaults to name ascending' do
          service = SortingService.new(Category, 'invalid_sort')
          result = service.sorted_collection
          test_categories = result.select { |category| category.name.start_with?('Test Category') }

          expect(test_categories.map(&:name)).to eq(['Test Category A', 'Test Category B', 'Test Category C', 'Test Category D'])
        end
      end
    end
  end

  describe 'Edge cases' do
    context 'when model has no test records' do
      it 'returns empty collection for name sorting when no test brands exist' do
        service = SortingService.new(Brand, 'name_asc')
        result = service.sorted_collection
        test_brands = result.select { |brand| brand.name.start_with?('Test Brand') }

        expect(test_brands).to be_empty
      end

      it 'returns empty array for product count sorting when no test brands exist' do
        service = SortingService.new(Brand, 'products_asc')
        result = service.sorted_collection
        test_brands = result.select { |brand| brand.name.start_with?('Test Brand') }

        expect(test_brands).to be_empty
      end
    end

    context 'when model has records but no items' do
      let!(:brand_without_items) { create(:brand, name: 'Test Brand Without Items') }

      it 'handles zero item counts correctly for product sorting' do
        service = SortingService.new(Brand, 'products_asc')
        result = service.sorted_collection
        test_brands = result.select { |brand| brand.name.start_with?('Test Brand') }

        expect(test_brands.map(&:name)).to eq(['Test Brand Without Items'])
        expect(test_brands.first.items.count).to eq(0)
      end
    end

    context 'when sorting with ties in product count' do
      let!(:brand1) { create(:brand, name: 'Test Brand A') }
      let!(:brand2) { create(:brand, name: 'Test Brand B') }

      before do
        create(:item, brand: brand1)
        create(:item, brand: brand2)
      end

      it 'maintains consistent ordering for tied product counts' do
        service = SortingService.new(Brand, 'products_asc')
        result = service.sorted_collection
        test_brands = result.select { |brand| brand.name.start_with?('Test Brand') }

        expect(test_brands.map(&:name)).to eq(['Test Brand A', 'Test Brand B'])
        expect(test_brands.map { |brand| brand.items.count }).to eq([1, 1])
      end
    end
  end
end
