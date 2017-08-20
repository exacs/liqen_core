defmodule LiqenCore.CMSTest do
  use LiqenCore.DataCase
  alias LiqenCore.CMS
  alias LiqenCore.CMS.{Entry}

  @params_entry %{
    title: "Digimon adventures",
  }

  defp insert_entry(params) do
    Repo.insert(Map.merge(%Entry{}, params))
  end

  test "Create a valid entry" do
    assert {:ok, returned} = CMS.create_entry(@params_entry)

    expected = Map.put(@params_entry, :id, returned.id)
    assert expected == returned
  end

  test "Fail to create a entry without some parameters" do
    empty_params = %{}

    assert {:error, changeset} = CMS.create_entry(empty_params)
    assert %{title: _} = errors_on(changeset)
  end

  test "Get an existing entry" do
    {:ok, inserted} = insert_entry(@params_entry)
    expected = Map.put(@params_entry, :id, inserted.id)

    assert {:ok, returned} = CMS.get_entry(inserted.id)
    assert returned == expected
  end

  test "Fail to get a non-existing entry" do
    insert_entry(@params_entry)

    assert {:error, :not_found} == CMS.get_entry(0)
  end

  test "Get all entries when there is no entry" do
    assert {:ok, []} == CMS.list_entries()
  end

  test "Get all entries" do
    {:ok, i1} = insert_entry(@params_entry)
    {:ok, i2} = insert_entry(@params_entry)

    e1 = Map.put(@params_entry, :id, i1.id)
    e2 = Map.put(@params_entry, :id, i2.id)

    assert {:ok, list} = CMS.list_entries()

    assert Enum.member?(list, e1)
    assert Enum.member?(list, e2)
  end
end
