defmodule AuditDashboardPoc.Repo.Migrations.AddDatabaseUpdatedTrigger do
  use Ecto.Migration

  def change do
    execute """
    CREATE OR REPLACE FUNCTION notify_audit_events_updated()
      RETURNS trigger AS $trigger$
      DECLARE
        payload TEXT;
      BEGIN
        IF TG_OP = 'DELETE' THEN
          payload := json_build_object('action', TG_OP, 'id', OLD.id, 'record', row_to_json(OLD));
          PERFORM pg_notify('audit_events_updated', payload);
          RETURN OLD;
        ELSE
          payload := json_build_object('action', TG_OP, 'id', NEW.id, 'record', row_to_json(NEW));
          PERFORM pg_notify('audit_events_updated', payload);
          RETURN NEW;
        END IF;
      END;
      $trigger$ LANGUAGE plpgsql;
    """

    execute """
    CREATE TRIGGER audit_events_updated_trigger
      AFTER INSERT OR UPDATE OR DELETE ON audit_events FOR EACH ROW
      EXECUTE PROCEDURE notify_audit_events_updated();
    """
  end

  def down do
    execute "DROP TRIGGER IF EXISTS audit_events_updated_trigger ON audit_events;"
    execute "DROP FUNCTION IF EXISTS notify_audit_events_updated();"
  end
end
