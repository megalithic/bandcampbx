require_relative './entities/balance'
require_relative './entities/order'

module BandCampBX
  class Mapper
    def initialize
    end

    def map_balance(json)
      Entities::Balance.new(parsed(json))
    end

    def map_orders(json)
      STDOUT.puts json
      orders_data = parsed(json)
      # NOTE: This is because when there are no orders of a given type, the response looks like: {"Buy":[{"Info":"No open Buy Orders"}], ...}
      orders_data = { "Buy" => without_empty_results(orders_data["Buy"]), "Sell" => without_empty_results(orders_data["Sell"]) }
      orders = []
      orders += orders_data["Buy"].map{|o| map_order(o.merge(type: :buy)) }
      orders += orders_data["Sell"].map{|o| map_order(o.merge(type: :sell)) }
      orders.map{|o| map_order(o) }
    end

    def map_order(order)
      if is_error?(parsed(order))
        raise StandardError.new(parsed(order)["Error"])
      else
        begin
          Entities::Order.new(parsed(order)) # NOTE: They give back {"Success"=>"1000486"} - we can't map that to an order
        rescue Exception => e
          raise StandardError.new(e.message)
        end
      end
    end

    def map_cancel(result)
      parsed(result) == 'true'
    end

    private
    # Allow passing either a String or anything else in.  If it's not a string,
    # we assume we've already parsed it and just give it back to you.  This
    # allows us to handle things like collections more easily.
    def parsed(json)
      if(json.is_a?(String))
        BandCampBX::Helpers.json_parse(json)
      else
        json
      end
    end

    def is_error?(data)
      data.has_key?("Error")
    end

    def without_empty_results(orders)
      orders.reject{|order| order["Info"] =~ /\ANo open/ }
    end
  end
end
