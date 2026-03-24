defmodule KempaEcommerce.Shopping.CartItem do
  @moduledoc """
  Represents an item in a shopping cart.
  """
  use Ash.Resource,
    otp_app: :kempa_ecommerce,
    domain: KempaEcommerce.Shopping,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type :cart_item

    queries do
      list :list_cart_items, :read
    end

    mutations do
      create :add_to_cart, :create
      update :update_cart_item, :update
      destroy :remove_from_cart, :destroy
    end
  end

  postgres do
    table "cart_items"
    repo KempaEcommerce.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:quantity, :unit_price, :cart_id, :product_id]
    end

    update :update do
      accept [:quantity]
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

    timestamps()
  end

  relationships do
    belongs_to :cart, KempaEcommerce.Shopping.Cart do
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
