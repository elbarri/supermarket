defmodule Checkout.DiscountCalculator do
  @moduledoc """
  Holds the logic to calculate the discounts
  Leaves the door open for extension/new discount types, ie. 10% off 
  when spending X amount of more. 
  """
  alias Checkout.Catalog

  @doc """
  Calculates the amount of money to deduct as a discount. 
  It applies a buy _threshold_ take _operand_ free

  ## Example
    iex> alias Checkout.DiscountCalculator
    iex> items = ["GR1","GR1"]
    iex> pr = %PricingRules{
    ...>discount_type: :buy_n_get_x_free,
    ...>threshold: 2,
    ...>operand: 1,
    ...>product_codes: ["GR1"]
    ...>}
    iex> DiscountCalculator.calculate(items, pr)
    Money.new(3_11)

    iex> alias Checkout.DiscountCalculator
    iex> items = ["SR1","SR1","SR1"]
    iex> pr = %PricingRules{
    ...>discount_type: :proportional,
    ...>threshold: 3,
    ...>operand: 0.10,
    ...>product_codes: ["SR1"]
    ...>}
    iex> DiscountCalculator.calculate(items, pr)
    Money.new(1_50)

  """
  def calculate(
        basket,
        %PricingRules{
          discount_type: :buy_n_get_x_free,
          threshold: threshold,
          operand: operand,
          product_codes: codes
        }
      )
      when length(codes) > 0 and threshold > 0 do
    basket
    |> filter_group_and_count(codes)
    |> Enum.reduce(Money.new(0), fn {product, qty}, discount ->
      Catalog.product(product).price
      |> Money.multiply(div(qty, threshold))
      |> Money.multiply(operand)
      |> Money.add(discount)
    end)
  end

  def calculate(
        basket,
        %PricingRules{discount_type: :proportional, product_codes: codes} = rules
      )
      when length(codes) > 0 do
    basket
    |> filter_group_and_count(codes)
    |> Enum.reduce(Money.new(0), fn {product, qty}, acc_discount ->
      if qty >= rules.threshold do
        Catalog.product(product).price
        |> Money.multiply(qty)
        |> Money.multiply(rules.operand)
        |> Money.add(acc_discount)
      else
        acc_discount
      end
    end)
  end

  def calculate(_basket, _), do: Money.new(0)

  ###
  # Provides counts grouped by item, returning only those which might 
  # be eligible for a discount
  ###
  defp filter_group_and_count(items, affected_products) do
    items
    |> Enum.reduce(%{}, fn item, acc_map ->
      case Enum.member?(affected_products, item) do
        true ->
          count = Map.get(acc_map, item, 0) + 1
          Map.put(acc_map, item, count)

        false ->
          acc_map
      end
    end)
  end
end
