defmodule Test do
    def create_nodes(num_nodes, _) do
        num_nodes = String.to_integer(num_nodes)
        m = trunc( Float.ceil ( :math.log( num_nodes )/ :math.log(2) ) )
        max_val = :math.pow(2, m+3) |> trunc

        set = MapSet.new
        set = Utility.generate_unique_ids(num_nodes, max_val, set)

        nodes = MapSet.to_list(set)

        IO.inspect nodes
    end

end