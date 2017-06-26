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
      description: "A certificate cache for Elixir / Pheonix",
      package: package()
    ]
  end

  def application do
    [extra_applications: [ :logger ]]
  end

  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
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
