require 'rails_helper'

RSpec.describe Promotion, type: :model do
  describe 'associations' do
    it { should belong_to(:promotionable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:start_time) }
    
    describe 'conditional validations' do
      context 'when not bogo or weight_threshold' do
        before { allow(subject).to receive(:bogo_or_weight_threshold?).and_return(false) }
        it { should validate_presence_of(:discount_value) }
        it { should validate_numericality_of(:discount_value).is_greater_than(0) }
      end
      
      context 'when bogo or weight_threshold' do
        before { allow(subject).to receive(:bogo_or_weight_threshold?).and_return(true) }
        it { should_not validate_presence_of(:discount_value) }
        it { should_not validate_numericality_of(:discount_value).is_greater_than(0) }
      end
      
      context 'when bogo promotion' do
        before { allow(subject).to receive(:bogo?).and_return(true) }
        it { should validate_presence_of(:buy_quantity) }
        it { should validate_presence_of(:get_quantity) }
        it { should validate_presence_of(:get_discount_percentage) }
      end
      
      context 'when not bogo promotion' do
        before { allow(subject).to receive(:bogo?).and_return(false) }
        it { should_not validate_presence_of(:buy_quantity) }
        it { should_not validate_presence_of(:get_quantity) }
        it { should_not validate_presence_of(:get_discount_percentage) }
      end
      
      context 'when weight_threshold promotion' do
        before { allow(subject).to receive(:weight_threshold?).and_return(true) }
        it { should validate_presence_of(:weight_threshold) }
        it { should validate_presence_of(:weight_discount_percentage) }
      end
      
      context 'when not weight_threshold promotion' do
        before { allow(subject).to receive(:weight_threshold?).and_return(false) }
        it { should_not validate_presence_of(:weight_threshold) }
        it { should_not validate_presence_of(:weight_discount_percentage) }
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:promotion_type).with_values(flat_fee: 0, percentage: 1, bogo: 2, weight_threshold: 3) }
  end

  describe 'scopes' do
    let!(:active_promotion) { create(:promotion, start_time: 1.day.ago, end_time: 1.day.from_now) }
    let!(:expired_promotion) { create(:promotion, start_time: 2.days.ago, end_time: 1.day.ago) }
    let!(:future_promotion) { create(:promotion, start_time: 1.day.from_now, end_time: 2.days.from_now) }

    describe '.active' do
      it 'returns only active promotions' do
        expect(Promotion.active).to include(active_promotion)
        expect(Promotion.active).not_to include(expired_promotion, future_promotion)
      end
    end

    describe '.for_item' do
      let(:item) { create(:item) }
      let!(:item_promotion) { create(:promotion, promotionable: item) }

      it 'returns promotions for specific item' do
        expect(Promotion.for_item(item)).to include(item_promotion)
      end
    end

    describe '.for_category' do
      let(:category) { create(:category) }
      let!(:category_promotion) { create(:promotion, promotionable: category) }

      it 'returns promotions for specific category' do
        expect(Promotion.for_category(category)).to include(category_promotion)
      end
    end

    describe '.for_brand' do
      let(:brand) { create(:brand) }
      let!(:brand_promotion) { create(:promotion, promotionable: brand) }

      it 'returns promotions for specific brand' do
        expect(Promotion.for_brand(brand)).to include(brand_promotion)
      end
    end
  end

  describe '#bogo?' do
    it 'returns true for bogo promotion type' do
      promotion = build(:promotion, promotion_type: 'bogo')
      expect(promotion.bogo?).to be true
    end

    it 'returns false for other promotion types' do
      promotion = build(:promotion, promotion_type: 'percentage')
      expect(promotion.bogo?).to be false
    end
  end

  describe '#weight_threshold?' do
    it 'returns true for weight_threshold promotion type' do
      promotion = build(:promotion, promotion_type: 'weight_threshold')
      expect(promotion.weight_threshold?).to be true
    end

    it 'returns false for other promotion types' do
      promotion = build(:promotion, promotion_type: 'percentage')
      expect(promotion.weight_threshold?).to be false
    end
  end

  describe '#bogo_or_weight_threshold?' do
    it 'returns true for bogo promotion' do
      promotion = build(:promotion, promotion_type: 'bogo')
      expect(promotion.bogo_or_weight_threshold?).to be true
    end

    it 'returns true for weight_threshold promotion' do
      promotion = build(:promotion, promotion_type: 'weight_threshold')
      expect(promotion.bogo_or_weight_threshold?).to be true
    end

    it 'returns false for other promotion types' do
      promotion = build(:promotion, promotion_type: 'percentage')
      expect(promotion.bogo_or_weight_threshold?).to be false
    end
  end
end
