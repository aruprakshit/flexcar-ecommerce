# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Starting seed data creation..."

# Clear existing data (for development/testing)
if Rails.env.development? || Rails.env.test?
  puts "Clearing existing data..."
  Promotion.destroy_all
  CartItem.destroy_all
  Cart.destroy_all
  Item.destroy_all
  Category.destroy_all
  Brand.destroy_all
end

# Create brands
brands_data = [
  # Electronics
  { name: 'Apple' },
  { name: 'Samsung' },
  { name: 'Google' },
  { name: 'Sony' },
  { name: 'Microsoft' },
  { name: 'Dell' },
  { name: 'HP' },
  { name: 'Lenovo' },
  { name: 'Asus' },
  { name: 'LG' },
  
  # Clothing & Fashion
  { name: 'Nike' },
  { name: 'Adidas' },
  { name: 'Puma' },
  { name: 'Under Armour' },
  { name: 'Zara' },
  { name: 'H&M' },
  { name: 'Uniqlo' },
  { name: 'Levi\'s' },
  { name: 'Gap' },
  { name: 'Calvin Klein' },
  
  # Food & Grocery
  { name: 'Organic Valley' },
  { name: 'Whole Foods' },
  { name: 'Kraft' },
  { name: 'Nestle' },
  { name: 'Coca-Cola' },
  { name: 'Pepsi' },
  { name: 'General Mills' },
  { name: 'Kellogg\'s' },
  { name: 'Campbell\'s' },
  { name: 'Heinz' },
  
  # Home & Garden
  { name: 'IKEA' },
  { name: 'Home Depot' },
  { name: 'Lowe\'s' },
  { name: 'Target' },
  { name: 'Walmart' },
  { name: 'Amazon Basics' },
  { name: 'KitchenAid' },
  { name: 'Dyson' },
  { name: 'Shark' },
  { name: 'Bissell' }
]

brands = brands_data.map { |attrs| Brand.find_or_create_by(name: attrs[:name]) }
puts "Created #{brands.count} brands"

# Create categories
puts "Creating categories..."
categories_data = [
  { name: 'Electronics' },
  { name: 'Smartphones' },
  { name: 'Laptops' },
  { name: 'Tablets' },
  { name: 'Audio & Headphones' },
  { name: 'Cameras' },
  { name: 'Gaming' },
  { name: 'Clothing' },
  { name: 'Shoes' },
  { name: 'Accessories' },
  { name: 'Men\'s Fashion' },
  { name: 'Women\'s Fashion' },
  { name: 'Kids\' Fashion' },
  { name: 'Sports & Outdoors' },
  { name: 'Fitness' },
  { name: 'Food & Grocery' },
  { name: 'Fresh Produce' },
  { name: 'Dairy & Eggs' },
  { name: 'Meat & Seafood' },
  { name: 'Beverages' },
  { name: 'Snacks' },
  { name: 'Home & Garden' },
  { name: 'Furniture' },
  { name: 'Kitchen & Dining' },
  { name: 'Bedding & Bath' },
  { name: 'Tools & Hardware' },
  { name: 'Books' },
  { name: 'Movies & TV' },
  { name: 'Music' },
  { name: 'Toys & Games' },
  { name: 'Health & Beauty' },
  { name: 'Automotive' },
  { name: 'Pet Supplies' }
]

categories = categories_data.map { |attrs| Category.find_or_create_by(name: attrs[:name]) }
puts "Created #{categories.count} categories"

# Create items
puts "Creating items..."
items_data = [
  # Electronics - Smartphones
  { name: 'iPhone 15 Pro', description: 'Latest iPhone with titanium design', price: 999.99, sale_type: 'by_quantity', brand: brands[0], category: categories[1] },
  { name: 'iPhone 15', description: 'Latest iPhone with advanced camera system', price: 799.99, sale_type: 'by_quantity', brand: brands[0], category: categories[1] },
  { name: 'Samsung Galaxy S24 Ultra', description: 'Premium Android smartphone with S Pen', price: 1199.99, sale_type: 'by_quantity', brand: brands[1], category: categories[1] },
  { name: 'Samsung Galaxy S24', description: 'Flagship Android smartphone', price: 799.99, sale_type: 'by_quantity', brand: brands[1], category: categories[1] },
  { name: 'Google Pixel 8 Pro', description: 'AI-powered smartphone with advanced photography', price: 999.99, sale_type: 'by_quantity', brand: brands[2], category: categories[1] },
  { name: 'Google Pixel 8', description: 'Pure Android experience with Google AI', price: 699.99, sale_type: 'by_quantity', brand: brands[2], category: categories[1] },
  
  # Electronics - Laptops
  { name: 'MacBook Pro 16"', description: 'Professional laptop with M3 chip', price: 2499.99, sale_type: 'by_quantity', brand: brands[0], category: categories[2] },
  { name: 'MacBook Air 13"', description: 'Ultra-thin laptop with M2 chip', price: 1199.99, sale_type: 'by_quantity', brand: brands[0], category: categories[2] },
  { name: 'Dell XPS 13', description: 'Premium Windows laptop with InfinityEdge display', price: 1299.99, sale_type: 'by_quantity', brand: brands[5], category: categories[2] },
  { name: 'HP Spectre x360', description: '2-in-1 convertible laptop', price: 1399.99, sale_type: 'by_quantity', brand: brands[6], category: categories[2] },
  { name: 'Lenovo ThinkPad X1', description: 'Business laptop with legendary keyboard', price: 1599.99, sale_type: 'by_quantity', brand: brands[7], category: categories[2] },
  
  # Electronics - Audio
  { name: 'AirPods Pro', description: 'Active noise cancellation earbuds', price: 249.99, sale_type: 'by_quantity', brand: brands[0], category: categories[4] },
  { name: 'Sony WH-1000XM5', description: 'Premium noise-canceling headphones', price: 399.99, sale_type: 'by_quantity', brand: brands[3], category: categories[4] },
  { name: 'Bose QuietComfort 45', description: 'Industry-leading noise cancellation', price: 329.99, sale_type: 'by_quantity', brand: brands[3], category: categories[4] },
  
  # Clothing - Shoes
  { name: 'Nike Air Max 270', description: 'Comfortable running shoes with Max Air', price: 150.00, sale_type: 'by_quantity', brand: brands[10], category: categories[8] },
  { name: 'Adidas Ultraboost 22', description: 'Energy-returning running shoes', price: 180.00, sale_type: 'by_quantity', brand: brands[11], category: categories[8] },
  { name: 'Puma RS-X', description: 'Retro-inspired lifestyle sneakers', price: 120.00, sale_type: 'by_quantity', brand: brands[12], category: categories[8] },
  { name: 'Nike Dunk Low', description: 'Classic basketball-inspired sneakers', price: 110.00, sale_type: 'by_quantity', brand: brands[10], category: categories[8] },
  { name: 'Adidas Stan Smith', description: 'Iconic tennis-inspired sneakers', price: 80.00, sale_type: 'by_quantity', brand: brands[11], category: categories[8] },
  
  # Clothing - Apparel
  { name: 'Nike Dri-FIT T-Shirt', description: 'Moisture-wicking athletic t-shirt', price: 25.00, sale_type: 'by_quantity', brand: brands[10], category: categories[7] },
  { name: 'Adidas Originals Hoodie', description: 'Classic three-stripe hoodie', price: 65.00, sale_type: 'by_quantity', brand: brands[11], category: categories[7] },
  { name: 'Levi\'s 501 Jeans', description: 'Original straight-fit jeans', price: 89.00, sale_type: 'by_quantity', brand: brands[17], category: categories[7] },
  { name: 'Zara Blazer', description: 'Modern tailored blazer', price: 79.99, sale_type: 'by_quantity', brand: brands[14], category: categories[7] },
  { name: 'H&M Basic T-Shirt', description: 'Essential cotton t-shirt', price: 9.99, sale_type: 'by_quantity', brand: brands[15], category: categories[7] },
  
  # Food - Fresh Produce
  { name: 'Organic Apples', description: 'Fresh organic red apples', price: 3.99, sale_type: 'by_weight', brand: brands[20], category: categories[16] },
  { name: 'Bananas', description: 'Fresh yellow bananas', price: 1.99, sale_type: 'by_weight', brand: brands[20], category: categories[16] },
  { name: 'Organic Spinach', description: 'Fresh organic baby spinach', price: 4.99, sale_type: 'by_weight', brand: brands[20], category: categories[16] },
  { name: 'Avocados', description: 'Fresh Hass avocados', price: 2.99, sale_type: 'by_weight', brand: brands[20], category: categories[16] },
  { name: 'Organic Carrots', description: 'Fresh organic carrots', price: 2.49, sale_type: 'by_weight', brand: brands[20], category: categories[16] },
  { name: 'Strawberries', description: 'Fresh sweet strawberries', price: 5.99, sale_type: 'by_weight', brand: brands[20], category: categories[16] },
  
  # Food - Dairy
  { name: 'Organic Milk', description: 'Fresh organic whole milk', price: 4.99, sale_type: 'by_quantity', brand: brands[20], category: categories[17] },
  { name: 'Free-Range Eggs', description: 'Farm-fresh free-range eggs (dozen)', price: 6.99, sale_type: 'by_quantity', brand: brands[20], category: categories[17] },
  { name: 'Greek Yogurt', description: 'Creamy Greek yogurt', price: 3.99, sale_type: 'by_quantity', brand: brands[20], category: categories[17] },
  { name: 'Cheddar Cheese', description: 'Aged cheddar cheese', price: 7.99, sale_type: 'by_weight', brand: brands[20], category: categories[17] },
  
  # Food - Beverages
  { name: 'Coca-Cola Classic', description: 'Classic Coca-Cola (12-pack)', price: 8.99, sale_type: 'by_quantity', brand: brands[24], category: categories[19] },
  { name: 'Pepsi Cola', description: 'Classic Pepsi (12-pack)', price: 8.99, sale_type: 'by_quantity', brand: brands[25], category: categories[19] },
  { name: 'Sparkling Water', description: 'Refreshing sparkling water (24-pack)', price: 12.99, sale_type: 'by_quantity', brand: brands[20], category: categories[19] },
  { name: 'Orange Juice', description: 'Fresh squeezed orange juice', price: 4.99, sale_type: 'by_quantity', brand: brands[20], category: categories[19] },
  
  # Home - Kitchen
  { name: 'KitchenAid Stand Mixer', description: 'Professional stand mixer', price: 299.99, sale_type: 'by_quantity', brand: brands[36], category: categories[23] },
  { name: 'Dyson V15 Vacuum', description: 'Cordless vacuum with laser dust detection', price: 649.99, sale_type: 'by_quantity', brand: brands[37], category: categories[22] },
  { name: 'Shark Navigator', description: 'Upright vacuum with self-cleaning brushroll', price: 199.99, sale_type: 'by_quantity', brand: brands[38], category: categories[22] },
  { name: 'IKEA Dining Table', description: 'Modern wooden dining table', price: 199.99, sale_type: 'by_quantity', brand: brands[30], category: categories[22] },
  { name: 'IKEA Office Chair', description: 'Ergonomic office chair', price: 149.99, sale_type: 'by_quantity', brand: brands[30], category: categories[22] },
  
  # Books
  { name: 'The Great Gatsby', description: 'Classic American novel by F. Scott Fitzgerald', price: 12.99, sale_type: 'by_quantity', brand: brands[0], category: categories[26] },
  { name: 'To Kill a Mockingbird', description: 'Harper Lee\'s masterpiece', price: 14.99, sale_type: 'by_quantity', brand: brands[0], category: categories[26] },
  { name: '1984', description: 'George Orwell\'s dystopian classic', price: 13.99, sale_type: 'by_quantity', brand: brands[0], category: categories[26] },
  { name: 'Pride and Prejudice', description: 'Jane Austen\'s romantic novel', price: 11.99, sale_type: 'by_quantity', brand: brands[0], category: categories[26] },
  
  # Toys & Games
  { name: 'LEGO Creator Set', description: 'Creative building blocks set', price: 49.99, sale_type: 'by_quantity', brand: brands[0], category: categories[29] },
  { name: 'Monopoly Board Game', description: 'Classic property trading game', price: 24.99, sale_type: 'by_quantity', brand: brands[0], category: categories[29] },
  { name: 'Scrabble Word Game', description: 'Classic word-building game', price: 19.99, sale_type: 'by_quantity', brand: brands[0], category: categories[29] }
]

items = items_data.map { |attrs| Item.find_or_create_by(name: attrs[:name]) { |item| item.assign_attributes(attrs) } }
puts "Created #{items.count} items"

# Create comprehensive promotions
puts "Creating promotions..."

# Item-specific promotions
item_promotions = [
  {
    name: 'iPhone 15 Pro Launch Sale',
    promotion_type: 'percentage',
    discount_value: 15,
    start_time: 1.day.ago,
    end_time: 1.month.from_now,
    promotionable: items.find { |item| item.name == 'iPhone 15 Pro' }
  },
  {
    name: 'Samsung Galaxy S24 Ultra Deal',
    promotion_type: 'flat_fee',
    discount_value: 200,
    start_time: 1.day.ago,
    end_time: 2.weeks.from_now,
    promotionable: items.find { |item| item.name == 'Samsung Galaxy S24 Ultra' }
  },
  {
    name: 'MacBook Pro Bundle',
    promotion_type: 'flat_fee',
    discount_value: 300,
    start_time: 1.day.ago,
    end_time: 1.month.from_now,
    promotionable: items.find { |item| item.name == 'MacBook Pro 16"' }
  }
]

# Category-specific promotions
category_promotions = [
  {
    name: 'Electronics BOGO',
    promotion_type: 'bogo',
    discount_value: 0,
    buy_quantity: 2,
    get_quantity: 1,
    get_discount_percentage: 100,
    start_time: 1.day.ago,
    end_time: 1.month.from_now,
    promotionable: categories.find { |cat| cat.name == 'Electronics' }
  },
  {
    name: 'Smartphone Trade-In',
    promotion_type: 'percentage',
    discount_value: 20,
    start_time: 1.day.ago,
    end_time: 1.month.from_now,
    promotionable: categories.find { |cat| cat.name == 'Smartphones' }
  },
  {
    name: 'Shoes Buy 2 Get 1 Free',
    promotion_type: 'bogo',
    discount_value: 0,
    buy_quantity: 2,
    get_quantity: 1,
    get_discount_percentage: 100,
    start_time: 1.day.ago,
    end_time: 2.weeks.from_now,
    promotionable: categories.find { |cat| cat.name == 'Shoes' }
  },
  {
    name: 'Fresh Produce Weight Deal',
    promotion_type: 'weight_threshold',
    discount_value: 0,
    weight_threshold: 5.0,
    weight_discount_percentage: 25,
    start_time: 1.day.ago,
    end_time: 1.week.from_now,
    promotionable: categories.find { |cat| cat.name == 'Fresh Produce' }
  }
]

# Brand-specific promotions
brand_promotions = [
  {
    name: 'Apple Store Special',
    promotion_type: 'percentage',
    discount_value: 10,
    start_time: 1.day.ago,
    end_time: 1.month.from_now,
    promotionable: brands.find { |brand| brand.name == 'Apple' }
  },
  {
    name: 'Nike Athletic Gear Sale',
    promotion_type: 'percentage',
    discount_value: 25,
    start_time: 1.day.ago,
    end_time: 2.weeks.from_now,
    promotionable: brands.find { |brand| brand.name == 'Nike' }
  },
  {
    name: 'Adidas Originals Collection',
    promotion_type: 'flat_fee',
    discount_value: 30,
    start_time: 1.day.ago,
    end_time: 1.month.from_now,
    promotionable: brands.find { |brand| brand.name == 'Adidas' }
  },
  {
    name: 'Samsung Galaxy Ecosystem',
    promotion_type: 'percentage',
    discount_value: 15,
    start_time: 1.day.ago,
    end_time: 1.month.from_now,
    promotionable: brands.find { |brand| brand.name == 'Samsung' }
  }
]

# Expired promotions (for testing)
expired_promotions = [
  {
    name: 'Black Friday Sale',
    promotion_type: 'percentage',
    discount_value: 50,
    start_time: 1.month.ago,
    end_time: 1.week.ago,
    promotionable: categories.find { |cat| cat.name == 'Electronics' }
  },
  {
    name: 'Holiday Special',
    promotion_type: 'flat_fee',
    discount_value: 100,
    start_time: 2.weeks.ago,
    end_time: 1.week.ago,
    promotionable: brands.find { |brand| brand.name == 'Apple' }
  }
]

# Future promotions (for testing)
future_promotions = [
  {
    name: 'New Year Sale',
    promotion_type: 'percentage',
    discount_value: 30,
    start_time: 1.week.from_now,
    end_time: 1.month.from_now,
    promotionable: categories.find { |cat| cat.name == 'Clothing' }
  },
  {
    name: 'Spring Collection Launch',
    promotion_type: 'flat_fee',
    discount_value: 50,
    start_time: 2.weeks.from_now,
    end_time: 1.month.from_now,
    promotionable: brands.find { |brand| brand.name == 'Nike' }
  }
]

all_promotions = item_promotions + category_promotions + brand_promotions + expired_promotions + future_promotions
promotions = all_promotions.compact.map do |attrs| 
  Promotion.find_or_create_by(name: attrs[:name]) { |promo| promo.assign_attributes(attrs) }
end
puts "Created #{promotions.count} promotions"

puts "Seed data creation completed!"
puts "Summary:"
puts "   - #{brands.count} brands"
puts "   - #{categories.count} categories" 
puts "   - #{items.count} items"
puts "   - #{promotions.count} promotions"
puts "   - #{Cart.count} carts"
puts "   - #{CartItem.count} cart items"
puts ""
puts "Your e-commerce application is ready for testing!"