defmodule Utility do

    def fix_fingers(nodeId, nodesListSorted, m) do
      num_nodes = length(nodesListSorted)
      iter=m
      :lists.reverse(fingerTable(nodeId, nodesListSorted, iter, num_nodes-1, [],m))
    end

    def fingerTable(_, _, 0, _, fingerTableList,_) do
        fingerTableList
    end

    def fingerTable(nodeId, nodesListSorted, iter, num_nodes, fingerTableList, m) do

        pos_node = rem( ( nodeId + trunc( :math.pow(2, iter - 1) ) ), trunc( :math.pow(2,m+3) ) )
        successor = find_successor(nodesListSorted, pos_node, num_nodes)

        if successor != nodeId do
            fingerTable(nodeId, nodesListSorted, iter - 1, num_nodes, fingerTableList ++ [successor], m)
        else
            fingerTable(nodeId, nodesListSorted, iter - 1, num_nodes, fingerTableList, m)
        end
    end

    def find_successor(nodesListSorted, pos_node, curr) do
        # IO.puts "Checking successor"

        successor =
        if ( pos_node >= Enum.at(nodesListSorted, -1) ) do
            Enum.at(nodesListSorted, 0)
        else
            cond do
                pos_node < Enum.at(nodesListSorted, 0) -> Enum.at(nodesListSorted, 0)
                pos_node >= Enum.at(nodesListSorted, curr-1) and pos_node < Enum.at(nodesListSorted, curr) -> Enum.at(nodesListSorted, curr)
                true -> nil
            end
        end

        if successor != nil do
            successor
        else
            find_successor(nodesListSorted, pos_node, curr-1 )
        end
    end

    def convert_int_string(integer) do
        integer |> Integer.to_string()
    end

    def convert_int_atom(integer) do
        #IO.puts integer
        integer |> Integer.to_string() |> String.to_atom()
    end

    def generate_unique_ids(num, max_val, set) do
        if (MapSet.size(set) < num) do
            set = MapSet.put(set, get_rand_id(max_val))
            generate_unique_ids(num, max_val, set)
        else
            set
        end
    end

    def get_rand_id(max_val) do
        Enum.random(1..max_val)
        #:random.uniform(max_val)
    end

    def generate_nodelist_hashing(num_of_nodes) do
        m = trunc( Float.ceil ( :math.log( num_of_nodes )/ :math.log(2) ) )
        pow_m_2 =  :math.pow(2, m+3) |> trunc
        nodes = for node_id_to_hash <- 1..num_of_nodes do
            (node_id_to_hash * (node_id_to_hash + 3))
            |> rem(pow_m_2)
        end
        nodes
    end


end
