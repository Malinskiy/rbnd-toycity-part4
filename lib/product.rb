require_relative 'udacidata'

class Product < Udacidata
  attr_reader :id, :price, :brand, :name
  create_finder_methods :id, :price, :brand, :name

  @@db_file   = File.dirname(__FILE__) + '/../data/data.csv'
  @@db_schema = %w(id brand name price)
  @@constructor = Product.method(:new)

  def self.schema
    @@db_schema
  end

  def self.where(options)
    superclass.where(@@db_file, @@constructor, options)
  end

  def self.all
    superclass.all(@@db_file, @@constructor)
  end

  def self.first(n=nil)
    superclass.first(@@db_file, @@constructor, n)
  end

  def self.last(n=nil)
    superclass.last(@@db_file, @@constructor, n)
  end

  def self.find(id)
    superclass.find(@@db_file, @@constructor, id)
  end

  def self.destroy(id)
    superclass.destroy(@@db_file, @@constructor, id)
  end

  def initialize(opts={})

    # Get last ID from the database if ID exists
    get_last_id
    # Set the ID if it was passed in, otherwise use last existing ID
    @id = opts[:id] ? opts[:id].to_i : @@count_class_instances
    # Increment ID by 1
    auto_increment if !opts[:id]
    # Set the brand, name, and price normally
    @brand = opts[:brand]
    @name  = opts[:name]
    @price = opts[:price]
  end

  def update(options)
    super(@@db_file, @@db_schema, @@constructor, options)
  end

  def self.create(options)
    # existing = superclass::where(@@db_file, @@constructor, options)

    superclass::create(@@db_file, @@db_schema, @@constructor, options)
  end

  private

  def get_last_id
    # Reads the last line of the data file, and gets the id if one exists
    # If it exists, increment and use this value
    # Otherwise, use 0 as starting ID number
    last_id                 = File.exist?(@@db_file) ? CSV.read(@@db_file).last[0].to_i + 1 : nil
    @@count_class_instances = last_id || 0
  end

  def auto_increment
    @@count_class_instances += 1
  end

end