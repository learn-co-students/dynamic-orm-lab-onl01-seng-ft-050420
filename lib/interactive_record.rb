require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    def self.table_name 
       self.to_s.downcase.pluralize 
    end 

    def self.column_names 
      DB[:conn].results_as_hash = true
      DB[:conn].execute("PRAGMA table_info('#{table_name}')").map {|column| column["name"]}.compact 
    end 

    def initialize(options={})
      options.each {|prop, value| self.send("#{prop}=", value)}
    end 

    def table_name_for_insert 
       self.class.table_name 
    end 

    def col_names_for_insert
      self.class.column_names.delete_if {|col| col == 'id'}.join(', ')
    #    a = self.class.column_names
    #    a.delete('id')
    #    a.join(', ')
    end 

    def values_for_insert
   
         
        values = [] 
        self.class.column_names.each do |col_names|
            values << "'#{send(col_names)}'" unless send(col_names).nil? 
        end 
        values.join(', ')
    #     a = self.class.column_names.map { |col_names| "'#{send(col_names)}'" unless send(col_names).nil? }
    #     a.delete_if{|ele| ele == nil}
    #     a.join(', ')
     end 

     def save
       
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
      
        DB[:conn].execute(sql)
        
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

   def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", [name])
   end 

   def self.find_by(attribute)
    column_name = attribute.keys[0].to_s
    value_name = attribute.values[0]

    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE #{column_name} = ?
      SQL

    DB[:conn].execute(sql, value_name);
  end


  
end