defmodule Test.User do
  @moduledoc """
  Test user struct for DynamoDB integration tests.
  """

  @derive [ExAws.Dynamo.Encodable]
  defstruct [:email, :name, :age, :admin]

  @type t :: %__MODULE__{
    email: String.t(),
    name: map(),
    age: integer() | String.t(),
    admin: boolean()
  }
end
