# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# General application configuration
config :kempa_ecommerce,
  ecto_repos: [KempaEcommerce.Repo],
  generators: [timestamp_type: :utc_datetime],
  ash_domains: [
    KempaEcommerce.Catalog,
    KempaEcommerce.Accounts,
    KempaEcommerce.Shopping,
    KempaEcommerce.Ordering,
    KempaEcommerce.Payments
  ]

# Ash Framework configuration
config :ash,
  include_embedded_source_by_default?: false,
  default_page_type: :keyset,
  policies: [no_filter_static_forbidden_reads?: false]

# Configures the endpoint
config :kempa_ecommerce, KempaEcommerceWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: KempaEcommerceWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: KempaEcommerce.PubSub,
  live_view: [signing_salt: "kempa_ecommerce_salt"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
