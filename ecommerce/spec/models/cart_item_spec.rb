require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'associations' do
    it { should belong_to(:cart) }
    it { should belong_to(:item) }
    it { should belong_to(:promotion).optional }
  end

  describe 'validations' do
    subject { build(:cart_item) }
    
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_presence_of(:final_price) }
    it { should validate_numericality_of(:final_price).is_greater_than_or_equal_to(0) }
    
    describe 'uniqueness validations' do
      let(:cart) { create(:cart) }
      let(:item) { create(:item) }
      subject { build(:cart_item, cart: cart, item: item) }
      
      it { should validate_uniqueness_of(:item_id).scoped_to(:cart_id).ignoring_case_sensitivity }
    end
  end

  describe 'methods' do
    let(:item) { create(:item, price: 100.0) }
    let(:cart_item) { create(:cart_item, item: item, quantity: 3) }

    describe '#subtotal' do
      it 'calculates subtotal correctly' do
        expect(cart_item.subtotal).to eq(300.0)
      end
    end

    describe '#weight' do
      context 'when item is by_weight' do
        let(:item) { create(:item, sale_type: 'by_weight') }
        
        it 'returns quantity as weight' do
          expect(cart_item.weight).to eq(3)
        end
      end

      context 'when item is by_quantity' do
        let(:item) { create(:item, sale_type: 'by_quantity') }
        
        it 'returns 0' do
          expect(cart_item.weight).to eq(0)
        end
      end
    end

    describe '#calculate_final_price' do
      context 'without promotion' do
        it 'returns subtotal' do
          expect(cart_item.calculate_final_price).to eq(300.0)
        end
      end

      context 'with percentage promotion' do
        let(:promotion) { create(:promotion, promotion_type: 'percentage', discount_value: 20) }
        let(:cart_item) { create(:cart_item, item: item, quantity: 3, promotion: promotion) }

        it 'applies percentage discount' do
          expect(cart_item.calculate_final_price).to eq(240.0)
        end
      end

      context 'with flat_fee promotion' do
        let(:promotion) { create(:promotion, promotion_type: 'flat_fee', discount_value: 50) }
        let(:cart_item) { create(:cart_item, item: item, quantity: 3, promotion: promotion) }

        it 'applies flat fee discount' do
          expect(cart_item.calculate_final_price).to eq(250.0)
        end
      end

      context 'with BOGO promotion' do
        let(:item) { create(:item, price: 100.0) }
        let(:promotion) { create(:promotion, promotion_type: 'bogo', buy_quantity: 2, get_quantity: 1, get_discount_percentage: 100) }
        let(:cart_item) { create(:cart_item, item: item, quantity: 4, promotion: promotion) }

        it 'applies BOGO discount correctly' do
          # 4 items, 2 sets of BOGO (buy 2 get 1 free), so 2 free items
          # Original: 4 * 100 = 400, Discount: 2 * 100 = 200, Final: 200
          expect(cart_item.calculate_final_price).to eq(200.0)
        end
      end

      context 'with weight_threshold promotion' do
        let(:item) { create(:item, sale_type: 'by_weight', price: 10.0) }
        let(:promotion) { create(:promotion, promotion_type: 'weight_threshold', weight_threshold: 5.0, weight_discount_percentage: 25) }
        let(:cart_item) { create(:cart_item, item: item, quantity: 6.0, promotion: promotion) }

        it 'applies weight threshold discount correctly' do
          # 6kg at 10/kg = 60, 25% discount = 15, Final: 45
          expect(cart_item.calculate_final_price).to eq(45.0)
        end
      end
    end

    describe '#recalculate_final_price!' do
      it 'updates final_price and saves' do
        cart_item.final_price = 999.0
        cart_item.recalculate_final_price!
        
        expect(cart_item.final_price).to eq(300.0)
        expect(cart_item).to be_persisted
      end
    end
  end
end
