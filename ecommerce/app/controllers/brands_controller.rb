class BrandsController < ApplicationController
  def index
    @sort_option = params[:sort] || 'name_asc'
    @brands = SortingService.new(Brand, @sort_option).sorted_collection
  end

  def show
    @brand = Brand.find(params[:id])
    @items = @brand.items.includes(:brand, :category, :promotions).order(:name)
  end
end
