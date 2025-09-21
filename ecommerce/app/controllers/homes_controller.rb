class HomesController < ApplicationController
  def index
    @featured_items = FeaturedItemsService.new(limit: 5).call
    @categories = FeaturedCategoriesService.new(limit: 11).call
  end
end
