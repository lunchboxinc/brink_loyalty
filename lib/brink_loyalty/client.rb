# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module BrinkLoyalty
  class Client
    def initialize(base_url:, api_key:)
      @base_url = base_url
      @api_key  = api_key
    end

    # -------------------------------------------------------------------------
    # Example: Lookup endpoint
    # POST /Locations/{storeId}/Orders/{orderId}/Lookup
    # -------------------------------------------------------------------------
    def lookup(store_id:, order_id:, body:)
      endpoint = "/Locations/#{store_id}/Orders/#{order_id}/Lookup"
      post_request(endpoint, body)
    end

    # -------------------------------------------------------------------------
    # Finalize endpoint
    # POST /Locations/{storeId}/Orders/{orderId}/Finalize
    # -------------------------------------------------------------------------
    def finalize(store_id:, order_id:, body:)
      endpoint = "/Locations/#{store_id}/Orders/#{order_id}/Finalize"
      post_request(endpoint, body)
    end

    # -------------------------------------------------------------------------
    # POS Configurations endpoint
    # GET /Locations/{storeId}/POSConfigurations
    # -------------------------------------------------------------------------
    def pos_configurations(store_id:)
      endpoint = "/Locations/#{store_id}/POSConfigurations"
      get_request(endpoint)
    end

    # -------------------------------------------------------------------------
    # Receipt endpoint
    # POST /Locations/{storeId}/Orders/{orderId}/Receipt
    # -------------------------------------------------------------------------
    def receipt(store_id:, order_id:, body:)
      endpoint = "/Locations/#{store_id}/Orders/#{order_id}/Receipt"
      post_request(endpoint, body)
    end

    # -------------------------------------------------------------------------
    # Redeem endpoint
    # POST /Locations/{storeId}/Orders/{orderId}/Redeem
    # -------------------------------------------------------------------------
    def redeem(store_id:, order_id:, body:)
      endpoint = "/Locations/#{store_id}/Orders/#{order_id}/Redeem"
      post_request(endpoint, body)
    end

    # -------------------------------------------------------------------------
    # Remove Rewards (void) endpoint
    # DELETE /Locations/{storeId}/Orders/{orderId}/Redeem
    # -------------------------------------------------------------------------
    def remove_rewards(store_id:, order_id:, body:)
      endpoint = "/Locations/#{store_id}/Orders/#{order_id}/Redeem"
      delete_request(endpoint, body)
    end

    # -------------------------------------------------------------------------
    # Validate endpoint
    # POST /Locations/{storeId}/Orders/{orderId}/Validate
    # -------------------------------------------------------------------------
    def validate_order(store_id:, order_id:, body:)
      endpoint = "/Locations/#{store_id}/Orders/#{order_id}/Validate"
      post_request(endpoint, body)
    end

    private

    def get_request(endpoint)
      uri = URI.join(@base_url, endpoint)
      request = Net::HTTP::Get.new(uri)
      apply_auth(request)
      execute_request(uri, request)
    end

    def post_request(endpoint, body)
      uri = URI.join(@base_url, endpoint)
      request = Net::HTTP::Post.new(uri)
      request.content_type = 'application/json'
      request.body = body.to_json
      apply_auth(request)
      execute_request(uri, request)
    end

    def delete_request(endpoint, body)
      uri = URI.join(@base_url, endpoint)
      request = Net::HTTP::Delete.new(uri)
      request.content_type = 'application/json'
      request.body = body.to_json
      apply_auth(request)
      execute_request(uri, request)
    end

    def apply_auth(request)
      return unless @api_key

      # If using a bearer token:
      # request['Authorization'] = "Bearer #{@api_key}"

      # If using a custom header or similar approach:
      request['APIKey'] = @api_key
    end

    def execute_request(uri, request)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        response = http.request(request)
        parse_response(response)
      end
    end

    def parse_response(response)
      body = response.body && !response.body.empty? ? JSON.parse(response.body) : {}
      {
        code:    response.code.to_i,
        body:    body,
        headers: response.each_header.to_h
      }
    rescue JSON::ParserError
      # Non-JSON response fallback
      {
        code:    response.code.to_i,
        body:    response.body,
        headers: response.each_header.to_h
      }
    end
  end
end
