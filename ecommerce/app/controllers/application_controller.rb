class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Global cart helper method
  def current_cart
    @current_cart ||= find_or_create_cart
  end
  
  # Global cart service helper method
  def current_cart_service
    @current_cart_service ||= CartService.new(current_session_id)
  end
  
  # Make cart available in views
  helper_method :current_cart, :current_cart_service
  
  private
  
  def current_session_id
    session.id&.to_s || SecureRandom.hex(10)
  end
  
  def find_or_create_cart
    Cart.find_or_create_by(session_id: current_session_id)
  end
end
