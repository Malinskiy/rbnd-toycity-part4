require_relative 'find_by'
require_relative 'errors'
require 'csv'

class Udacidata
  def self.create(db_file, db_schema, constructor, options)
    entity = constructor.call options

    return append(db_file, db_schema, entity)
  end

  def self.append(db_file, db_schema, entity)
    CSV.open(db_file, 'ab') do |csv|
      csv << db_schema.map { |field| entity.send(field.to_sym) }
    end

    return entity
  end

  def self.clear(db_file, db_schema)
    CSV.open(db_file, 'wb') do |csv|
      csv << db_schema
    end
  end

  def self.all(db_file, constructor)
    whole_file  = CSV.read(db_file)
    file_schema = whole_file[0]
    data        = whole_file.slice(1, whole_file.length - 1)

    data.map { |cursor| constructor.call(to_options(cursor, file_schema)) }
  end

  def self.to_options(db_array, db_schema)
    db_schema.map.with_index { |attr_name, idx| [attr_name.to_sym, db_array[idx]] }.to_h
  end

  def self.first(db_file, constructor, n=nil)
    all = all(db_file, constructor)
    return n.nil? ? all.first : all.first(n)
  end

  def self.last(db_file, constructor, n=nil)
    all = all(db_file, constructor)
    return n.nil? ? all.last : all.last(n)
  end

  def update(db_file, db_schema, constructor, options)
    existing = Udacidata.all(db_file, constructor)
    options.each { |option, value| instance_variable_set("@#{option}", value) }

    Udacidata.clear(db_file, db_schema)

    existing.each do |entity|
      entity = entity.id == self.id ? self : entity
      Udacidata.append(db_file, db_schema, entity)
    end

    return self
  end

  def self.where(db_file, constructor, options)
    all(db_file, constructor).select { |x| compare_options_with_instance(options, x) }
  end

  def self.compare_options_with_instance(options, x)
    options.map { |symbol, value| x.respond_to?(symbol) && x.public_send(symbol).eql?(value) ? 1 : 0 }.reduce(:+) == options.size
  end

  def self.find(db_file, constructor, id)
    result = flatten(where(db_file, constructor, :id => id).flatten)

    if result.is_a? Product || (result.is_a? Array && !result.empty?)
      return result
    elsif raise ProductNotFoundError.new
    end
  end

  def self.destroy(db_file, constructor, id)
    result = nil

    entities = CSV.read(db_file, headers: true)
    entities.delete_if { |row| row['id'] == id.to_s ? result = row : false }

    if !result.nil?
      File.open(db_file, 'w') do |f|
        f.write(entities.to_csv)
      end

      whole_file  = CSV.read(db_file)
      file_schema = whole_file[0]
      result      = constructor.call(to_options(result, file_schema))
    elsif raise ProductNotFoundError.new
    end

    return result
  end

  def self.flatten(array)
    return array[0] if array.is_a?(Array) && array.length == 1
    return array
  end
end