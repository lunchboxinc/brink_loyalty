# frozen_string_literal: true

require 'brink_loyalty/version'
require 'brink_loyalty/configuration'
require 'brink_loyalty/client'

module BrinkLoyalty
  class << self
    # Expose a thread-safe config object
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    # Returns a BrinkLoyalty::Client instance using the current configuration
    def client
      unless configuration
        raise "BrinkLoyalty is not configured. Call BrinkLoyalty.configure first."
      end

      Client.new(
        base_url: configuration.base_url,
        api_key:  configuration.api_key
      )
    end
  end
end
