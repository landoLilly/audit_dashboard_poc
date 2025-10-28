defmodule AuditDashboardPocWeb.DashboardLive do
  use AuditDashboardPocWeb, :live_view
  alias AuditDashboardPoc.Repo
  alias AuditDashboardPoc.AuditEvent
  import Ecto.Query
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
      <Layouts.app flash={@flash}>
        <h1 class="text-3xl font-bold mb-6 text-center">Audit Dashboard</h1>
        <table class="p-8 mx-auto table-auto border-collapse border border-gray-200">
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
            <tr class="hidden only:block">
              <td colspan="7" class="border border-gray-300 px-4 py-8 text-center text-gray-500">
                  No audit events found.
              </td>
            </tr>
            <tr :for={{id, event} <- @streams.audit_events} id={id}>
              <td class="border border-gray-300 px-4 py-2"><%= event.id %></td>
              <td class="border border-gray-300 px-4 py-2"><%= event.event_type %></td>
              <td class="border border-gray-300 px-4 py-2"><%= event.user_id %></td>
              <td class="border border-gray-300 px-4 py-2"><%= event.event_timestamp %></td>
              <td class="border border-gray-300 px-4 py-2"><%= event.ip_address %></td>
              <td class="border border-gray-300 px-4 py-2"><%= event.action %></td>
              <td class="border border-gray-300 px-4 py-2"><%= if event.success, do: "Yes", else: "No" %></td>
            </tr>
          </tbody>
        </table>
      </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AuditDashboardPoc.PubSub, "audit_events")
    end

    audit_events =
      from(ae in AuditEvent, order_by: [desc: ae.event_timestamp], limit: 100)
      |> Repo.all()

    socket =
      socket
      |> stream(:audit_events, audit_events)

    {:ok, socket}
  end

  @impl true
  def handle_info({:audit_event_updated, data}, socket) do
    case data["action"] do
      "INSERT" ->
        # Add new audit event to the stream
        new_event = struct(AuditEvent, atomize_keys(data["record"]))
        {:noreply, stream_insert(socket, :audit_events, new_event, at: 0)}

      "UPDATE" ->
        # Update existing audit event in the stream
        updated_event = struct(AuditEvent, atomize_keys(data["record"]))
        {:noreply, stream_insert(socket, :audit_events, updated_event)}

      "DELETE" ->
        # Remove audit event from the stream
        {:noreply, stream_delete_by_dom_id(socket, :audit_events, "audit_events-#{data["id"]}")}

      _ ->
        {:noreply, socket}
    end
  end

  # Helper function to convert string keys to atoms for struct creation
  defp atomize_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {String.to_atom(k), v} end)
  end
end
