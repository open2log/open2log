defmodule Open2log.Products.Price do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "prices" do
    belongs_to :product, Open2log.Products.Product
    belongs_to :shop, Open2log.Stores.Shop
    belongs_to :user, Open2log.Accounts.User

    # Price info
    field :price_cents, :integer
    field :currency, :string, default: "EUR"

    # Unit price for comparison
    field :unit_price_cents, :integer
    field :comparison_unit, Ecto.Enum, values: [:kg, :l, :pcs]

    # Source tracking
    field :source, Ecto.Enum, values: [:crawled, :user_scanned]
    field :scanned_at, :utc_datetime

    # Images stored in R2
    field :barcode_image_url, :string
    field :price_image_url, :string

    # Validity
    field :valid_from, :utc_datetime
    field :valid_until, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(price, attrs) do
    price
    |> cast(attrs, [:product_id, :shop_id, :user_id, :price_cents, :currency,
                    :unit_price_cents, :comparison_unit, :source, :scanned_at,
                    :barcode_image_url, :price_image_url, :valid_from, :valid_until])
    |> validate_required([:product_id, :shop_id, :price_cents, :source])
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:shop_id)
  end
end
