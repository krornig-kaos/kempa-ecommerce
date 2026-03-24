defmodule KempaEcommerce.Ordering.OrderItem do
  @moduledoc """
  Represents an item within an order.
  """
  use Ash.Resource,
    otp_app: :kempa_ecommerce,
    domain: KempaEcommerce.Ordering,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type :order_item

    queries do
      list :list_order_items, :read
    end

    mutations do
      create :create_order_item, :create
    end
  end

  postgres do
    table "order_items"
    repo KempaEcommerce.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:quantity, :unit_price, :order_id, :product_id]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :quantity, :integer do
      allow_nil? false
      public? true
      constraints [min: 1]
    end

    attribute :unit_price, :decimal do
      allow_nil? false
      public? true
      constraints [min: 0]
    end

    attribute :total_price, :decimal do
      public? true
      constraints [min: 0]
    end

    attribute :product_name, :string do
      public? true
      description "Snapshot of the product name at the time of order"
    end

    attribute :product_sku, :string do
      public? true
      description "Snapshot of the product SKU at the time of order"
    end

    timestamps()
  end

  relationships do
    belongs_to :order, KempaEcommerce.Ordering.Order do
      allow_nil? false
      attribute_writable? true
      public? true
    end

    belongs_to :product, KempaEcommerce.Catalog.Product do
      allow_nil? false
      attribute_writable? true
      public? true
    end
  end
end
