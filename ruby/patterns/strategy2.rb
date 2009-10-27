class Desktop
  attr_reader :price
  attr_accessor :discount

  def initialize(price, discount)
    @price = price
    @discount = discount
  end

  def get_money_after_discount
    @discount.call(@price)
  end
end

DiscountA =  lambda do |price|
    puts "打了九折"
    return price * 0.9
end

d = Desktop.new(110, DiscountA)
puts d.get_money_after_discount
