defmodule AuditDashboardPocWeb.WebhookController do
  use AuditDashboardPocWeb, :controller

  alias AuditDashboardPoc.DynamoDBStreamsListener
  require Logger

  @doc """
  Webhook endpoint for receiving DynamoDB stream events from AWS Lambda.

  This endpoint receives HTTP POST requests from AWS Lambda functions
  that process DynamoDB stream records. The Lambda function should send
  the DynamoDB stream record in the request body.

  Expected request body format:
  {
    "Records": [
      {
        "eventName": "INSERT|MODIFY|REMOVE",
        "dynamodb": {
          "Keys": {"AuditId": {"S": "audit-id"}},
          "NewImage": {...},
          "OldImage": {...}
        }
      }
    ]
  }
  """
  def dynamodb_stream(conn, params) do
    Logger.debug("Received DynamoDB stream webhook: #{inspect(params)}")

    case process_dynamodb_records(params) do
      :ok ->
        Logger.info("Successfully processed DynamoDB stream records")
        conn
        |> put_status(:ok)
        |> json(%{status: "success", message: "Stream records processed"})

      {:error, reason} ->
        # Log validation errors at debug level, processing errors at error level
        if String.contains?(reason, "Invalid payload format") do
          Logger.debug("Invalid webhook payload received: #{inspect(reason)}")
        else
          Logger.error("Failed to process DynamoDB stream records: #{inspect(reason)}")
        end

        conn
        |> put_status(:bad_request)
        |> json(%{status: "error", message: "Failed to process records", error: reason})
    end
  end

  # Private functions

  defp process_dynamodb_records(%{"Records" => records}) when is_list(records) do
    try do
      Enum.each(records, fn record ->
        DynamoDBStreamsListener.process_stream_record(record)
      end)
      :ok
    rescue
      error ->
        {:error, "Failed to process records: #{inspect(error)}"}
    end
  end

  defp process_dynamodb_records(_) do
    {:error, "Invalid payload format - expected Records array"}
  end
end
