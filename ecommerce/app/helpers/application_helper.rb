module ApplicationHelper
  # Format INR amount with proper delimiters
  def format_currency_inr(inr_amount)
    "₹#{number_with_delimiter(inr_amount.round(2))}"
  end
  
  # Format cart count as whole number
  def format_cart_count(count)
    count.to_i
  end
end
