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
      orders_data = parsed(json)
      # NOTE: This is because when there are no orders of a given type, the response looks like: {"Buy":[{"Info":"No open Buy Orders"}], ...}
      orders_data = { "Buy" => without_empty_results(orders_data["Buy"]), "Sell" => without_empty_results(orders_data["Sell"]) }
      orders = []
      orders += orders_data["Buy"].map{|o| map_order(o.merge(type: :buy)) }
      orders += orders_data["Sell"].map{|o| map_order(o.merge(type: :sell)) }
      orders
    end

    def map_trade(trade)
      handle_error(parsed(trade))
      parsed(trade)["Success"].to_i
    end

    def map_order(order)
      handle_error(parsed(order))
      begin
        Entities::Order.new(parsed(order)) # NOTE: They give back {"Success"=>"1000486"} - we can't map that to an order
      rescue Exception => e
        raise StandardError.new(e.message)
      end
    end

    def map_cancel(result)
      parsed(result) == 'true'
    end

    def map_ticker(result)
      parsed_result = parsed(result)
      {
        ask: parsed_result["Best Ask"].to_f,
        bid: parsed_result["Best Bid"].to_f,
        trade: parsed_result["Last Trade"].to_f
      }
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

    def handle_error(data)
      raise StandardError.new(data["Error"]) if is_error?(data)
    end

    def is_error?(data)
      data.has_key?("Error")
    end

    def without_empty_results(orders)
      orders.reject{|order| order["Info"] =~ /\ANo open/ }
    end
  end
end
