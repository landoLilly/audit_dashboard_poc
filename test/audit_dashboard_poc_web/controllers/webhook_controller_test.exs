defmodule AuditDashboardPocWeb.WebhookControllerTest do
  use AuditDashboardPocWeb.ConnCase

  describe "POST /api/webhook/dynamodb-stream" do
    test "processes valid DynamoDB stream records", %{conn: conn} do
      # Mock DynamoDB stream payload
      payload = %{
        "Records" => [
          %{
            "eventName" => "INSERT",
            "dynamodb" => %{
              "Keys" => %{
                "AuditId" => %{"S" => "test-audit-id"}
              },
              "NewImage" => %{
                "AuditId" => %{"S" => "test-audit-id"},
                "EventType" => %{"S" => "authentication"},
                "UserId" => %{"S" => "test-user"},
                "EventTimestamp" => %{"S" => "2024-10-28T10:15:00Z"},
                "IpAddress" => %{"S" => "192.168.1.1"},
                "Action" => %{"S" => "login"},
                "Status" => %{"S" => "SUCCESS"}
              }
            }
          }
        ]
      }

      conn = post(conn, ~p"/api/webhook/dynamodb-stream", payload)

      assert json_response(conn, 200) == %{
        "status" => "success",
        "message" => "Stream records processed"
      }
    end

    test "handles invalid payload format", %{conn: conn} do
      payload = %{"invalid" => "payload"}

      conn = post(conn, ~p"/api/webhook/dynamodb-stream", payload)

      assert json_response(conn, 400)["status"] == "error"
    end

    test "handles empty records array", %{conn: conn} do
      payload = %{"Records" => []}

      conn = post(conn, ~p"/api/webhook/dynamodb-stream", payload)

      assert json_response(conn, 200) == %{
        "status" => "success",
        "message" => "Stream records processed"
      }
    end
  end
end
