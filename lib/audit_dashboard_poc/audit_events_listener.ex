defmodule AuditDashboardPoc.AuditEventsListener do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, pid} = Postgrex.Notifications.start_link(AuditDashboardPoc.Repo.config())
    {:ok, _ref} = Postgrex.Notifications.listen(pid, "audit_events_updated")

    Logger.info("Started listening for audit_events_updated notifications")

    {:ok, Map.put(state, :notifications_pid, pid)}
  end

  @impl true
  def handle_info({:notification, _pid, _ref, "audit_events_updated", payload}, state) do
    case Jason.decode(payload) do
      {:ok, data} ->
        Logger.debug("Received audit event notification: #{inspect(data)}")

        # Broadcast to all LiveViews listening to this topic
        Phoenix.PubSub.broadcast(
          AuditDashboardPoc.PubSub,
          "audit_events",
          {:audit_event_updated, data}
        )

      {:error, error} ->
        Logger.error("Failed to decode notification payload: #{inspect(error)}")
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.debug("Received unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end
end
