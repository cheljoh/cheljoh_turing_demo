require "cat"
require "cat_food"
require "cat_food_finder_response"
require "fake_api_call"
require "dry-monads"

class CatFoodFinder
  include Dry::Monads[:try, :maybe, :result]

  def initialize(request, api_call = FakeApiCall)
    @api_call = api_call
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

  attr_accessor :request, :api_call

  def parse_api_response(api_response)
    parsed_json = JSON.parse(api_response.body, symbolize_names: true)
    CatFood.new(
      parsed_json[:food],
      parsed_json[:days_supply],
      parsed_json[:quantity]
    )
  end

  def present_response(response)
    {
      message: "yay you did it!"
    }.merge(response.to_h).to_json
  end

  def create_cat(parsed_json)
    Cat.new(
      parsed_json[:name],
      parsed_json[:age],
      parsed_json[:color]
    )
  end

  def fake_api_call(_age)
   api_call.call
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
