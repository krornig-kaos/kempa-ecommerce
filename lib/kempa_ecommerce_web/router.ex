defmodule KempaEcommerceWeb.Router do
  use Phoenix.Router

  import Plug.Conn
  import Phoenix.Controller

  pipeline :api do
    plug :accepts, ["json"]
  end

  # GraphQL API endpoint
  scope "/api" do
    pipe_through :api

    forward "/graphql",
      Absinthe.Plug,
      schema: KempaEcommerceWeb.Schema

    # GraphiQL interactive interface (only in dev)
    if Mix.env() == :dev do
      forward "/graphiql",
        Absinthe.Plug.GraphiQL,
        schema: KempaEcommerceWeb.Schema,
        interface: :playground
    end
  end

  # Health check endpoint
  scope "/api", KempaEcommerceWeb do
    pipe_through :api

    get "/health", HealthController, :index
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:kempa_ecommerce, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: KempaEcommerceWeb.Telemetry
    end
  end
end
