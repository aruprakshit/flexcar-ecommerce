require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'associations' do
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:items).through(:cart_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:session_id) }
    it { should validate_uniqueness_of(:session_id) }
  end
end
