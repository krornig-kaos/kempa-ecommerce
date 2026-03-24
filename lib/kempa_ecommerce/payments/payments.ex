defmodule KempaEcommerce.Payments do
  @moduledoc """
  The Payments domain manages payment transactions.
  PaymentTransaction uses AshStateMachine for state management.
  """
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource KempaEcommerce.Payments.PaymentTransaction
  end
end
