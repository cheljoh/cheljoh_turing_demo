require "cat"
require "cat_food"
require "cat_food_finder_response"
require "fake_api_call"
require "dry-monads"

class CatFoodFinder
  include Dry::Monads[:try, :maybe, :result]

  def initialize(request)
    @request = request
  end

  def call
    parse_json(request)
      .bind { |parsed_json| create_cat(parsed_json) }
      .bind { |cat| fake_api_call(cat.age) }
      .bind { |api_response| parse_api_response(api_response) }
      .bind { |cat_food| present_response(cat_food) }
      .value_or { |error| return error }
  end

  private

  attr_accessor :request

  def parse_api_response(api_response)
    parse_json(api_response.body)
      .bind { |parsed_json|
        Success(
          CatFood.new(
            parsed_json[:food],
            parsed_json[:days_supply],
            parsed_json[:quantity]
          )
        )
      }
      .or {
        Failure({ error: "no food found" }.to_json)
      }
  end

  def present_response(response)
    Success(
      {
        message: "yay you did it!"
      }.merge(response.to_h).to_json
    )
  end

  def create_cat(parsed_json)
    Try {
      Cat.new(
        name: parsed_json[:name],
        age: parsed_json[:age],
        color: parsed_json[:color]
      )
    }.to_result
      .or do
      Failure({ error: "Missing required fields" }.to_json)
    end
  end

  def fake_api_call(_age)
    api_response = FakeApiCall.call

    if api_response.status == 200
      Success(FakeApiCall.call)
    else
      Failure({ error: "no food found" }.to_json)
    end
  end

  def parse_json(json)
    Try { JSON.parse(json, symbolize_names: true) }.to_result
      .or do
      Failure({ error: "invalid json" }.to_json)
    end
  end
end
