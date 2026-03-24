defmodule KempaEcommerce.Shopping.Cart do
  @moduledoc """
  Represents a shopping cart for a user.
  """
  use Ash.Resource,
    otp_app: :kempa_ecommerce,
    domain: KempaEcommerce.Shopping,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type :cart

    queries do
      get :get_cart, :read
      list :list_carts, :read
    end

    mutations do
      create :create_cart, :create
    end
  end

  postgres do
    table "carts"
    repo KempaEcommerce.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:user_id]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :status, :atom do
      default :active
      allow_nil? false
      public? true
      constraints [one_of: [:active, :abandoned, :converted]]
    end

    timestamps()
  end

  relationships do
    belongs_to :user, KempaEcommerce.Accounts.User do
      allow_nil? false
      attribute_writable? true
      public? true
    end

    has_many :items, KempaEcommerce.Shopping.CartItem
  end
end
