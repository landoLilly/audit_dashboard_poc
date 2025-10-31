defmodule AuditDashboardPoc.AuditEvent do
  use Ecto.Schema
  import Ecto.Changeset

  # This schema matches the audit_events table in the PostgreSQL database.
  # Note: The DynamoDB audit_events table has a different schema structure.
  schema "audit_events" do
    field :event_type, :string
    field :user_id, :string
    field :event_timestamp, :utc_datetime
    field :ip_address, :string
    field :action, :string
    field :success, :boolean, default: false
  end

  @doc false
  def changeset(audit_event, attrs) do
    audit_event
    |> cast(attrs, [:event_type, :user_id, :event_timestamp, :ip_address, :action, :success])
    |> validate_required([:event_type, :user_id, :event_timestamp, :ip_address, :action, :success])
  end
end
