defmodule KempaEcommerce.Catalog.Category do
  @moduledoc """
  Represents a product category in the catalog.
  """
  use Ash.Resource,
    otp_app: :kempa_ecommerce,
    domain: KempaEcommerce.Catalog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type :category

    queries do
      get :get_category, :read
      list :list_categories, :read
    end

    mutations do
      create :create_category, :create
      update :update_category, :update
      destroy :destroy_category, :destroy
    end
  end

  postgres do
    table "categories"
    repo KempaEcommerce.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name, :description, :slug, :parent_id]
    end

    update :update do
      accept [:name, :description, :slug, :parent_id]
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

    attribute :is_active, :boolean do
      default true
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :parent, KempaEcommerce.Catalog.Category do
      attribute_writable? true
      public? true
    end

    has_many :subcategories, KempaEcommerce.Catalog.Category do
      destination_attribute :parent_id
    end

    has_many :products, KempaEcommerce.Catalog.Product
  end

  identities do
    identity :unique_slug, [:slug]
  end
end
