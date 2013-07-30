require_relative 'net'
require_relative 'mapper'
require 'bigdecimal/util'

module BandCampBX
  class Client
    attr_accessor :key
    attr_accessor :secret

    def initialize(key = nil, secret = nil)
      @key    = key
      @secret = secret
    end

    def balance
      mapper.map_balance(net.post("myfunds.php"))
    end

    def orders
      mapper.map_orders(net.post("myorders.php"))
    end

    def buy!(amount, price)
      trade!("buy", amount, price)
    end

    def sell!(amount, price)
      trade!("sell", amount, price)
    end

    def cancel(id, type)
      wrapping_standard_error do
        mapper.map_cancel(net.post("tradecancel.php", { id: id.to_s, type: type.to_s }))
      end
    end

    private
    def net
      @net ||= Net.new(self)
    end

    def mapper
      @mapper ||= Mapper.new
    end

    def trade!(type, amount, price)
      wrapping_standard_error do
        mapper.map_order(net.post(type, { price: price.to_digits, amount: amount.to_digits }))
      end
    end

    def wrapping_standard_error &block
      begin
        yield
      rescue ::StandardError => e
        raise BandCampBX::StandardError.new(e.message)
      end
    end
  end
end
