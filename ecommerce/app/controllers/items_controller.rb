class ItemsController < ApplicationController
  def index
    @items = Item.includes(:brand, :category, :promotions)
                 .order(:name)
                 .page(params[:page])
                 .per(12)
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
