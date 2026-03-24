defmodule KempaEcommerce.Payments.PaymentTransaction do
  @moduledoc """
  Represents a payment transaction for an order.

  Uses AshStateMachine to manage the payment lifecycle:

    pending → processing → completed
    pending → processing → failed → pending (retry)
    pending → cancelled
    processing → refunded
    completed → refunded
  """
  use Ash.Resource,
    otp_app: :kempa_ecommerce,
    domain: KempaEcommerce.Payments,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshStateMachine]

  graphql do
    type :payment_transaction

    queries do
      get :get_payment_transaction, :read
      list :list_payment_transactions, :read
    end

    mutations do
      create :create_payment_transaction, :create
      update :start_processing, :start_processing
      update :complete_payment, :complete
      update :fail_payment, :fail
      update :retry_payment, :retry
      update :cancel_payment, :cancel
      update :refund_payment, :refund
    end
  end

  state_machine do
    initial_states [:pending]
    default_initial_state :pending

    transitions do
      transition :start_processing, from: :pending, to: :processing
      transition :complete, from: :processing, to: :completed
      transition :fail, from: :processing, to: :failed
      transition :retry, from: :failed, to: :pending
      transition :cancel, from: :pending, to: :cancelled
      transition :refund, from: [:processing, :completed], to: :refunded
    end
  end

  postgres do
    table "payment_transactions"
    repo KempaEcommerce.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:amount, :currency, :payment_method, :order_id]
    end

    update :start_processing do
      accept [:gateway_reference]
    end

    update :complete do
      accept [:gateway_reference]
    end

    update :fail do
      accept [:failure_reason]
    end

    update :retry do
      accept []
    end

    update :cancel do
      accept [:cancellation_reason]
    end

    update :refund do
      accept [:refund_reason, :refund_amount]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :state, :atom do
      allow_nil? false
      default :pending
      public? true
      constraints [
        one_of: [:pending, :processing, :completed, :failed, :cancelled, :refunded]
      ]
    end

    attribute :transaction_number, :string do
      allow_nil? false
      public? true
      default &generate_transaction_number/0
    end

    attribute :amount, :decimal do
      allow_nil? false
      public? true
      constraints [min: 0]
    end

    attribute :currency, :string do
      default "USD"
      allow_nil? false
      public? true
    end

    attribute :payment_method, :atom do
      allow_nil? false
      public? true
      constraints [one_of: [:credit_card, :debit_card, :paypal, :bank_transfer, :cash_on_delivery]]
    end

    attribute :gateway_reference, :string do
      public? true
      description "External payment gateway transaction reference"
    end

    attribute :failure_reason, :string do
      public? true
    end

    attribute :cancellation_reason, :string do
      public? true
    end

    attribute :refund_reason, :string do
      public? true
    end

    attribute :refund_amount, :decimal do
      public? true
      constraints [min: 0]
    end

    attribute :processed_at, :utc_datetime do
      public? true
    end

    attribute :completed_at, :utc_datetime do
      public? true
    end

    attribute :failed_at, :utc_datetime do
      public? true
    end

    attribute :refunded_at, :utc_datetime do
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :order, KempaEcommerce.Ordering.Order do
      allow_nil? false
      attribute_writable? true
      public? true
    end
  end

  identities do
    identity :unique_transaction_number, [:transaction_number]
  end

  defp generate_transaction_number do
    timestamp = DateTime.utc_now() |> Calendar.strftime("%Y%m%d%H%M%S")
    random = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :upper)
    "TXN-#{timestamp}-#{random}"
  end
end
