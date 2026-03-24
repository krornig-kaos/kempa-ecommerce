defmodule KempaEcommerce.Catalog do
  @moduledoc """
  The Catalog domain manages product categories and products.
  """
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource KempaEcommerce.Catalog.Category
    resource KempaEcommerce.Catalog.Product
  end
end
