# spec/brink_generic_loyalty/client_spec.rb

require 'spec_helper'
require 'webmock/rspec'

RSpec.describe BrinkLoyalty::Client do
  let(:store_id) { "STORE123" }
  let(:order_id) { "ORDER456" }

  before do
    BrinkLoyalty.configure do |config|
      config.base_url = "https://api.example.com"
      config.api_key  = "TEST_API_KEY"
    end

    @client = BrinkLoyalty.client
  end

  # ---------------------------------------------------------------------------
  # 1) Lookup
  # POST /Locations/{storeId}/Orders/{orderId}/Lookup
  # ---------------------------------------------------------------------------
  describe "#lookup" do
    let(:lookup_body) do
      {
        emailAddress: "user@example.com",
        order: { id: 123456 },
        employee: { id: 1001 }
      }
    end

    context "when 200 Success" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Lookup")
          .to_return(
            status: 200,
            body: {
              id: "CUSTOMER001",
              name: "John Smith",
              memberDetail: "john.smith@sampleloyalty.com",
              points: 100
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns a 200 with loyalty details" do
        response = @client.lookup(store_id: store_id, order_id: order_id, body: lookup_body)
        expect(response[:code]).to eq(200)
        expect(response[:body]).to include("id" => "CUSTOMER001", "points" => 100)
      end
    end

    context "when 401 Unauthorized" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Lookup")
          .to_return(
            status: 401,
            body: {
              message: "Unauthorized",
              code: 401,
              errors: [
                { source: "ModuleName", error: "APIKey is invalid" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns 401 with an unauthorized message" do
        response = @client.lookup(store_id: store_id, order_id: order_id, body: lookup_body)
        expect(response[:code]).to eq(401)
        expect(response[:body]).to include("message" => "Unauthorized")
      end
    end

    context "when 500 Server Error" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Lookup")
          .to_return(
            status: 500,
            body: {
              message: "Loyalty is unreachable",
              code: 500,
              errors: [
                { source: "ModuleName", error: "Unable to reach loyalty" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns 500 with an error message" do
        response = @client.lookup(store_id: store_id, order_id: order_id, body: lookup_body)
        expect(response[:code]).to eq(500)
        expect(response[:body]).to include("message" => "Loyalty is unreachable")
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 2) Finalize
  # POST /Locations/{storeId}/Orders/{orderId}/Finalize
  # ---------------------------------------------------------------------------
  describe "#finalize" do
    let(:finalize_body) do
      {
        order: { id: 123456 },
        employee: { id: 1001 },
        destination: { id: 1 },
        terminalId: 1
      }
    end

    context "when 200 Success" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Finalize")
          .to_return(
            status: 200,
            body: { success: true }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns success: true" do
        response = @client.finalize(store_id: store_id, order_id: order_id, body: finalize_body)
        expect(response[:code]).to eq(200)
        expect(response[:body]).to eq("success" => true)
      end
    end

    context "when 401 Unauthorized" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Finalize")
          .to_return(
            status: 401,
            body: {
              message: "Unauthorized",
              code: 401,
              errors: [
                { source: "ModuleName", error: "APIKey is invalid" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns a 401 with unauthorized message" do
        response = @client.finalize(store_id: store_id, order_id: order_id, body: finalize_body)
        expect(response[:code]).to eq(401)
        expect(response[:body]).to include("message" => "Unauthorized")
      end
    end

    context "when 500 Server Error" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Finalize")
          .to_return(
            status: 500,
            body: {
              message: "Invalid reward",
              code: 500,
              errors: [
                { source: "ModuleName", error: "Unable to apply reward" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns 500 with error message" do
        response = @client.finalize(store_id: store_id, order_id: order_id, body: finalize_body)
        expect(response[:code]).to eq(500)
        expect(response[:body]).to include("message" => "Invalid reward")
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 3) POSConfigurations
  # GET /Locations/{storeId}/POSConfigurations
  # ---------------------------------------------------------------------------
  describe "#pos_configurations" do
    context "when 200 Success" do
      before do
        stub_request(:get, "https://api.example.com/Locations/#{store_id}/POSConfigurations")
          .to_return(
            status: 200,
            body: {
              callFinalizeForNonLoyaltyOrders: true,
              notifyOrderModifications: true,
              supportsEnteringRewardCode: true,
              supportsRedeemingMultipleRewards: true
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns the POS configurations" do
        response = @client.pos_configurations(store_id: store_id)
        expect(response[:code]).to eq(200)
        expect(response[:body]).to include("callFinalizeForNonLoyaltyOrders" => true)
      end
    end

    context "when 401 Unauthorized" do
      before do
        stub_request(:get, "https://api.example.com/Locations/#{store_id}/POSConfigurations")
          .to_return(
            status: 401,
            body: {
              message: "Unauthorized",
              code: 401,
              errors: [
                { source: "ModuleName", error: "APIKey is invalid" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns a 401 error" do
        response = @client.pos_configurations(store_id: store_id)
        expect(response[:code]).to eq(401)
        expect(response[:body]).to include("message" => "Unauthorized")
      end
    end

    context "when 500 Server Error" do
      before do
        stub_request(:get, "https://api.example.com/Locations/#{store_id}/POSConfigurations")
          .to_return(
            status: 500,
            body: {
              message: "Loyalty is unreachable",
              code: 500,
              errors: [
                { source: "ModuleName", error: "Unable to reach loyalty" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns 500 with server error message" do
        response = @client.pos_configurations(store_id: store_id)
        expect(response[:code]).to eq(500)
        expect(response[:body]).to include("message" => "Loyalty is unreachable")
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 4) Receipt
  # POST /Locations/{storeId}/Orders/{orderId}/Receipt
  # ---------------------------------------------------------------------------
  describe "#receipt" do
    let(:receipt_body) do
      {
        order: { id: 123456 },
        destination: { id: 1, name: "Eat In" }
      }
    end

    context "when 200 Success" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Receipt")
          .to_return(
            status: 200,
            body: {
              lines: ["This is a", "test receipt", "with multiple lines"]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns the lines array" do
        response = @client.receipt(store_id: store_id, order_id: order_id, body: receipt_body)
        expect(response[:code]).to eq(200)
        expect(response[:body]["lines"]).to eq(["This is a", "test receipt", "with multiple lines"])
      end
    end

    context "when 401 Unauthorized" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Receipt")
          .to_return(
            status: 401,
            body: {
              message: "Unauthorized",
              code: 401,
              errors: [
                { source: "ModuleName", error: "APIKey is invalid" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns 401 with error" do
        response = @client.receipt(store_id: store_id, order_id: order_id, body: receipt_body)
        expect(response[:code]).to eq(401)
        expect(response[:body]).to include("message" => "Unauthorized")
      end
    end

    context "when 500 Server Error" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Receipt")
          .to_return(
            status: 500,
            body: {
              message: "Unable to reach loyalty",
              code: 500,
              errors: [
                { source: "ModuleName", error: "Unable to reach loyalty" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns a 500 with a server error" do
        response = @client.receipt(store_id: store_id, order_id: order_id, body: receipt_body)
        expect(response[:code]).to eq(500)
        expect(response[:body]).to include("message" => "Unable to reach loyalty")
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 5) Redeem
  # POST /Locations/{storeId}/Orders/{orderId}/Redeem
  # ---------------------------------------------------------------------------
  describe "#redeem" do
    let(:redeem_body) do
      {
        order: {
          id: 123456,
          customerAccountNumber: "CUSTOMER001"
        },
        employee: { id: 1001 },
        offerCode: "",
        selectedRewards: [
          {
            amount: 2,
            autoApply: true,
            brinkDiscountId: 1242354,
            id: "ID020",
            name: "$2 off order"
          }
        ]
      }
    end

    context "when 200 Success" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Redeem")
          .to_return(
            status: 200,
            body: {
              rewardsToRemove: [],
              rewardsToApply: [
                {
                  amount: 2,
                  autoApply: true,
                  brinkDiscountId: 1242354,
                  id: "ID020",
                  name: "$2 off order"
                }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns rewards to apply" do
        response = @client.redeem(store_id: store_id, order_id: order_id, body: redeem_body)
        expect(response[:code]).to eq(200)
        expect(response[:body]["rewardsToApply"].first["name"]).to eq("$2 off order")
      end
    end

    context "when 401 Unauthorized" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Redeem")
          .to_return(
            status: 401,
            body: {
              message: "Unauthorized",
              code: 401,
              errors: [
                { source: "ModuleName", error: "APIKey is invalid" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns 401 unauthorized" do
        response = @client.redeem(store_id: store_id, order_id: order_id, body: redeem_body)
        expect(response[:code]).to eq(401)
        expect(response[:body]).to include("message" => "Unauthorized")
      end
    end

    context "when 500 Server Error" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Redeem")
          .to_return(
            status: 500,
            body: {
              message: "Invalid reward",
              code: 500,
              errors: [
                { source: "ModuleName", error: "Unable to apply reward" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns 500 invalid reward error" do
        response = @client.redeem(store_id: store_id, order_id: order_id, body: redeem_body)
        expect(response[:code]).to eq(500)
        expect(response[:body]).to include("message" => "Invalid reward")
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 6) Remove Rewards (DELETE)
  # DELETE /Locations/{storeId}/Orders/{orderId}/Redeem
  # ---------------------------------------------------------------------------
  describe "#remove_rewards" do
    let(:remove_body) do
      {
        order: { id: 123456 },
        employee: { id: 1001 },
        rewardsToRemove: [
          {
            id: "ID020",
            name: "$2 off order"
          }
        ]
      }
    end

    context "when 200 Success" do
      before do
        stub_request(:delete, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Redeem")
          .to_return(
            status: 200,
            body: { success: true }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns success true" do
        response = @client.remove_rewards(store_id: store_id, order_id: order_id, body: remove_body)
        expect(response[:code]).to eq(200)
        expect(response[:body]).to eq("success" => true)
      end
    end

    context "when 401 Unauthorized" do
      before do
        stub_request(:delete, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Redeem")
          .to_return(
            status: 401,
            body: {
              message: "Unauthorized",
              code: 401,
              errors: [
                { source: "ModuleName", error: "APIKey is invalid" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns 401 unauthorized" do
        response = @client.remove_rewards(store_id: store_id, order_id: order_id, body: remove_body)
        expect(response[:code]).to eq(401)
        expect(response[:body]).to include("message" => "Unauthorized")
      end
    end

    context "when 500 Server Error" do
      before do
        stub_request(:delete, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Redeem")
          .to_return(
            status: 500,
            body: {
              message: "Invalid user",
              code: 500,
              errors: [
                { source: "ModuleName", error: "User not found with loyalty" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns 500 invalid user error" do
        response = @client.remove_rewards(store_id: store_id, order_id: order_id, body: remove_body)
        expect(response[:code]).to eq(500)
        expect(response[:body]).to include("message" => "Invalid user")
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 7) Validate
  # POST /Locations/{storeId}/Orders/{orderId}/Validate
  # ---------------------------------------------------------------------------
  describe "#validate_order" do
    let(:validate_body) do
      {
        order: { id: 123456, discounts: [] },
        employee: { id: 1001 },
        destination: { id: 1 },
        terminalId: 1
      }
    end

    context "when 200 Success" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Validate")
          .to_return(
            status: 200,
            body: {
              rewardsToRemove: [],
              rewardsToApply: [
                {
                  amount: 2,
                  autoApply: true,
                  id: "ID020",
                  name: "$2 off order"
                }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns 200 with rewards to apply" do
        response = @client.validate_order(store_id: store_id, order_id: order_id, body: validate_body)
        expect(response[:code]).to eq(200)
        expect(response[:body]["rewardsToApply"].first["name"]).to eq("$2 off order")
      end
    end

    context "when 401 Unauthorized" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Validate")
          .to_return(
            status: 401,
            body: {
              message: "Unauthorized",
              code: 401,
              errors: [
                { source: "ModuleName", error: "APIKey is invalid" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns 401 unauthorized" do
        response = @client.validate_order(store_id: store_id, order_id: order_id, body: validate_body)
        expect(response[:code]).to eq(401)
        expect(response[:body]).to include("message" => "Unauthorized")
      end
    end

    context "when 500 Server Error" do
      before do
        stub_request(:post, "https://api.example.com/Locations/#{store_id}/Orders/#{order_id}/Validate")
          .to_return(
            status: 500,
            body: {
              message: "Invalid reward",
              code: 500,
              errors: [
                { source: "ModuleName", error: "Unable to apply reward" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns 500 invalid reward error" do
        response = @client.validate_order(store_id: store_id, order_id: order_id, body: validate_body)
        expect(response[:code]).to eq(500)
        expect(response[:body]).to include("message" => "Invalid reward")
      end
    end
  end
end
