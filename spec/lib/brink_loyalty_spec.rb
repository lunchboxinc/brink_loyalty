describe BrinkLoyalty do
  it 'is possible to configure the gem' do

    described_class.configure do |config|
      config.api_key = 'test'
    end

    expect(described_class.configuration.api_key).to eq('test')
  end
end