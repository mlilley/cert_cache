defmodule CertCache.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cert_cache,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: "A certificate cache for Elixir / Phoenix",
      package: package()
    ]
  end

  def application do
    [
      # mod: {CertCache.Application, []},
      extra_applications: [ :logger ]
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:stubr, "~> 1.5.0", only: :test, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Michael Lilley"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mlilley/cert_cache"}
    ]
  end
end
