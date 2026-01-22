defmodule Open2log.Stores.Shop do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shops" do
    # Overture Maps GERS ID for unique identification
    field :gers_id, :string

    # Basic info
    field :name, :string
    field :chain, Ecto.Enum, values: [:lidl, :s_kaupat, :k_market, :tokmanni, :prisma, :other]
    field :address, :string
    field :city, :string
    field :postal_code, :string
    field :country, :string, default: "FI"

    # Location - H3 index for efficient geo queries
    field :latitude, :float
    field :longitude, :float
    field :h3_index, :string

    # Opening hours (stored as JSONB-like map)
    field :opening_hours, :map

    timestamps(type: :utc_datetime)
  end

  def changeset(shop, attrs) do
    shop
    |> cast(attrs, [:gers_id, :name, :chain, :address, :city, :postal_code,
                    :country, :latitude, :longitude, :h3_index, :opening_hours])
    |> validate_required([:name, :chain, :latitude, :longitude])
    |> unique_constraint(:gers_id)
    |> compute_h3_index()
  end

  defp compute_h3_index(changeset) do
    # H3 index will be computed when we have lat/lng
    # Resolution 9 gives ~174m hexagons, good for store identification
    lat = get_change(changeset, :latitude)
    lng = get_change(changeset, :longitude)

    if lat && lng do
      # This would use an H3 library - placeholder for now
      # h3_index = H3.geo_to_h3(lat, lng, 9)
      changeset
    else
      changeset
    end
  end
end
