class HomesController < ApplicationController
  def index
    @categories = Category.all
    @featured_items = Item.limit(4)
  end
end
