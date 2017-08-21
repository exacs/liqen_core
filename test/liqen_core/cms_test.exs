defmodule LiqenCore.CMSTest do
  use LiqenCore.DataCase
  alias LiqenCore.CMS
  alias LiqenCore.CMS.{Entry}

  @params_entry %{
    title: "Digimon adventures",
  }

  @expected_entry %{
    title: "Digimon adventures",
    entry_type: nil,
    content: nil
  }

  @params_external_html %{
    title: "Digimon adventures 02",
    external_html: %{
      uri: "https://en.wikipedia.org/wiki/Digimon_Adventure_02"
    }
  }

  @expected_external_html %{
    title: "Digimon adventures 02",
    entry_type: "external_html",
    content: %{
      uri: "https://en.wikipedia.org/wiki/Digimon_Adventure_02"
    }
  }

  defp insert_entry(params) do
    Repo.insert(Map.merge(%Entry{}, params))
  end

  test "Create a valid entry" do
    assert {:ok, returned} = CMS.create_entry(@params_entry)

    expected =
      @expected_entry
      |> Map.put(:id, returned.id)

    assert expected == returned
  end

  test "Create a external_html entry" do
    assert {:ok, returned} = CMS.create_external_html(@params_external_html)

    expected =
      @expected_external_html
      |> Map.put(:id, returned.id)

    assert expected == returned
  end

  test "Fail to create a external_html entry without some parameters" do
    empty_params = %{
      title: "Digimon Adventures 02",
      external_html: %{}
    }
    assert {:error, changeset} = CMS.create_external_html(empty_params)
    assert %{external_html: _} = errors_on(changeset)
  end

  test "Fail to create a entry without some parameters" do
    empty_params = %{}

    assert {:error, changeset} = CMS.create_entry(empty_params)
    assert %{title: _} = errors_on(changeset)
  end

  test "Get an existing entry" do
    {:ok, inserted} = insert_entry(@params_entry)
    expected =
      @expected_entry
      |> Map.put(:id, inserted.id)

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

    e1 =
      @expected_entry
      |> Map.put(:id, i1.id)

    e2 =
      @expected_entry
      |> Map.put(:id, i2.id)

    assert {:ok, list} = CMS.list_entries()

    assert Enum.member?(list, e1)
    assert Enum.member?(list, e2)
  end
end
