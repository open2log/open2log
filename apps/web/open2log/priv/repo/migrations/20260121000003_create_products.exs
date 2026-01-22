defmodule Open2log.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ean, :string
      add :sku, :string
      add :name, :string, null: false
      add :brand, :string
      add :description, :text
      add :category, :string
      add :unit_size, :float
      add :unit_type, :string
      add :image_url, :string
      add :source, :string, null: false
      add :source_url, :string
      add :match_confidence, :float
      add :vote_count, :integer, default: 0

      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:ean])
    create index(:products, [:name])
    create index(:products, [:brand])
  end
end
