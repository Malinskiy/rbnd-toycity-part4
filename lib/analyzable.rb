module Analyzable
  def count_by_brand(entities)
    count_by(:brand, entities)
  end


  def count_by_name(entities)
    count_by(:name, entities)
  end

  def average_price(entities)
    average(:price, entities)
  end

  def print_report(entities)
    report = ''
    report << "Average Price: $#{average_price(entities)}\n\r"

    report << "Inventory by Brand:\n\r"
    count_by_brand(entities).each {|brand, count| report << "\t- #{brand}: #{count}\n\r" }

    report << "Inventory by Name:\n\r"
    count_by_name(entities).each {|name, count| report << "\t- #{name}: #{count}\n\r"}

    return report
  end

  def average(attr, entities)
    sum = entities.map { |entity| entity.send(attr.to_sym).to_f }.reduce(:+)
    return (sum / entities.size).round(2)
  end

  def count_by(attr, entities)
    result = Hash.new(0)

    entities.each { |entity| result[entity.send(attr)] += 1 }

    return result
  end
end

# class Module
#   def create_analyzable_methods(*attributes)
#     attributes.each do |attr|
#       metaclass.instance_eval do
#         define_method "average_#{attr}".to_sym do |value|
#         end
#       end
#     end
#   end
# end