require 'rails_helper'

RSpec.describe PromotionService, type: :service do
  let(:item) { create(:item, price: 100.0) }
  let(:cart_item) { create(:cart_item, item: item, quantity: 3) }
  let(:service) { described_class.new(cart_item) }

  describe '#calculate_final_price_for_promotion' do
    context 'without promotion' do
      it 'returns original price' do
        expect(service.calculate_final_price_for_promotion(nil)).to eq(300.0)
      end
    end

    context 'with percentage promotion' do
      let(:promotion) { create(:promotion, promotion_type: 'percentage', discount_value: 20) }

      it 'applies percentage discount' do
        expect(service.calculate_final_price_for_promotion(promotion)).to eq(240.0)
      end
    end

    context 'with flat_fee promotion' do
      let(:promotion) { create(:promotion, promotion_type: 'flat_fee', discount_value: 50) }

      it 'applies flat fee discount' do
        expect(service.calculate_final_price_for_promotion(promotion)).to eq(250.0)
      end
    end

    context 'with BOGO promotion' do
      let(:promotion) { create(:promotion, promotion_type: 'bogo', buy_quantity: 2, get_quantity: 1, get_discount_percentage: 100) }

      it 'applies BOGO discount correctly' do
        # 3 items, 1 set of BOGO (buy 2 get 1 free), so 1 free item
        # Original: 3 * 100 = 300, Discount: 1 * 100 = 100, Final: 200
        expect(service.calculate_final_price_for_promotion(promotion)).to eq(200.0)
      end
    end

    context 'with weight_threshold promotion' do
      let(:item) { create(:item, sale_type: 'by_weight', price: 10.0) }
      let(:cart_item) { create(:cart_item, item: item, quantity: 6.0) }
      let(:promotion) { create(:promotion, promotion_type: 'weight_threshold', weight_threshold: 5.0, weight_discount_percentage: 25) }

      it 'applies weight threshold discount correctly' do
        # 6kg at 10/kg = 60, 25% discount = 15, Final: 45
        expect(service.calculate_final_price_for_promotion(promotion)).to eq(45.0)
      end
    end
  end

  describe '#calculate_best_promotion' do
    context 'when no promotions exist' do
      it 'returns nil' do
        expect(service.calculate_best_promotion).to be_nil
      end
    end

    context 'when promotions exist' do
      let!(:percentage_promotion) { create(:promotion, promotionable: item, promotion_type: 'percentage', discount_value: 20) }
      let!(:flat_fee_promotion) { create(:promotion, promotionable: item, promotion_type: 'flat_fee', discount_value: 50) }

      it 'returns the best promotion result' do
        result = service.calculate_best_promotion
        expect(result).to be_a(Hash)
        expect(result[:promotion]).to be_a(Promotion)
        expect(result[:final_price]).to be_a(Numeric)
      end
    end
  end
end