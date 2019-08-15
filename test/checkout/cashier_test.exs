defmodule Checkout.CashierTest do
  use ExUnit.Case, async: true
  alias Checkout.Cashier

  import Money.Currency, only: [gbp: 1]

  test "no pricing rules" do
    {c, product} =
      Cashier.new_with([])
      |> Cashier.scan("GR1")

    assert product.price == gbp(3_11)
    assert Cashier.total(c) == gbp(3_11)

    {c, _} = Cashier.scan(c, "GR1")
    assert Cashier.total(c) == gbp(6_22)
  end

  test "unexistent product" do
    {_, product} =
      Cashier.new_with([])
      |> Cashier.scan("ASD")

    assert product == nil
  end

  test "applies discount" do
    prs = [
      %PricingRules{
        discount_type: :buy_n_get_x_free,
        threshold: 2,
        operand: 1,
        product_codes: ["GR1"]
      },
      %PricingRules{
        discount_type: :proportional,
        threshold: 3,
        operand: 0.10,
        product_codes: ["SR1"]
      },
      %PricingRules{
        discount_type: :proportional,
        threshold: 3,
        operand: 1 / 3,
        product_codes: ["CF1"]
      }
    ]

    c = Cashier.new_with(prs)
    {c, _} = Cashier.scan(c, "GR1")
    {c, _} = Cashier.scan(c, "GR1")
    assert Cashier.total(c) == gbp(3_11)

    {c, _} = Cashier.scan(c, "SR1")
    {c, _} = Cashier.scan(c, "SR1")
    {c, _} = Cashier.scan(c, "SR1")
    assert Cashier.total(c) == gbp(16_61)

    {c, _} = Cashier.scan(c, "CF1")
    {c, _} = Cashier.scan(c, "CF1")
    {c, _} = Cashier.scan(c, "CF1")
    assert Cashier.total(c) == gbp(39_07)
  end
end
