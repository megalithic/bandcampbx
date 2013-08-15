require_relative './base'

module BandCampBX
  module Entities
    class Order < Base
      class InvalidTypeError < StandardError; end

      def self.map_type
        ->(val) do
          case val.to_s
          when 'Quick Sell'
            :sell
          when 'Quick Buy'
            :buy
          else
            raise InvalidTypeError
          end
        end
      end

      def self.mappings
        {
          id: map_int,
          datetime: map_time,
          type: map_type,
          price: map_decimal,
          amount: map_decimal
        }
      end

      def self.attribute_names
        {
          id: "Order ID",
          datetime: "Order Entered",
          type: "Order Type",
          price: "Price",
          amount: "Quantity"
        }
      end

      setup_readers
    end
  end
end
