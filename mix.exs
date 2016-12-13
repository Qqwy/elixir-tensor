defmodule Tensor.Mixfile do
  use Mix.Project

  def project do
    [app: :tensor,
     version: "0.7.2",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:dialyxir, "~> 0.3", only: :dev},
      {:ex_doc, ">= 0.14.0", only: :dev},
      {:numbers, "~> 0.1"}
    ]
  end

  defp description do
    """
    Tensor adds Vectors, Matrices and Tensors to your application. These are a lot faster than a list (of lists).
    """
  end

  defp package do
    [# These are the default files included in the package
     name: :tensor,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Wiebe-Marten/Qqwy"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/qqwy/tensor",
              }]
  end
end
