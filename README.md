# KempaEcommerce

Backend de e-commerce construido con **Elixir**, **Phoenix**, **Ash Framework**, **PostgreSQL**, **GraphQL** (AshGraphql) y **Máquinas de Estado** (AshStateMachine).

## Arquitectura

### Dominios y Recursos

El sistema está organizado en 5 dominios principales:

| Dominio | Recursos | Descripción |
|---------|----------|-------------|
| **Catalog** | `Category`, `Product` | Gestión del catálogo de productos y categorías |
| **Accounts** | `User` | Registro y gestión de usuarios |
| **Shopping** | `Cart`, `CartItem` | Carrito de compras |
| **Ordering** | `Order` ⚡, `OrderItem` | Gestión de pedidos (con máquina de estado) |
| **Payments** | `PaymentTransaction` ⚡ | Transacciones de pago (con máquina de estado) |

### Máquinas de Estado

#### Order (Pedido)
```
pending → confirmed → processing → shipped → delivered
                                 ↘ cancelled
pending → cancelled
confirmed → cancelled
```

#### PaymentTransaction (Transacción de Pago)
```
pending → processing → completed
pending → processing → failed → pending (retry)
pending → cancelled
processing → refunded
completed → refunded
```

### API GraphQL

- **Endpoint**: `POST /api/graphql`
- **GraphiQL** (solo dev): `GET /api/graphiql`
- **Health Check**: `GET /api/health`

## Requisitos Previos

- **Elixir** >= 1.16
- **Erlang/OTP** >= 26
- **PostgreSQL** >= 14
- **Node.js** (opcional, para assets)

## Inicialización Rápida

### 1. Crear el proyecto desde cero (alternativa)

Si prefieres iniciar con `mix igniter.new`:

```bash
mix igniter.new kempa_ecommerce --install ash,ash_postgres,ash_graphql
```

### 2. Instalar dependencias

```bash
mix deps.get
```

### 3. Configurar la base de datos

Asegúrate de que PostgreSQL esté corriendo y edita `config/dev.exs` con tus credenciales:

```elixir
config :kempa_ecommerce, KempaEcommerce.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "kempa_ecommerce_dev"
```

### 4. Crear y migrar la base de datos

```bash
# Generar migraciones de Ash
mix ash.codegen initial_migration

# Crear la base de datos y ejecutar migraciones
mix ash.setup
```

### 5. Levantar el servidor

```bash
mix phx.server
```

O dentro de IEx:

```bash
iex -S mix phx.server
```

El servidor estará disponible en:
- API GraphQL: http://localhost:4000/api/graphql
- GraphiQL: http://localhost:4000/api/graphiql

## Estructura del Proyecto

```
lib/
├── kempa_ecommerce/
│   ├── application.ex          # Supervisor OTP
│   ├── repo.ex                 # Repositorio Ecto/AshPostgres
│   ├── accounts/
│   │   ├── accounts.ex         # Dominio Accounts
│   │   └── resources/
│   │       └── user.ex         # Recurso User
│   ├── catalog/
│   │   ├── catalog.ex          # Dominio Catalog
│   │   └── resources/
│   │       ├── category.ex     # Recurso Category
│   │       └── product.ex      # Recurso Product
│   ├── shopping/
│   │   ├── shopping.ex         # Dominio Shopping
│   │   └── resources/
│   │       ├── cart.ex         # Recurso Cart
│   │       └── cart_item.ex    # Recurso CartItem
│   ├── ordering/
│   │   ├── ordering.ex         # Dominio Ordering
│   │   └── resources/
│   │       ├── order.ex        # Recurso Order (StateMachine)
│   │       └── order_item.ex   # Recurso OrderItem
│   └── payments/
│       ├── payments.ex         # Dominio Payments
│       └── resources/
│           └── payment_transaction.ex  # Recurso PaymentTransaction (StateMachine)
├── kempa_ecommerce_web/
│   ├── endpoint.ex             # Phoenix Endpoint
│   ├── router.ex               # Rutas (GraphQL + GraphiQL)
│   ├── schema.ex               # Schema GraphQL (AshGraphql)
│   ├── error_json.ex           # Manejo de errores JSON
│   ├── telemetry.ex            # Métricas y telemetría
│   └── controllers/
│       └── health_controller.ex # Health check
config/
├── config.exs                  # Configuración general + dominios Ash
├── dev.exs                     # Configuración desarrollo
├── test.exs                    # Configuración tests
├── prod.exs                    # Configuración producción
└── runtime.exs                 # Variables de entorno en producción
```

## Dependencias Principales

| Dependencia | Versión | Propósito |
|-------------|---------|-----------|
| `ash` | ~> 3.4 | Framework principal de recursos |
| `ash_postgres` | ~> 2.4 | Data layer PostgreSQL |
| `ash_graphql` | ~> 1.4 | Extensión GraphQL |
| `ash_state_machine` | ~> 0.2 | Máquinas de estado |
| `picosat_elixir` | ~> 0.2 | SAT solver (requerido por Ash) |
| `phoenix` | ~> 1.7.18 | Framework web |
| `absinthe` | ~> 1.7 | GraphQL para Elixir |
| `absinthe_plug` | ~> 1.5 | Plug para Absinthe |

## Ejemplos de Uso con GraphQL

### Crear una categoría

```graphql
mutation {
  createCategory(input: {
    name: "Electrónica"
    slug: "electronica"
    description: "Productos electrónicos"
  }) {
    result {
      id
      name
      slug
    }
  }
}
```

### Crear un producto

```graphql
mutation {
  createProduct(input: {
    name: "Laptop Pro"
    slug: "laptop-pro"
    sku: "LAP-001"
    price: "999.99"
    stockQuantity: 50
    categoryId: "<category-uuid>"
  }) {
    result {
      id
      name
      price
      stockQuantity
    }
  }
}
```

### Crear un pedido y avanzar el estado

```graphql
# Crear orden
mutation {
  createOrder(input: {
    userId: "<user-uuid>"
    shippingAddress: "Calle 123, Ciudad"
  }) {
    result {
      id
      orderNumber
      state
    }
  }
}

# Confirmar orden
mutation {
  confirmOrder(id: "<order-uuid>") {
    result {
      id
      state
    }
  }
}
```

### Procesar un pago

```graphql
# Crear transacción de pago
mutation {
  createPaymentTransaction(input: {
    orderId: "<order-uuid>"
    amount: "999.99"
    paymentMethod: CREDIT_CARD
  }) {
    result {
      id
      transactionNumber
      state
    }
  }
}

# Iniciar procesamiento
mutation {
  startProcessing(id: "<transaction-uuid>", input: {
    gatewayReference: "stripe_pi_123456"
  }) {
    result {
      id
      state
      gatewayReference
    }
  }
}
```

## Tests

```bash
mix test
```

## Producción

Variables de entorno necesarias:

```bash
DATABASE_URL=ecto://user:pass@host/kempa_ecommerce_prod
SECRET_KEY_BASE=$(mix phx.gen.secret)
PHX_HOST=tudominio.com
PORT=4000
```

## Licencia

Proyecto privado - KempaEcommerce © 2024
