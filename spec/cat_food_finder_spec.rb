require "cat_food_finder"
require "json"

RSpec.describe CatFoodFinder do
  describe "#call" do
    let(:json) do
      {
        name: "Caia",
        age: 15,
        color: "orange"
      }.to_json
    end

    context "json" do
      context "valid json" do
        it "parses the json" do
          results = described_class.new(json).call

          expect(results).to eq({
            name: "Yummy Kitty Food",
            days_supply: 30,
            quantity: 3,
          }.to_json)
        end
      end

      context "invalid json" do
        it "returns an error" do
          results = described_class.new("asdf").call

          expect(results).to eq({ error: "invalid json" }.to_json)
        end
      end
    end
  end
end
