class FakeApiCall
  def self.call
    OpenStruct.new(
      status: 200,
      body: {
        food: "Yummy Kitty Food",
        quantity: 3,
        days_supply: 30,
      }.to_json
    )
  end
end