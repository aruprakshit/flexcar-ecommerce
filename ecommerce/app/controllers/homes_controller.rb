class HomesController < ApplicationController
  def index
    @categories = Category.all
    @featured_items = Item.joins(:promotions)
                          .where(promotions: Promotion.active)
                          .distinct
                          .limit(4)
  end
end
