defmodule AuditDashboardPocWeb.DashboardLive do
  use AuditDashboardPocWeb, :live_view
  alias AuditDashboardPoc.Repo
  alias AuditDashboardPoc.AuditEvent

  def render(assigns) do
    ~H"""
      <h1 class="text-3xl font-bold mb-6 text-center">Audit Dashboard</h1>
      <%= if @audit_events == [] do %>
        <p>No audit events found.</p>
      <% else %>
        <table class="p-8 mx-auto table-auto border-collapse border border-gray-200">
          <thead>
            <tr class="">
              <th class="border border-gray-300 px-4 py-2">Audit Event Id</th>
              <th class="border border-gray-300 px-4 py-2">Event Type</th>
              <th class="border border-gray-300 px-4 py-2">User ID</th>
              <th class="border border-gray-300 px-4 py-2">Timestamp</th>
              <th class="border border-gray-300 px-4 py-2">IP Address</th>
              <th class="border border-gray-300 px-4 py-2">Action</th>
              <th class="border border-gray-300 px-4 py-2">Success</th>
            </tr>
          </thead>
          <tbody>
            <%= for event <- @audit_events do %>
              <tr>
                <td class="border border-gray-300 px-4 py-2"><%= event.id %></td>
                <td class="border border-gray-300 px-4 py-2"><%= event.event_type %></td>
                <td class="border border-gray-300 px-4 py-2"><%= event.user_id %></td>
                <td class="border border-gray-300 px-4 py-2"><%= event.event_timestamp %></td>
                <td class="border border-gray-300 px-4 py-2"><%= event.ip_address %></td>
                <td class="border border-gray-300 px-4 py-2"><%= event.action %></td>
                <td class="border border-gray-300 px-4 py-2"><%= if event.success, do: "Yes", else: "No" %></td>
              </tr>
            <% end %>
          </tbody>
        </table>
      <% end %>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :audit_events, Repo.all(AuditEvent))}
  end
end
