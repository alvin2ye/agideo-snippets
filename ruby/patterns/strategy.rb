class Desktop
  attr_accessor :price

  def get_money_after_discount(dic_type)
    dic_type.calc(price)
  end
end

class Discount
  def calc(price)
    raise 'Called abstract method : calc'
  end
end

class DiscountA < Discount
  def calc(price)
    puts "打了九折"
    return price * 0.9
  end
end

class DiscountB < Discount
  def calc(price)
    puts "满100 少 50"
    # ...
    return 60
  end
end

d = Desktop.new
d.price = 110
puts d.get_money_after_discount(DiscountB.new)
puts 
puts d.get_money_after_discount(DiscountA.new)
