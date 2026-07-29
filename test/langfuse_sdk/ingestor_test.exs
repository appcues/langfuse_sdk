defmodule LangfuseSdk.IngestorTest do
  use ExUnit.Case, async: true

  alias LangfuseSdk.Ingestor
  alias LangfuseSdk.Tracing.Generation

  describe "to_event/2 for generations" do
    test "includes usageDetails and costDetails in the body" do
      # OpenAI Responses API usage passed through verbatim: Langfuse parses this
      # shape natively via OpenAIResponseUsageSchema, including the nested
      # cached and reasoning token counts.
      usage_details = %{
        "input_tokens" => 12_000,
        "output_tokens" => 400,
        "total_tokens" => 12_400,
        "input_tokens_details" => %{"cached_tokens" => 11_000},
        "output_tokens_details" => %{"reasoning_tokens" => 128}
      }

      generation =
        Generation.new(%{
          name: "assistant",
          model: "gpt-5.4",
          usage_details: usage_details,
          cost_details: %{"total" => 0.0123}
        })

      %{"body" => body} = Ingestor.to_event(generation, :create)

      assert body["usageDetails"] == usage_details
      assert body["costDetails"] == %{"total" => 0.0123}
      assert get_in(body, ["usageDetails", "input_tokens_details", "cached_tokens"]) == 11_000
    end

    test "omits the new fields as nil when unset, leaving usage untouched" do
      generation = Generation.new(%{name: "assistant", usage: %{input: 10, output: 2, total: 12}})

      %{"body" => body} = Ingestor.to_event(generation, :create)

      assert body["usage"] == %{input: 10, output: 2, total: 12}
      assert body["usageDetails"] == nil
      assert body["costDetails"] == nil
    end
  end
end
