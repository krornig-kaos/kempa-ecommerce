defmodule KempaEcommerce.Ordering do
  @moduledoc """
  The Ordering domain manages orders and order items.
  Orders use AshStateMachine for state management.
  """
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource KempaEcommerce.Ordering.Order
    resource KempaEcommerce.Ordering.OrderItem
  end
end
