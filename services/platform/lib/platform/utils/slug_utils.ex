defmodule Platform.Utils.SlugUtils do
  import Ecto.Query
  import Ecto.Changeset

  def generate_unique_slug(changeset, field) do
    if str = get_change(changeset, field) do
      base_slug = Slugger.slugify_downcase(str)
      final_slug = check_unicity_and_suffix_if_necessary(base_slug)
      put_change(changeset, :slug, final_slug)
    else
      changeset
    end
  end

  defp check_unicity_and_suffix_if_necessary(slug, suffix \\ "") do
    current_slug = "#{slug}#{suffix}"

    if Platform.Repo.exists?(from k in Platform.Game.Kingdom, where: k.slug == ^current_slug) do
      new_suffix = "-" <> :crypto.strong_rand_bytes(3)
      |> Base.url_encode64(padding: false)
      |> String.downcase()

      check_unicity_and_suffix_if_necessary(slug, new_suffix)
    else
      current_slug
    end
  end
end
