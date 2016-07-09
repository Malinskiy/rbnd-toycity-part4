class Module
  def create_finder_methods(*attributes)
    attributes.each do |attr|
      metaclass.instance_eval do
        define_method "find_by_#{attr}".to_sym do |value|
          flatten(where({attr => value}).flatten)
        end
      end
    end
  end
end

class Object
  def metaclass
    class << self;
      self;
    end
  end
end