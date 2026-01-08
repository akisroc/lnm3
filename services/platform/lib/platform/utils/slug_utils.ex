defmodule Platform.Utils.SlugUtils do
  import Ecto.Query
  import Ecto.Changeset

  @doc """
  `schema` example: Platform.Game.Kingdom
  """
  def generate_unique_slug(changeset, schema, field) do
    if str = get_change(changeset, field) do
      base_slug = Slugger.slugify_downcase(str)
      final_slug = check_unicity_and_suffix_if_necessary(schema, base_slug)
      put_change(changeset, :slug, final_slug)
    else
      changeset
    end
  end

  defp check_unicity_and_suffix_if_necessary(schema, slug, suffix \\ "") do
    current_slug = "#{slug}#{suffix}"

    if Platform.Repo.exists?(from x in schema, where: field(x, :slug) == ^current_slug) do
      new_suffix = "-" <> generate_random_suffix()
      check_unicity_and_suffix_if_necessary(schema, slug, new_suffix)
    else
      current_slug
    end
  end

  defp generate_random_suffix do
    :crypto.strong_rand_bytes(3)
    |> Base.url_encode64(padding: false)
    |> String.downcase()
  end
end
