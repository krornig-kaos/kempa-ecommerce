defmodule KempaEcommerce.MixProject do
  use Mix.Project

  def project do
    [
      app: :kempa_ecommerce,
      version: "0.1.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :dev,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  def application do
    [
      mod: {KempaEcommerce.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Run `mix deps.get` to install them.
  defp deps do
    [
      # Phoenix
      {:phoenix, "~> 1.7.18"},
      {:phoenix_ecto, "~> 4.6"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.7"},
      {:bandit, "~> 1.6"},

      # Ash Framework
      {:ash, "~> 3.4"},
      {:ash_postgres, "~> 2.4"},
      {:ash_graphql, "~> 1.4"},
      {:ash_state_machine, "~> 0.2"},

      # SAT Solver (required by Ash)
      {:picosat_elixir, "~> 0.2"},

      # GraphQL
      {:absinthe, "~> 1.7"},
      {:absinthe_plug, "~> 1.5"},

      # CORS
      {:cors_plug, "~> 3.0"},

      # Dev & Test
      {:phoenix_live_dashboard, "~> 0.8", only: :dev},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev, only: :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:swoosh, "~> 1.17"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  defp aliases do
    [
      setup: ["deps.get", "ash.setup"],
      "ash.setup": ["ash.codegen", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
