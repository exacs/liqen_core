defmodule LiqenCore.CMS do
  alias LiqenCore.CMS.Entry
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
    params = Map.put(params, :entry_type, "external_html")

    %Entry{}
    |> Entry.changeset(params)
    |> Repo.insert()
    |> take()
  end

  defp take(list) when is_list(list) do
    list =
      list
      |> Enum.map(&take(&1))
      |> Enum.map(fn {:ok, obj} -> obj end)

    {:ok, list}
  end
  defp take({:ok, %Entry{} = object}) do
    {:ok, Map.take(object, [:id, :title, :entry_type, :content])}
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
end
