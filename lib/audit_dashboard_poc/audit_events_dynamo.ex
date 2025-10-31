defmodule AuditDashboardPoc.AuditEventsDynamo do
  @moduledoc """
  Context module for managing audit events in DynamoDB.
  """

  alias ExAws.Dynamo
  alias AuditDashboardPoc.AuditEvent
  require Logger

  @table_name "AuditEvents"

  @doc """
  Lists audit events with optional filtering and pagination.
  Returns the most recent events first.
  """
  def list_audit_events(opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)

    # Scan the table and get recent events
    # Note: In production, you'd want to use Query with a GSI for better performance
    case Dynamo.scan(@table_name, limit: limit) |> ExAws.request() do
      {:ok, %{"Items" => items}} ->
        events =
          items
          |> Enum.map(&parse_dynamo_item/1)
          |> Enum.filter(& &1.event_timestamp != nil)
          |> Enum.sort_by(& &1.event_timestamp, {:desc, DateTime})
          |> Enum.take(limit)

        {:ok, events}

      {:error, reason} ->
        Logger.error("Failed to scan DynamoDB table: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Gets a single audit event by ID.
  """
  def get_audit_event(audit_id) do
    case Dynamo.get_item(@table_name, %{AuditId: audit_id}) |> ExAws.request() do
      {:ok, %{"Item" => item}} ->
        {:ok, parse_dynamo_item(item)}

      {:ok, %{}} ->
        {:error, :not_found}

      {:error, reason} ->
        Logger.error("Failed to get audit event: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Creates a new audit event in DynamoDB.
  """
  def create_audit_event(attrs) do
    audit_id = generate_uuid()
    timestamp = DateTime.utc_now() |> DateTime.to_iso8601()

    # Helper function to get values from map with both atom and string keys
    get_value = fn key ->
      Map.get(attrs, key) || Map.get(attrs, to_string(key), "")
    end

    # Use simple Elixir values - ExAws will handle DynamoDB encoding
    item = %{
      "AuditId" => audit_id,
      "EventTimestamp" => timestamp,
      "CreatedAt" => timestamp,
      "UserId" => get_value.(:user_id),
      "EventType" => get_value.(:event_type),
      "Source" => get_value.(:source),
      "Status" => get_value.(:status) || "SUCCESS",
      "Action" => get_value.(:action),
      "IpAddress" => get_value.(:ip_address),
      "Description" => get_value.(:description),
      "ResourceId" => get_value.(:resource_id),
      "ResourceType" => get_value.(:resource_type),
      "SessionId" => get_value.(:session_id),
      "UserAgent" => get_value.(:user_agent) || "Test/1.0",
      "PartitionKey" => String.slice(timestamp, 0, 7), # YYYY-MM format
      "TTL" => calculate_ttl(timestamp)
    }

    case Dynamo.put_item(@table_name, item) |> ExAws.request() do
      {:ok, _} ->
        # Return the created event
        {:ok, parsed_timestamp, _} = DateTime.from_iso8601(timestamp)
        event = %AuditEvent{
          id: audit_id,
          event_type: get_value.(:event_type),
          user_id: get_value.(:user_id),
          event_timestamp: parsed_timestamp,
          ip_address: get_value.(:ip_address),
          action: get_value.(:action),
          success: (get_value.(:status) || "SUCCESS") == "SUCCESS"
        }

        # Broadcast the new event immediately to LiveViews
        event_data = %{
          "action" => "INSERT",
          "record" => %{
            "id" => event.id,
            "event_type" => event.event_type,
            "user_id" => event.user_id,
            "event_timestamp" => DateTime.to_iso8601(event.event_timestamp),
            "ip_address" => event.ip_address,
            "action" => event.action,
            "success" => event.success
          }
        }

        Phoenix.PubSub.broadcast(
          AuditDashboardPoc.PubSub,
          "audit_events",
          {:audit_event_updated, event_data}
        )

        Logger.debug("Created and broadcasted new audit event: #{audit_id}")

        {:ok, event}

      {:error, reason} ->
        Logger.error("Failed to create audit event: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # Private functions

  defp parse_dynamo_item(item) do
    # Parse DynamoDB item format to our struct
    %AuditEvent{
      id: get_string_value(item, "AuditId"),
      event_type: get_string_value(item, "EventType"),
      user_id: get_string_value(item, "UserId"),
      event_timestamp: parse_timestamp(get_string_value(item, "EventTimestamp")),
      ip_address: get_string_value(item, "IpAddress"),
      action: get_string_value(item, "Action"),
      success: get_string_value(item, "Status") == "SUCCESS"
    }
  end

  defp get_string_value(item, key) do
    case Map.get(item, key) do
      %{"S" => value} -> value
      _ -> ""
    end
  end

  defp parse_timestamp(timestamp_string) when is_binary(timestamp_string) and timestamp_string != "" do
    case DateTime.from_iso8601(timestamp_string) do
      {:ok, datetime, _} -> datetime
      _ -> DateTime.utc_now()
    end
  end
  defp parse_timestamp(_), do: DateTime.utc_now()

  defp generate_uuid do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
    |> String.replace(~r/(.{8})(.{4})(.{4})(.{4})(.{12})/, "\\1-\\2-\\3-\\4-\\5")
  end

  defp calculate_ttl(timestamp) do
    {:ok, dt, _} = DateTime.from_iso8601(timestamp)
    DateTime.to_unix(dt) + (90 * 24 * 60 * 60) # 90 days TTL - return as integer
  end
end
