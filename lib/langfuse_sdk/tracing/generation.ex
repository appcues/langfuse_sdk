defmodule LangfuseSdk.Tracing.Generation do
  @moduledoc """
  This module contains functions to handle generations:
  https://langfuse.com/docs/sdk/typescript/guide#generation

  ## Usage reporting

  `usage` maps to the ingestion API's `usage` field, which upstream marks as
  deprecated in favour of `usage_details` and `cost_details`.

  `usage_details` accepts either a plain map of metric name to integer, or one
  of the OpenAI usage shapes Langfuse parses natively — `OpenAICompletionUsageSchema`
  and `OpenAIResponseUsageSchema`. For the OpenAI Responses API, pass the raw
  `usage` object straight through and Langfuse reads the nested
  `input_tokens_details` / `output_tokens_details` (cached and reasoning tokens)
  without any key remapping.

  `cost_details` is a map of cost metric name to USD amount.
  """

  alias __MODULE__
  alias LangfuseSdk.Support.Value

  defstruct [
    :id,
    :name,
    :start_time,
    :completion_start_time,
    :end_time,
    :model,
    :model_parameters,
    :input,
    :output,
    :usage,
    :usage_details,
    :cost_details,
    :metadata,
    :level,
    :status_message,
    :version,
    :prompt,
    :timestamp,
    :trace_id,
    :parent_observation_id,
    :environment
  ]

  def new(opts \\ []) do
    Generation
    |> struct!(opts)
    |> Value.force_new(:id, UUID.uuid4())
    |> Value.force_new(:timestamp, DateTime.utc_now())
  end
end
