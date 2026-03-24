import Config

# Configure your database
config :kempa_ecommerce, KempaEcommerce.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "kempa_ecommerce_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
config :kempa_ecommerce, KempaEcommerceWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev_secret_key_base_kempa_ecommerce_replace_in_production_at_least_64_bytes_long_string_here!!",
  watchers: []

# Enable dev routes for dashboard
config :kempa_ecommerce, dev_routes: true

# Set a higher stacktrace during development.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
