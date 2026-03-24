defmodule KempaEcommerce.Accounts.User do
  @moduledoc """
  Represents a user account in the system.
  """
  use Ash.Resource,
    otp_app: :kempa_ecommerce,
    domain: KempaEcommerce.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type :user

    queries do
      get :get_user, :read
      list :list_users, :read
    end

    mutations do
      create :register, :register
      update :update_user, :update
    end
  end

  postgres do
    table "users"
    repo KempaEcommerce.Repo
  end

  actions do
    defaults [:read]

    create :register do
      accept [:email, :first_name, :last_name, :phone]
    end

    update :update do
      accept [:first_name, :last_name, :phone, :is_active]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :string do
      allow_nil? false
      public? true
    end

    attribute :first_name, :string do
      allow_nil? false
      public? true
    end

    attribute :last_name, :string do
      allow_nil? false
      public? true
    end

    attribute :phone, :string do
      public? true
    end

    attribute :role, :atom do
      default :customer
      allow_nil? false
      public? true
      constraints [one_of: [:customer, :admin, :staff]]
    end

    attribute :is_active, :boolean do
      default true
      public? true
    end

    timestamps()
  end

  relationships do
    has_many :orders, KempaEcommerce.Ordering.Order
    has_many :carts, KempaEcommerce.Shopping.Cart
  end

  identities do
    identity :unique_email, [:email]
  end
end
