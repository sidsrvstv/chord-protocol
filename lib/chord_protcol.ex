defmodule ChordProtocol do
  @moduledoc """
  Documentation for ChordProtocol.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ChordProtocol.hello()
      :world

  """
  def main do
    # num_nodes = String.to_integer(Enum.at(System.argv, 0))
    # num_req = String.to_integer(Enum.at(System.argv, 1))

    # IO.inspect num_nodes
    # IO.inspect num_req

    # a = ChordProtocol.Network.init(num_nodes, num_req)
    # IO.inspect a
    matchArguments = System.argv()
    case matchArguments do
      [nodes, req] -> ChordProtocol.Network.init(nodes, req)
      _ -> IO.puts "Argument error"
    end
  end
end

ChordProtocol.main
