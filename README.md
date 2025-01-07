# Brink Loyalty

Brink Loyalty is a Ruby gem designed to facilitate integration with the Brink Generic Loyalty API. It provides a simple SDK for interacting with various endpoints related to loyalty programs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brink_loyalty'
```

Then run `bundle install`.


## Usage

### Configuration

Before using the gem, you need to configure it with your API credentials:

```ruby
BrinkLoyalty.configure do |config|
  config.api_key = 'your_api_key'
  config.base_url = 'base_url'
end
```

### Client

Create a client instance to interact with the API:

```ruby
client = BrinkLoyalty.client
```


### Endpoints

The gem provides methods to interact with various endpoints:

- **Lookup Order**:
  ```ruby
  client.lookup(store_id: '123', order_id: '456', body: { ... })
  ```

- **Finalize Order**:
  ```ruby
  client.finalize(store_id: '123', order_id: '456', body: { ... })
  ```

- **POS Configurations**:
  ```ruby
  client.pos_configurations(store_id: '123')
  ```

- **Receipt**:
  ```ruby
  client.receipt(store_id: '123', order_id: '456', body: { ... })
  ```

- **Redeem Rewards**:
  ```ruby
  client.redeem(store_id: '123', order_id: '456', body: { ... })
  ```

- **Remove Rewards**:
  ```ruby
  client.remove_rewards(store_id: '123', order_id: '456', body: { ... })
  ```

- **Validate Order**:
  ```ruby
  client.validate_order(store_id: '123', order_id: '456', body: { ... })
  ```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/lunchboxinc/brink_loyalty](https://github.com/lunchboxinc/brink_loyalty). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://www.contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
