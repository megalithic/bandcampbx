require_relative '../../spec_helper'

describe BandCampBX::Mapper do
  subject(:mapper) { described_class.new }
  let(:json_object){ '{"foo": "bar"}' }
  let(:json_array){ '[{"foo": "bar"}]' }

  describe '#map_balance' do
    let(:balance) { double }

    before do
      Entities::Balance.stub(:new).and_return(balance)
    end

    it "maps a balance API response into a Balance entity" do
      mapper.map_balance(json_object)
      expect(Entities::Balance).to have_received(:new).with(json_parse(json_object))
    end

    it "returns the mapped Balance entity" do
      expect(mapper.map_balance(json_object)).to eq(balance)
    end
  end

  describe '#map_order' do
    let(:order) { double }
  end

  describe '#map_orders' do
    let(:order) { double }

    it "filters out empty results appropriately" do
      empty_json = '{"Buy": [{"Info":"No open Buy Orders"}], "Sell": [{"Info":"No open Sell Orders"}]}'
      expect(mapper.map_orders(empty_json)).to eq([])
    end

    it "returns an Order if mapped appropriately" do
      Entities::Order.stub(:new).and_return(order)
      expect(mapper.map_order(json_object)).to eq(order)
    end

    it "raises a StandardError if it doesn't know what to do with a mapping" do
      expect{ mapper.map_order('{}') }.to raise_error(StandardError)
    end

    it "raises an InvalidTradeTypeError if that message comes back from the API" do
      expect{ mapper.map_order('{"Error":"Invalid trade type."}') }.to raise_error(StandardError, "Invalid trade type.")
    end
  end

  describe '#map_cancel' do
    it "maps a cancel API response to a boolean" do
      expect(mapper.map_cancel('"true"')).to eq(true)
      expect(mapper.map_cancel('"false"')).to eq(false)
    end
  end

  describe "#map_ticker" do
    it "maps a ticker response to a JSON object" do
      json_string = "{\"Last Trade\":\"143.23\",\"Best Bid\":\"142.92\",\"Best Ask\":\"143.99\"}"
      json_object = {trade: 143.23, bid: 142.92, ask: 143.99}
      expect(mapper.map_ticker(json_string)).to eq(json_object)
    end
  end
end
