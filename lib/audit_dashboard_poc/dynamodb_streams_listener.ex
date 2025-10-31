defmodule AuditDashboardPoc.DynamoDBStreamsListener do
  @moduledoc """
  GenServer that processes DynamoDB stream events and broadcasts them to LiveViews.

  This module handles webhook calls from AWS Lambda functions that process
  DynamoDB stream records. When records are modified in DynamoDB, the Lambda
  function sends HTTP requests to this server, which then broadcasts the
  changes to all connected LiveViews via Phoenix PubSub.
  """

  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Logger.info("Started DynamoDB Streams Listener")
    {:ok, state}
  end

  @doc """
  Processes a DynamoDB stream record from AWS Lambda webhook.

  Expected payload format:
  %{
    "eventName" => "INSERT" | "MODIFY" | "REMOVE",
    "dynamodb" => %{
      "Keys" => %{"AuditId" => %{"S" => "audit-id"}},
      "NewImage" => %{...},  # For INSERT/MODIFY
      "OldImage" => %{...}   # For MODIFY/REMOVE
    }
  }
  """
  def process_stream_record(stream_record) do
    GenServer.cast(__MODULE__, {:process_record, stream_record})
  end

  @impl true
  def handle_cast({:process_record, stream_record}, state) do
    case process_dynamo_stream_record(stream_record) do
      {:ok, event_data} ->
        # Broadcast to all LiveViews listening to audit_events topic
        Phoenix.PubSub.broadcast(
          AuditDashboardPoc.PubSub,
          "audit_events",
          {:audit_event_updated, event_data}
        )

        Logger.info("Broadcasted DynamoDB stream event: #{event_data["action"]}")

      {:error, reason} ->
        Logger.error("Failed to process DynamoDB stream record: #{inspect(reason)}")
    end

    {:noreply, state}
  end

  # Private functions

  defp process_dynamo_stream_record(%{"eventName" => event_name, "dynamodb" => dynamo_data}) do
    case event_name do
      "INSERT" ->
        case extract_audit_event_from_image(dynamo_data["NewImage"]) do
          {:ok, audit_event} ->
            {:ok, %{
              "action" => "INSERT",
              "record" => audit_event
            }}
          error -> error
        end

      "MODIFY" ->
        case extract_audit_event_from_image(dynamo_data["NewImage"]) do
          {:ok, audit_event} ->
            {:ok, %{
              "action" => "UPDATE",
              "record" => audit_event
            }}
          error -> error
        end

      "REMOVE" ->
        audit_id = get_audit_id_from_keys(dynamo_data["Keys"])
        {:ok, %{
          "action" => "DELETE",
          "id" => audit_id
        }}

      _ ->
        {:error, "Unknown event name: #{event_name}"}
    end
  end

  defp process_dynamo_stream_record(_), do: {:error, "Invalid stream record format"}

  defp extract_audit_event_from_image(dynamo_image) when is_map(dynamo_image) do
    try do
      # Convert DynamoDB image format to our expected format
      audit_event = %{
        "id" => get_string_value(dynamo_image, "AuditId"),
        "event_type" => get_string_value(dynamo_image, "EventType"),
        "user_id" => get_string_value(dynamo_image, "UserId"),
        "event_timestamp" => get_string_value(dynamo_image, "EventTimestamp"),
        "ip_address" => get_string_value(dynamo_image, "IpAddress"),
        "action" => get_string_value(dynamo_image, "Action"),
        "success" => get_string_value(dynamo_image, "Status") == "SUCCESS"
      }

      # Validate required fields
      if audit_event["id"] && audit_event["event_timestamp"] do
        {:ok, audit_event}
      else
        {:error, "Missing required fields in DynamoDB image"}
      end
    rescue
      error ->
        {:error, "Failed to extract audit event: #{inspect(error)}"}
    end
  end

  defp extract_audit_event_from_image(_), do: {:error, "Invalid DynamoDB image format"}

  defp get_string_value(dynamo_item, key) do
    case Map.get(dynamo_item, key) do
      %{"S" => value} when is_binary(value) -> value
      _ -> ""
    end
  end

  defp get_audit_id_from_keys(keys) when is_map(keys) do
    case Map.get(keys, "AuditId") do
      %{"S" => audit_id} -> audit_id
      _ -> nil
    end
  end

  defp get_audit_id_from_keys(_), do: nil
end
