class CartsController < ApplicationController
  def new
    # Redirect to show action since cart is auto-created
    redirect_to cart_path
  end

  def show
    @cart = current_cart
    @cart_items = @cart.cart_items.includes(:item, :promotion)
  end

  def add_item
    quantity = params[:quantity].to_i
    quantity = 1 if quantity <= 0
    
    begin
      cart_item = current_cart_service.add_item(params[:item_id], quantity)
      flash[:notice] = "#{cart_item.item.name} added to cart!"
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "Item not found."
    rescue => e
      flash[:alert] = "Error adding item to cart: #{e.message}"
    end
    
    redirect_back(fallback_location: root_path)
  end

  def remove_item
    begin
      current_cart_service.remove_item(params[:item_id])
      flash[:notice] = "Item removed from cart."
    rescue => e
      flash[:alert] = "Error removing item from cart: #{e.message}"
    end
    
    redirect_back(fallback_location: root_path)
  end

  def update_item_quantity
    quantity = params[:quantity].to_i
    
    begin
      if quantity <= 0
        current_cart_service.remove_item(params[:item_id])
        flash[:notice] = "Item removed from cart."
      else
        current_cart_service.update_item_quantity(params[:item_id], quantity)
        flash[:notice] = "Cart updated."
      end
    rescue => e
      flash[:alert] = "Error updating cart: #{e.message}"
    end
    
    redirect_back(fallback_location: root_path)
  end
end
