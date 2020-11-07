require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true

        table_columns = DB[:conn].execute("PRAGMA table_info(#{table_name})")
        column_names = []
    
        table_columns.each do |col|
          column_names << col["name"]
        end
    
        column_names.compact
    end

    def initialize(object = {})
        object.each do |k, v|
        self.send("#{k}=", v)
        end
    end

    def values_for_insert
        values_array = []
        self.class.column_names.each do |col_name|
            values_array << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values_array.join(", ")
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if { |col_name| col_name == "id"}.join(", ")
    end

    def save
        sql = <<-SQL
        INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
        VALUES (#{values_for_insert})
        SQL
  
      DB[:conn].execute(sql)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM #{self.table_name}
        WHERE name = ?
        SQL

        DB[:conn].execute(sql, name)
    end

    def self.find_by(attribute) #find a row by attribute
        attribute_key = attribute.keys[0].to_s
        attribute_value = attribute.values[0]

        sql = <<-SQL
        SELECT * FROM #{self.table_name}
        WHERE #{attribute_key} = "#{attribute_value}"
        LIMIT 1
        SQL

        DB[:conn].execute(sql)
    end
  
end