defmodule Platform.Game.Battle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Platform.EctoTypes.UUIDv7, autogenerate: true}
  @foreign_key_type Platform.EctoTypes.UUIDv7

  schema "battles" do

  end

end
