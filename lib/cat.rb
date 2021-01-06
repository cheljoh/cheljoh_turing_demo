require 'dry-struct'
require 'types'

class Cat < Dry::Struct
  include Types

  attribute :name, Types::String
  attribute :age, Types::Integer
  attribute :color, Types::String
end
