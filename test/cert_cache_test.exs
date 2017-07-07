defmodule CertCacheTest do
  use ExUnit.Case

  @procname __MODULE__
  @fixtures "test/fixtures"

  defp assert_down(pid) do
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end

  defp load_cert(filename) do
    filename
      |> to_fixture
      |> File.read!
      |> :public_key.pem_decode
  end

  defp to_fixture(filename) do
    @fixtures
      |> Path.join(filename)
      |> Path.expand
  end

  setup_all do
    context = [certs: [
      sample1: load_cert("sample1-crt.pem"),
      sample2: load_cert("sample2-crt.pem")
    ]]
    {:ok, context}
  end

  setup do
    {:ok, pid} = CertCache.start_link(name: @procname)
    context = [provider_spy: Stubr.spy!(CertCache.FileProvider)]
    on_exit(fn -> assert_down(pid) end)
    {:ok, context}
  end

  test "can get cert", context do
    opts = [name: @procname, provider: context[:provider_spy]]
    assert CertCache.get(to_fixture("sample1-crt.pem"), opts) == context[:certs][:sample1]
  end

  test "can fetch cert", context do
    opts = [name: @procname, provider: context[:provider_spy]]
    assert CertCache.fetch(to_fixture("sample1-crt.pem"), opts) == context[:certs][:sample1]
  end

  test "get non-existing cert raises File.Error", context do
    opts = [name: @procname, provider: context[:provider_spy]]
    assert_raise File.Error, fn -> CertCache.get(to_fixture("something.pem"), opts) end
  end

  test "fetch non-existing cert raises File.Error", context do
    opts = [name: @procname, provider: context[:provider_spy]]
    assert_raise File.Error, fn -> CertCache.fetch(to_fixture("something.pem"), opts) end
  end

  test "repeat gets read from cache", context do
    opts = [name: @procname, provider: context[:provider_spy]]
    assert CertCache.get(to_fixture("sample1-crt.pem"), opts) == context[:certs][:sample1]
    assert Stubr.called_once?(context[:provider_spy], :load)
    assert CertCache.get(to_fixture("sample1-crt.pem"), opts) == context[:certs][:sample1]
    assert CertCache.get(to_fixture("sample1-crt.pem"), opts) == context[:certs][:sample1]
    assert Stubr.called_once?(context[:provider_spy], :load)
  end

  test "repeat fetches dont read from cache", context do
    opts = [name: @procname, provider: context[:provider_spy]]
    assert CertCache.fetch(to_fixture("sample1-crt.pem"), opts) == context[:certs][:sample1]
    assert CertCache.fetch(to_fixture("sample1-crt.pem"), opts) == context[:certs][:sample1]
    assert CertCache.fetch(to_fixture("sample1-crt.pem"), opts) == context[:certs][:sample1]
    assert Stubr.called_thrice?(context[:provider_spy], :load)
  end

  test "fetches insert into cache", context do
    opts = [name: @procname, provider: context[:provider_spy]]
    assert CertCache.fetch(to_fixture("sample1-crt.pem"), opts) == context[:certs][:sample1]
    assert Stubr.called_once?(context[:provider_spy], :load)
    assert CertCache.get(to_fixture("sample1-crt.pem"), opts) == context[:certs][:sample1]
    assert Stubr.called_once?(context[:provider_spy], :load)
  end

  test "fetches update cache", context do
    temp    = to_fixture("temp-crt.pem")
    sample1 = to_fixture("sample1-crt.pem")
    sample2 = to_fixture("sample2-crt.pem")
    opts    = [name: @procname, provider: context[:provider_spy]]
    on_exit(fn -> File.rm(temp) end)

    File.rm(temp)
    File.copy!(sample1, temp)
    assert CertCache.get(to_fixture("temp-crt.pem"), opts) == context[:certs][:sample1]

    File.copy!(sample2, temp)
    assert CertCache.fetch(to_fixture("temp-crt.pem"), opts) == context[:certs][:sample2]
    assert CertCache.get(to_fixture("temp-crt.pem"), opts) == context[:certs][:sample2]
  end
end
