require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'associations' do
    it { should belong_to(:brand) }
    it { should belong_to(:category) }
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:carts).through(:cart_items) }
    it { should have_many(:promotions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
    it { should validate_presence_of(:brand_id) }
    it { should validate_presence_of(:category_id) }
  end

  describe 'enums' do
    it { should define_enum_for(:sale_type).with_values(by_weight: 0, by_quantity: 1) }
  end

  describe 'methods' do
    let(:item) { create(:item, sale_type: 'by_weight') }

    describe '#by_weight?' do
      it 'returns true for by_weight sale_type' do
        expect(item.by_weight?).to be true
      end

      it 'returns false for by_quantity sale_type' do
        item.update(sale_type: 'by_quantity')
        expect(item.by_weight?).to be false
      end
    end

    describe '#calculate_discounted_price' do
      let(:item) { create(:item, price: 100.0) }

      context 'without promotions' do
        it 'returns original price' do
          expect(item.calculate_discounted_price).to eq(100.0)
        end
      end

      context 'with percentage promotion' do
        let!(:promotion) { create(:promotion, promotionable: item, promotion_type: 'percentage', discount_value: 20) }

        it 'applies percentage discount' do
          expect(item.calculate_discounted_price).to eq(80.0)
        end
      end

      context 'with flat_fee promotion' do
        let!(:promotion) { create(:promotion, promotionable: item, promotion_type: 'flat_fee', discount_value: 30) }

        it 'applies flat fee discount' do
          expect(item.calculate_discounted_price).to eq(70.0)
        end
      end

      context 'with BOGO promotion' do
        let!(:promotion) { create(:promotion, promotionable: item, promotion_type: 'bogo', buy_quantity: 2, get_quantity: 1, get_discount_percentage: 100) }

        it 'applies BOGO discount for quantity >= buy_quantity' do
          expect(item.calculate_discounted_price(2)).to eq(50.0) # 2 items, 1 free
        end

        it 'returns original price for quantity < buy_quantity' do
          expect(item.calculate_discounted_price(1)).to eq(100.0)
        end
      end

      context 'with weight_threshold promotion' do
        let(:item) { create(:item, sale_type: 'by_weight', price: 100.0) }
        let!(:promotion) { create(:promotion, promotionable: item, promotion_type: 'weight_threshold', weight_threshold: 5.0, weight_discount_percentage: 25) }

        it 'applies weight discount for weight >= threshold' do
          expect(item.calculate_discounted_price(5.0)).to eq(75.0)
        end

        it 'returns original price for weight < threshold' do
          expect(item.calculate_discounted_price(3.0)).to eq(100.0)
        end

        it 'returns original price for by_quantity items' do
          item.update(sale_type: 'by_quantity')
          expect(item.calculate_discounted_price(5.0)).to eq(100.0)
        end
      end
    end
  end
end
