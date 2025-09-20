class ItemsController < ApplicationController
  def index
    @items = ItemFilterService.new(params).call
  end

  def show
    @item = Item.includes(:brand, :category, :promotions)
                .find(params[:id])
    @related_items = Item.includes(:brand, :category, :promotions)
                         .where(category: @item.category)
                         .where.not(id: @item.id)
                         .limit(4)
  end
end
