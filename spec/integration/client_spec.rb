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
        "Total USD":"0.20",
        "Total BTC":"0.10000000",
        "Liquid USD":"0.00",
        "Liquid BTC":"0.08000000",
        "Margin Account USD":"0.00",
        "Margin Account BTC":"0.00000000"
      }
    JSON

    FakeWeb.register_uri(:post, "https://campbx.com/api/myfunds.php", body: example_balance)

    bal = subject.balance
    expect(bal.btc_balance).to eq(BigDecimal('0.1'))
    expect(bal.usd_balance).to eq(BigDecimal('0.2'))
  end

  it "handles #orders" do
    example_orders = <<-JSON
      {
        "Buy":[
          {"Info":"No open Buy Orders"}
        ],
        "Sell":[
          {
            "Order Entered":"2013-08-13 16:06:29",
            "Order Expiry":"2013-11-20 15:06:29",
            "Order Type":"Quick Sell",
            "Margin Percent":"None",
            "Quantity":"0.01000000",
            "Price":"108.00",
            "Stop-loss":"No",
            "Fill Type":"Incr",
            "Dark Pool":"No",
            "Order ID":"1000486"
          },
          {
            "Order Entered":"2013-08-13 16:04:33",
            "Order Expiry":"2013-11-20 15:04:33",
            "Order Type":"Quick Sell",
            "Margin Percent":"None",
            "Quantity":"0.01000000",
            "Price":"108.00",
            "Stop-loss":"No",
            "Fill Type":"Incr",
            "Dark Pool":"No",
            "Order ID":"1000477"
          }
        ]
      }
    JSON

    FakeWeb.register_uri(:post, "https://campbx.com/api/myorders.php", body: example_orders)

    orders = subject.orders
    expect(orders[0].type).to eq(:sell)
  end

  context "handling #buy!" do
    it "succeeds properly" do
      example_buy_response = <<-JSON
        \r\n
        {"Success":"1010399"}
      JSON

      FakeWeb.register_uri(:post, "https://campbx.com/api/tradeenter.php", body: example_buy_response)

      buy = subject.buy!(BigDecimal('1'), BigDecimal('100'), "QuickBuy")
      expect(buy).to eq(1010399)
    end

    it "fails properly" do
      example_buy_response = <<-JSON
        {"Error":"Minimum quantity for a trade is :1000000 Satoshis."}
      JSON

      FakeWeb.register_uri(:post, "https://campbx.com/api/tradeenter.php", body: example_buy_response)

      expect{ subject.buy!(BigDecimal('0.01'), BigDecimal('100'), 'QuickBuy') }.to raise_error(BandCampBX::StandardError, "Minimum quantity for a trade is :1000000 Satoshis.")
    end
  end

  it "handles #sell!" do
    example_sell_response = <<-JSON
      \r\n
      {"Success":"1010399"}
    JSON

    FakeWeb.register_uri(:post, "https://campbx.com/api/tradeenter.php", body: example_sell_response)

    sell = subject.sell!(BigDecimal('1'), BigDecimal('100'), "QuickSell")
    expect(sell).to eq(1010399)
  end

  it "handles #cancel" do
    example_cancel_response = <<-JSON
      "true"
    JSON

    FakeWeb.register_uri(:post, "https://campbx.com/api/tradecancel.php", body: example_cancel_response)

    cancel = subject.cancel(12345, "Buy")
    expect(cancel).to eq(true)
  end

  it "handles #ticker" do
    example_ticker_response = <<-JSON
      {"Last Trade":"143.23","Best Bid":"142.92","Best Ask":"143.99"}
    JSON

    FakeWeb.register_uri(:post, "https://campbx.com/api/xticker.php", body: example_ticker_response)
    ticker = subject.ticker
    expect(ticker).to eq({trade: 143.23, bid: 142.92, ask: 143.99})
  end
end
