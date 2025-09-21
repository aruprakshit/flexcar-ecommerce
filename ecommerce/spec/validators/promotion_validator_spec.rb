require 'rails_helper'

RSpec.describe PromotionValidator do
  let(:item) { create(:item) }
  let(:category) { create(:category) }
  let(:brand) { create(:brand) }

  describe '#validate' do
    context 'when promotion_type is bogo' do
      let(:promotion) { build(:promotion, :bogo, promotionable: item) }

      it 'calls validate_bogo_promotion' do
        validator = PromotionValidator.new
        expect(validator).to receive(:validate_bogo_promotion).with(promotion)
        validator.validate(promotion)
      end
    end

    context 'when promotion_type is weight_threshold' do
      let(:promotion) { build(:promotion, :weight_threshold, promotionable: item) }

      it 'calls validate_weight_threshold_promotion' do
        validator = PromotionValidator.new
        expect(validator).to receive(:validate_weight_threshold_promotion).with(promotion)
        validator.validate(promotion)
      end
    end

    context 'when promotion_type is neither bogo nor weight_threshold' do
      let(:promotion) { build(:promotion, :percentage, promotionable: item) }

      it 'does not call any specific validation methods' do
        validator = PromotionValidator.new
        expect(validator).not_to receive(:validate_bogo_promotion)
        expect(validator).not_to receive(:validate_weight_threshold_promotion)
        validator.validate(promotion)
      end
    end
  end

  describe '#validate_bogo_promotion' do
    context 'with valid BOGO promotion data' do
      let(:promotion) do
        build(:promotion, :bogo,
              promotionable: item,
              buy_quantity: 2,
              get_quantity: 1,
              get_discount_percentage: 50)
      end

      it 'does not add any errors' do
        validator = PromotionValidator.new
        validator.validate(promotion)
        expect(promotion.errors).to be_empty
      end
    end

    context 'with invalid buy_quantity' do
      context 'when buy_quantity is blank' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: nil,
                get_quantity: 1,
                get_discount_percentage: 50)
        end

        it 'adds bogo_required error to buy_quantity' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:buy_quantity]).to include('must be present and greater than 0 for BOGO promotions')
        end
      end

      context 'when buy_quantity is zero' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 0,
                get_quantity: 1,
                get_discount_percentage: 50)
        end

        it 'adds bogo_required error to buy_quantity' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:buy_quantity]).to include('must be present and greater than 0 for BOGO promotions')
        end
      end

      context 'when buy_quantity is negative' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: -1,
                get_quantity: 1,
                get_discount_percentage: 50)
        end

        it 'adds bogo_required error to buy_quantity' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:buy_quantity]).to include('must be present and greater than 0 for BOGO promotions')
        end
      end
    end

    context 'with invalid get_quantity' do
      context 'when get_quantity is blank' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 2,
                get_quantity: nil,
                get_discount_percentage: 50)
        end

        it 'adds bogo_required error to get_quantity' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:get_quantity]).to include('must be present and greater than 0 for BOGO promotions')
        end
      end

      context 'when get_quantity is zero' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 2,
                get_quantity: 0,
                get_discount_percentage: 50)
        end

        it 'adds bogo_required error to get_quantity' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:get_quantity]).to include('must be present and greater than 0 for BOGO promotions')
        end
      end

      context 'when get_quantity is negative' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 2,
                get_quantity: -1,
                get_discount_percentage: 50)
        end

        it 'adds bogo_required error to get_quantity' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:get_quantity]).to include('must be present and greater than 0 for BOGO promotions')
        end
      end
    end

    context 'with invalid get_discount_percentage' do
      context 'when get_discount_percentage is blank' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 2,
                get_quantity: 1,
                get_discount_percentage: nil)
        end

        it 'adds bogo_range error to get_discount_percentage' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:get_discount_percentage]).to include('must be between 0 and 100 for BOGO promotions')
        end
      end

      context 'when get_discount_percentage is negative' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 2,
                get_quantity: 1,
                get_discount_percentage: -10)
        end

        it 'adds bogo_range error to get_discount_percentage' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:get_discount_percentage]).to include('must be between 0 and 100 for BOGO promotions')
        end
      end

      context 'when get_discount_percentage is greater than 100' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 2,
                get_quantity: 1,
                get_discount_percentage: 150)
        end

        it 'adds bogo_range error to get_discount_percentage' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:get_discount_percentage]).to include('must be between 0 and 100 for BOGO promotions')
        end
      end

      context 'when get_discount_percentage is exactly 100' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 2,
                get_quantity: 1,
                get_discount_percentage: 100)
        end

        it 'does not add any errors' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end

      context 'when get_discount_percentage is exactly 0' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 2,
                get_quantity: 1,
                get_discount_percentage: 0)
        end

        it 'does not add any errors' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end
    end

    context 'with multiple invalid fields' do
      let(:promotion) do
        build(:promotion, :bogo,
              promotionable: item,
              buy_quantity: nil,
              get_quantity: -1,
              get_discount_percentage: 150)
      end

      it 'adds errors to all invalid fields' do
        validator = PromotionValidator.new
        validator.validate(promotion)
        
        expect(promotion.errors[:buy_quantity]).to include('must be present and greater than 0 for BOGO promotions')
        expect(promotion.errors[:get_quantity]).to include('must be present and greater than 0 for BOGO promotions')
        expect(promotion.errors[:get_discount_percentage]).to include('must be between 0 and 100 for BOGO promotions')
      end
    end
  end

  describe '#validate_weight_threshold_promotion' do
    context 'with valid weight_threshold promotion data' do
      let(:promotion) do
        build(:promotion, :weight_threshold,
              promotionable: item,
              weight_threshold: 5.0,
              weight_discount_percentage: 25)
      end

      it 'does not add any errors' do
        validator = PromotionValidator.new
        validator.validate(promotion)
        expect(promotion.errors).to be_empty
      end
    end

    context 'with invalid weight_threshold' do
      context 'when weight_threshold is blank' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: nil,
                weight_discount_percentage: 25)
        end

        it 'adds weight_required error to weight_threshold' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:weight_threshold]).to include('must be present and greater than 0 for weight threshold promotions')
        end
      end

      context 'when weight_threshold is zero' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: 0,
                weight_discount_percentage: 25)
        end

        it 'adds weight_required error to weight_threshold' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:weight_threshold]).to include('must be present and greater than 0 for weight threshold promotions')
        end
      end

      context 'when weight_threshold is negative' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: -2.5,
                weight_discount_percentage: 25)
        end

        it 'adds weight_required error to weight_threshold' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:weight_threshold]).to include('must be present and greater than 0 for weight threshold promotions')
        end
      end
    end

    context 'with invalid weight_discount_percentage' do
      context 'when weight_discount_percentage is blank' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: 5.0,
                weight_discount_percentage: nil)
        end

        it 'adds weight_range error to weight_discount_percentage' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:weight_discount_percentage]).to include('must be between 0 and 100 for weight threshold promotions')
        end
      end

      context 'when weight_discount_percentage is negative' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: 5.0,
                weight_discount_percentage: -15)
        end

        it 'adds weight_range error to weight_discount_percentage' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:weight_discount_percentage]).to include('must be between 0 and 100 for weight threshold promotions')
        end
      end

      context 'when weight_discount_percentage is greater than 100' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: 5.0,
                weight_discount_percentage: 125)
        end

        it 'adds weight_range error to weight_discount_percentage' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors[:weight_discount_percentage]).to include('must be between 0 and 100 for weight threshold promotions')
        end
      end

      context 'when weight_discount_percentage is exactly 100' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: 5.0,
                weight_discount_percentage: 100)
        end

        it 'does not add any errors' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end

      context 'when weight_discount_percentage is exactly 0' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: 5.0,
                weight_discount_percentage: 0)
        end

        it 'does not add any errors' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end
    end

    context 'with multiple invalid fields' do
      let(:promotion) do
        build(:promotion, :weight_threshold,
              promotionable: item,
              weight_threshold: nil,
              weight_discount_percentage: 150)
      end

      it 'adds errors to all invalid fields' do
        validator = PromotionValidator.new
        validator.validate(promotion)
        
        expect(promotion.errors[:weight_threshold]).to include('must be present and greater than 0 for weight threshold promotions')
        expect(promotion.errors[:weight_discount_percentage]).to include('must be between 0 and 100 for weight threshold promotions')
      end
    end
  end

  describe 'validation across all promotionable resources' do
    context 'BOGO promotions' do
      context 'for Item' do
        context 'with valid data' do
          let(:promotion) do
            build(:promotion, :bogo,
                  promotionable: item,
                  buy_quantity: 3,
                  get_quantity: 1,
                  get_discount_percentage: 75)
          end

          it 'validates successfully' do
            validator = PromotionValidator.new
            validator.validate(promotion)
            expect(promotion.errors).to be_empty
          end
        end

        context 'with invalid data' do
          let(:promotion) do
            build(:promotion, :bogo,
                  promotionable: item,
                  buy_quantity: nil,
                  get_quantity: -1,
                  get_discount_percentage: 150)
          end

          it 'adds appropriate errors' do
            validator = PromotionValidator.new
            validator.validate(promotion)
            
            expect(promotion.errors[:buy_quantity]).to include('must be present and greater than 0 for BOGO promotions')
            expect(promotion.errors[:get_quantity]).to include('must be present and greater than 0 for BOGO promotions')
            expect(promotion.errors[:get_discount_percentage]).to include('must be between 0 and 100 for BOGO promotions')
          end
        end
      end

      context 'for Category' do
        context 'with valid data' do
          let(:promotion) do
            build(:promotion, :bogo,
                  promotionable: category,
                  buy_quantity: 3,
                  get_quantity: 1,
                  get_discount_percentage: 75)
          end

          it 'validates successfully' do
            validator = PromotionValidator.new
            validator.validate(promotion)
            expect(promotion.errors).to be_empty
          end
        end

        context 'with invalid data' do
          let(:promotion) do
            build(:promotion, :bogo,
                  promotionable: category,
                  buy_quantity: nil,
                  get_quantity: -1,
                  get_discount_percentage: 150)
          end

          it 'adds appropriate errors' do
            validator = PromotionValidator.new
            validator.validate(promotion)
            
            expect(promotion.errors[:buy_quantity]).to include('must be present and greater than 0 for BOGO promotions')
            expect(promotion.errors[:get_quantity]).to include('must be present and greater than 0 for BOGO promotions')
            expect(promotion.errors[:get_discount_percentage]).to include('must be between 0 and 100 for BOGO promotions')
          end
        end
      end

      context 'for Brand' do
        context 'with valid data' do
          let(:promotion) do
            build(:promotion, :bogo,
                  promotionable: brand,
                  buy_quantity: 3,
                  get_quantity: 1,
                  get_discount_percentage: 75)
          end

          it 'validates successfully' do
            validator = PromotionValidator.new
            validator.validate(promotion)
            expect(promotion.errors).to be_empty
          end
        end

        context 'with invalid data' do
          let(:promotion) do
            build(:promotion, :bogo,
                  promotionable: brand,
                  buy_quantity: nil,
                  get_quantity: -1,
                  get_discount_percentage: 150)
          end

          it 'adds appropriate errors' do
            validator = PromotionValidator.new
            validator.validate(promotion)
            
            expect(promotion.errors[:buy_quantity]).to include('must be present and greater than 0 for BOGO promotions')
            expect(promotion.errors[:get_quantity]).to include('must be present and greater than 0 for BOGO promotions')
            expect(promotion.errors[:get_discount_percentage]).to include('must be between 0 and 100 for BOGO promotions')
          end
        end
      end
    end

    context 'weight_threshold promotions' do
      context 'for Item' do
        context 'with valid data' do
          let(:promotion) do
            build(:promotion, :weight_threshold,
                  promotionable: item,
                  weight_threshold: 10.5,
                  weight_discount_percentage: 30)
          end

          it 'validates successfully' do
            validator = PromotionValidator.new
            validator.validate(promotion)
            expect(promotion.errors).to be_empty
          end
        end

        context 'with invalid data' do
          let(:promotion) do
            build(:promotion, :weight_threshold,
                  promotionable: item,
                  weight_threshold: 0,
                  weight_discount_percentage: -10)
          end

          it 'adds appropriate errors' do
            validator = PromotionValidator.new
            validator.validate(promotion)
            
            expect(promotion.errors[:weight_threshold]).to include('must be present and greater than 0 for weight threshold promotions')
            expect(promotion.errors[:weight_discount_percentage]).to include('must be between 0 and 100 for weight threshold promotions')
          end
        end
      end

      context 'for Category' do
        context 'with valid data' do
          let(:promotion) do
            build(:promotion, :weight_threshold,
                  promotionable: category,
                  weight_threshold: 10.5,
                  weight_discount_percentage: 30)
          end

          it 'validates successfully' do
            validator = PromotionValidator.new
            validator.validate(promotion)
            expect(promotion.errors).to be_empty
          end
        end

        context 'with invalid data' do
          let(:promotion) do
            build(:promotion, :weight_threshold,
                  promotionable: category,
                  weight_threshold: 0,
                  weight_discount_percentage: -10)
          end

          it 'adds appropriate errors' do
            validator = PromotionValidator.new
            validator.validate(promotion)
            
            expect(promotion.errors[:weight_threshold]).to include('must be present and greater than 0 for weight threshold promotions')
            expect(promotion.errors[:weight_discount_percentage]).to include('must be between 0 and 100 for weight threshold promotions')
          end
        end
      end

      context 'for Brand' do
        context 'with valid data' do
          let(:promotion) do
            build(:promotion, :weight_threshold,
                  promotionable: brand,
                  weight_threshold: 10.5,
                  weight_discount_percentage: 30)
          end

          it 'validates successfully' do
            validator = PromotionValidator.new
            validator.validate(promotion)
            expect(promotion.errors).to be_empty
          end
        end

        context 'with invalid data' do
          let(:promotion) do
            build(:promotion, :weight_threshold,
                  promotionable: brand,
                  weight_threshold: 0,
                  weight_discount_percentage: -10)
          end

          it 'adds appropriate errors' do
            validator = PromotionValidator.new
            validator.validate(promotion)
            
            expect(promotion.errors[:weight_threshold]).to include('must be present and greater than 0 for weight threshold promotions')
            expect(promotion.errors[:weight_discount_percentage]).to include('must be between 0 and 100 for weight threshold promotions')
          end
        end
      end
    end
  end

  describe 'edge cases and boundary conditions' do
    context 'BOGO promotions' do
      context 'with decimal quantities' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 2.5,
                get_quantity: 1.0,
                get_discount_percentage: 50)
        end

        it 'validates successfully with decimal values' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end

      context 'with very large quantities' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 999999,
                get_quantity: 999999,
                get_discount_percentage: 100)
        end

        it 'validates successfully with large values' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end

      context 'with zero discount percentage' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 2,
                get_quantity: 1,
                get_discount_percentage: 0)
        end

        it 'validates successfully with zero discount' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end

      context 'with full discount percentage' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 2,
                get_quantity: 1,
                get_discount_percentage: 100)
        end

        it 'validates successfully with full discount' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end
    end

    context 'weight_threshold promotions' do
      context 'with very small weight threshold' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: 0.01,
                weight_discount_percentage: 0)
        end

        it 'validates successfully with small weight values' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end

      context 'with very large weight threshold' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: 999999.99,
                weight_discount_percentage: 100)
        end

        it 'validates successfully with large weight values' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end

      context 'with zero discount percentage' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: 5.0,
                weight_discount_percentage: 0)
        end

        it 'validates successfully with zero discount' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end

      context 'with full discount percentage' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: 5.0,
                weight_discount_percentage: 100)
        end

        it 'validates successfully with full discount' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end
    end
  end

  describe 'business rule validation based on requirements' do
    context 'BOGO promotions (Buy X Get Y discount)' do
      context 'Buy 1 get 1 free scenario' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 1,
                get_quantity: 1,
                get_discount_percentage: 100)
        end

        it 'validates successfully for buy 1 get 1 free' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end

      context 'Buy 3 get 1 50% off scenario' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 3,
                get_quantity: 1,
                get_discount_percentage: 50)
        end

        it 'validates successfully for buy 3 get 1 50% off' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end

      context 'Buy 2 get 2 free scenario' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 2,
                get_quantity: 2,
                get_discount_percentage: 100)
        end

        it 'validates successfully for buy 2 get 2 free' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end
    end

    context 'Weight threshold promotions (Buy more than X grams and get Y% off)' do
      context 'Buy more than 101 grams and get 50% off' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: 101.0,
                weight_discount_percentage: 50)
        end

        it 'validates successfully for weight threshold promotion' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end

      context 'Buy more than 500 grams and get 25% off' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: item,
                weight_threshold: 500.0,
                weight_discount_percentage: 25)
        end

        it 'validates successfully for weight threshold promotion' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end
    end

    context 'Promotions for different resource types' do
      context 'Individual item promotion' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: item,
                buy_quantity: 2,
                get_quantity: 1,
                get_discount_percentage: 50)
        end

        it 'validates successfully for individual item' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end

      context 'Category promotion' do
        let(:promotion) do
          build(:promotion, :weight_threshold,
                promotionable: category,
                weight_threshold: 100.0,
                weight_discount_percentage: 30)
        end

        it 'validates successfully for category' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end

      context 'Brand promotion' do
        let(:promotion) do
          build(:promotion, :bogo,
                promotionable: brand,
                buy_quantity: 1,
                get_quantity: 1,
                get_discount_percentage: 100)
        end

        it 'validates successfully for brand' do
          validator = PromotionValidator.new
          validator.validate(promotion)
          expect(promotion.errors).to be_empty
        end
      end
    end
  end
end
