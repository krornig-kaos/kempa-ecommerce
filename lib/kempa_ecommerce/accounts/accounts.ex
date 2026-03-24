defmodule KempaEcommerce.Accounts do
  @moduledoc """
  The Accounts domain manages user registration, authentication and profiles.
  """
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource KempaEcommerce.Accounts.User
  end
end
