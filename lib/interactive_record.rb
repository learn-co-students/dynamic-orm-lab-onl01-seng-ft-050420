require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        sql = "PRAGMA table_info('#{self.table_name}')"
        column_hash = DB[:conn].execute(sql)
        info = column_hash.map do |column|
            column["name"]
        end
        info.compact
    end

    def initialize(hash={})
        hash.each do |k, v|
            self.send("#{k}=", v)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if{|col| col == "id"}.join(", ")
    end

    def values_for_insert
        values_arr = []
        self.class.column_names.each {|col_name| values_arr << "'#{self.send(col_name)}'" if !self.send(col_name).nil?}
        values_arr.join(", ")
    end

    def save
        clas = self.class
        sql = <<-SQL
            INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert})
            VALUES (#{self.values_for_insert})
        SQL
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0] 
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM #{self.table_name}
            WHERE name = ?
        SQL
        DB[:conn].execute(sql, name)
    end

    def self.find_by(hash)
        array = []
        hash.each  do |k, v|  
            array << k.to_s
            array << v
        end
        sql = <<-SQL
            SELECT * 
            FROM #{self.table_name}
            WHERE #{array[0]} = ?
        SQL
        DB[:conn].execute(sql, array[1])
    end
end