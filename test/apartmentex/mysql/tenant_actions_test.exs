defmodule Apartmentex.TenantActionsMySQLTest do
  use ExUnit.Case

  alias Apartmentex.Note
  alias Apartmentex.TestMySQLRepo

  @migration_version 20160711125401
  @repo TestMySQLRepo
  @tenant_id 2

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(@repo)

    Apartmentex.drop_tenant(@repo, @tenant_id)

    on_exit fn ->
      Apartmentex.drop_tenant(@repo, @tenant_id)
    end
  end

  test ".migrate_tenant/2 migrates the tenant forward" do
    create_tenant_schema

    assert_creates_notes_table fn ->
      {status, prefix, versions} = Apartmentex.migrate_tenant(@repo, @tenant_id)
        |> IO.inspect

      assert status == :ok
      assert prefix == "tenant_#{@tenant_id}"
      assert versions == [@migration_version]
    end
  end

  test ".migrate_tenant/2 returns an error tuple when it fails" do
    create_and_migrate_tenant

    force_migration_failure fn(expected_db_error) ->
      {status, prefix, error_message} = Apartmentex.migrate_tenant(@repo, @tenant_id)
        |> IO.inspect

      assert status == :error
      assert prefix == "tenant_#{@tenant_id}"
      assert error_message == expected_db_error
    end
  end

  defp assert_creates_notes_table(fun) do
    assert_notes_table_is_dropped
    fun.()
    assert_notes_table_is_present
  end

  defp assert_drops_notes_table(fun) do
    assert_notes_table_is_present
    fun.()
    assert_notes_table_is_dropped
  end

  defp assert_notes_table_is_dropped do
    assert_raise Mariaex.Error, fn ->
      find_tenant_notes
    end
  end

  defp assert_notes_table_is_present do
    assert find_tenant_notes == []
  end

  defp create_and_migrate_tenant do
    Apartmentex.new_tenant(@repo, @tenant_id)
  end

  defp create_tenant_schema do
    Apartmentex.TenantActions.create_schema(@repo, @tenant_id)
  end

  defp find_tenant_notes do
    Apartmentex.all(@repo, Note, @tenant_id)
  end

  defp force_migration_failure(migration_function) do
    @repo
    |> Ecto.Adapters.SQL.query("DELETE FROM \"tenant_#{@tenant_id}\".\"schema_migrations\"", [])

    migration_function.("ERROR (duplicate_table): relation \"notes\" already exists")
  end
end
