defmodule Open2log.Repo.Migrations.CreatePrices do
  use Ecto.Migration

  def change do
    create table(:prices, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :product_id, references(:products, type: :binary_id), null: false
      add :shop_id, references(:shops, type: :binary_id)
      add :user_id, references(:users, type: :binary_id)
      add :price_cents, :integer, null: false
      add :currency, :string, default: "EUR"
      add :unit_price_cents, :integer
      add :comparison_unit, :string
      add :source, :string, null: false
      add :scanned_at, :utc_datetime
      add :barcode_image_url, :string
      add :price_image_url, :string
      add :valid_from, :utc_datetime
      add :valid_until, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:prices, [:product_id])
    create index(:prices, [:shop_id])
    create index(:prices, [:valid_from])
  end
end
