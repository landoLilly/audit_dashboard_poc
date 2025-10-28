# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AuditDashboardPoc.Repo.insert!(%AuditDashboardPoc.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query
alias AuditDashboardPoc.Repo
alias AuditDashboardPoc.AuditEvent

# Create 10 sample audit event records
audit_events = [
  %{
    event_type: "authentication",
    user_id: "user001",
    event_timestamp: ~U[2024-10-28 10:15:00Z],
    ip_address: "192.168.1.101",
    action: "login",
    success: true
  },
  %{
    event_type: "authentication",
    user_id: "user002",
    event_timestamp: ~U[2024-10-28 10:30:00Z],
    ip_address: "192.168.1.102",
    action: "login_failed",
    success: false
  },
  %{
    event_type: "data_access",
    user_id: "user001",
    event_timestamp: ~U[2024-10-28 11:00:00Z],
    ip_address: "192.168.1.101",
    action: "view_sensitive_data",
    success: true
  },
  %{
    event_type: "data_modification",
    user_id: "user003",
    event_timestamp: ~U[2024-10-28 11:15:00Z],
    ip_address: "192.168.1.103",
    action: "update_user_profile",
    success: true
  },
  %{
    event_type: "authentication",
    user_id: "user004",
    event_timestamp: ~U[2024-10-28 11:45:00Z],
    ip_address: "10.0.0.15",
    action: "logout",
    success: true
  },
  %{
    event_type: "system_access",
    user_id: "admin001",
    event_timestamp: ~U[2024-10-28 12:00:00Z],
    ip_address: "192.168.1.200",
    action: "admin_panel_access",
    success: true
  },
  %{
    event_type: "data_access",
    user_id: "user002",
    event_timestamp: ~U[2024-10-28 12:30:00Z],
    ip_address: "192.168.1.102",
    action: "download_report",
    success: false
  },
  %{
    event_type: "authentication",
    user_id: "user005",
    event_timestamp: ~U[2024-10-28 13:00:00Z],
    ip_address: "203.0.113.45",
    action: "login",
    success: true
  },
  %{
    event_type: "data_modification",
    user_id: "user001",
    event_timestamp: ~U[2024-10-28 13:15:00Z],
    ip_address: "192.168.1.101",
    action: "delete_record",
    success: true
  },
  %{
    event_type: "system_access",
    user_id: "user006",
    event_timestamp: ~U[2024-10-28 14:00:00Z],
    ip_address: "172.16.0.25",
    action: "api_access_denied",
    success: false
  }
]

# Insert the audit events
Enum.each(audit_events, fn event_attrs ->
  %AuditEvent{}
  |> AuditEvent.changeset(event_attrs)
  |> Repo.insert!()
end)

IO.puts("Successfully created 10 audit event records!")
