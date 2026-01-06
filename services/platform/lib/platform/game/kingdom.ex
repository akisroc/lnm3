defmodule Platform.Game.Kingdom do
  use Ecto.Schema
  import Ecto.Changeset
  import Platform.Utils.SlugUtils

  @name_regex ~r/^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-]+$/
  @slug_regex ~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/

  @primary_key {:id, Platform.EctoTypes.UUIDv7, autogenerate: true}
  @foreign_key_type Platform.EctoTypes.UUIDv7

  schema "kingdoms" do
    field :name, :string
    field :slug, :string
    field :fame, :decimal, default: Decimal.new("30000.0")
    field :defense_troup, {:array, :integer}, default: [0, 0, 0, 0, 0, 0, 0, 0]
    field :attack_troup, {:array, :integer}, default: [0, 0, 0, 0, 0, 0, 0, 0]
    field :is_active, :boolean, default: false
    field :is_removed, :boolean, default: false

    belongs_to :user, Platform.Accounts.User

    timestamps()
  end

  def changeset(kingdom, attrs) do
    kingdom
    |> cast(attrs, [:user_id, :name, :slug, :fame, :defense_troup, :attack_troup, :is_active, :is_removed])
    |> validate_required([:user_id, :name])
    |> unique_constraint([:name, :slug])
    |> generate_unique_slug(:name)
    |> validate_length(:name, min: 1, max: 63)
    |> validate_length(:slug, min: 1, max: 127)
    |> validate_fame()
    |> validate_format(:name, @name_regex)
    |> validate_format(:slug, @slug_regex)
    |> validate_troup_structure(:attack_troup)
    |> validate_troup_structure(:defense_troup)

    |> update_change(:name, &String.trim/1)

  end

  defp validate_fame(changeset) do
    validate_number(changeset, :fame, greater_than_or_equal_to: 0)
  end

  defp validate_troup_structure(changeset, field) do
    validate_change(changeset, field, fn _, values ->
      cond do
        length(values) != 8 ->
          [{field, "Must have exactly 8 elements"}]
        Enum.any?(values, &(&1 < 0)) ->
          [{field, "Cannot contain negative integers"}]
        true ->
          []
      end
    end)
  end
end
