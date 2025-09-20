class CategoriesController < ApplicationController
  def index
    @categories = Category.includes(:items).order(:name)
  end

  def show
    @category = Category.find(params[:id])
    @items = @category.items.includes(:brand, :category, :promotions).order(:name)
  end
end
