require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#format_currency_inr' do
    context 'with integer amounts' do
      it 'formats 1000 as ₹1,000' do
        expect(helper.format_currency_inr(1000)).to eq('₹1,000')
      end

      it 'formats 10000 as ₹10,000' do
        expect(helper.format_currency_inr(10000)).to eq('₹10,000')
      end

      it 'formats 100000 as ₹100,000' do
        expect(helper.format_currency_inr(100000)).to eq('₹100,000')
      end

      it 'formats 0 as ₹0' do
        expect(helper.format_currency_inr(0)).to eq('₹0')
      end
    end

    context 'with decimal amounts' do
      it 'formats 1000.50 as ₹1,000.5' do
        expect(helper.format_currency_inr(1000.50)).to eq('₹1,000.5')
      end

      it 'formats 1234.567 as ₹1,234.57' do
        expect(helper.format_currency_inr(1234.567)).to eq('₹1,234.57')
      end

      it 'formats 999.999 as ₹1,000.0' do
        expect(helper.format_currency_inr(999.999)).to eq('₹1,000.0')
      end

      it 'formats 0.99 as ₹0.99' do
        expect(helper.format_currency_inr(0.99)).to eq('₹0.99')
      end
    end

    context 'with negative amounts' do
      it 'formats -1000 as ₹-1,000' do
        expect(helper.format_currency_inr(-1000)).to eq('₹-1,000')
      end

      it 'formats -1234.56 as ₹-1,234.56' do
        expect(helper.format_currency_inr(-1234.56)).to eq('₹-1,234.56')
      end
    end

    context 'with edge cases' do
      it 'handles nil by raising an error' do
        expect { helper.format_currency_inr(nil) }.to raise_error(NoMethodError)
      end

      it 'handles string numbers by raising an error' do
        expect { helper.format_currency_inr('1000') }.to raise_error(NoMethodError)
      end

      it 'handles very large numbers' do
        expect(helper.format_currency_inr(1000000)).to eq('₹1,000,000')
      end

      it 'handles very small decimal numbers' do
        expect(helper.format_currency_inr(0.001)).to eq('₹0.0')
      end
    end
  end

  describe '#format_cart_count' do
    context 'with integer values' do
      it 'formats 5 as 5' do
        expect(helper.format_cart_count(5)).to eq(5)
      end

      it 'formats 0 as 0' do
        expect(helper.format_cart_count(0)).to eq(0)
      end

      it 'formats 100 as 100' do
        expect(helper.format_cart_count(100)).to eq(100)
      end
    end

    context 'with decimal values' do
      it 'formats 5.7 as 5' do
        expect(helper.format_cart_count(5.7)).to eq(5)
      end

      it 'formats 10.9 as 10' do
        expect(helper.format_cart_count(10.9)).to eq(10)
      end

      it 'formats 0.9 as 0' do
        expect(helper.format_cart_count(0.9)).to eq(0)
      end
    end

    context 'with string values' do
      it 'formats "5" as 5' do
        expect(helper.format_cart_count("5")).to eq(5)
      end

      it 'formats "10.7" as 10' do
        expect(helper.format_cart_count("10.7")).to eq(10)
      end

      it 'formats "0" as 0' do
        expect(helper.format_cart_count("0")).to eq(0)
      end
    end

    context 'with edge cases' do
      it 'handles nil by treating it as 0' do
        expect(helper.format_cart_count(nil)).to eq(0)
      end

      it 'handles empty string as 0' do
        expect(helper.format_cart_count("")).to eq(0)
      end

      it 'handles negative numbers' do
        expect(helper.format_cart_count(-5)).to eq(-5)
      end

      it 'handles very large numbers' do
        expect(helper.format_cart_count(999999)).to eq(999999)
      end
    end
  end
end
