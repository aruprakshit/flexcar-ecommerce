class Brand < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :promotions, as: :promotionable, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
