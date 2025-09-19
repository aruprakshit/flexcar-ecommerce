require 'rails_helper'

RSpec.describe CartService do
  let(:session_id) { 'test_session_123' }
  let(:cart_service) { described_class.new(session_id) }
  let(:item) { create(:item, price: 100.0) }
  let(:cart) { cart_service.get_cart }

  describe '#initialize' do
    context 'with new session_id' do
      it 'creates a new cart' do
        expect { described_class.new('new_session') }.to change(Cart, :count).by(1)
      end

      it 'sets the session_id correctly' do
        service = described_class.new('new_session')
        expect(service.get_cart.session_id).to eq('new_session')
      end
    end

    context 'with existing session_id' do
      let!(:existing_cart) { create(:cart, session_id: session_id) }

      it 'finds the existing cart' do
        expect(cart_service.get_cart).to eq(existing_cart)
      end

      it 'does not create a new cart' do
        expect { cart_service }.not_to change(Cart, :count)
      end
    end
  end

  describe '#add_item' do
    context 'when adding item for the first time' do
      it 'creates a new cart item' do
        expect { cart_service.add_item(item.id, 2) }.to change(CartItem, :count).by(1)
      end

      it 'sets the correct quantity' do
        cart_item = cart_service.add_item(item.id, 3)
        expect(cart_item.quantity).to eq(3)
      end

      it 'calculates the correct subtotal' do
        cart_item = cart_service.add_item(item.id, 2)
        expect(cart_item.subtotal).to eq(200.0)
      end

      it 'sets final_price to subtotal when no promotion applies' do
        cart_item = cart_service.add_item(item.id, 2)
        expect(cart_item.final_price).to eq(200.0)
      end

      it 'returns the created cart item' do
        cart_item = cart_service.add_item(item.id, 2)
        expect(cart_item).to be_a(CartItem)
        expect(cart_item.item).to eq(item)
      end
    end

    context 'when adding item that already exists in cart' do
      let!(:existing_cart_item) { create(:cart_item, cart: cart, item: item, quantity: 2) }

      it 'does not create a new cart item' do
        expect { cart_service.add_item(item.id, 3) }.not_to change(CartItem, :count)
      end

      it 'adds to existing quantity' do
        cart_service.add_item(item.id, 3)
        existing_cart_item.reload
        expect(existing_cart_item.quantity).to eq(5)
      end

      it 'recalculates final price with new quantity' do
        cart_service.add_item(item.id, 3)
        existing_cart_item.reload
        expect(existing_cart_item.final_price).to eq(500.0) # 5 * 100
      end
    end

    context 'with promotion applied' do
      let!(:promotion) { create(:promotion, :percentage, promotionable: item, discount_value: 20) }

      it 'applies the promotion to cart item' do
        cart_item = cart_service.add_item(item.id, 2)
        expect(cart_item.promotion).to eq(promotion)
      end

      it 'calculates final price with promotion discount' do
        cart_item = cart_service.add_item(item.id, 2)
        # 2 items * 100 price * (1 - 0.20) = 160
        expect(cart_item.final_price).to eq(160.0)
      end
    end

    context 'with invalid item_id' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect { cart_service.add_item(999999, 1) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#remove_item' do
    context 'when item exists in cart' do
      let!(:cart_item) { create(:cart_item, cart: cart, item: item) }

      it 'removes the cart item' do
        expect { cart_service.remove_item(item.id) }.to change(CartItem, :count).by(-1)
      end

      it 'removes the correct cart item' do
        cart_service.remove_item(item.id)
        expect(CartItem.exists?(cart_item.id)).to be_falsey
      end
    end

    context 'when item does not exist in cart' do
      it 'does not raise an error' do
        expect { cart_service.remove_item(item.id) }.not_to raise_error
      end

      it 'does not change cart item count' do
        expect { cart_service.remove_item(item.id) }.not_to change(CartItem, :count)
      end
    end
  end

  describe '#update_item_quantity' do
    let!(:cart_item) { create(:cart_item, cart: cart, item: item, quantity: 3) }

    context 'with positive quantity' do
      it 'updates the quantity' do
        cart_service.update_item_quantity(item.id, 5)
        cart_item.reload
        expect(cart_item.quantity).to eq(5)
      end

      it 'recalculates final price with new quantity' do
        cart_service.update_item_quantity(item.id, 4)
        cart_item.reload
        expect(cart_item.final_price).to eq(400.0) # 4 * 100
      end

      it 'saves the cart item' do
        cart_service.update_item_quantity(item.id, 6)
        cart_item.reload
        expect(cart_item.quantity).to eq(6)
      end
    end

    context 'with promotion applied' do
      let!(:promotion) { create(:promotion, :flat_fee, promotionable: item, discount_value: 50) }

      it 'recalculates promotion with new quantity' do
        cart_service.update_item_quantity(item.id, 2)
        cart_item.reload
        expect(cart_item.promotion).to eq(promotion)
        # 2 items * 100 - 50 flat discount = 150
        expect(cart_item.final_price).to eq(150.0)
      end
    end

    context 'with quantity zero' do
      it 'removes the cart item' do
        expect { cart_service.update_item_quantity(item.id, 0) }.to change(CartItem, :count).by(-1)
      end

      it 'destroys the cart item' do
        cart_service.update_item_quantity(item.id, 0)
        expect(CartItem.exists?(cart_item.id)).to be_falsey
      end
    end

    context 'with negative quantity' do
      it 'removes the cart item' do
        expect { cart_service.update_item_quantity(item.id, -1) }.to change(CartItem, :count).by(-1)
      end
    end

    context 'when item does not exist in cart' do
      it 'does not raise an error' do
        expect { cart_service.update_item_quantity(999999, 5) }.not_to raise_error
      end

      it 'does not change cart item count' do
        expect { cart_service.update_item_quantity(999999, 5) }.not_to change(CartItem, :count)
      end
    end
  end

  describe '#get_cart' do
    it 'returns the cart associated with session_id' do
      expect(cart_service.get_cart).to be_a(Cart)
      expect(cart_service.get_cart.session_id).to eq(session_id)
    end

    it 'returns the same cart instance' do
      cart1 = cart_service.get_cart
      cart2 = cart_service.get_cart
      expect(cart1).to eq(cart2)
    end
  end

  describe 'promotion integration' do
    let!(:bogo_promotion) { create(:promotion, :bogo, promotionable: item, buy_quantity: 2, get_quantity: 1) }
    let!(:weight_promotion) { create(:promotion, :weight_threshold, promotionable: item, weight_threshold: 5.0, weight_discount_percentage: 30) }

    context 'with BOGO promotion' do
      it 'applies BOGO promotion for eligible quantity' do
        cart_item = cart_service.add_item(item.id, 3) # Buy 2, get 1 free
        expect(cart_item.promotion).to eq(bogo_promotion)
        # 3 items: 2 paid + 1 free = 200
        expect(cart_item.final_price).to eq(200.0)
      end

      it 'does not apply BOGO for insufficient quantity' do
        cart_item = cart_service.add_item(item.id, 1)
        expect(cart_item.promotion).to be_nil
        expect(cart_item.final_price).to eq(100.0)
      end
    end

    context 'with weight threshold promotion' do
      let(:weight_item) { create(:item, :by_weight, price: 10.0) }
      let!(:weight_promotion) { create(:promotion, :weight_threshold, promotionable: weight_item, weight_threshold: 5.0, weight_discount_percentage: 30) }

      it 'applies weight promotion when threshold is met' do
        cart_item = cart_service.add_item(weight_item.id, 6.0) # 6 grams
        expect(cart_item.promotion).to eq(weight_promotion)
        # 6 * 10 * (1 - 0.30) = 42
        expect(cart_item.final_price).to eq(42.0)
      end

      it 'does not apply weight promotion when threshold is not met' do
        cart_item = cart_service.add_item(weight_item.id, 4.0) # 4 grams
        expect(cart_item.promotion).to be_nil
        expect(cart_item.final_price).to eq(40.0)
      end
    end

    context 'with multiple promotions available' do
      let!(:percentage_promotion) { create(:promotion, :percentage, promotionable: item, discount_value: 15) }

      it 'applies the best promotion (BOGO in this case)' do
        cart_item = cart_service.add_item(item.id, 3) # Buy 2, get 1 free
        expect(cart_item.promotion).to eq(bogo_promotion)
        expect(cart_item.final_price).to eq(200.0) # Better than 15% off (255)
      end
    end

    context 'with expired promotion' do
      # Use a different item to avoid interference from other promotions
      let(:expired_item) { create(:item, price: 100.0) }
      let!(:expired_promotion) { create(:promotion, :expired, :percentage, promotionable: expired_item, discount_value: 25) }

      it 'does not apply expired promotion' do
        # Verify the promotion is actually expired
        expect(Promotion.active).not_to include(expired_promotion)
        
        cart_item = cart_service.add_item(expired_item.id, 2)
        expect(cart_item.promotion).to be_nil
        expect(cart_item.final_price).to eq(200.0)
      end
    end

    context 'with future promotion' do
      # Use a different item to avoid interference from other promotions
      let(:future_item) { create(:item, price: 100.0) }
      let!(:future_promotion) { create(:promotion, :future, :percentage, promotionable: future_item, discount_value: 25) }

      it 'does not apply future promotion' do
        # Verify the promotion is actually future
        expect(Promotion.active).not_to include(future_promotion)
        
        cart_item = cart_service.add_item(future_item.id, 2)
        expect(cart_item.promotion).to be_nil
        expect(cart_item.final_price).to eq(200.0)
      end
    end
  end

  describe 'edge cases' do
    context 'with very large quantities' do
      it 'handles large quantities correctly' do
        cart_item = cart_service.add_item(item.id, 1000)
        expect(cart_item.quantity).to eq(1000)
        expect(cart_item.final_price).to eq(100000.0)
      end
    end

    context 'with decimal quantities for weight items' do
      let(:weight_item) { create(:item, :by_weight, price: 5.0) }

      it 'handles decimal quantities correctly' do
        cart_item = cart_service.add_item(weight_item.id, 2.5)
        expect(cart_item.quantity).to eq(2.5)
        expect(cart_item.final_price).to eq(12.5)
      end
    end

    context 'when updating quantity multiple times' do
      let!(:cart_item) { create(:cart_item, cart: cart, item: item, quantity: 1) }

      it 'maintains correct state through multiple updates' do
        cart_service.update_item_quantity(item.id, 3)
        cart_item.reload
        expect(cart_item.quantity).to eq(3)

        cart_service.update_item_quantity(item.id, 1)
        cart_item.reload
        expect(cart_item.quantity).to eq(1)

        cart_service.update_item_quantity(item.id, 0)
        expect(CartItem.exists?(cart_item.id)).to be_falsey
      end
    end
  end
end
