# frozen_string_literal: true

module BrinkLoyalty
  class Configuration
    attr_accessor :base_url, :api_key

    def initialize
      # Provide default values, if desired
      @base_url = nil
      @api_key  = nil
    end
  end
end
