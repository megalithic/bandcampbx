require_relative '../spec_helper'

describe BandCampBX do
  it "should be an instance rather than a singleton" do
    client = BandCampBX::Client.new
    expect(client.key).to eq(nil)
    expect(client.secret).to eq(nil)
    client.key = '1'
    client.secret = '2'
    expect(client.key).to eq('1')
    expect(client.secret).to eq('2')
  end
end
