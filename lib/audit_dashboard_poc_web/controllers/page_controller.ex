defmodule AuditDashboardPocWeb.PageController do
  use AuditDashboardPocWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
