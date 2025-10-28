defmodule AuditDashboardPocWeb.DashboardLive do
  use AuditDashboardPocWeb, :live_view

  def render(assigns) do
    ~H"""
      <h1 class="text-3xl font-bold mb-6">Audit Dashboard</h1>
    """
  end
end
