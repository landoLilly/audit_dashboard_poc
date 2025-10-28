defmodule AuditDashboardPoc.Repo.Migrations.CreateAuditEvents do
  use Ecto.Migration

  def change do
    create table(:audit_events) do
      add :event_type, :string, null: false
      add :user_id, :string, null: false
      add :event_timestamp, :utc_datetime, null: false
      add :ip_address, :string, null: false
      add :action, :string, null: false
      add :success, :boolean, default: false, null: false
    end
  end
end
