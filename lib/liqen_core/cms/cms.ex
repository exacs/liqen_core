defmodule LiqenCore.CMS do
  alias LiqenCore.CMS.{Entry,
                       ExternalHTML}
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
    params =
      params
      |> Map.put(:entry_type, "external_html")

    %Entry{}
    |> Entry.changeset(params)
    |> Ecto.Changeset.cast_assoc(:external_html, with: &ExternalHTML.changeset/2)
    |> Repo.insert()
    |> put_content()
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
    entry = Map.take(object, [:id, :title, :entry_type])
    {:ok, content} = take({:ok, Map.get(object, :content)})

    {:ok, Map.put(entry, :content, content)}
  end
  defp take({:ok, %ExternalHTML{} = object}) do
    {:ok, Map.take(object, [:uri])}
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

  defp put_external_html(%Ecto.Changeset{valid?: true} = changeset) do
    changeset

  end

  defp put_content({:ok, %Entry{} = object}) do
    content =
      case Map.get(object, :entry_type) do
        "external_html" -> Map.get(object, :external_html)
      end

    {:ok, Map.put(object, :content, content)}
  end
  defp put_content(any), do: any
end
