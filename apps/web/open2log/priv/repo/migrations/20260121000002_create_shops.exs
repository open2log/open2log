defmodule Open2log.Repo.Migrations.CreateShops do
  use Ecto.Migration

  def change do
    create table(:shops, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :gers_id, :string
      add :name, :string, null: false
      add :chain, :string, null: false
      add :address, :string
      add :city, :string
      add :postal_code, :string
      add :country, :string, default: "FI"
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :h3_index, :string
      add :opening_hours, :map

      timestamps(type: :utc_datetime)
    end

    create unique_index(:shops, [:gers_id])
    create index(:shops, [:chain])
    create index(:shops, [:city])
    create index(:shops, [:h3_index])
  end
end
