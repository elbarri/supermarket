defmodule Checkout.Catalog do
  use Agent

  @me __MODULE__
  def start_link(_) do
    Agent.start_link(&product_list/0, name: @me)
  end

  def product(code) do
    Agent.get(@me, &Map.get(&1, code))
  end

  defp product_list() do
    %{
      "GR1" => %{name: "Green Tea", price: Money.new(3_11)},
      "SR1" => %{name: "Strawberries", price: Money.new(5_00)},
      "CF1" => %{name: "Coffee", price: Money.new(11_23)}
    }
  end
end
