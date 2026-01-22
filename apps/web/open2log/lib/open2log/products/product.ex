defmodule Open2log.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    # Barcode identification
    field :ean, :string
    field :sku, :string

    # Product info
    field :name, :string
    field :brand, :string
    field :description, :string
    field :category, :string

    # Unit info
    field :unit_size, :float
    field :unit_type, Ecto.Enum, values: [:g, :kg, :ml, :l, :pcs]

    # Images stored in R2
    field :image_url, :string

    # Source tracking
    field :source, Ecto.Enum, values: [:crawled, :user_submitted]
    field :source_url, :string

    # Match confidence for barcode-to-online matching
    field :match_confidence, :float
    field :vote_count, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  def changeset(product, attrs) do
    product
    |> cast(attrs, [:ean, :sku, :name, :brand, :description, :category,
                    :unit_size, :unit_type, :image_url, :source, :source_url,
                    :match_confidence, :vote_count])
    |> validate_required([:name])
    |> unique_constraint(:ean)
  end
end
