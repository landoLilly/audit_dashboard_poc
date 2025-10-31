defmodule AuditDashboardPocWeb.DashboardLive do
  use AuditDashboardPocWeb, :live_view
  alias AuditDashboardPoc.AuditEvent
  alias AuditDashboardPoc.AuditEventsDynamo
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
      <Layouts.app flash={@flash}>
        <h1 class="text-3xl font-bold mb-6">Audit Dashboard</h1>
        <%= if @audit_events_count == 0 do %>
          <div class="text-center py-8">
            <p class="text-gray-500 text-lg">No audit events found.</p>
          </div>
        <% else %>
          <table class="p-8 mx-auto table-auto border-collapse border border-gray-200 w-full">
            <thead>
              <tr class="">
                <th class="border border-gray-300 px-4 py-2">Audit Event Id</th>
                <th class="border border-gray-300 px-4 py-2">Event Type</th>
                <th class="border border-gray-300 px-4 py-2">User ID</th>
                <th class="border border-gray-300 px-4 py-2">Event Timestamp</th>
                <th class="border border-gray-300 px-4 py-2">IP Address</th>
                <th class="border border-gray-300 px-4 py-2">Action</th>
                <th class="border border-gray-300 px-4 py-2">Success</th>
              </tr>
            </thead>
            <tbody id="audit-events" phx-update="stream">
              <tr :for={{id, event} <- @streams.audit_events} id={id}>
                <td class="border border-gray-300 px-4 py-2">{event.id}</td>
                <td class="border border-gray-300 px-4 py-2">{event.event_type}</td>
                <td class="border border-gray-300 px-4 py-2">{event.user_id}</td>
                <td class="border border-gray-300 px-4 py-2">{Calendar.strftime(event.event_timestamp, "%Y-%m-%d %H:%M:%S")}</td>
                <td class="border border-gray-300 px-4 py-2">{event.ip_address}</td>
                <td class="border border-gray-300 px-4 py-2">{event.action}</td>
                <td class="border border-gray-300 px-4 py-2">{if event.success, do: "Yes", else: "No"}</td>
              </tr>
            </tbody>
          </table>
        <% end %>
      </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AuditDashboardPoc.PubSub, "audit_events")
    end

    case AuditEventsDynamo.list_audit_events(limit: 100) do
      {:ok, audit_events} ->
        socket =
          socket
          |> assign(:audit_events_count, length(audit_events))
          |> stream(:audit_events, audit_events)

        {:ok, socket}

      {:error, _reason} ->
        socket =
          socket
          |> assign(:audit_events_count, 0)
          |> stream(:audit_events, [])
          |> put_flash(:error, "Failed to load audit events from DynamoDB")

        {:ok, socket}
    end
  end

  @impl true
  def handle_info({:audit_event_updated, data}, socket) do
    Logger.info("LiveView received audit event update: #{inspect(data)}")

    case data["action"] do
      "INSERT" ->
        # Convert the record data to an AuditEvent struct with proper timestamp parsing
        record_data = data["record"]

        # Parse the timestamp properly - DynamoDB returns ISO8601 format
        event_timestamp = case DateTime.from_iso8601(record_data["event_timestamp"]) do
          {:ok, timestamp, _} -> timestamp
          _ -> DateTime.utc_now()
        end

        new_event = %AuditEvent{
          id: record_data["id"],
          event_type: record_data["event_type"],
          user_id: record_data["user_id"],
          event_timestamp: event_timestamp,
          ip_address: record_data["ip_address"],
          action: record_data["action"],
          success: record_data["success"]
        }

        socket =
          socket
          |> assign(:audit_events_count, socket.assigns.audit_events_count + 1)
          |> stream_insert(:audit_events, new_event, at: 0)

        {:noreply, socket}

      "UPDATE" ->
        # Parse the timestamp properly
        record_data = data["record"]
        event_timestamp = case DateTime.from_iso8601(record_data["event_timestamp"]) do
          {:ok, timestamp, _} -> timestamp
          _ -> DateTime.utc_now()
        end

        updated_event = %AuditEvent{
          id: record_data["id"],
          event_type: record_data["event_type"],
          user_id: record_data["user_id"],
          event_timestamp: event_timestamp,
          ip_address: record_data["ip_address"],
          action: record_data["action"],
          success: record_data["success"]
        }

        {:noreply, stream_insert(socket, :audit_events, updated_event)}

      "DELETE" ->
        socket =
          socket
          |> assign(:audit_events_count, max(0, socket.assigns.audit_events_count - 1))
          |> stream_delete_by_dom_id(:audit_events, "audit_events-#{data["id"]}")

        {:noreply, socket}

      _ ->
        Logger.warning("Unknown action received: #{data["action"]}")
        {:noreply, socket}
    end
  end
end
