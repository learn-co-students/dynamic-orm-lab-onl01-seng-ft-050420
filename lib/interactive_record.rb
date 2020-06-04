require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info(#{table_name})" # Possible to use a bound parameter here?
    table_info = DB[:conn].execute(sql)
    column_names = table_info.map { |row| row["name"] } # `.compact` removes `nil` elements~!
    column_names.compact
  end

  def initialize(attributes = {})
    attributes.map { |attribute, value| self.send("#{attribute}=", value) }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    x = self.class.column_names.delete_if { |col| col == "id" }.join(", ") # We don't *ever* touch `id`s.
  end

  def values_for_insert
    values = [] 
    self.class.column_names.each { |col_name| values << "'#{send(col_name)}'" unless send(col_name).nil? }
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql) # Same thing here; is it possible to use multiple bound parameters?
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE name = ?
      SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    column = attribute.keys[0].to_s
    value = attribute.values[0]
    #binding.pry
    sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE #{column} = ?
    SQL
    DB[:conn].execute(sql, value)
  end
  
end