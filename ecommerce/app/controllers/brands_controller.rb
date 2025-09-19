class BrandsController < ApplicationController
  def index
    @brands = Brand.includes(:items).order(:name)
  end

  def show
    @brand = Brand.find(params[:id])
    @items = @brand.items.includes(:brand, :category, :promotions).order(:name)
  end
end
