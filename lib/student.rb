require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  attr_accessor :name, :grade, :id
  
  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end 
  end
  
  def table_name_for_insert
    return Student.table_name
  end
  
  def col_names_for_insert
    col_names = Student.column_names
    col_names.delete("id")
    return col_names.join(", ")
  end
  
  def values_for_insert
    values = ["'#{@name}'", "'#{@grade}'"]
    return values.join(", ")
  end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM  #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{Student.table_name} WHERE name = '#{name}'"
    return DB[:conn].execute(sql)
  end
  
  def self.find_by(attribute)
    sql = ""
    
    attribute.each do |key, value|
      if value.is_a? String
        sql = "SELECT * FROM #{Student.table_name} WHERE #{key} = '#{value}'"
      else
        sql = "SELECT * FROM #{Student.table_name} WHERE #{key} = #{value}"
      end
    end
    
    return DB[:conn].execute(sql)
  end
end
