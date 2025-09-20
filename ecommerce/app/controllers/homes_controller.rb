class HomesController < ApplicationController
  def index
    @categories = Category.all
    @featured_items = FeaturedItemsService.new(limit: 4).call
  end
end
