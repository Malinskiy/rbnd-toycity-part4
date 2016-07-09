require 'faker'

def db_seed
  10.times do
    Product.create(brand: Faker::Commerce.department, name: Faker::Commerce.product_name, price: Faker::Commerce.price)
  end
end
