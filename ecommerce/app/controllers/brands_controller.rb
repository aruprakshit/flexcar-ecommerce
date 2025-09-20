class BrandsController < ApplicationController
  def index
    # Handle sorting
    case params[:sort]
    when 'name_asc'
      @brands = Brand.includes(:items).order(:name)
    when 'name_desc'
      @brands = Brand.includes(:items).order(name: :desc)
    when 'products_asc'
      # Sort by product count using SQL - load all brands first, then sort in Ruby
      all_brands = Brand.includes(:items).to_a
      @brands = all_brands.sort_by { |brand| brand.items.count }
    when 'products_desc'
      # Sort by product count using SQL - load all brands first, then sort in Ruby
      all_brands = Brand.includes(:items).to_a
      @brands = all_brands.sort_by { |brand| -brand.items.count }
    else
      @brands = Brand.includes(:items).order(:name) # Default sorting
    end
    
    @sort_option = params[:sort] || 'name_asc'
  end

  def show
    @brand = Brand.find(params[:id])
    @items = @brand.items.includes(:brand, :category, :promotions).order(:name)
  end
end
