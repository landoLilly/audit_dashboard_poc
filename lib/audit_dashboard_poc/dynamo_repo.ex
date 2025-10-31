defmodule AuditDashboardPoc.DynamoRepo do
  alias ExAws.Dynamo

  @table_name "AuditEvents"

  def put_item(item) do
    Dynamo.put_item(@table_name, item)
    |> ExAws.request()
  end

  def get_item(key) do
    Dynamo.get_item(@table_name, key)
    |> ExAws.request()
  end

  def get_all_items do
    Dynamo.scan(@table_name)
    |> ExAws.request()
  end
end
