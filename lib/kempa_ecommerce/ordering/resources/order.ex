defmodule KempaEcommerce.Ordering.Order do
  @moduledoc """
  Represents a customer order.

  Uses AshStateMachine to manage the order lifecycle:

    pending → confirmed → processing → shipped → delivered
                                    ↘ cancelled
    pending → cancelled
    confirmed → cancelled
  """
  use Ash.Resource,
    otp_app: :kempa_ecommerce,
    domain: KempaEcommerce.Ordering,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshStateMachine]

  graphql do
    type :order

    queries do
      get :get_order, :read
      list :list_orders, :read
    end

    mutations do
      create :create_order, :create
      update :confirm_order, :confirm
      update :process_order, :process
      update :ship_order, :ship
      update :deliver_order, :deliver
      update :cancel_order, :cancel
    end
  end

  state_machine do
    initial_states [:pending]
    default_initial_state :pending

    transitions do
      transition :confirm, from: :pending, to: :confirmed
      transition :process, from: :confirmed, to: :processing
      transition :ship, from: :processing, to: :shipped
      transition :deliver, from: :shipped, to: :delivered
      transition :cancel, from: [:pending, :confirmed, :processing], to: :cancelled
    end
  end

  postgres do
    table "orders"
    repo KempaEcommerce.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:shipping_address, :billing_address, :notes, :user_id]
    end

    update :confirm do
      accept []
    end

    update :process do
      accept []
    end

    update :ship do
      accept [:tracking_number]
    end

    update :deliver do
      accept []
    end

    update :cancel do
      accept [:cancellation_reason]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :state, :atom do
      allow_nil? false
      default :pending
      public? true
      constraints [
        one_of: [:pending, :confirmed, :processing, :shipped, :delivered, :cancelled]
      ]
    end

    attribute :order_number, :string do
      allow_nil? false
      public? true
      default &generate_order_number/0
    end

    attribute :total_amount, :decimal do
      default 0
      public? true
      constraints [min: 0]
    end

    attribute :shipping_address, :string do
      allow_nil? false
      public? true
    end

    attribute :billing_address, :string do
      public? true
    end

    attribute :tracking_number, :string do
      public? true
    end

    attribute :notes, :string do
      public? true
    end

    attribute :cancellation_reason, :string do
      public? true
    end

    attribute :confirmed_at, :utc_datetime do
      public? true
    end

    attribute :shipped_at, :utc_datetime do
      public? true
    end

    attribute :delivered_at, :utc_datetime do
      public? true
    end

    attribute :cancelled_at, :utc_datetime do
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :user, KempaEcommerce.Accounts.User do
      allow_nil? false
      attribute_writable? true
      public? true
    end

    has_many :items, KempaEcommerce.Ordering.OrderItem
    has_many :payment_transactions, KempaEcommerce.Payments.PaymentTransaction
  end

  identities do
    identity :unique_order_number, [:order_number]
  end

  defp generate_order_number do
    timestamp = DateTime.utc_now() |> Calendar.strftime("%Y%m%d%H%M%S")
    random = :crypto.strong_rand_bytes(4) |> Base.encode16(case: :upper)
    "ORD-#{timestamp}-#{random}"
  end
end
