defmodule Checkout.Cashier do
  @moduledoc """
  Handles cashier operations
  """
  alias Checkout.Catalog
  alias Checkout.DiscountCalculator, as: Discount
  alias __MODULE__

  defstruct(
    pricing_rules: [],
    items: []
  )

  def new_with(pricing_rules) do
    %Cashier{
      pricing_rules: pricing_rules,
      items: []
    }
  end

  def scan(cashier, item) do
    with product when not is_nil(product) <- Catalog.product(item) do
      cashier = %Cashier{
        pricing_rules: cashier.pricing_rules,
        items: cashier.items ++ [item]
      }

      {cashier, product}
    else
      _ -> {cashier, nil}
    end
  end

  @doc """
  Returns a total after applying discounts, if any.
  """
  def total(basket) do
    basket.items
    |> Enum.reduce(Money.new(0), &Money.add(Catalog.product(&1).price, &2))
    |> Money.subtract(discounts(basket.items, basket.pricing_rules))
  end

  defp discounts(_, []), do: Money.new(0)

  defp discounts(items, [head | tail]) do
    Discount.calculate(items, head)
    |> Money.add(discounts(items, tail))
  end
end
