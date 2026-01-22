defmodule Open2log.Products.ProductMatch do
  @moduledoc """
  Tracks user votes for matching physical products (scanned barcodes)
  to online products (crawled data without barcodes).
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "product_matches" do
    # The physical product with barcode
    belongs_to :physical_product, Open2log.Products.Product
    # The crawled online product without barcode
    belongs_to :online_product, Open2log.Products.Product
    belongs_to :user, Open2log.Accounts.User

    field :vote, Ecto.Enum, values: [:match, :not_match]
    field :confidence, :float

    timestamps(type: :utc_datetime)
  end

  def changeset(match, attrs) do
    match
    |> cast(attrs, [:physical_product_id, :online_product_id, :user_id, :vote, :confidence])
    |> validate_required([:physical_product_id, :online_product_id, :user_id, :vote])
    |> foreign_key_constraint(:physical_product_id)
    |> foreign_key_constraint(:online_product_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:physical_product_id, :online_product_id, :user_id],
       name: :product_matches_unique_vote)
  end
end
