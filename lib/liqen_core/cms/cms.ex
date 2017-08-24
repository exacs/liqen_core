defmodule LiqenCore.CMS do
  alias LiqenCore.CMS.{Entry,
                       ExternalHTML,
                       MediumPost,
                       Author}
  alias LiqenCore.Accounts
  alias LiqenCore.Repo
  @moduledoc """
  Content Management System of Liqen Core.

  - This module handles user permissions for managing content.
  """

  @typedoc """
  Represents an entry. It has four fields: "id", "title", "author" and "content":

  ```
  %{
    id: "1",
    title: "Digimon Adventures",
    author: %{
      id: "42",
      username: "tai",
      name: "Taichi Yagami"
    },
    entry_type: :medium,
    content: %{
      uri: "http://medium.com/..."
    }
  }
  ```

  Depending on the entry type (indicated by an atom in the "entry_type" field), the
  shape of the "content" field may vary.

  The module `LiqenCore.CMS.EntryContent` has all the type definitions of the
  possible `content` values.

  Currently, we allow the following entry types:

  | Type                 | entry_type         | content     |
  | :------------------- | :----------------- | :---------- |
  | External HTML        | `external_html`    | `t:LiqenCore.CMS.EntryContent.external_html_content/0` |
  | Medium article       | `medium`           | `t:LiqenCore.CMS.EntryContent.medium_content/0` |
  """
  @type entry :: %{
    id: number,
    title: String.t,
    author: LiqenCore.Accounts.user,
    entry_type: String.t,
    content: LiqenCore.CMS.EntryContent.t
  }

  @doc """
  Returns one entry
  """
  def get_entry(id) do
    Entry
    |> get(id)
    |> take()
  end

  @doc """
  Returns the list of all entries
  """
  def list_entries do
    Entry
    |> get_all()
    |> take()
  end

  @doc """
  Creates a generic entry
  """
  def create_entry(params) do
    %Entry{}
    |> Entry.changeset(params)
    |> Repo.insert()
    |> take()
  end

  @doc """
  Creates an entry of type `external_html`
  """
  def create_external_html(params) do
    params
    |> prepare_entry_params(:external_html)
    |> Repo.insert()
    |> put_content()
    |> take()
  end

  @doc """
  Creates an entry of type `medium_post`
  """
  def create_medium_post(params) do
    params
    |> prepare_entry_params(:medium_post)
    |> Repo.insert()
    |> put_content()
    |> take()
  end

  def ensure_author_exists(%Accounts.User{} = user) do
    %Author{user_id: user.id}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.unique_constraint(:user_id)
    |> Repo.insert()
    |> handle_existing_author()
  end

  defp handle_existing_author({:ok, author}), do: author
  defp handle_existing_author({:error, changeset}) do
    Repo.get_by!(Author, user_id: changeset.data.user_id)
  end

  defp prepare_entry_params(params, type) do
    {name, module} =
      case type do
        :external_html ->
          {"external_html", ExternalHTML}
        :medium_post ->
          {"medium_post", MediumPost}
      end

    params = Map.put(params, :entry_type, name)

    %Entry{}
    |> Entry.changeset(params)
    |> Ecto.Changeset.cast_assoc(type, with: &module.changeset/2)
  end

  defp take(list) when is_list(list) do
    list =
      list
      |> Enum.map(&take(&1))
      |> Enum.map(fn {:ok, obj} -> obj end)

    {:ok, list}
  end
  defp take({:ok, %Entry{} = object}) do
    entry = Map.take(object, [:id, :title, :entry_type])
    {:ok, content} = take({:ok, Map.get(object, :content)})

    {:ok, Map.put(entry, :content, content)}
  end
  defp take({:ok, %ExternalHTML{} = object}) do
    {:ok, Map.take(object, [:uri])}
  end
  defp take({:ok, %MediumPost{} = object}) do
    {:ok, Map.take(object, [:uri, :title, :publishing_date, :license, :tags])}
  end
  defp take(any), do: any

  defp get(struct, id) do
    case Repo.get(struct, id) do
      %{} = object ->
        {:ok, object}

      _ ->
        {:error, :not_found}
    end
  end
  defp get_all(struct) do
    struct
    |> Repo.all()
    |> Enum.map(fn obj -> {:ok, obj} end)
  end

  defp put_content({:ok, %Entry{} = object}) do
    content =
      case Map.get(object, :entry_type) do
        "external_html" -> Map.get(object, :external_html)
        "medium_post" -> Map.get(object, :medium_post)
        _ -> nil
      end

    {:ok, Map.put(object, :content, content)}
  end
  defp put_content(any), do: any
end
