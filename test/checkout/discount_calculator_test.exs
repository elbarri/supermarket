defmodule Checkout.DiscountCalculatorTest do
  use ExUnit.Case, async: true
  doctest Checkout.DiscountCalculator
  alias Checkout.DiscountCalculator, as: Calc
  import Money.Currency, only: [gbp: 1]

  @b2g1 %PricingRules{
    discount_type: :buy_n_get_x_free,
    threshold: 2,
    operand: 1,
    product_codes: ["GR1"]
  }

  @tenth %PricingRules{
    discount_type: :proportional,
    threshold: 3,
    operand: 0.10,
    product_codes: ["SR1"]
  }

  @third %PricingRules{
    discount_type: :proportional,
    threshold: 3,
    operand: 1 / 3,
    product_codes: ["CF1"]
  }

  test "buy 2 get 1 free" do
    assert Calc.calculate(many("GR1", 1), @b2g1) == gbp(0)
    assert Calc.calculate(many("GR1", 2), @b2g1) == gbp(3_11)
    assert Calc.calculate(many("GR1", 3), @b2g1) == gbp(3_11)
    assert Calc.calculate(many("GR1", 4), @b2g1) == gbp(6_22)
  end

  test "bulk prices" do
    assert Calc.calculate(many("SR1", 2), @tenth) == gbp(0)
    assert Calc.calculate(many("SR1", 3), @tenth) == gbp(1_50)
    assert Calc.calculate(many("SR1", 4), @tenth) == gbp(2_00)
    assert Calc.calculate(many("SR1", 6), @tenth) == gbp(3_00)

    assert Calc.calculate(many("CF1", 2), @third) == gbp(0)
    assert Calc.calculate(many("CF1", 3), @third) == gbp(11_23)
  end

  test "no discount when product is not eligible" do
    pr = %PricingRules{
      discount_type: :buy_n_get_x_free,
      threshold: 2,
      operand: 1,
      product_codes: ["AAA", "ASD"]
    }

    assert Calc.calculate(many("GR1", 2), pr) == gbp(0)

    pr = %PricingRules{
      discount_type: :proportional,
      threshold: 3,
      operand: 0.10,
      product_codes: ["AAA", "ASD"]
    }

    assert Calc.calculate(many("SR1", 3), pr) == gbp(0)
  end

  test "applies discount only to eligible products" do
    assert Calc.calculate(["GR1", "GR1", "CF1", "CF1"], @b2g1) == gbp(3_11)
  end

  test "applies discount to every eligible product" do
    pr = %PricingRules{
      discount_type: :buy_n_get_x_free,
      threshold: 2,
      operand: 1,
      product_codes: ["GR1", "SR1"]
    }

    assert Calc.calculate(["GR1", "GR1", "SR1", "SR1", "CF1", "CF1"], pr) == gbp(8_11)

    pr = %PricingRules{
      discount_type: :proportional,
      threshold: 2,
      operand: 0.10,
      product_codes: ["GR1", "SR1"]
    }

    assert Calc.calculate(["GR1", "GR1", "SR1", "SR1"], pr) == gbp(1_62)
  end

  test "no discount with empty product list" do
    assert Calc.calculate([], @b2g1) == gbp(0)
  end

  defp many(item, n) when n <= 1, do: [item]

  defp many(item, n) do
    [item | many(item, n - 1)]
  end
end
