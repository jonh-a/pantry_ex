defmodule PantryEx do
  @moduledoc """
  Unofficial Elixir wrapper for Pantry (free cloud storage API).
  """

  use HTTPoison.Base

  # Decodes a JSON string into a map. Returns map.
  defp decode_json(response) do
    {status, body} = response

    case JSX.decode(body) do
      {:ok, map} -> {status, map}
      _ -> {status, body}
    end
  end

  # Encodes a map into a JSON string. Returns string or raises exception.
  defp encode_json(map) do
    {status, json} = JSX.encode(map)

    case status do
      :ok -> json
      _ -> raise "Failed to encode params."
    end
  end

  # Parse HTTPoison response object. Returns status and decoded response body or error reason.
  defp parse_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body} |> decode_json()
      {:ok, %HTTPoison.Response{body: body}} -> {:error, body}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end

  @doc """
  Fetch pantry details.

  ## Examples
      iex > PantryEx.get_pantry(id)
      {:ok,
       %{
         "baskets" => [],
         "description" => "test",
         "errors" => [],
         "name" => "Test",
         "notifications" => true,
         "percentFull" => 0
       }}
  """
  def get_pantry(pantry_id) do
    HTTPoison.get(
      "https://getpantry.cloud/apiv1/pantry/#{pantry_id}",
      [{"Content-Type", "application/json"}]
    )
    |> parse_response()
  end

  @doc """
  Update pantry details.

  ## Examples
      iex > PantryEx.update_pantry!(id, %{"name" => "New name", "description" => "New description"})
      {:ok,
       %{
         "baskets" => [],
         "description" => "New description",
         "errors" => [],
         "name" => "New name",
         "notifications" => true,
         "percentFull" => 0
       }}
  """
  def update_pantry!(pantry_id, params) do
    HTTPoison.put(
      "https://getpantry.cloud/apiv1/pantry/#{pantry_id}",
      encode_json(params),
      [{"Content-Type", "application/json"}]
    )
    |> parse_response()
  end

  @doc """
  Create or replace basket contents.

  Given a basket name as provided, this will either create a new basket inside your pantry, or replace an existing one.

  ## Examples
      iex > PantryEx.create_or_replace_basket!(id, "test", %{"someValue" => "Test", "someNumber" => 1234})
      {:ok, "Your Pantry was updated with basket: test!"}
  """
  def create_or_replace_basket!(pantry_id, basket_name, contents) do
    HTTPoison.post(
      "https://getpantry.cloud/apiv1/pantry/#{pantry_id}/basket/#{basket_name}",
      encode_json(contents),
      [{"Content-Type", "application/json"}]
    )
    |> parse_response()
  end

  @doc """
  Update basket contents.

  Given a basket name, this will update the existing contents and return the contents of the newly updated basket.
  This operation performs a deep merge and will overwrite the values of any existing keys, or append values to nested objects or arrays.

  ## Examples
      iex > PantryEx.update_basket!(id, "test", %{"newValue" => "Test", "someNumber" => 12345})
      {:ok, %{"newValue" => "Test", "someNumber" => 12345, "someValue" => "Test"}}
  """
  def update_basket!(pantry_id, basket_name, contents) do
    HTTPoison.put(
      "https://getpantry.cloud/apiv1/pantry/#{pantry_id}/basket/#{basket_name}",
      encode_json(contents),
      [{"Content-Type", "application/json"}]
    )
    |> parse_response()
  end

  @doc """
  Get basket contents.

  Given a basket name, return the full contents of the basket.

  ## Examples
      iex > PantryEx.get_basket(id, "test")
      {:ok, %{"newValue" => "Test", "someNumber" => 12345, "someValue" => "Test"}}
  """
  def get_basket(pantry_id, basket_name) do
    HTTPoison.get("https://getpantry.cloud/apiv1/pantry/#{pantry_id}/basket/#{basket_name}")
    |> parse_response()
  end
end
