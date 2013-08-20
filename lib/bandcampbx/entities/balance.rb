require_relative './base'

module BandCampBX
  module Entities
    class Balance < Base
      def self.mappings
        {
          usd_balance: map_decimal,
          btc_balance: map_decimal
        }
      end

      def self.attribute_names
        {
          usd_balance: "Total USD",
          btc_balance: "Total BTC"
        }
      end

      setup_readers
    end
  end
end
