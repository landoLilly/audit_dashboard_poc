defmodule TestFoo do
  @moduledoc """
  Test module for DynamoDB integration tests.
  """

  @derive [ExAws.Dynamo.Encodable]
  defstruct [:shard_id]

  @type t :: %__MODULE__{
    shard_id: String.t()
  }
end
