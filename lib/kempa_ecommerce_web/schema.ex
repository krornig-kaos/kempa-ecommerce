defmodule KempaEcommerceWeb.Schema do
  @moduledoc """
  The main GraphQL schema for KempaEcommerce.

  This module aggregates all Ash domains that expose GraphQL types and queries.
  """
  use AshGraphql, domains: [
    KempaEcommerce.Catalog,
    KempaEcommerce.Accounts,
    KempaEcommerce.Shopping,
    KempaEcommerce.Ordering,
    KempaEcommerce.Payments
  ]

  query do
  end

  mutation do
  end
end
