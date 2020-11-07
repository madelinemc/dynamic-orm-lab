require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

    self.column_names.each do |column_name|
        #turn each column name into a symbol with .to_sym
        attr_accessor column_name.to_sym
    end

end
