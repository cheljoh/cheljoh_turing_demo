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

    context "happy path" do
      it "returns cat food recommendation" do
        results = described_class.new(json).call

        expect(results).to eq({
          message: "yay you did it!",
          name: "Yummy Kitty Food",
          days_supply: 30,
          quantity: 3,
        }.to_json)
      end
    end

    context "sad path" do
      context "invalid json" do
        it "returns an error" do
          results = described_class.new("asdf").call

          expect(results).to eq({ error: "invalid json" }.to_json)
        end
      end

      context "api call" do
        context "non-200" do
          it "returns an error" do
            allow(FakeApiCall).to receive(:call).and_return(
              OpenStruct.new(
                status: 400,
                body: {
                  error: "food not found"
                }.to_json
              )
            )

            results = described_class.new(json).call

            expect(results).to eq({ error: "no food found" }.to_json)
          end
        end

        context "bad json" do
          it "returns an error" do
            allow(FakeApiCall).to receive(:call).and_return(
              OpenStruct.new(
                status: 200,
                body: "asdada"
              )
            )

            results = described_class.new(json).call

            expect(results).to eq({ error: "no food found" }.to_json)
          end
        end
      end

      context "validate input" do
        it "requires all cat attributes" do
          json =  {
            name: "Caia",
            age: nil,
            color: "orange"
          }.to_json

          results = described_class.new(json).call

          expect(results).to eq({ error: "Missing required fields" }.to_json)
        end
      end
    end
  end
end
