defmodule AuditDashboardPoc.Repo do
  use Ecto.Repo,
    otp_app: :audit_dashboard_poc,
    adapter: Ecto.Adapters.Postgres
end
