defmodule KempaEcommerce.Shopping do
  @moduledoc """
  The Shopping domain manages shopping carts and cart items.
  """
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource KempaEcommerce.Shopping.Cart
    resource KempaEcommerce.Shopping.CartItem
  end
end
