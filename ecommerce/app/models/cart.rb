class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :items, through: :cart_items

  validates :session_id, presence: true, uniqueness: true
end
