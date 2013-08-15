require_relative '../spec_helper'

describe "Integrating a client" do
  subject{ Client.new }

  before do
    subject.secret = '1'
    subject.key = '2'
  end

  it "handles #balance" do
    example_balance = <<-JSON
      {
        "usd_balance": "12.34",
        "btc_balance": "23.45",
        "usd_reserved": "1.11",
        "btc_reserved": "2.22",
        "usd_available": "11.23",
        "btc_available": "21.23",
        "fee": "0.5"
      }
    JSON

    FakeWeb.register_uri(:post, "https://campbx.com/api/myfunds.php", body: example_balance)

    bal = subject.balance
    expect(bal.usd_balance).to eq(BigDecimal('12.34'))
  end

  it "handles #orders" do
    example_orders = <<-JSON
      {
        "Buy": [
          {
            "id": "1",
            "datetime": "1234567",
            "type": 0,
            "price": "12.34",
            "quantity": "100"
          }
        ],
        "Sell": []
      }
    JSON

    FakeWeb.register_uri(:post, "https://campbx.com/api/myorders.php", body: example_orders)

    orders = subject.orders
    expect(orders[0].type).to eq(:buy)
  end

  context "handling #buy!" do
    it "succeeds properly" do
      example_buy_response = <<-JSON
        {
          "id": "1",
          "datetime": "1234567",
          "type": "0",
          "price": "12.34",
          "quantity": "100"
        }
      JSON

      FakeWeb.register_uri(:post, "https://campbx.com/api/tradeenter.php", body: example_buy_response)

      buy = subject.buy!(BigDecimal('1'), BigDecimal('100'), "QuickBuy")
      expect(buy.type).to eq(:buy)
    end

    it "fails properly" do
      example_buy_response = <<-JSON
        {"error":{"__all__":["Minimum order quantity is 0.1"]}}
      JSON

      FakeWeb.register_uri(:post, "https://campbx.com/api/tradeenter.php", body: example_buy_response)

      expect{ subject.buy!(BigDecimal('0.01'), BigDecimal('100'), 'QuickBuy') }.to raise_error(BandCampBX::StandardError, "Minimum order quantity is 0.1")
    end
  end

  it "handles #sell!" do
    example_sell_response = <<-JSON
      {
        "id": "1",
        "datetime": "1234567",
        "type": "1",
        "price": "12.34",
        "quantity": "100"
      }
    JSON

    FakeWeb.register_uri(:post, "https://campbx.com/api/tradeenter.php", body: example_sell_response)

    sell = subject.sell!(BigDecimal('1'), BigDecimal('100'), "QuickSell")
    expect(sell.type).to eq(:sell)
  end

  it "handles #cancel" do
    example_cancel_response = <<-JSON
      "true"
    JSON

    FakeWeb.register_uri(:post, "https://campbx.com/api/tradecancel.php", body: example_cancel_response)

    cancel = subject.cancel(12345, "Buy")
    expect(cancel).to eq(true)
  end
end
