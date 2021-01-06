require "cat"
require "cat_food"
require "cat_food_finder_response"
require "dry-monads"

class CatFoodFinder
  include Dry::Monads[:try, :maybe, :result]

  def initialize(request)
    @request = request
  end

  def call
    parsed_json = JSON.parse(request, symbolize_names: true)
    cat = create_cat(parsed_json)
    api_response = fake_api_call(cat.age)
    cat_food = parse_api_response(api_response)
    present_response(cat_food)
  end

  private

  attr_accessor :request

  def parse_api_response(api_response)
    parsed_json = JSON.parse(api_response.body, symbolize_names: true)
    CatFood.new(
      parsed_json[:food],
      parsed_json[:days_supply],
      parsed_json[:quantity]
    )
  end

  def present_response(response)
    response.to_h.to_json
  end

  def create_cat(parsed_json)
    Cat.new(
      parsed_json[:name],
      parsed_json[:age],
      parsed_json[:color]
    )
  end

  def fake_api_call(_age)
    OpenStruct.new(
      status: 200,
      body: {
        food: "Yummy Kitty Food",
        quantity: 3,
        days_supply: 30,
      }.to_json
    )
  end

  def is_valid_json?
    begin
      JSON.parse(request)
      true
    rescue JSON::ParserError
      false
    end
  end
end
