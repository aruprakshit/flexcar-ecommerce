require 'rails_helper'

RSpec.describe PromotionService, type: :service do
  let(:brand) { create(:brand) }
  let(:category) { create(:category) }
  let(:item) { create(:item, brand: brand, category: category, price: 100.0) }
  let(:cart_item) { create(:cart_item, item: item, quantity: 2) }
  let(:service) { described_class.new(cart_item) }

  describe '#initialize' do
    it 'sets the cart_item, item, and quantity' do
      expect(service.instance_variable_get(:@cart_item)).to eq(cart_item)
      expect(service.instance_variable_get(:@item)).to eq(item)
      expect(service.instance_variable_get(:@quantity)).to eq(2)
    end
  end

  describe '#calculate_best_promotion' do
    context 'when no applicable promotions exist' do
      it 'returns nil' do
        result = service.calculate_best_promotion
        expect(result).to be_nil
      end
    end

    context 'when applicable promotions exist' do
      let!(:promotion) { create(:promotion, :percentage, promotionable: item, discount_value: 10) }

      it 'returns the best promotion result' do
        result = service.calculate_best_promotion
        expect(result).to be_a(Hash)
        expect(result[:promotion]).to eq(promotion)
        expect(result[:original_price]).to eq(200.0) # 100 * 2
        expect(result[:discount_amount]).to eq(20.0) # 10% of 200
        expect(result[:final_price]).to eq(180.0) # 200 - 20
      end
    end
  end

  describe 'promotion type calculations' do
    context 'flat_fee promotion' do
      let!(:promotion) { create(:promotion, :flat_fee, promotionable: item, discount_value: 25) }

      it 'calculates correct discount amount' do
        result = service.calculate_best_promotion
        expect(result[:discount_amount]).to eq(25.0)
        expect(result[:final_price]).to eq(175.0) # 200 - 25
      end
    end

    context 'percentage promotion' do
      let!(:promotion) { create(:promotion, :percentage, promotionable: item, discount_value: 15) }

      it 'calculates correct discount amount' do
        result = service.calculate_best_promotion
        expect(result[:discount_amount]).to eq(30.0) # 15% of 200
        expect(result[:final_price]).to eq(170.0) # 200 - 30
      end
    end

    context 'BOGO promotion' do
      let!(:promotion) { create(:promotion, :bogo, promotionable: item, buy_quantity: 2, get_quantity: 1, get_discount_percentage: 100) }

      it 'calculates correct BOGO discount for exact quantity' do
        result = service.calculate_best_promotion
        # Buy 2, get 1 free (100% off)
        expect(result[:discount_amount]).to eq(100.0) # 1 free item
        expect(result[:final_price]).to eq(100.0) # 200 - 100
      end

      context 'with higher quantity' do
        let(:cart_item) { create(:cart_item, item: item, quantity: 5) }

        it 'calculates correct BOGO discount for multiple sets' do
          result = service.calculate_best_promotion
          # Buy 2, get 1 free - 2 sets = 2 free items
          expect(result[:discount_amount]).to eq(200.0) # 2 free items
          expect(result[:final_price]).to eq(300.0) # 500 - 200
        end
      end

      context 'with partial discount' do
        let!(:promotion) { create(:promotion, :bogo, promotionable: item, buy_quantity: 2, get_quantity: 1, get_discount_percentage: 50) }

        it 'calculates correct partial BOGO discount' do
          result = service.calculate_best_promotion
          # Buy 2, get 1 at 50% off
          expect(result[:discount_amount]).to eq(50.0) # 1 item at 50% off
          expect(result[:final_price]).to eq(150.0) # 200 - 50
        end
      end
    end

    context 'weight_threshold promotion' do
      let(:item) { create(:item, :by_weight, brand: brand, category: category, price: 5.0) }
      let(:cart_item) { create(:cart_item, item: item, quantity: 10.0) }
      let!(:promotion) { create(:promotion, :weight_threshold, promotionable: item, weight_threshold: 5.0, weight_discount_percentage: 20) }

      it 'calculates correct weight threshold discount' do
        result = service.calculate_best_promotion
        expect(result[:discount_amount]).to eq(10.0) # 20% of 50
        expect(result[:final_price]).to eq(40.0) # 50 - 10
      end

      context 'when quantity is below threshold' do
        let(:cart_item) { create(:cart_item, item: item, quantity: 3.0) }

        it 'does not apply the promotion' do
          result = service.calculate_best_promotion
          expect(result).to be_nil
        end
      end

      context 'when item is not sold by weight' do
        let(:item) { create(:item, :by_quantity, brand: brand, category: category, price: 5.0) }

        it 'does not apply the promotion' do
          result = service.calculate_best_promotion
          expect(result).to be_nil
        end
      end
    end
  end

  describe 'promotion targeting' do
    context 'item-specific promotion' do
      let!(:promotion) { create(:promotion, :percentage, promotionable: item, discount_value: 10) }

      it 'applies item-specific promotion' do
        result = service.calculate_best_promotion
        expect(result[:promotion]).to eq(promotion)
      end
    end

    context 'category-specific promotion' do
      let!(:promotion) { create(:promotion, :percentage, promotionable: category, discount_value: 15) }

      it 'applies category-specific promotion' do
        result = service.calculate_best_promotion
        expect(result[:promotion]).to eq(promotion)
      end
    end

    context 'brand-specific promotion' do
      let!(:promotion) { create(:promotion, :percentage, promotionable: brand, discount_value: 20) }

      it 'applies brand-specific promotion' do
        result = service.calculate_best_promotion
        expect(result[:promotion]).to eq(promotion)
      end
    end

    context 'multiple applicable promotions' do
      let!(:item_promotion) { create(:promotion, :percentage, promotionable: item, discount_value: 10) }
      let!(:category_promotion) { create(:promotion, :percentage, promotionable: category, discount_value: 15) }
      let!(:brand_promotion) { create(:promotion, :percentage, promotionable: brand, discount_value: 20) }

      it 'selects the promotion with highest discount' do
        result = service.calculate_best_promotion
        expect(result[:promotion]).to eq(brand_promotion) # 20% > 15% > 10%
        expect(result[:discount_amount]).to eq(40.0) # 20% of 200
      end
    end
  end

  describe 'promotion time validation' do
    context 'expired promotion' do
      let!(:promotion) { create(:promotion, :percentage, promotionable: item, discount_value: 10, start_time: 2.days.ago, end_time: 1.day.ago) }

      it 'does not apply expired promotion' do
        result = service.calculate_best_promotion
        expect(result).to be_nil
      end
    end

    context 'future promotion' do
      let!(:promotion) { create(:promotion, :percentage, promotionable: item, discount_value: 10, start_time: 1.day.from_now, end_time: 1.week.from_now) }

      it 'does not apply future promotion' do
        result = service.calculate_best_promotion
        expect(result).to be_nil
      end
    end

    context 'active promotion' do
      let!(:promotion) { create(:promotion, :percentage, promotionable: item, discount_value: 10, start_time: 1.day.ago, end_time: 1.day.from_now) }

      it 'applies active promotion' do
        result = service.calculate_best_promotion
        expect(result[:promotion]).to eq(promotion)
      end
    end

    context 'promotion without end time' do
      let!(:promotion) { create(:promotion, :percentage, promotionable: item, discount_value: 10, start_time: 1.day.ago, end_time: nil) }

      it 'applies promotion without end time' do
        result = service.calculate_best_promotion
        expect(result[:promotion]).to eq(promotion)
      end
    end
  end

  describe 'edge cases' do
    context 'when final price would be negative' do
      let!(:promotion) { create(:promotion, :flat_fee, promotionable: item, discount_value: 300) }

      it 'returns minimum price of 0' do
        result = service.calculate_best_promotion
        expect(result[:final_price]).to eq(0.0)
      end
    end

    context 'BOGO with insufficient quantity' do
      let!(:promotion) { create(:promotion, :bogo, promotionable: item, buy_quantity: 3, get_quantity: 1, get_discount_percentage: 100) }
      let(:cart_item) { create(:cart_item, item: item, quantity: 2) }

      it 'does not apply BOGO promotion' do
        result = service.calculate_best_promotion
        expect(result).to be_nil
      end
    end

    context 'BOGO with fractional sets' do
      let!(:promotion) { create(:promotion, :bogo, promotionable: item, buy_quantity: 2, get_quantity: 1, get_discount_percentage: 100) }
      let(:cart_item) { create(:cart_item, item: item, quantity: 3) }

      it 'calculates discount for complete sets only' do
        result = service.calculate_best_promotion
        # Only 1 complete set (buy 2, get 1 free)
        expect(result[:discount_amount]).to eq(100.0) # 1 free item
        expect(result[:final_price]).to eq(200.0) # 300 - 100
      end
    end
  end

  describe 'promotion applicability' do
    context 'when promotion is not applicable' do
      let!(:promotion) { create(:promotion, :bogo, promotionable: item, buy_quantity: 5, get_quantity: 1, get_discount_percentage: 100) }

      it 'does not include inapplicable promotions' do
        result = service.calculate_best_promotion
        expect(result).to be_nil
      end
    end
  end
end
