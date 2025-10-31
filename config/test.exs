import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :audit_dashboard_poc, AuditDashboardPoc.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "audit_dashboard_poc_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :audit_dashboard_poc, AuditDashboardPocWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "y6CyFlDRh70Xe3Nw5Z+b5m5SXaPN05StIe6J6b59PX+Hzz2l/oRGY3eroA1wI+h9",
  server: false

# In test we don't send emails
config :audit_dashboard_poc, AuditDashboardPoc.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Import DynamoDB Local test configuration
import_config "ddb_local_test.exs"
