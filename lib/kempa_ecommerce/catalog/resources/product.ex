defmodule KempaEcommerce.Catalog.Product do
  @moduledoc """
  Represents a product in the catalog.
  """
  use Ash.Resource,
    otp_app: :kempa_ecommerce,
    domain: KempaEcommerce.Catalog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type :product

    queries do
      get :get_product, :read
      list :list_products, :read
    end

    mutations do
      create :create_product, :create
      update :update_product, :update
      destroy :destroy_product, :destroy
    end
  end

  postgres do
    table "products"
    repo KempaEcommerce.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name, :description, :slug, :sku, :price, :compare_at_price, :stock_quantity, :category_id]
    end

    update :update do
      accept [:name, :description, :slug, :sku, :price, :compare_at_price, :stock_quantity, :is_active, :category_id]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :slug, :string do
      allow_nil? false
      public? true
    end

    attribute :sku, :string do
      allow_nil? false
      public? true
      description "Stock Keeping Unit - unique product identifier"
    end

    attribute :price, :decimal do
      allow_nil? false
      public? true
      constraints [min: 0]
    end

    attribute :compare_at_price, :decimal do
      public? true
      constraints [min: 0]
      description "Original price before discount"
    end

    attribute :stock_quantity, :integer do
      default 0
      allow_nil? false
      public? true
      constraints [min: 0]
    end

    attribute :is_active, :boolean do
      default true
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :category, KempaEcommerce.Catalog.Category do
      attribute_writable? true
      public? true
    end
  end

  identities do
    identity :unique_slug, [:slug]
    identity :unique_sku, [:sku]
  end
end
