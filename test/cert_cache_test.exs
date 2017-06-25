defmodule CertCacheTest do
  use ExUnit.Case
  doctest CertCache
  @fixtures_path "./test/fixtures"

  setup do
    CertCache.start_link(@fixtures_path)
    clear_cert("test-crt.pem")
    on_exit(fn -> clear_cert("test-crt.pem") end)
    :ok
  end

  test "a get for a not in cache reads from provider" do
    set_cert("test-crt.pem", "sample1-crt.pem")
    assert CertCache.get_cert("test-crt.pem") == get_cert("sample1-crt.pem")
  end

  test "a get for a cert in cache reads from cache" do
    set_cert("test-crt.pem", "sample1-crt.pem")
    assert CertCache.get_cert("test-crt.pem") == get_cert("sample1-crt.pem")
    set_cert("test-crt.pem", "sample2-crt.pem")
    assert CertCache.get_cert("test-crt.pem") == get_cert("sample1-crt.pem")
  end

  test "a bypassing get for a cert in cache reads from provider" do
    set_cert("test-crt.pem", "sample1-crt.pem")
    assert CertCache.get_cert("test-crt.pem") == get_cert("sample1-crt.pem")
    set_cert("test-crt.pem", "sample2-crt.pem")
    assert CertCache.get_cert("test-crt.pem", false) == get_cert("sample2-crt.pem")
  end

  test "a get for a non-existent cert raises File.Error" do
    assert_raise(File.Error, fn -> CertCache.get_cert("test-crt.pem") end)
  end

  defp get_path(filename) do
    Path.expand(Path.join(@fixtures_path, filename))
  end

  defp set_cert(dest_filename, src_filename) do
    File.copy!(get_path(src_filename), get_path(dest_filename))
  end

  defp clear_cert(filename) do
    File.rm(get_path(filename))
  end

  defp get_cert(filename) do
    File.read!(get_path(filename)) |> :public_key.pem_decode
  end
end
