require 'bigdecimal'

module BandCampBX
  module Entities
    class Base
      def self.setup_readers
        keys.each {|k| attr_reader k.to_sym }
      end

      def self.keys
        self.mappings.keys
      end

      def initialize(hash)
        check_for_errors(hash)
        map_instance_variables(hash)
      end

      def inspect
        inspect_string = "#<#{self.class}:#{self.object_id} "
        self.class.keys.each do |key|
          inspect_string << "#{key}: #{send(key).inspect} "
        end
        inspect_string << " >"
        inspect_string
      end

      def self.map_time
        ->(val) { Time.parse(val) }
      end

      def self.map_int
        ->(val) { val.to_i }
      end

      def self.map_decimal
        ->(val) { BigDecimal(val) }
      end

      private
      def map_instance_variables(hash)
        self.class.keys.each do |key|
          attribute_name = self.class.attribute_name_for(key)
          instance_variable_set("@#{key}", self.class.mappings[key].call(hash[self.class.attribute_name_for(key)].to_s))
        end
      end

      def self.attribute_name_for(key)
        attribute_names[key]
      end

      def self.attribute_names
        raise "NYI - attribute_names"
      end

      def check_for_errors(hash)
        if hash.has_key?("error")
          if hash["error"].has_key?("__all__")
            raise BandCampBX::StandardError.new(hash["error"]["__all__"].join(".  "))
          else
            raise BandCampBX::StandardError.new("CampBX API Error #404")
          end
        end
      end
    end
  end
end
