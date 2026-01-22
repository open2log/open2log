defmodule Open2log.Repo.Migrations.CreateProductMatches do
  use Ecto.Migration

  def change do
    create table(:product_matches, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :physical_product_id, references(:products, type: :binary_id), null: false
      add :online_product_id, references(:products, type: :binary_id), null: false
      add :user_id, references(:users, type: :binary_id), null: false
      add :vote, :string, null: false
      add :confidence, :float

      timestamps(type: :utc_datetime)
    end

    create index(:product_matches, [:physical_product_id])
    create index(:product_matches, [:online_product_id])
    create unique_index(:product_matches, [:physical_product_id, :online_product_id, :user_id],
      name: :product_matches_unique_vote)
  end
end
